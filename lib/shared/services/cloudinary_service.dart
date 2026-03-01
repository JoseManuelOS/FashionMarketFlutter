import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Servicio de subida de imágenes a Cloudinary
/// Usa unsigned upload preset (no requiere API secret)
///
/// Configuración del FashionStore:
/// - Cloud Name: djlc45ybk
/// - Upload Preset: fashionstore_products (unsigned)
/// - Folders: products, carousel, categories
class CloudinaryService {
  CloudinaryService._();

  static const String _cloudName = 'djlc45ybk';
  static const String _uploadPreset = 'fashionstore_products';
  static const String _uploadUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  /// Carpetas disponibles para organizar imágenes
  static const String folderProducts = 'products';
  static const String folderCarousel = 'carousel';
  static const String folderCategories = 'categories';

  /// Comprime una imagen antes de subirla.
  /// En web, solo lee bytes directamente (flutter_image_compress no soporta web nativo).
  /// En móvil/escritorio, comprime con calidad 80 y ancho máximo 1200px.
  static Future<Uint8List> _compressImage(XFile imageFile) async {
    final originalBytes = await imageFile.readAsBytes();

    if (kIsWeb) {
      // On web, flutter_image_compress has limited support.
      // Return original bytes — Cloudinary will optimize server-side.
      return originalBytes;
    }

    try {
      final compressed = await FlutterImageCompress.compressWithList(
        originalBytes,
        minWidth: 1200,
        minHeight: 1200,
        quality: 80,
        format: CompressFormat.jpeg,
      );
      debugPrint(
        '🗜️ Imagen comprimida: ${originalBytes.length} → ${compressed.length} bytes '
        '(${(compressed.length / originalBytes.length * 100).toStringAsFixed(0)}%)',
      );
      return compressed;
    } catch (e) {
      debugPrint('⚠️ Compresión falló, usando imagen original: $e');
      return originalBytes;
    }
  }

  /// Sube una imagen a Cloudinary desde un archivo [XFile].
  /// La imagen se comprime automáticamente antes de subirla (móvil/escritorio).
  ///
  /// [imageFile] — Archivo de imagen (desde image_picker)
  /// [folder] — Carpeta en Cloudinary (products, carousel, categories)
  /// [publicId] — ID público opcional (si no se da, Cloudinary genera uno)
  ///
  /// Retorna la URL pública de la imagen o null si falla.
  static Future<String?> uploadImage({
    required XFile imageFile,
    String folder = folderProducts,
    String? publicId,
  }) async {
    try {
      // Comprimir imagen antes de subir
      final compressedBytes = await _compressImage(imageFile);

      final uri = Uri.parse(_uploadUrl);
      final request = http.MultipartRequest('POST', uri);

      // Campos del formulario
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = folder;

      if (publicId != null) {
        request.fields['public_id'] = publicId;
      }

      // Adjuntar archivo comprimido
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          compressedBytes,
          filename: imageFile.name,
        ),
      );

      // Enviar
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final secureUrl = json['secure_url'] as String?;
        debugPrint('✅ Imagen subida a Cloudinary: $secureUrl');
        return secureUrl;
      } else {
        debugPrint(
          '❌ Error subiendo imagen: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('❌ Exception subiendo imagen a Cloudinary: $e');
      return null;
    }
  }

  /// Sube múltiples imágenes en paralelo
  ///
  /// Retorna lista de URLs exitosas (puede tener menos elementos que la entrada
  /// si alguna falla).
  static Future<List<String>> uploadMultiple({
    required List<XFile> imageFiles,
    String folder = folderProducts,
  }) async {
    final futures = imageFiles.map(
      (file) => uploadImage(imageFile: file, folder: folder),
    );

    final results = await Future.wait(futures);
    return results.whereType<String>().toList();
  }

  /// Genera URL de Cloudinary optimizada con transformaciones
  ///
  /// [originalUrl] — URL original de Cloudinary
  /// [width] — Ancho en px
  /// [height] — Alto en px
  /// [quality] — Calidad (auto, auto:good, auto:best, 80, etc.)
  static String optimizedUrl(
    String originalUrl, {
    int? width,
    int? height,
    String quality = 'auto',
  }) {
    // Ej: https://res.cloudinary.com/djlc45ybk/image/upload/v123/folder/file.jpg
    // -> https://res.cloudinary.com/djlc45ybk/image/upload/w_300,h_300,q_auto,f_auto/v123/folder/file.jpg
    final parts = originalUrl.split('/upload/');
    if (parts.length != 2) return originalUrl;

    final transforms = <String>[];
    if (width != null) transforms.add('w_$width');
    if (height != null) transforms.add('h_$height');
    transforms.add('q_$quality');
    transforms.add('f_auto');

    return '${parts[0]}/upload/${transforms.join(",")}/${parts[1]}';
  }
}
