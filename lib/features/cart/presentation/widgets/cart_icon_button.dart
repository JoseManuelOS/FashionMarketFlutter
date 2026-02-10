import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme/app_colors.dart';
import '../../presentation/providers/cart_providers.dart';
import '../../presentation/widgets/cart_slide_over.dart';

/// Botón del carrito con badge de cantidad
/// Para usar en AppBar o en cualquier lugar
class CartIconButton extends ConsumerWidget {
  final Color? iconColor;
  final double iconSize;
  final bool showSlideOver;

  const CartIconButton({
    super.key,
    this.iconColor,
    this.iconSize = 24,
    this.showSlideOver = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemCount = ref.watch(cartItemCountProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: () {
            if (showSlideOver) {
              CartSlideOver.show(context);
            }
          },
          icon: Icon(
            Icons.shopping_bag_outlined,
            color: iconColor ?? AppColors.textPrimary,
            size: iconSize,
          ),
        ),
        if (itemCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonCyan.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  itemCount > 99 ? '99+' : '$itemCount',
                  style: TextStyle(
                    color: AppColors.textOnPrimary,
                    fontSize: itemCount > 99 ? 8 : 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Floating action button del carrito
class CartFAB extends ConsumerWidget {
  const CartFAB({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemCount = ref.watch(cartItemCountProvider);
    final total = ref.watch(cartTotalProvider);

    if (itemCount == 0) return const SizedBox.shrink();

    return FloatingActionButton.extended(
      onPressed: () => CartSlideOver.show(context),
      backgroundColor: AppColors.neonCyan,
      foregroundColor: AppColors.textOnPrimary,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.shopping_bag),
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.neonFuchsia,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$itemCount',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      label: Text(
        '€${total.toStringAsFixed(2)}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
