import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/router/app_router.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_drawer.dart';

/// Pantalla de gestión de códigos de descuento
/// Equivalente a /admin/codigos en FashionStore
class AdminDiscountCodesScreen extends ConsumerStatefulWidget {
  const AdminDiscountCodesScreen({super.key});

  @override
  ConsumerState<AdminDiscountCodesScreen> createState() => _AdminDiscountCodesScreenState();
}

class _AdminDiscountCodesScreenState extends ConsumerState<AdminDiscountCodesScreen> {
  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(adminSessionProvider);
    final codesAsync = ref.watch(adminDiscountCodesProvider);

    if (admin == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.home);
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      drawer: AdminDrawer(currentRoute: AppRoutes.adminDiscountCodes),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D14),
        title: const Text(
          'Códigos Promocionales',
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
            onPressed: () => _showCreateCodeDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.neonCyan,
        backgroundColor: const Color(0xFF12121A),
        onRefresh: () async {
          ref.invalidate(adminDiscountCodesProvider);
        },
        child: codesAsync.when(
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
                  'Error al cargar códigos',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                TextButton(
                  onPressed: () => ref.invalidate(adminDiscountCodesProvider),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
          data: (codes) => _buildContent(codes),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateCodeDialog(context),
        backgroundColor: AppColors.neonCyan,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          'Nuevo Código',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildContent(List<Map<String, dynamic>> codes) {
    // Calcular estadísticas
    final totalCodes = codes.length;
    final activeCodes = codes.where((c) => c['active'] == true).length;
    final inactiveCodes = totalCodes - activeCodes;
    final totalUses = codes.fold<int>(0, (sum, c) => sum + ((c['times_used'] as int?) ?? 0));

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          _buildStatsRow(totalCodes, activeCodes, inactiveCodes, totalUses),
          const SizedBox(height: 24),

          // Lista de códigos
          if (codes.isEmpty)
            _buildEmptyState()
          else
            _buildCodesList(codes),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int total, int active, int inactive, int uses) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            value: '$total',
            label: 'Total',
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            value: '$active',
            label: 'Activos',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            value: '$inactive',
            label: 'Inactivos',
            color: Colors.amber,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            value: '$uses',
            label: 'Usos',
            color: AppColors.neonPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
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
              Icons.discount_outlined,
              color: Colors.grey[600],
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay códigos promocionales',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer código de descuento',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCodesList(List<Map<String, dynamic>> codes) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: codes.length,
        separatorBuilder: (_, __) => Divider(
          color: Colors.white.withValues(alpha: 0.05),
          height: 1,
        ),
        itemBuilder: (context, index) {
          final code = codes[index];
          return _buildCodeItem(code);
        },
      ),
    );
  }

  Widget _buildCodeItem(Map<String, dynamic> code) {
    final isActive = code['active'] == true;
    final discountType = code['discount_type'] as String? ?? 'percentage';
    final discountValue = (code['discount_value'] as num?)?.toDouble() ?? 0;
    final timesUsed = code['times_used'] ?? 0;
    final usageLimit = code['usage_limit'];
    final expiresAt = code['expires_at'];
    
    // Formatear descuento
    final discountText = discountType == 'percentage'
        ? '${discountValue.toInt()}%'
        : '€${discountValue.toStringAsFixed(2)}';

    // Verificar si está expirado
    bool isExpired = false;
    if (expiresAt != null) {
      try {
        isExpired = DateTime.parse(expiresAt).isBefore(DateTime.now());
      } catch (_) {}
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive && !isExpired
              ? AppColors.neonCyan.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.discount_outlined,
          color: isActive && !isExpired ? AppColors.neonCyan : Colors.grey,
        ),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              code['code'] ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.neonFuchsia.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              discountText,
              style: const TextStyle(
                color: AppColors.neonFuchsia,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (!isActive || isExpired) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isExpired ? 'Expirado' : 'Inactivo',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'Usado $timesUsed${usageLimit != null ? '/$usageLimit' : ''} veces · ${code['description'] ?? 'Sin descripción'}',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, color: Colors.grey[500]),
        color: const Color(0xFF1A1A24),
        onSelected: (value) => _handleCodeAction(value, code),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'copy',
            child: Row(
              children: [
                Icon(Icons.copy, color: Colors.grey[400], size: 18),
                const SizedBox(width: 12),
                const Text('Copiar código', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
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
    );
  }

  void _handleCodeAction(String action, Map<String, dynamic> code) async {
    switch (action) {
      case 'copy':
        await Clipboard.setData(ClipboardData(text: code['code'] ?? ''));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Código "${code['code']}" copiado'),
              backgroundColor: AppColors.neonCyan,
            ),
          );
        }
        break;
      case 'toggle':
        await _toggleCodeStatus(code);
        break;
      case 'delete':
        _confirmDeleteCode(code);
        break;
    }
  }

  Future<void> _toggleCodeStatus(Map<String, dynamic> code) async {
    final success = await ref.read(adminDiscountCodesProvider.notifier).toggleCode(
      code['id'],
      code['active'] != true,
    );
    
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            code['active'] == true ? 'Código desactivado' : 'Código activado',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _confirmDeleteCode(Map<String, dynamic> code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF12121A),
        title: const Text(
          '¿Eliminar código?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Se eliminará el código "${code['code']}" permanentemente.',
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
              await _deleteCode(code);
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.red[400])),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCode(Map<String, dynamic> code) async {
    final success = await ref.read(adminDiscountCodesProvider.notifier).deleteCode(code['id']);
    
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código eliminado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showCreateCodeDialog(BuildContext context) {
    final codeController = TextEditingController();
    final descController = TextEditingController();
    final valueController = TextEditingController();
    final minPurchaseController = TextEditingController(text: '0');
    final usageLimitController = TextEditingController();
    String discountType = 'percentage';
    bool singleUse = false;
    DateTime? expiresAt;

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
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nuevo Código',
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

                // Código
                _buildTextField(
                  controller: codeController,
                  label: 'Código',
                  hint: 'Ej: VERANO20',
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 16),

                // Descripción
                _buildTextField(
                  controller: descController,
                  label: 'Descripción (opcional)',
                  hint: 'Ej: Descuento de verano',
                ),
                const SizedBox(height: 16),

                // Tipo de descuento
                const Text(
                  'Tipo de descuento',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildTypeChip(
                        label: 'Porcentaje',
                        isSelected: discountType == 'percentage',
                        onTap: () => setState(() => discountType = 'percentage'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTypeChip(
                        label: 'Cantidad fija',
                        isSelected: discountType == 'fixed',
                        onTap: () => setState(() => discountType = 'fixed'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Valor del descuento
                _buildTextField(
                  controller: valueController,
                  label: discountType == 'percentage' ? 'Porcentaje (%)' : 'Cantidad (€)',
                  hint: discountType == 'percentage' ? 'Ej: 20' : 'Ej: 10.00',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Compra mínima
                _buildTextField(
                  controller: minPurchaseController,
                  label: 'Compra mínima (€)',
                  hint: '0 para sin mínimo',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Límite de usos
                _buildTextField(
                  controller: usageLimitController,
                  label: 'Límite de usos (opcional)',
                  hint: 'Vacío para ilimitado',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Uso único por cliente
                SwitchListTile(
                  value: singleUse,
                  onChanged: (v) => setState(() => singleUse = v),
                  title: const Text(
                    'Uso único por cliente',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  activeColor: AppColors.neonCyan,
                  contentPadding: EdgeInsets.zero,
                ),

                // Fecha de expiración
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Fecha de expiración',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  subtitle: Text(
                    expiresAt != null
                        ? DateFormat('dd/MM/yyyy').format(expiresAt!)
                        : 'Sin fecha límite',
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (expiresAt != null)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () => setState(() => expiresAt = null),
                        ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today, color: AppColors.neonCyan),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 30)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() => expiresAt = date);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Botón crear
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _createCode(
                      context,
                      code: codeController.text.toUpperCase(),
                      description: descController.text,
                      discountType: discountType,
                      discountValue: double.tryParse(valueController.text) ?? 0,
                      minPurchase: double.tryParse(minPurchaseController.text) ?? 0,
                      usageLimit: int.tryParse(usageLimitController.text),
                      singleUse: singleUse,
                      expiresAt: expiresAt,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonCyan,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Crear Código',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
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
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
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

  Widget _buildTypeChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neonCyan.withValues(alpha: 0.1) : const Color(0xFF1A1A24),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.neonCyan : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.neonCyan : Colors.grey[400],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createCode(
    BuildContext context, {
    required String code,
    required String description,
    required String discountType,
    required double discountValue,
    required double minPurchase,
    int? usageLimit,
    required bool singleUse,
    DateTime? expiresAt,
  }) async {
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El código es obligatorio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (discountValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El valor del descuento debe ser mayor a 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await ref.read(adminDiscountCodesProvider.notifier).createCode(
      code: code,
      description: description,
      discountType: discountType,
      discountValue: discountValue,
      minPurchase: minPurchase,
      usageLimit: usageLimit,
      singleUse: singleUse,
      expiresAt: expiresAt,
    );

    if (mounted) {
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Código "$code" creado' : 'Error al crear código'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}
