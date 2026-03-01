import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/exceptions/app_exception.dart';
import '../models/product_model.dart';

/// Interfaz del datasource remoto de productos
abstract class ProductRemoteDataSource {
  /// Obtiene todos los productos con paginación
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? categoryId,
  });

  /// Obtiene un producto por su ID
  Future<ProductModel> getProductById(String id);

  /// Busca productos por nombre
  Future<List<ProductModel>> searchProducts(String query);

  /// Crea un nuevo producto
  Future<ProductModel> createProduct(ProductModel product);

  /// Actualiza un producto existente
  Future<ProductModel> updateProduct(ProductModel product);

  /// Elimina un producto
  Future<void> deleteProduct(String id);
}

/// Implementación del datasource remoto usando Supabase
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final SupabaseClient _supabaseClient;

  ProductRemoteDataSourceImpl(this._supabaseClient);

  static const String _tableName = 'products';

  @override
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? categoryId,
  }) async {
    try {
      final start = (page - 1) * pageSize;
      final end = start + pageSize - 1;

      var query = _supabaseClient
          .from(_tableName)
          .select('''
            *,
            category:categories(*),
            images:product_images(*),
            variants:product_variants(id, size, stock, sku, color)
          ''')
          .eq('active', true)
          .order('created_at', ascending: false)
          .range(start, end);

      if (categoryId != null) {
        query = _supabaseClient
            .from(_tableName)
            .select('''
              *,
              category:categories(*),
              images:product_images(*),
              variants:product_variants(id, size, stock, sku, color)
            ''')
            .eq('active', true)
            .eq('category_id', categoryId)
            .order('created_at', ascending: false)
            .range(start, end);
      }

      final response = await query;
      return (response as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw UnknownException(originalError: e);
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      // Intentar buscar por ID (UUID) o por slug
      dynamic response;
      
      // Verificar si es un UUID válido
      final uuidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
      );
      
      if (uuidRegex.hasMatch(id)) {
        response = await _supabaseClient
            .from(_tableName)
            .select('''
              *,
              category:categories(*),
              images:product_images(*),
              variants:product_variants(id, size, stock, sku, color)
            ''')
            .eq('id', id)
            .single();
      } else {
        // Buscar por slug
        response = await _supabaseClient
            .from(_tableName)
            .select('''
              *,
              category:categories(*),
              images:product_images(*),
              variants:product_variants(id, size, stock, sku, color)
            ''')
            .eq('slug', id)
            .single();
      }

      return ProductModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const NotFoundException(message: 'Producto no encontrado');
      }
      throw ServerException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw UnknownException(originalError: e);
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .select('''
            *,
            category:categories(*),
            images:product_images(*),
            variants:product_variants(id, size, stock, sku, color)
          ''')
          .ilike('name', '%$query%')
          .eq('active', true)
          .order('name')
          .limit(50);

      return (response as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw UnknownException(originalError: e);
    }
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .insert(product.toJson())
          .select()
          .single();

      return ProductModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw UnknownException(originalError: e);
    }
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .update(product.toJson())
          .eq('id', product.id)
          .select()
          .single();

      return ProductModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw UnknownException(originalError: e);
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await _supabaseClient.from(_tableName).delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw UnknownException(originalError: e);
    }
  }
}
