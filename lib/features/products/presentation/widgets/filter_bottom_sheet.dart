import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme/app_colors.dart';
import '../providers/filter_providers.dart';

/// Bottom sheet con filtros igual que la web de FashionStore
/// Incluye: búsqueda, precio, estilos, ofertas, categorías, tallas y colores
class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late TextEditingController _searchController;
  late double _priceMin;
  late double _priceMax;

  @override
  void initState() {
    super.initState();
    final filters = ref.read(productFiltersProvider);
    _searchController = TextEditingController(text: filters.search);
    _priceMin = filters.priceMin;
    _priceMax = filters.priceMax;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(productFiltersProvider);
    final categories = ref.watch(categoriesProvider);
    final allSizes = ref.watch(availableSizesProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.dark400,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.glassBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filtros',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (filters.hasActiveFilters)
                  TextButton(
                    onPressed: () {
                      ref.read(productFiltersProvider.notifier).clearAll();
                      _searchController.clear();
                      setState(() {
                        _priceMin = 0;
                        _priceMax = 500;
                      });
                    },
                    child: Text(
                      'Limpiar (${filters.activeFiltersCount})',
                      style: TextStyle(color: AppColors.neonCyan),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ══════════════════════════════════════════════════════════
                  // BÚSQUEDA
                  // ══════════════════════════════════════════════════════════
                  _buildSearchField(),
                  const SizedBox(height: 20),

                  // ══════════════════════════════════════════════════════════
                  // RANGO DE PRECIO
                  // ══════════════════════════════════════════════════════════
                  _buildPriceRange(filters),
                  const SizedBox(height: 20),

                  // ══════════════════════════════════════════════════════════
                  // ESTILOS POPULARES
                  // ══════════════════════════════════════════════════════════
                  _buildStyleTags(filters),
                  const SizedBox(height: 20),

                  // ══════════════════════════════════════════════════════════
                  // TOGGLE DE OFERTAS
                  // ══════════════════════════════════════════════════════════
                  _buildOffersToggle(filters),
                  const SizedBox(height: 20),

                  // ══════════════════════════════════════════════════════════
                  // CATEGORÍAS
                  // ══════════════════════════════════════════════════════════
                  categories.when(
                    data: (cats) => _buildCategories(filters, cats),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 20),

                  // ══════════════════════════════════════════════════════════
                  // TALLAS
                  // ══════════════════════════════════════════════════════════
                  allSizes.when(
                    data: (sizes) => _buildSizes(filters, sizes),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 20),

                  // ══════════════════════════════════════════════════════════
                  // COLORES
                  // ══════════════════════════════════════════════════════════
                  _buildColors(filters),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Apply button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.dark500,
              border: Border(
                top: BorderSide(color: AppColors.glassBorder),
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonCyan,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Aplicar Filtros',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Buscar productos...',
        hintStyle: TextStyle(color: AppColors.textMuted),
        prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: AppColors.textMuted),
                onPressed: () {
                  _searchController.clear();
                  ref.read(productFiltersProvider.notifier).setSearch('');
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.dark300,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.neonCyan),
        ),
      ),
      onSubmitted: (value) {
        ref.read(productFiltersProvider.notifier).setSearch(value);
      },
    );
  }

  Widget _buildPriceRange(ProductFilters filters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRECIO',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPriceInput(
                value: _priceMin,
                label: 'Min',
                onChanged: (val) {
                  setState(() => _priceMin = val);
                  ref.read(productFiltersProvider.notifier).setPriceRange(
                        _priceMin,
                        _priceMax,
                      );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('—', style: TextStyle(color: AppColors.textMuted)),
            ),
            Expanded(
              child: _buildPriceInput(
                value: _priceMax,
                label: 'Max',
                onChanged: (val) {
                  setState(() => _priceMax = val);
                  ref.read(productFiltersProvider.notifier).setPriceRange(
                        _priceMin,
                        _priceMax,
                      );
                },
              ),
            ),
            const SizedBox(width: 8),
            Text('€', style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
        const SizedBox(height: 16),
        RangeSlider(
          values: RangeValues(_priceMin, _priceMax),
          min: 0,
          max: 500,
          divisions: 50,
          activeColor: AppColors.neonCyan,
          inactiveColor: AppColors.dark300,
          labels: RangeLabels(
            '€${_priceMin.toInt()}',
            '€${_priceMax.toInt()}',
          ),
          onChanged: (values) {
            setState(() {
              _priceMin = values.start;
              _priceMax = values.end;
            });
          },
          onChangeEnd: (values) {
            ref.read(productFiltersProvider.notifier).setPriceRange(
                  values.start,
                  values.end,
                );
          },
        ),
      ],
    );
  }

  Widget _buildPriceInput({
    required double value,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    return TextField(
      controller: TextEditingController(text: value.toInt().toString()),
      keyboardType: TextInputType.number,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        filled: true,
        fillColor: AppColors.dark300,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
      ),
      onSubmitted: (val) {
        final parsed = double.tryParse(val) ?? value;
        onChanged(parsed.clamp(0, 500));
      },
    );
  }

  Widget _buildStyleTags(ProductFilters filters) {
    const styleTags = [
      'Manga corta',
      'Manga larga',
      'Slim fit',
      'Regular',
      'Casual',
      'Formal',
      'Verano',
      'Invierno',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ESTILOS POPULARES',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: styleTags.map((tag) {
            final isSelected =
                filters.search.toLowerCase() == tag.toLowerCase();
            return GestureDetector(
              onTap: () {
                if (isSelected) {
                  ref.read(productFiltersProvider.notifier).setSearch('');
                  _searchController.clear();
                } else {
                  ref.read(productFiltersProvider.notifier).setSearch(tag);
                  _searchController.text = tag;
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.neonCyan.withValues(alpha: 0.1)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppColors.neonCyan : AppColors.glassBorder,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: isSelected ? AppColors.neonCyan : AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOffersToggle(ProductFilters filters) {
    return GestureDetector(
      onTap: () {
        ref.read(productFiltersProvider.notifier).toggleOffers();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: filters.offersOnly
              ? LinearGradient(
                  colors: [
                    AppColors.neonFuchsia.withValues(alpha: 0.2),
                    AppColors.neonCyan.withValues(alpha: 0.1),
                  ],
                )
              : null,
          color: filters.offersOnly ? null : AppColors.dark300,
          border: Border.all(
            color: filters.offersOnly
                ? AppColors.neonFuchsia.withValues(alpha: 0.4)
                : AppColors.glassBorder,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: filters.offersOnly
                    ? AppColors.neonFuchsia
                    : AppColors.textMuted,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Solo Ofertas',
              style: TextStyle(
                color: filters.offersOnly
                    ? AppColors.neonFuchsia
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            _buildToggleSwitch(filters.offersOnly),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSwitch(bool isOn) {
    return Container(
      width: 44,
      height: 24,
      decoration: BoxDecoration(
        color: isOn ? AppColors.neonFuchsia : AppColors.dark400,
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(
      ProductFilters filters, List<Map<String, dynamic>> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CATEGORÍA',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildCategoryChip(
              label: 'Todas',
              isSelected: filters.categorySlug == null,
              onTap: () {
                ref.read(productFiltersProvider.notifier).setCategory(null);
              },
            ),
            ...categories.map((cat) => _buildCategoryChip(
                  label: cat['name'] as String,
                  isSelected: filters.categorySlug == cat['slug'],
                  onTap: () {
                    ref
                        .read(productFiltersProvider.notifier)
                        .setCategory(cat['slug'] as String);
                  },
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.neonCyan.withValues(alpha: 0.1) : AppColors.dark300,
          border: Border.all(
            color: isSelected ? AppColors.neonCyan : AppColors.glassBorder,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.neonCyan : AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSizes(ProductFilters filters, List<String> allSizes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'TALLA',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            if (filters.sizes.isNotEmpty)
              Text(
                ' (${filters.sizes.length})',
                style: TextStyle(color: AppColors.neonCyan, fontSize: 12),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allSizes.map((size) {
            final isSelected = filters.sizes.contains(size);
            return GestureDetector(
              onTap: () {
                ref.read(productFiltersProvider.notifier).toggleSize(size);
              },
              child: Container(
                width: 48,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.neonCyan.withValues(alpha: 0.1)
                      : AppColors.dark300,
                  border: Border.all(
                    color:
                        isSelected ? AppColors.neonCyan : AppColors.glassBorder,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  size,
                  style: TextStyle(
                    color:
                        isSelected ? AppColors.neonCyan : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColors(ProductFilters filters) {
    const colors = [
      {'value': 'negro', 'hex': Color(0xFF1a1a1a), 'label': 'Negro'},
      {'value': 'blanco', 'hex': Color(0xFFffffff), 'label': 'Blanco'},
      {'value': 'azul', 'hex': Color(0xFF1e3a5f), 'label': 'Azul'},
      {'value': 'gris', 'hex': Color(0xFF6b7280), 'label': 'Gris'},
      {'value': 'beige', 'hex': Color(0xFFd4c4a8), 'label': 'Beige'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COLOR',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((color) {
            final isSelected = filters.color == color['value'];
            return GestureDetector(
              onTap: () {
                ref.read(productFiltersProvider.notifier).setColor(
                      isSelected ? null : color['value'] as String,
                    );
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color['hex'] as Color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.neonCyan : AppColors.glassBorder,
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.neonCyan.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: 18,
                        color: color['value'] == 'blanco'
                            ? Colors.black
                            : Colors.white,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
