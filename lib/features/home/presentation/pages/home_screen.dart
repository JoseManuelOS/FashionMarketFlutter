import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/newsletter_popup.dart';
import '../providers/home_providers.dart';
import '../providers/realtime_offers_provider.dart';
import '../widgets/product_grid_section.dart';
import '../widgets/category_chips.dart';

/// Pantalla principal de la aplicación
/// Muestra el carousel hero, categorías, productos destacados y ofertas
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static final _scaffoldKey = GlobalKey<ScaffoldState>();
  static bool _newsletterChecked = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mostrar newsletter popup una vez tras la primera carga
    if (!_newsletterChecked) {
      _newsletterChecked = true;
      final shouldShow = ref.read(shouldShowNewsletterProvider);
      if (shouldShow) {
        Future.delayed(const Duration(seconds: 3), () {
          if (context.mounted) showNewsletterPopup(context);
        });
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: CustomScrollView(
        slivers: [
          // App Bar con logo y carrito
          _buildAppBar(context),

          // Hero Carousel
          SliverToBoxAdapter(
            child: _buildHeroCarousel(ref),
          ),

          // Categorías
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: CategoryChips(),
            ),
          ),

          // Sección: Novedades
          SliverToBoxAdapter(
            child: ProductGridSection(
              title: 'Novedades',
              subtitle: 'Lo más nuevo de la temporada',
              productsProvider: featuredProductsProvider,
              heroTagPrefix: 'product-hero-novedades',
              onViewAll: () => context.push('/productos'),
            ),
          ),

          // Sección: Ofertas (Realtime + global toggle)
          SliverToBoxAdapter(
            child: Consumer(
              builder: (context, ref, _) {
                final offersEnabled = ref.watch(offersEnabledProvider).valueOrNull ?? true;
                if (!offersEnabled) return const SizedBox.shrink();
                return ProductGridSection(
                  title: 'Ofertas',
                  subtitle: 'Descuentos especiales',
                  productsProvider: realtimeOfferProductsProvider,
                  heroTagPrefix: 'product-hero-ofertas',
                  showBadge: true,
                  badgeText: 'SALE',
                  onViewAll: () => context.push('/ofertas'),
                );
              },
            ),
          ),

          // Espaciado final
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.dark500.withValues(alpha: 0.95),
      elevation: 0,
      centerTitle: true,
      title: SvgPicture.asset(
        'assets/logo/logo.svg',
        height: 32,
        fit: BoxFit.contain,
      ),
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppColors.textPrimary),
        onPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.textPrimary),
          onPressed: () => context.push('/buscar'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroCarousel(WidgetRef ref) {
    final slidesAsync = ref.watch(carouselSlidesProvider);

    return slidesAsync.when(
      data: (slides) {
        if (slides.isEmpty) {
          return const SizedBox(height: 200);
        }

        return CarouselSlider.builder(
          itemCount: slides.length,
          itemBuilder: (context, index, realIndex) {
            final slide = slides[index];
            return GestureDetector(
              onTap: () {
                if (slide.hasCta && slide.ctaLink != null) {
                  context.push(slide.ctaLink!);
                }
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen
                  CachedNetworkImage(
                    imageUrl: slide.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: AppColors.dark400,
                      highlightColor: AppColors.dark300,
                      child: Container(color: AppColors.dark400),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.dark400,
                      child: const Icon(Icons.image_not_supported,
                          color: AppColors.textMuted),
                    ),
                  ),

                  // Gradiente oscuro
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.dark600.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),

                  // Contenido
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (slide.title != null) ...[
                          Text(
                            slide.title!,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (slide.subtitle != null) ...[
                          Text(
                            slide.subtitle!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (slide.hasCta)
                          ElevatedButton(
                            onPressed: () {
                              if (slide.ctaLink != null) {
                                context.push(slide.ctaLink!);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.neonCyan,
                              foregroundColor: AppColors.textOnPrimary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: Text(slide.ctaText ?? 'Ver más'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          options: CarouselOptions(
            height: 400,
            viewportFraction: 1.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            enlargeCenterPage: false,
          ),
        );
      },
      loading: () => Shimmer.fromColors(
        baseColor: AppColors.dark400,
        highlightColor: AppColors.dark300,
        child: Container(
          height: 400,
          color: AppColors.dark400,
        ),
      ),
      error: (error, stack) => Container(
        height: 200,
        color: AppColors.dark400,
        child: Center(
          child: Text(
            'Error cargando carousel',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      ),
    );
  }
}
