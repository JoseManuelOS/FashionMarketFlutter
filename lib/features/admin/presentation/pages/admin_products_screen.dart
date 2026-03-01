import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/router/app_router.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/admin_notification_button.dart';
import '../widgets/variant_editor_widget.dart';
import '../widgets/color_editor_widget.dart';
import '../../../../shared/widgets/cloudinary_image_uploader.dart';
import '../../../../shared/services/cloudinary_service.dart';

/// Pantalla de gestión de productos (Admin)
class AdminProductsScreen extends ConsumerStatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  ConsumerState<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends ConsumerState<AdminProductsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  /// null = Todos, true = Activos, false = Inactivos
  bool? _activeFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterProducts(List<Map<String, dynamic>> products) {
    var filtered = products;

    // Filtro por activo/inactivo
    if (_activeFilter != null) {
      filtered = filtered.where((p) => (p['active'] as bool? ?? true) == _activeFilter).toList();
    }

    // Filtro por búsqueda
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((product) {
        final name = (product['name'] as String? ?? '').toLowerCase();
        final category = (product['category']?['name'] as String? ?? '').toLowerCase();
        final slug = (product['slug'] as String? ?? '').toLowerCase();
        return name.contains(query) || category.contains(query) || slug.contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(adminSessionProvider);
    final productsAsync = ref.watch(adminProductsProvider);

    if (admin == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.home);
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      drawer: AdminDrawer(currentRoute: AppRoutes.adminProducts),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D14),
        title: const Text(
          'Productos',
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
            onPressed: () => _showCreateProductDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Buscador
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
                hintText: 'Buscar productos...',
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          // Filtros activo/inactivo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D14),
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              ),
            ),
            child: Row(
              children: [
                _buildFilterChip('Todos', _activeFilter == null, () {
                  setState(() => _activeFilter = null);
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Activos', _activeFilter == true, () {
                  setState(() => _activeFilter = true);
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Inactivos', _activeFilter == false, () {
                  setState(() => _activeFilter = false);
                }),
              ],
            ),
          ),
          // Lista de productos
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.neonCyan),
              ),
              error: (e, stack) {
                print('Error cargando productos: $e');
                print('Stack: $stack');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar productos',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          e.toString(),
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => ref.invalidate(adminProductsProvider),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              },
              data: (products) {
                final filteredProducts = _filterProducts(products);
                
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, color: Colors.grey[600], size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'No hay productos',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showCreateProductDialog(context, ref),
                          icon: const Icon(Icons.add),
                          label: const Text('Añadir Producto'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.neonCyan,
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, color: Colors.grey[600], size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron productos',
                          style: TextStyle(color: Colors.grey[400], fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Prueba con otra búsqueda',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.neonCyan,
                  backgroundColor: const Color(0xFF12121A),
                  onRefresh: () async {
                    ref.invalidate(adminProductsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ProductCard(product: filteredProducts[index]),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.neonCyan.withValues(alpha: 0.15) : const Color(0xFF12121A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.neonCyan : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.neonCyan : Colors.grey[500],
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// Muestra diálogo para CREAR nuevo producto (formulario completo)
  /// Usa RPC admin_create_product para bypassear RLS
  Future<void> _showCreateProductDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final originalPriceController = TextEditingController();
    final discountPercentController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isOffer = false;
    bool isCreating = false;
    String? selectedCategoryId;
    List<String> imageUrls = [];
    List<Map<String, dynamic>> variants = [];
    List<ProductColor> productColors = [];
    Map<String, String?> imageColorAssignments = {};

    // Pre-cargar categorías antes de abrir el modal (evita loading infinito)
    List<Map<String, dynamic>> categories = [];
    try {
      categories = ref.read(adminCategoriesProvider).valueOrNull ?? 
          await ref.read(adminCategoriesProvider.future);
    } catch (_) {}
    final admin = ref.read(adminSessionProvider);
    final parentScaffoldMessenger = ScaffoldMessenger.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF12121A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Crear Nuevo Producto',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
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

                      // ─── Imágenes del producto ───
                      CloudinaryMultiImageUploader(
                        imageUrls: imageUrls,
                        folder: CloudinaryService.folderProducts,
                        label: 'Imágenes del producto',
                        maxImages: 8,
                        onChanged: (urls) => setModalState(() => imageUrls = urls),
                        availableColors: productColors.map((c) => {'name': c.name, 'hex': c.hex}).toList(),
                        imageColorAssignments: imageColorAssignments,
                        onColorAssignmentsChanged: (assignments) => setModalState(() => imageColorAssignments = assignments),
                      ),
                      const SizedBox(height: 20),

                      // Nombre
                      _buildCreateTextField(
                        controller: nameController,
                        label: 'Nombre del producto',
                        icon: Icons.label_outline,
                      ),
                      const SizedBox(height: 16),

                      // ─── Categoría selector ───
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A24),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: selectedCategoryId,
                          decoration: InputDecoration(
                            labelText: 'Categoría',
                            labelStyle: TextStyle(color: Colors.grey[500]),
                            prefixIcon: const Icon(Icons.category_outlined, color: AppColors.neonCyan),
                            border: InputBorder.none,
                          ),
                          dropdownColor: const Color(0xFF1A1A24),
                          style: const TextStyle(color: Colors.white),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Sin categoría', style: TextStyle(color: Colors.grey)),
                            ),
                            ...categories.map((cat) => DropdownMenuItem<String>(
                                  value: cat['id'] as String,
                                  child: Text(cat['name'] as String? ?? ''),
                                )),
                          ],
                          onChanged: (value) => setModalState(() => selectedCategoryId = value),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ─── Precios ───
                      Row(
                        children: [
                          Expanded(
                            child: _buildCreateTextField(
                              controller: priceController,
                              label: 'Precio (€)',
                              icon: Icons.euro,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCreateTextField(
                              controller: originalPriceController,
                              label: 'Precio original (€)',
                              icon: Icons.price_change_outlined,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Descuento
                      _buildCreateTextField(
                        controller: discountPercentController,
                        label: 'Descuento (%)',
                        icon: Icons.percent,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Descripción
                      _buildCreateTextField(
                        controller: descriptionController,
                        label: 'Descripción',
                        icon: Icons.description_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),

                      // Switch oferta
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A24),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Es oferta', style: TextStyle(color: Colors.white)),
                            Switch(
                              value: isOffer,
                              onChanged: (v) => setModalState(() => isOffer = v),
                              activeColor: AppColors.neonFuchsia,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ─── COLORES DEL PRODUCTO ───
                      ColorEditorWidget(
                        initialColors: productColors,
                        onChanged: (colors) => setModalState(() => productColors = colors),
                      ),
                      const SizedBox(height: 20),

                      // ─── VARIANTES (Tallas con Stock) ───
                      const Text(
                        'Stock por Talla',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        productColors.isEmpty
                            ? 'Define el stock por cada talla disponible'
                            : 'Define el stock por cada talla × color',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      VariantEditorWidget(
                        initialVariants: const [],
                        onChanged: (v) => variants = v,
                        colors: productColors,
                      ),
                      const SizedBox(height: 24),

                      // Botón crear
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isCreating ? null : () async {
                            if (nameController.text.isEmpty || priceController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Nombre y precio son requeridos'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }
                            if (variants.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Añade al menos una talla con stock'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            setModalState(() => isCreating = true);
                            final supabase = Supabase.instance.client;

                            try {
                              // Crear array de imágenes para el RPC
                              final imagesData = imageUrls
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                    final imgData = <String, dynamic>{
                                      'image_url': entry.value,
                                      'order': entry.key,
                                    };
                                    // Add color assignment if exists
                                    final assignedColor = imageColorAssignments[entry.value];
                                    if (assignedColor != null) {
                                      imgData['color'] = assignedColor;
                                      final colorMatch = productColors.where((c) => c.name == assignedColor).firstOrNull;
                                      if (colorMatch != null) {
                                        imgData['color_hex'] = colorMatch.hex;
                                      }
                                    }
                                    return imgData;
                                  })
                                  .toList();

                              // Construir sizes array
                              final sizes = variants.map((v) => v['size'] as String).toSet().toList();

                              // Construir colors JSONB
                              final colorsJson = productColors.map((c) => c.toJson()).toList();

                              final productData = {
                                'name': nameController.text.trim(),
                                'description': descriptionController.text.isNotEmpty
                                    ? descriptionController.text.trim()
                                    : null,
                                'price': double.tryParse(priceController.text) ?? 0,
                                'category_id': selectedCategoryId,
                                'is_offer': isOffer,
                                'active': true,
                                'sizes': sizes,
                                'variants': variants,
                                'images': imagesData,
                                'colors': colorsJson,
                              };

                              // Precio original
                              final originalPrice = double.tryParse(originalPriceController.text);
                              if (originalPrice != null) {
                                productData['original_price'] = originalPrice;
                              }

                              // Descuento
                              final discountPercent = int.tryParse(discountPercentController.text);
                              if (discountPercent != null) {
                                productData['discount_percent'] = discountPercent;
                              }

                              // Llamar al RPC (SECURITY DEFINER bypassea RLS)
                              await supabase.rpc(
                                'admin_create_product',
                                params: {
                                  'p_admin_email': admin?.email ?? '',
                                  'p_data': productData,
                                },
                              );

                              if (context.mounted) {
                                Navigator.pop(context);
                                ref.invalidate(adminProductsProvider);
                                ref.invalidate(adminDashboardStatsProvider);
                                parentScaffoldMessenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Producto creado correctamente'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              setModalState(() => isCreating = false);
                              if (context.mounted) {
                                Navigator.pop(context);
                                parentScaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text('Error al crear: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.neonCyan,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isCreating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text(
                                  'Crear Producto',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                // Loading overlay
                if (isCreating)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.3),
                      child: const Center(
                        child: CircularProgressIndicator(color: AppColors.neonCyan),
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

  Widget _buildCreateTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500]),
        prefixIcon: Icon(icon, color: AppColors.neonCyan),
        filled: true,
        fillColor: const Color(0xFF1A1A24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neonCyan),
        ),
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  final Map<String, dynamic> product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = product['images'] as List? ?? [];
    final imageUrl = images.isNotEmpty ? images[0]['image_url'] : null;
    final category = product['category'] as Map<String, dynamic>?;
    final isActive = product['active'] == true;
    final isOffer = product['is_offer'] == true;
    
    // Stock por talla desde variants
    final variants = product['variants'] as List? ?? [];

    // Colores del producto
    final productColors = product['colors'] as List? ?? [];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          // Imagen y info principal
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Imagen
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imageUrl != null
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
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        )
                      : const Icon(Icons.image, color: Colors.grey),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre
                      Text(
                        product['name'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Categoría
                      if (category != null)
                        Text(
                          category['name'] ?? '',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      const SizedBox(height: 8),

                      // Precio
                      Row(
                        children: [
                          Text(
                            '€${(product['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(
                              color: AppColors.neonCyan,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isOffer && product['original_price'] != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '€${(product['original_price'] as num?)?.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Acciones
                Column(
                  children: [
                    // Estado activo/inactivo
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isActive ? 'Activo' : 'Inactivo',
                        style: TextStyle(
                          color: isActive ? Colors.green : Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Badges
                    Row(
                      children: [
                        if (isOffer)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.neonFuchsia.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'OFERTA',
                              style: TextStyle(
                                color: AppColors.neonFuchsia,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Footer con stock por talla y acciones
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                // Color chips
                if (productColors.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.palette_outlined, color: Colors.grey[500], size: 14),
                        const SizedBox(width: 6),
                        ...productColors.take(6).map((c) {
                          Color chipColor;
                          try {
                            final h = ((c as Map)['hex'] as String? ?? '#808080').replaceFirst('#', '');
                            chipColor = Color(int.parse('FF$h', radix: 16));
                          } catch (_) {
                            chipColor = Colors.grey;
                          }
                          return Container(
                            margin: const EdgeInsets.only(right: 4),
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: chipColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24),
                            ),
                          );
                        }),
                        if (productColors.length > 6)
                          Text(
                            '+${productColors.length - 6}',
                            style: TextStyle(color: Colors.grey[500], fontSize: 11),
                          ),
                      ],
                    ),
                  ),
                // Stock por talla (desglosado por color cuando hay colores)
                Builder(
                  builder: (context) {
                    final sizeOrder = ['XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL', '36', '38', '40', '42', '44', '46'];
                    
                    if (variants.isEmpty) {
                      final globalStock = product['stock'] as int? ?? 0;
                      return Row(
                        children: [
                          Icon(Icons.inventory_2_outlined, color: Colors.grey[500], size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'Stock: $globalStock uds',
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                        ],
                      );
                    }

                    // Comprobar si hay múltiples colores en las variantes
                    final hasColors = variants.any((v) => v['color'] != null && (v['color'] as String).isNotEmpty);

                    // Si tiene colores, mostrar stock desglosado por color → talla
                    if (hasColors) {
                      // Agrupar: color → {size → stock}
                      final Map<String, Map<String, int>> stockByColor = {};
                      final Map<String, String> colorHexMap = {};
                      for (final v in variants) {
                        final color = v['color'] as String? ?? 'Sin color';
                        final size = v['size'] as String? ?? '?';
                        final qty = v['stock'] as int? ?? 0;
                        stockByColor.putIfAbsent(color, () => {});
                        stockByColor[color]![size] = (stockByColor[color]![size] ?? 0) + qty;
                      }
                      // Obtener hex de colores desde productColors
                      for (final c in productColors) {
                        try {
                          final name = (c as Map)['name'] as String? ?? '';
                          final hex = (c)['hex'] as String? ?? '';
                          if (name.isNotEmpty) colorHexMap[name] = hex;
                        } catch (_) {}
                      }

                      final colorNames = stockByColor.keys.toList()..sort();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: colorNames.map((colorName) {
                          final sizesMap = stockByColor[colorName]!;
                          final sortedSizes = sizesMap.keys.toList()..sort((a, b) {
                            final indexA = sizeOrder.indexOf(a.toUpperCase());
                            final indexB = sizeOrder.indexOf(b.toUpperCase());
                            if (indexA == -1 && indexB == -1) return a.compareTo(b);
                            if (indexA == -1) return 1;
                            if (indexB == -1) return -1;
                            return indexA.compareTo(indexB);
                          });

                          // Resolve color dot
                          Color dotColor = Colors.grey;
                          final hex = colorHexMap[colorName];
                          if (hex != null && hex.isNotEmpty) {
                            try {
                              final h = hex.replaceFirst('#', '');
                              dotColor = Color(int.parse('FF$h', radix: 16));
                            } catch (_) {}
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: dotColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white24, width: 0.5),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  ...sortedSizes.map((size) {
                                    final qty = sizesMap[size]!;
                                    final isLow = qty > 0 && qty <= 3;
                                    final isOut = qty == 0;
                                    return Container(
                                      margin: const EdgeInsets.only(right: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isOut
                                            ? Colors.red.withValues(alpha: 0.15)
                                            : isLow
                                                ? Colors.orange.withValues(alpha: 0.15)
                                                : Colors.grey.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: isOut
                                              ? Colors.red.withValues(alpha: 0.3)
                                              : isLow
                                                  ? Colors.orange.withValues(alpha: 0.3)
                                                  : Colors.grey.withValues(alpha: 0.15),
                                        ),
                                      ),
                                      child: Text(
                                        '$size:$qty',
                                        style: TextStyle(
                                          color: isOut ? Colors.red : isLow ? Colors.orange : Colors.grey[400],
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }

                    // Sin colores: mostrar cada variante individual
                    final sortedVariants = List<Map<String, dynamic>>.from(variants);
                    sortedVariants.sort((a, b) {
                      final sizeA = a['size'] as String? ?? '';
                      final sizeB = b['size'] as String? ?? '';
                      final indexA = sizeOrder.indexOf(sizeA.toUpperCase());
                      final indexB = sizeOrder.indexOf(sizeB.toUpperCase());
                      if (indexA == -1 && indexB == -1) return sizeA.compareTo(sizeB);
                      if (indexA == -1) return 1;
                      if (indexB == -1) return -1;
                      return indexA.compareTo(indexB);
                    });
                    
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Icon(Icons.inventory_2_outlined, color: Colors.grey[500], size: 14),
                          const SizedBox(width: 6),
                          ...sortedVariants.map((v) {
                            final size = v['size'] as String? ?? '?';
                            final qty = v['stock'] as int? ?? 0;
                            final isLow = qty > 0 && qty <= 3;
                            final isOut = qty == 0;
                            return Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isOut 
                                    ? Colors.red.withValues(alpha: 0.15)
                                    : isLow 
                                        ? Colors.orange.withValues(alpha: 0.15)
                                        : Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isOut 
                                      ? Colors.red.withValues(alpha: 0.3)
                                      : isLow 
                                          ? Colors.orange.withValues(alpha: 0.3)
                                          : Colors.grey.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(
                                '$size: $qty',
                                style: TextStyle(
                                  color: isOut ? Colors.red : isLow ? Colors.orange : Colors.grey[400],
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                
                // Acciones (sin stock total ya que se muestra por talla arriba)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Acciones
                    Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.edit_outlined,
                          color: AppColors.neonCyan,
                          onTap: () => _showEditProductDialog(context, ref, product),
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: Icons.visibility_outlined,
                          color: Colors.grey,
                          onTap: () => _showViewProductDialog(context, product),
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: (product['is_active'] as bool? ?? true)
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: (product['is_active'] as bool? ?? true)
                              ? Colors.orange
                              : Colors.green,
                          onTap: () => _confirmDeleteProduct(context, ref, product),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  /// Muestra diálogo de confirmación para DESACTIVAR un producto (soft delete).
  /// Pone is_active = false en vez de borrar el registro.
  Future<void> _confirmDeleteProduct(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> product,
  ) async {
    final productName = product['name'] as String? ?? 'Producto';
    final isActive = product['is_active'] as bool? ?? true;
    final actionLabel = isActive ? 'Desactivar' : 'Reactivar';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF12121A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '¿$actionLabel producto?',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          isActive
              ? '"$productName" dejará de aparecer en la tienda. Podrás reactivarlo después.'
              : '"$productName" volverá a aparecer en la tienda.',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              actionLabel,
              style: TextStyle(color: isActive ? Colors.orange : Colors.green),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final supabase = Supabase.instance.client;

      await supabase
          .from('products')
          .update({'is_active': !isActive})
          .eq('id', product['id']);

      ref.invalidate(adminProductsProvider);
      ref.invalidate(adminDashboardStatsProvider);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            isActive
                ? 'Producto desactivado correctamente'
                : 'Producto reactivado correctamente',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Muestra diálogo para VER detalles del producto
  void _showViewProductDialog(BuildContext context, Map<String, dynamic> product) {
    final images = product['images'] as List? ?? [];
    final imageUrl = images.isNotEmpty ? images[0]['image_url'] : null;
    final category = product['category'] as Map<String, dynamic>?;
    final currencyFormat = NumberFormat.currency(locale: 'es_ES', symbol: '€');
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF12121A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Detalles del Producto',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // Imagen
              if (imageUrl != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[900],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const Icon(Icons.image, color: Colors.grey, size: 48),
                  ),
                ),

              // Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    Text(
                      product['name'] ?? 'Sin nombre',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Categoría
                    if (category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.neonPurple.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category['name'] ?? '',
                          style: const TextStyle(
                            color: AppColors.neonPurple,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Precio
                    Row(
                      children: [
                        Text(
                          currencyFormat.format(product['price'] ?? 0),
                          style: const TextStyle(
                            color: AppColors.neonCyan,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (product['is_offer'] == true && product['original_price'] != null) ...[
                          const SizedBox(width: 12),
                          Text(
                            currencyFormat.format(product['original_price']),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Descripción
                    if (product['description'] != null) ...[
                      Text(
                        'Descripción',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product['description'],
                        style: TextStyle(color: Colors.grey[300], fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Stats
                    _buildDetailRow('Estado', product['active'] == true ? 'Activo' : 'Inactivo'),
                    _buildDetailRow('Oferta', product['is_offer'] == true ? 'Sí' : 'No'),
                    _buildDetailRow('ID', product['id'] ?? ''),
                    
                    const SizedBox(height: 16),
                    
                    // Stock por talla
                    Text(
                      'Stock por Talla',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStockBySize(product),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStockBySize(Map<String, dynamic> product) {
    final variants = product['variants'] as List? ?? [];
    
    if (variants.isEmpty) {
      final globalStock = product['stock'] as int? ?? 0;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A24),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Stock global: $globalStock unidades',
          style: TextStyle(color: Colors.grey[400]),
        ),
      );
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: variants.map((v) {
        final size = v['size'] as String? ?? '?';
        final qty = v['stock'] as int? ?? 0;
        final isLow = qty > 0 && qty <= 3;
        final isOut = qty == 0;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isOut 
                ? Colors.red.withValues(alpha: 0.15)
                : isLow 
                    ? Colors.orange.withValues(alpha: 0.15)
                    : const Color(0xFF1A1A24),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isOut 
                  ? Colors.red.withValues(alpha: 0.4)
                  : isLow 
                      ? Colors.orange.withValues(alpha: 0.4)
                      : Colors.grey.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Text(
                size,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$qty uds',
                style: TextStyle(
                  color: isOut ? Colors.red : isLow ? Colors.orange : Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Muestra diálogo para EDITAR producto con campos completos
  /// Usa RPC admin_update_product para bypassear RLS
  Future<void> _showEditProductDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> product) async {
    final nameController = TextEditingController(text: product['name']);
    final priceController = TextEditingController(text: (product['price'] ?? 0).toString());
    final originalPriceController = TextEditingController(
      text: product['original_price'] != null ? product['original_price'].toString() : '',
    );
    final discountPercentController = TextEditingController(
      text: product['discount_percent'] != null ? product['discount_percent'].toString() : '',
    );
    final descriptionController = TextEditingController(text: product['description'] ?? '');
    bool isOffer = product['is_offer'] == true;
    bool isActive = product['active'] == true;
    bool isSaving = false;

    // Categoría
    final category = product['category'] as Map<String, dynamic>?;
    String? selectedCategoryId = category?['id'] as String?;

    // Imágenes existentes
    final existingImages = (product['images'] as List? ?? [])
        .map((img) => img['image_url'] as String)
        .toList();
    List<String> imageUrls = List<String>.from(existingImages);

    // Color assignments for images
    Map<String, String?> imageColorAssignments = {};
    for (final img in (product['images'] as List? ?? [])) {
      final url = img['image_url'] as String?;
      final color = img['color'] as String?;
      if (url != null && color != null) {
        imageColorAssignments[url] = color;
      }
    }

    // Colores existentes del producto
    // Si colors JSONB es null pero las variantes tienen color, inferirlos automáticamente
    final existingColorsRaw = product['colors'] as List? ?? [];
    List<ProductColor> productColors = existingColorsRaw
        .where((c) => c is Map<String, dynamic>)
        .map((c) => ProductColor.fromJson(c as Map<String, dynamic>))
        .toList();
    
    if (productColors.isEmpty) {
      // Auto-inferir colores desde las variantes existentes
      final variantsList = product['variants'] as List? ?? [];
      final Map<String, String> inferredColors = {};
      for (final v in variantsList) {
        final colorName = v['color'] as String?;
        if (colorName != null && colorName.isNotEmpty && !inferredColors.containsKey(colorName)) {
          // Intentar obtener hex de las imágenes
          String hex = '#808080';
          for (final img in (product['images'] as List? ?? [])) {
            if (img['color'] == colorName && img['color_hex'] != null) {
              hex = img['color_hex'] as String;
              break;
            }
          }
          inferredColors[colorName] = hex;
        }
      }
      if (inferredColors.isNotEmpty) {
        productColors = inferredColors.entries
            .map((e) => ProductColor(name: e.key, hex: e.value))
            .toList();
      }
    }

    // Variantes existentes (tallas con stock y color)
    final existingVariants = (product['variants'] as List? ?? [])
        .map((v) => <String, dynamic>{
              'size': v['size'] as String? ?? '',
              'stock': v['stock'] as int? ?? 0,
              'sku': v['sku'] as String?,
              if (v['color'] != null) 'color': v['color'] as String,
            })
        .toList();
    List<Map<String, dynamic>> variants = List<Map<String, dynamic>>.from(existingVariants);

    // Pre-cargar categorías antes de abrir el modal (evita loading infinito)
    List<Map<String, dynamic>> categories = [];
    try {
      categories = ref.read(adminCategoriesProvider).valueOrNull ?? 
          await ref.read(adminCategoriesProvider.future);
    } catch (_) {}
    final admin = ref.read(adminSessionProvider);
    final parentScaffoldMessenger = ScaffoldMessenger.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.92,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF12121A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Editar Producto',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
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

                      // ─── Imágenes ───
                      CloudinaryMultiImageUploader(
                        imageUrls: imageUrls,
                        folder: CloudinaryService.folderProducts,
                        label: 'Imágenes del producto',
                        maxImages: 8,
                        onChanged: (urls) => setModalState(() => imageUrls = urls),
                        availableColors: productColors.map((c) => {'name': c.name, 'hex': c.hex}).toList(),
                        imageColorAssignments: imageColorAssignments,
                        onColorAssignmentsChanged: (assignments) => setModalState(() => imageColorAssignments = assignments),
                      ),
                      const SizedBox(height: 20),

                      // Nombre
                      _buildTextField(
                        controller: nameController,
                        label: 'Nombre',
                        icon: Icons.label_outline,
                      ),
                      const SizedBox(height: 16),

                      // ─── Categoría selector ───
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A24),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: selectedCategoryId,
                          decoration: InputDecoration(
                            labelText: 'Categoría',
                            labelStyle: TextStyle(color: Colors.grey[500]),
                            prefixIcon: const Icon(Icons.category_outlined, color: AppColors.neonCyan),
                            border: InputBorder.none,
                          ),
                          dropdownColor: const Color(0xFF1A1A24),
                          style: const TextStyle(color: Colors.white),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Sin categoría', style: TextStyle(color: Colors.grey)),
                            ),
                            ...categories.map((cat) => DropdownMenuItem<String>(
                                  value: cat['id'] as String,
                                  child: Text(cat['name'] as String? ?? ''),
                                )),
                          ],
                          onChanged: (value) => setModalState(() => selectedCategoryId = value),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ─── Precios ───
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: priceController,
                              label: 'Precio (€)',
                              icon: Icons.euro,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: originalPriceController,
                              label: 'Precio original (€)',
                              icon: Icons.price_change_outlined,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Descuento
                      _buildTextField(
                        controller: discountPercentController,
                        label: 'Descuento (%)',
                        icon: Icons.percent,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Descripción
                      _buildTextField(
                        controller: descriptionController,
                        label: 'Descripción',
                        icon: Icons.description_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),

                      // ─── COLORES DEL PRODUCTO ───
                      ColorEditorWidget(
                        initialColors: productColors,
                        onChanged: (colors) => setModalState(() => productColors = colors),
                      ),
                      const SizedBox(height: 20),

                      // ─── VARIANTES (Tallas con Stock) ───
                      const Text(
                        'Stock por Talla',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        productColors.isEmpty
                            ? 'Edita el stock por cada talla'
                            : 'Edita el stock por cada talla × color',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      VariantEditorWidget(
                        initialVariants: existingVariants,
                        onChanged: (v) => variants = v,
                        colors: productColors,
                      ),
                      const SizedBox(height: 20),

                      // Switches
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A24),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Producto activo', style: TextStyle(color: Colors.white)),
                                Switch(
                                  value: isActive,
                                  onChanged: (v) => setModalState(() => isActive = v),
                                  activeColor: AppColors.neonCyan,
                                ),
                              ],
                            ),
                            const Divider(color: Colors.grey, height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Es oferta', style: TextStyle(color: Colors.white)),
                                Switch(
                                  value: isOffer,
                                  onChanged: (v) => setModalState(() => isOffer = v),
                                  activeColor: AppColors.neonFuchsia,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Botón guardar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSaving ? null : () async {
                            setModalState(() => isSaving = true);
                            final supabase = Supabase.instance.client;
                            
                            try {
                              // Construir sizes array
                              final sizes = variants.map((v) => v['size'] as String).toSet().toList();

                              // Construir colors JSONB
                              final colorsJson = productColors.map((c) => c.toJson()).toList();

                              final updateData = <String, dynamic>{
                                'name': nameController.text.trim(),
                                'price': double.tryParse(priceController.text) ?? 0,
                                'is_offer': isOffer,
                                'active': isActive,
                                'category_id': selectedCategoryId,
                                'description': descriptionController.text.isNotEmpty
                                    ? descriptionController.text.trim()
                                    : null,
                                'sizes': sizes,
                                'variants': variants,
                                'colors': colorsJson,
                              };

                              final originalPrice = double.tryParse(originalPriceController.text);
                              updateData['original_price'] = originalPrice;

                              final discountPercent = int.tryParse(discountPercentController.text);
                              updateData['discount_percent'] = discountPercent;

                              // Actualizar imágenes (siempre enviar para actualizar colores)
                              updateData['images'] = imageUrls
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                    final imgData = <String, dynamic>{
                                      'image_url': entry.value,
                                      'order': entry.key,
                                    };
                                    final assignedColor = imageColorAssignments[entry.value];
                                    if (assignedColor != null) {
                                      imgData['color'] = assignedColor;
                                      final colorMatch = productColors.where((c) => c.name == assignedColor).firstOrNull;
                                      if (colorMatch != null) {
                                        imgData['color_hex'] = colorMatch.hex;
                                      }
                                    }
                                    return imgData;
                                  })
                                  .toList();

                              // Llamar al RPC (SECURITY DEFINER bypassea RLS)
                              await supabase.rpc(
                                'admin_update_product',
                                params: {
                                  'p_admin_email': admin?.email ?? '',
                                  'p_product_id': product['id'],
                                  'p_data': updateData,
                                },
                              );

                              if (context.mounted) {
                                Navigator.pop(context);
                                ref.invalidate(adminProductsProvider);
                                ref.invalidate(adminDashboardStatsProvider);
                                parentScaffoldMessenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Producto actualizado correctamente'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              setModalState(() => isSaving = false);
                              if (context.mounted) {
                                Navigator.pop(context);
                                parentScaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text('Error al actualizar: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.neonCyan,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text(
                                  'Guardar Cambios',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                // Loading overlay
                if (isSaving)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.3),
                      child: const Center(
                        child: CircularProgressIndicator(color: AppColors.neonCyan),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500]),
        prefixIcon: Icon(icon, color: AppColors.neonCyan),
        filled: true,
        fillColor: const Color(0xFF1A1A24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neonCyan),
        ),
      ),
    );
  }
}
