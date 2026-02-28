import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/router/app_router.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_drawer.dart';
import '../../../../shared/widgets/cloudinary_image_uploader.dart';
import '../../../../shared/services/cloudinary_service.dart';

/// Pantalla de gestión del carrusel
/// Equivalente a /admin/carrusel en FashionStore
class AdminCarouselScreen extends ConsumerWidget {
  const AdminCarouselScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admin = ref.watch(adminSessionProvider);
    final slidesAsync = ref.watch(adminCarouselSlidesProvider);

    if (admin == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.home);
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      drawer: AdminDrawer(currentRoute: AppRoutes.adminCarousel),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D14),
        title: const Text(
          'Carrusel',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.neonCyan),
            onPressed: () => _showCreateSlideDialog(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.neonCyan,
        backgroundColor: const Color(0xFF12121A),
        onRefresh: () async {
          ref.invalidate(adminCarouselSlidesProvider);
        },
        child: slidesAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.neonCyan),
          ),
          error: (e, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red[400], size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar slides',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                TextButton(
                  onPressed: () => ref.invalidate(adminCarouselSlidesProvider),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
          data: (slides) => _buildContent(context, ref, slides),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSlideDialog(context, ref),
        backgroundColor: AppColors.neonCyan,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          'Nueva Slide',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> slides) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.neonCyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.neonCyan),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'El orden determina la secuencia de visualización. Las slides inactivas no se mostrarán.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'Carrusel del Homepage',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${slides.length} slides configuradas',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Slides list
          if (slides.isEmpty)
            _buildEmptyState()
          else
            ...slides.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildSlideCard(context, ref, entry.value, entry.key),
              );
            }),

          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A24),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.view_carousel_outlined,
              color: Colors.grey[600],
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay slides configuradas',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Añade la primera slide del carrusel',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> slide,
    int index,
  ) {
    final isActive = slide['is_active'] == true;
    final imageUrl = slide['image_url'] as String?;
    final title = slide['title'] as String? ?? 'Sin título';
    final subtitle = slide['subtitle'] as String?;
    final description = slide['description'] as String?;
    final duration = (slide['duration'] as num?)?.toInt() ?? 5000;
    final ctaText = slide['cta_text'] as String?;
    final ctaLink = slide['cta_link'] as String?;
    final discountCode = slide['discount_code'] as String?;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? Colors.white.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Image preview
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          height: 160,
                          color: const Color(0xFF1A1A24),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.neonCyan,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          height: 160,
                          color: const Color(0xFF1A1A24),
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      )
                    : Container(
                        height: 160,
                        color: const Color(0xFF1A1A24),
                        child: const Center(
                          child: Icon(Icons.image_outlined, color: Colors.grey, size: 48),
                        ),
                      ),
              ),
              // Badges
              Positioned(
                top: 12,
                left: 12,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '#${index + 1}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Inactiva',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: AppColors.neonCyan,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey[500]),
                      color: const Color(0xFF1A1A24),
                      onSelected: (value) => _handleSlideAction(context, ref, value, slide),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'toggle',
                          child: Row(
                            children: [
                              Icon(
                                isActive ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey[400],
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                isActive ? 'Desactivar' : 'Activar',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Colors.red[400], size: 18),
                              const SizedBox(width: 12),
                              Text('Eliminar', style: TextStyle(color: Colors.red[400])),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Meta info
                if (description != null && description.isNotEmpty) ...[
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                ],
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildMetaItem(Icons.timer_outlined, '${duration ~/ 1000}s'),
                    if (ctaText != null)
                      _buildMetaItem(Icons.touch_app_outlined, ctaText),
                    if (ctaLink != null)
                      _buildMetaItem(Icons.link, ctaLink),
                    if (discountCode != null && discountCode.isNotEmpty)
                      _buildMetaItem(Icons.local_offer_outlined, discountCode),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.grey[500], size: 14),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _handleSlideAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    Map<String, dynamic> slide,
  ) async {
    switch (action) {
      case 'toggle':
        await ref.read(adminCarouselSlidesProvider.notifier).toggleSlide(
          slide['id'],
          slide['is_active'] != true,
        );
        break;
      case 'delete':
        _confirmDeleteSlide(context, ref, slide);
        break;
    }
  }

  void _confirmDeleteSlide(BuildContext context, WidgetRef ref, Map<String, dynamic> slide) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF12121A),
        title: const Text(
          '¿Eliminar slide?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Se eliminará la slide "${slide['title']}" permanentemente.',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(adminCarouselSlidesProvider.notifier).deleteSlide(slide['id']);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Slide eliminada'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.red[400])),
          ),
        ],
      ),
    );
  }

  void _showCreateSlideDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final descController = TextEditingController();
    final ctaTextController = TextEditingController(text: 'Ver más');
    final ctaLinkController = TextEditingController(text: '/productos');
    final discountCodeController = TextEditingController();
    double duration = 5;
    String? imageUrl;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF12121A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nueva Slide',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ─── Imagen con Cloudinary ───
                CloudinaryImageUploader(
                  currentUrl: imageUrl,
                  folder: CloudinaryService.folderCarousel,
                  label: 'Imagen de la slide',
                  onUploaded: (url) => setState(() => imageUrl = url),
                ),
                const SizedBox(height: 16),

                _buildInputField(titleController, 'Título', 'Ej: Nueva Colección'),
                const SizedBox(height: 16),
                _buildInputField(subtitleController, 'Subtítulo (opcional)', 'Ej: Primavera 2026'),
                const SizedBox(height: 16),
                _buildInputField(descController, 'Descripción (opcional)', 'Texto descriptivo...'),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(ctaTextController, 'Texto del botón', 'Ver más'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField(ctaLinkController, 'Enlace', '/productos'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildInputField(discountCodeController, 'Código descuento (opcional)', 'SUMMER25'),
                const SizedBox(height: 16),

                // Duración
                Text(
                  'Duración: ${duration.toInt()} segundos',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Slider(
                  value: duration,
                  min: 3,
                  max: 15,
                  divisions: 12,
                  activeColor: AppColors.neonCyan,
                  onChanged: (v) => setState(() => duration = v),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.isEmpty || imageUrl == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Título e imagen son obligatorios'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final success = await ref.read(adminCarouselSlidesProvider.notifier).createSlide(
                        title: titleController.text,
                        subtitle: subtitleController.text.isEmpty ? null : subtitleController.text,
                        description: descController.text.isEmpty ? null : descController.text,
                        imageUrl: imageUrl!,
                        ctaText: ctaTextController.text,
                        ctaLink: ctaLinkController.text,
                        duration: (duration * 1000).toInt(),
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? 'Slide creada' : 'Error al crear slide'),
                            backgroundColor: success ? Colors.green : Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonCyan,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Crear Slide',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: const Color(0xFF1A1A24),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
