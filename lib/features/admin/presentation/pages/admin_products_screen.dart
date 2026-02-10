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

/// Pantalla de gestión de productos (Admin)
class AdminProductsScreen extends ConsumerStatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  ConsumerState<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends ConsumerState<AdminProductsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterProducts(List<Map<String, dynamic>> products) {
    if (_searchQuery.isEmpty) return products;
    final query = _searchQuery.toLowerCase();
    return products.where((product) {
      final name = (product['name'] as String? ?? '').toLowerCase();
      final category = (product['category']?['name'] as String? ?? '').toLowerCase();
      final slug = (product['slug'] as String? ?? '').toLowerCase();
      return name.contains(query) || category.contains(query) || slug.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(adminSessionProvider);
    final productsAsync = ref.watch(adminProductsProvider);

    if (admin == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.adminLogin);
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
                bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
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
          // Lista de productos
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.neonCyan),
              ),
              error: (e, stack) {
                print('❌ Error cargando productos: $e');
                print('📍 Stack: $stack');
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

  /// Muestra diálogo para CREAR nuevo producto
  void _showCreateProductDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final slugController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController(text: '10');
    final descriptionController = TextEditingController();
    bool isOffer = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF12121A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
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

                  // Nombre
                  _buildCreateTextField(
                    controller: nameController,
                    label: 'Nombre del producto',
                    icon: Icons.label_outline,
                    onChanged: (value) {
                      // Auto-generar slug
                      slugController.text = value
                          .toLowerCase()
                          .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
                          .replaceAll(RegExp(r'^-|-$'), '');
                    },
                  ),
                  const SizedBox(height: 16),

                  // Slug
                  _buildCreateTextField(
                    controller: slugController,
                    label: 'Slug (URL)',
                    icon: Icons.link,
                  ),
                  const SizedBox(height: 16),

                  // Precio
                  _buildCreateTextField(
                    controller: priceController,
                    label: 'Precio (€)',
                    icon: Icons.euro,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Stock
                  _buildCreateTextField(
                    controller: stockController,
                    label: 'Stock inicial',
                    icon: Icons.inventory_2_outlined,
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
                  const SizedBox(height: 24),

                  // Botón crear
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isEmpty || priceController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Nombre y precio son requeridos'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        final supabase = Supabase.instance.client;

                        try {
                          await supabase.from('products').insert({
                            'name': nameController.text,
                            'slug': slugController.text.isNotEmpty
                                ? slugController.text
                                : nameController.text
                                    .toLowerCase()
                                    .replaceAll(RegExp(r'[^a-z0-9]+'), '-'),
                            'price': double.tryParse(priceController.text) ?? 0,
                            'stock': int.tryParse(stockController.text) ?? 0,
                            'description': descriptionController.text.isNotEmpty
                                ? descriptionController.text
                                : null,
                            'is_offer': isOffer,
                            'active': true,
                          });

                          if (context.mounted) {
                            Navigator.pop(context);
                            ref.invalidate(adminProductsProvider);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Producto creado correctamente'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
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
                      child: const Text(
                        'Crear Producto',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
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

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
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
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
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
                              color: AppColors.neonFuchsia.withOpacity(0.2),
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
                // Stock por talla
                Builder(
                  builder: (context) {
                    // Ordenar variantes por talla
                    final sizeOrder = ['XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL', '36', '38', '40', '42', '44', '46'];
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
                    
                    if (sortedVariants.isEmpty) {
                      // Mostrar stock global si no hay variantes
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
                    
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.grey[500],
                            size: 14,
                          ),
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

  /// Muestra diálogo para EDITAR producto con stock por talla
  void _showEditProductDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> product) {
    final nameController = TextEditingController(text: product['name']);
    final priceController = TextEditingController(text: (product['price'] ?? 0).toString());
    bool isOffer = product['is_offer'] == true;
    bool isActive = product['active'] == true;
    
    // Stock por talla
    final variants = List<Map<String, dynamic>>.from(product['variants'] ?? []);
    final stockControllers = <String, TextEditingController>{};
    for (final v in variants) {
      final size = v['size'] as String? ?? '';
      final stock = v['stock'] as int? ?? 0;
      stockControllers[size] = TextEditingController(text: stock.toString());
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF12121A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
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

                  // Nombre
                  _buildTextField(
                    controller: nameController,
                    label: 'Nombre',
                    icon: Icons.label_outline,
                  ),
                  const SizedBox(height: 16),

                  // Precio
                  _buildTextField(
                    controller: priceController,
                    label: 'Precio (€)',
                    icon: Icons.euro,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),

                  // Stock por talla
                  if (variants.isNotEmpty) ...[
                    Text(
                      'Stock por Talla',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A24),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: stockControllers.entries.map((entry) {
                          return SizedBox(
                            width: 80,
                            child: TextField(
                              controller: entry.value,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              decoration: InputDecoration(
                                labelText: entry.key,
                                labelStyle: const TextStyle(color: AppColors.neonCyan, fontSize: 12),
                                filled: true,
                                fillColor: const Color(0xFF0D0D14),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: AppColors.neonCyan),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

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
                      onPressed: () async {
                        final supabase = Supabase.instance.client;
                        
                        try {
                          // Actualizar producto
                          await supabase.from('products').update({
                            'name': nameController.text,
                            'price': double.tryParse(priceController.text) ?? 0,
                            'is_offer': isOffer,
                            'active': isActive,
                          }).eq('id', product['id']);

                          // Actualizar stock por talla
                          for (final entry in stockControllers.entries) {
                            final size = entry.key;
                            final newStock = int.tryParse(entry.value.text) ?? 0;
                            
                            await supabase
                                .from('product_variants')
                                .update({'stock': newStock})
                                .eq('product_id', product['id'])
                                .eq('size', size);
                          }

                          if (context.mounted) {
                            Navigator.pop(context);
                            ref.invalidate(adminProductsProvider);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Producto actualizado correctamente'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
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
                      child: const Text(
                        'Guardar Cambios',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
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
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
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
