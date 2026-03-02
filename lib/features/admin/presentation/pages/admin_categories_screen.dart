import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/router/app_router.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/admin_notification_button.dart';

/// Pantalla de gestión de categorías (Admin)
/// Equivalente a /admin/categorias en FashionStore
class AdminCategoriesScreen extends ConsumerStatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  ConsumerState<AdminCategoriesScreen> createState() =>
      _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends ConsumerState<AdminCategoriesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterCategories(
    List<Map<String, dynamic>> categories,
  ) {
    if (_searchQuery.isEmpty) return categories;
    final query = _searchQuery.toLowerCase();
    return categories.where((cat) {
      final name = (cat['name'] as String? ?? '').toLowerCase();
      final slug = (cat['slug'] as String? ?? '').toLowerCase();
      return name.contains(query) || slug.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(adminSessionProvider);
    final categoriesAsync = ref.watch(adminCategoriesProvider);

    if (admin == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.home);
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      drawer: AdminDrawer(currentRoute: AppRoutes.adminCategories),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D14),
        title: const Text(
          'Categorías',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          const AdminNotificationButton(),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.neonCyan),
            onPressed: () => _showCategoryDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D14),
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              ),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar categorías...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[600]),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF12121A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Categories list
          Expanded(
            child: categoriesAsync.when(
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
                      'Error al cargar categorías',
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      e.toString(),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => ref.invalidate(adminCategoriesProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonCyan,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              data: (categories) {
                final filtered = _filterCategories(categories);
                if (filtered.isEmpty) {
                  return _buildEmptyState();
                }
                return RefreshIndicator(
                  color: AppColors.neonCyan,
                  backgroundColor: const Color(0xFF12121A),
                  onRefresh: () async {
                    ref.invalidate(adminCategoriesProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) =>
                        _buildCategoryCard(context, ref, filtered[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(context, ref),
        backgroundColor: AppColors.neonCyan,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          'Nueva Categoría',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, color: Colors.grey[700], size: 64),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No se encontraron categorías'
                : 'No hay categorías',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Intenta con otro término'
                : 'Crea la primera categoría',
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> category,
  ) {
    final name = category['name'] as String? ?? '';
    final slug = category['slug'] as String? ?? '';
    final description = category['description'] as String?;
    final imageUrl = category['image_url'] as String?;
    final displayOrder = category['display_order'] as int? ?? 0;
    final productsCount = category['products_count'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showCategoryDialog(context, ref, category: category),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category image / icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF1A1A2E),
                ),
                clipBehavior: Clip.antiAlias,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.neonCyan,
                          ),
                        ),
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.category,
                          color: Colors.grey,
                          size: 28,
                        ),
                      )
                    : Icon(Icons.category, color: Colors.grey[600], size: 28),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(child: _buildMetaItem(Icons.link, '/$slug')),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetaItem(
                            Icons.inventory_2_outlined,
                            '$productsCount productos',
                          ),
                        ),
                      ],
                    ),
                    if (description != null && description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Order badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neonCyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#$displayOrder',
                  style: const TextStyle(
                    color: AppColors.neonCyan,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Actions
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                color: const Color(0xFF1A1A2E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (action) =>
                    _handleAction(context, ref, action, category),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: AppColors.neonCyan, size: 18),
                        SizedBox(width: 8),
                        Text('Editar', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red[400], size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Eliminar',
                          style: TextStyle(color: Colors.red[400]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 14),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _handleAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    Map<String, dynamic> category,
  ) {
    switch (action) {
      case 'edit':
        _showCategoryDialog(context, ref, category: category);
        break;
      case 'delete':
        _confirmDelete(context, ref, category);
        break;
    }
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> category,
  ) {
    final name = category['name'] as String? ?? '';
    final productsCount = category['products_count'] as int? ?? 0;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '¿Eliminar categoría?',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vas a eliminar "$name".',
              style: TextStyle(color: Colors.grey[400]),
            ),
            if (productsCount > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$productsCount productos quedarán sin categoría.',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey[400])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref
                  .read(adminCategoriesProvider.notifier)
                  .deleteCategory(category['id'] as String);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Categoría eliminada'
                          : 'Error al eliminar categoría',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog(
    BuildContext context,
    WidgetRef ref, {
    Map<String, dynamic>? category,
  }) {
    final isEditing = category != null;
    final nameController = TextEditingController(
      text: category?['name'] as String? ?? '',
    );
    final slugController = TextEditingController(
      text: category?['slug'] as String? ?? '',
    );
    final descriptionController = TextEditingController(
      text: category?['description'] as String? ?? '',
    );
    final imageUrlController = TextEditingController(
      text: category?['image_url'] as String? ?? '',
    );
    final displayOrderController = TextEditingController(
      text: (category?['display_order'] as int? ?? 0).toString(),
    );

    // Auto-generate slug from name
    bool autoSlug = !isEditing;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            height: MediaQuery.of(ctx).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Color(0xFF12121A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        isEditing ? Icons.edit : Icons.add_circle_outline,
                        color: AppColors.neonCyan,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEditing ? 'Editar Categoría' : 'Nueva Categoría',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: Icon(Icons.close, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                Divider(color: Colors.white.withValues(alpha: 0.05)),

                // Form
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image preview
                        if (imageUrlController.text.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: CachedNetworkImage(
                              imageUrl: imageUrlController.text,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.neonCyan,
                                ),
                              ),
                              errorWidget: (_, __, ___) => Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey[600],
                                  size: 40,
                                ),
                              ),
                            ),
                          ),

                        _buildInputField(
                          controller: nameController,
                          label: 'Nombre',
                          hint: 'Ej: Camisas',
                          icon: Icons.label_outline,
                          onChanged: (value) {
                            if (autoSlug) {
                              slugController.text = value
                                  .toLowerCase()
                                  .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
                                  .replaceAll(RegExp(r'^-|-$'), '');
                              setModalState(() {});
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildInputField(
                          controller: slugController,
                          label: 'Slug (URL)',
                          hint: 'Ej: camisas',
                          icon: Icons.link,
                          onChanged: (_) {
                            autoSlug = false;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildInputField(
                          controller: descriptionController,
                          label: 'Descripción (opcional)',
                          hint: 'Breve descripción de la categoría',
                          icon: Icons.description_outlined,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),

                        _buildInputField(
                          controller: imageUrlController,
                          label: 'URL de Imagen (opcional)',
                          hint: 'https://res.cloudinary.com/...',
                          icon: Icons.image_outlined,
                          onChanged: (_) => setModalState(() {}),
                        ),
                        const SizedBox(height: 16),

                        _buildInputField(
                          controller: displayOrderController,
                          label: 'Orden de visualización',
                          hint: '0',
                          icon: Icons.sort,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ),

                // Save button
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final slug = slugController.text.trim();

                        if (name.isEmpty || slug.isEmpty) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                              content: Text('Nombre y slug son obligatorios'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        Navigator.pop(ctx);

                        final description =
                            descriptionController.text.trim().isEmpty
                            ? null
                            : descriptionController.text.trim();
                        final imageUrl = imageUrlController.text.trim().isEmpty
                            ? null
                            : imageUrlController.text.trim();
                        final displayOrder =
                            int.tryParse(displayOrderController.text) ?? 0;

                        bool success;
                        if (isEditing) {
                          success = await ref
                              .read(adminCategoriesProvider.notifier)
                              .updateCategory(
                                id: category['id'] as String,
                                name: name,
                                slug: slug,
                                description: description,
                                imageUrl: imageUrl,
                                displayOrder: displayOrder,
                              );
                        } else {
                          success = await ref
                              .read(adminCategoriesProvider.notifier)
                              .createCategory(
                                name: name,
                                slug: slug,
                                description: description,
                                imageUrl: imageUrl,
                                displayOrder: displayOrder,
                              );
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? isEditing
                                          ? 'Categoría actualizada'
                                          : 'Categoría creada'
                                    : 'Error al guardar categoría',
                              ),
                              backgroundColor: success
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonCyan,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isEditing ? 'Guardar Cambios' : 'Crear Categoría',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[700]),
            prefixIcon: maxLines == 1
                ? Icon(icon, color: Colors.grey[600], size: 20)
                : null,
            filled: true,
            fillColor: const Color(0xFF0A0A0F),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.neonCyan),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
