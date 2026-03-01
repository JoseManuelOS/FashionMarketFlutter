import '../../../products/data/models/product_model.dart';
import '../../data/models/carousel_slide_model.dart';

/// Contrato del repositorio de la pantalla Home.
/// Abstrae las consultas de datos del home (carousel, categorías, productos).
abstract class HomeRepository {
  /// Obtiene los slides activos del carrusel
  Future<List<CarouselSlideModel>> getCarouselSlides();

  /// Obtiene productos destacados (más recientes)
  Future<List<ProductModel>> getFeaturedProducts({int limit = 8});

  /// Obtiene productos en oferta
  Future<List<ProductModel>> getOfferProducts({int limit = 8});

  /// Obtiene las categorías activas
  Future<List<Map<String, dynamic>>> getCategories();
}
