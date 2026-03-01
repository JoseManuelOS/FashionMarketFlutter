import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/carousel_slide_model.dart';
import '../../../products/data/models/product_model.dart';

part 'home_providers.g.dart';

/// Provider para obtener los slides del carousel
@riverpod
Future<List<CarouselSlideModel>> carouselSlides(Ref ref) async {
  final supabase = Supabase.instance.client;

  final response = await supabase
      .from('carousel_slides')
      .select()
      .eq('is_active', true)
      .order('sort_order', ascending: true);

  return (response as List)
      .map((json) => CarouselSlideModel.fromJson(json))
      .toList();
}

/// Provider para obtener productos destacados (más recientes)
@riverpod
Future<List<ProductModel>> featuredProducts(Ref ref) async {
  final supabase = Supabase.instance.client;

  final response = await supabase
      .from('products')
      .select('''
        *,
        category:categories(*),
        images:product_images(*)
      ''')
      .eq('active', true)
      .order('created_at', ascending: false)
      .limit(8);

  return (response as List)
      .map((json) => ProductModel.fromJson(json))
      .toList();
}

/// Provider para obtener productos en oferta
@riverpod
Future<List<ProductModel>> offerProducts(Ref ref) async {
  final supabase = Supabase.instance.client;

  final response = await supabase
      .from('products')
      .select('''
        *,
        category:categories(*),
        images:product_images(*)
      ''')
      .eq('active', true)
      .eq('is_offer', true)
      .order('discount_percent', ascending: false)
      .limit(8);

  return (response as List)
      .map((json) => ProductModel.fromJson(json))
      .toList();
}

/// Provider para obtener categorías activas
@riverpod
Future<List<Map<String, dynamic>>> homeCategories(Ref ref) async {
  final supabase = Supabase.instance.client;

  final response = await supabase
      .from('categories')
      .select()
      .order('display_order', ascending: true);

  return List<Map<String, dynamic>>.from(response);
}
