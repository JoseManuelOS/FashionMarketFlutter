import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';

class ProductFeatures extends StatelessWidget {
  const ProductFeatures({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildFeatureCard(
            icon: Icons.local_shipping_outlined,
            iconColor: AppColors.neonCyan,
            iconBgColor: AppColors.neonCyan.withValues(alpha: 0.1),
            text: 'Envío gratis +50€',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildFeatureCard(
            icon: Icons.refresh_rounded,
            iconColor: AppColors.neonFuchsia,
            iconBgColor: AppColors.neonFuchsia.withValues(alpha: 0.1),
            text: '30 días devolución',
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
