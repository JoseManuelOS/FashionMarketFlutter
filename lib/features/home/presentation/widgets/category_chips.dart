import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_colors.dart';
import '../providers/home_providers.dart';

/// Chips de categorías para navegación rápida
class CategoryChips extends ConsumerWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(homeCategoriesProvider);

    return SizedBox(
      height: 44,
      child: categoriesAsync.when(
        data: (categories) {
          // Añadir "Todos" al inicio
          final allCategories = [
            {'name': 'Todos', 'slug': null},
            ...categories,
          ];

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: allCategories.length,
            itemBuilder: (context, index) {
              final category = allCategories[index];
              final isFirst = index == 0;

              return Padding(
                padding: EdgeInsets.only(right: index < allCategories.length - 1 ? 8 : 0),
                child: _CategoryChip(
                  label: category['name'] as String,
                  isSelected: isFirst, // Por defecto "Todos" seleccionado
                  onTap: () {
                    final slug = category['slug'] as String?;
                    if (slug != null) {
                      context.push('/categoria/$slug');
                    } else {
                      context.push('/productos');
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(right: 8),
              child: Container(
                width: 80,
                decoration: BoxDecoration(
                  color: AppColors.dark400,
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            );
          },
        ),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neonCyan : AppColors.glassLight,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? AppColors.neonCyan : AppColors.glassBorder,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.neonCyan.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
