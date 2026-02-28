import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/theme/app_colors.dart';
import '../services/cloudinary_service.dart';

/// Widget reutilizable para subir imágenes a Cloudinary
///
/// Muestra un área de drop/tap que permite seleccionar una imagen
/// de la galería o cámara, subirla a Cloudinary, y devolver la URL.
///
/// Uso:
/// ```dart
/// CloudinaryImageUploader(
///   currentUrl: imageUrl,
///   folder: CloudinaryService.folderProducts,
///   onUploaded: (url) => setState(() => imageUrl = url),
/// )
/// ```
class CloudinaryImageUploader extends StatefulWidget {
  const CloudinaryImageUploader({
    super.key,
    this.currentUrl,
    this.folder = CloudinaryService.folderProducts,
    required this.onUploaded,
    this.height = 180,
    this.borderRadius = 12.0,
    this.label,
  });

  /// URL de imagen actual (para preview)
  final String? currentUrl;

  /// Carpeta en Cloudinary
  final String folder;

  /// Callback cuando se sube correctamente
  final ValueChanged<String> onUploaded;

  /// Altura del widget
  final double height;

  /// Radio de esquinas
  final double borderRadius;

  /// Label opcional (ej: "Imagen principal")
  final String? label;

  @override
  State<CloudinaryImageUploader> createState() =>
      _CloudinaryImageUploaderState();
}

class _CloudinaryImageUploaderState extends State<CloudinaryImageUploader> {
  final _picker = ImagePicker();
  bool _isUploading = false;
  double _progress = 0;

  Future<void> _pickAndUpload() async {
    final source = await _showSourceDialog();
    if (source == null) return;

    final XFile? picked = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (picked == null) return;

    setState(() {
      _isUploading = true;
      _progress = 0;
    });

    // Simular progreso (Cloudinary no da progreso real con http package)
    _simulateProgress();

    final url = await CloudinaryService.uploadImage(
      imageFile: picked,
      folder: widget.folder,
    );

    setState(() {
      _isUploading = false;
      _progress = 1;
    });

    if (url != null) {
      widget.onUploaded(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al subir imagen'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _simulateProgress() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_isUploading && mounted) {
        setState(() => _progress = (_progress + 0.15).clamp(0, 0.9));
        _simulateProgress();
      }
    });
  }

  Future<ImageSource?> _showSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Seleccionar imagen',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library,
                    color: AppColors.neonCyan),
                title: const Text('Galería',
                    style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt,
                    color: AppColors.neonCyan),
                title: const Text('Cámara',
                    style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        GestureDetector(
          onTap: _isUploading ? null : _pickAndUpload,
          child: Container(
            height: widget.height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0F),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: _isUploading
                    ? AppColors.neonCyan.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.1),
                width: _isUploading ? 2 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isUploading) {
      return _buildUploadingState();
    }

    if (widget.currentUrl != null && widget.currentUrl!.isNotEmpty) {
      return _buildPreview();
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            color: Colors.grey[600],
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            'Toca para subir imagen',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'JPG, PNG • Max 1920px',
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: widget.currentUrl!,
          fit: BoxFit.cover,
          placeholder: (_, __) => const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.neonCyan,
            ),
          ),
          errorWidget: (_, __, ___) => Center(
            child: Icon(Icons.broken_image, color: Colors.grey[600], size: 40),
          ),
        ),
        // Overlay with change button
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit, color: AppColors.neonCyan, size: 16),
                SizedBox(width: 4),
                Text(
                  'Cambiar',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              value: _progress > 0 ? _progress : null,
              color: AppColors.neonCyan,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Subiendo imagen...',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            '${(_progress * 100).toInt()}%',
            style: const TextStyle(
              color: AppColors.neonCyan,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Modelo de imagen con color opcional asignado
class ImageWithColor {
  final String url;
  final String? color;
  final String? colorHex;

  const ImageWithColor({required this.url, this.color, this.colorHex});

  Map<String, dynamic> toJson() => {
        'url': url,
        if (color != null) 'color': color,
        if (colorHex != null) 'color_hex': colorHex,
      };
}

/// Widget compacto para selección múltiple de imágenes con asignación de color
class CloudinaryMultiImageUploader extends StatefulWidget {
  const CloudinaryMultiImageUploader({
    super.key,
    required this.imageUrls,
    required this.onChanged,
    this.folder = CloudinaryService.folderProducts,
    this.maxImages = 10,
    this.label,
    this.availableColors = const [],
    this.imageColorAssignments = const {},
    this.onColorAssignmentsChanged,
  });

  final List<String> imageUrls;
  final ValueChanged<List<String>> onChanged;
  final String folder;
  final int maxImages;
  final String? label;

  /// Colores disponibles del producto para asignar a imágenes
  final List<Map<String, String>> availableColors;

  /// Mapa: imageUrl → nombre de color asignado
  final Map<String, String?> imageColorAssignments;

  /// Callback cuando se cambia la asignación de color de alguna imagen
  final ValueChanged<Map<String, String?>>? onColorAssignmentsChanged;

  @override
  State<CloudinaryMultiImageUploader> createState() =>
      _CloudinaryMultiImageUploaderState();
}

class _CloudinaryMultiImageUploaderState
    extends State<CloudinaryMultiImageUploader> {
  final _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _addImages() async {
    final picked = await _picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (picked.isEmpty) return;

    final remaining = widget.maxImages - widget.imageUrls.length;
    final toUpload = picked.take(remaining).toList();

    setState(() => _isUploading = true);

    final urls = await CloudinaryService.uploadMultiple(
      imageFiles: toUpload,
      folder: widget.folder,
    );

    setState(() => _isUploading = false);

    if (urls.isNotEmpty) {
      widget.onChanged([...widget.imageUrls, ...urls]);
    }
  }

  void _removeImage(int index) {
    final updated = List<String>.from(widget.imageUrls);
    updated.removeAt(index);
    widget.onChanged(updated);
  }

  void _reorderImage(int oldIndex, int newIndex) {
    final updated = List<String>.from(widget.imageUrls);
    if (newIndex > oldIndex) newIndex--;
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    widget.onChanged(updated);
  }

  bool get _hasColors => widget.availableColors.isNotEmpty;

  void _assignColor(int index, String? colorName) {
    final url = widget.imageUrls[index];
    final updated = Map<String, String?>.from(widget.imageColorAssignments);
    if (colorName == null) {
      updated.remove(url);
    } else {
      updated[url] = colorName;
    }
    widget.onColorAssignmentsChanged?.call(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.imageUrls.length}/${widget.maxImages}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          height: _hasColors ? 130 : 100,
          child: ReorderableListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.imageUrls.length +
                (widget.imageUrls.length < widget.maxImages ? 1 : 0),
            onReorder: _reorderImage,
            proxyDecorator: (child, index, animation) => Material(
              color: Colors.transparent,
              child: child,
            ),
            itemBuilder: (context, index) {
              if (index == widget.imageUrls.length) {
                // Add button
                return Container(
                  key: const ValueKey('add_button'),
                  width: 100,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0F),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: _isUploading
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.neonCyan,
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: _addImages,
                          borderRadius: BorderRadius.circular(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate,
                                  color: Colors.grey[600], size: 28),
                              const SizedBox(height: 4),
                              Text(
                                'Añadir',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                );
              }

              // Image thumbnail
              return Container(
                key: ValueKey(widget.imageUrls[index]),
                width: 100,
                margin: const EdgeInsets.only(right: 8),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: index == 0
                                ? AppColors.neonCyan.withValues(alpha: 0.5)
                                : Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: widget.imageUrls[index],
                              fit: BoxFit.cover,
                              placeholder: (_, __) => const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.neonCyan,
                                ),
                              ),
                              errorWidget: (_, __, ___) => Center(
                                child: Icon(Icons.broken_image,
                                    color: Colors.grey[600]),
                              ),
                            ),
                            // Delete button
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      color: Colors.white, size: 14),
                                ),
                              ),
                            ),
                            // Order badge
                            if (index == 0)
                              Positioned(
                                bottom: 4,
                                left: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.neonCyan,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Principal',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    // Color assignment chip below image
                    if (_hasColors)
                      _buildColorChip(index),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorChip(int index) {
    final url = widget.imageUrls[index];
    final assignedColor = widget.imageColorAssignments[url];

    Color? chipColor;
    if (assignedColor != null) {
      final match = widget.availableColors.where((c) => c['name'] == assignedColor).firstOrNull;
      if (match != null && match['hex'] != null) {
        try {
          final h = match['hex']!.replaceFirst('#', '');
          chipColor = Color(int.parse('FF$h', radix: 16));
        } catch (_) {}
      }
    }

    return GestureDetector(
      onTap: () => _showColorPickerForImage(index),
      child: Container(
        height: 24,
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A24),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: chipColor?.withValues(alpha: 0.5) ?? Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (chipColor != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: chipColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                assignedColor ?? 'Color',
                style: TextStyle(
                  color: assignedColor != null ? Colors.white70 : Colors.grey[600],
                  fontSize: 9,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPickerForImage(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Asignar color a la imagen',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              // Sin color
              ListTile(
                leading: Icon(Icons.block, color: Colors.grey[500]),
                title: const Text('Sin color asignado', style: TextStyle(color: Colors.white)),
                onTap: () {
                  _assignColor(index, null);
                  Navigator.pop(ctx);
                },
              ),
              // Available colors
              ...widget.availableColors.map((c) {
                Color? tileColor;
                try {
                  final h = (c['hex'] ?? '#808080').replaceFirst('#', '');
                  tileColor = Color(int.parse('FF$h', radix: 16));
                } catch (_) {
                  tileColor = Colors.grey;
                }
                return ListTile(
                  leading: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: tileColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                  ),
                  title: Text(c['name'] ?? '', style: const TextStyle(color: Colors.white)),
                  trailing: widget.imageColorAssignments[widget.imageUrls[index]] == c['name']
                      ? const Icon(Icons.check, color: AppColors.neonCyan, size: 20)
                      : null,
                  onTap: () {
                    _assignColor(index, c['name']);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
