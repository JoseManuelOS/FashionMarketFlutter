import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/router/app_router.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_drawer.dart';

/// Pantalla de gestión de usuarios/clientes
/// Equivalente a /admin/usuarios en FashionStore
class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(adminSessionProvider);
    final usersAsync = ref.watch(adminUsersProvider);

    if (admin == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.adminLogin);
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      drawer: AdminDrawer(currentRoute: AppRoutes.adminUsers),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D14),
        title: const Text(
          'Usuarios',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o email...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF12121A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),

          // Users list
          Expanded(
            child: usersAsync.when(
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
                      'Error al cargar usuarios',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    TextButton(
                      onPressed: () => ref.invalidate(adminUsersProvider),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
              data: (users) {
                // Filtrar por búsqueda
                final filteredUsers = _searchQuery.isEmpty
                    ? users
                    : users.where((u) {
                        final name = (u['full_name'] ?? '').toString().toLowerCase();
                        final email = (u['email'] ?? '').toString().toLowerCase();
                        return name.contains(_searchQuery) || email.contains(_searchQuery);
                      }).toList();

                return _buildContent(filteredUsers);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<Map<String, dynamic>> users) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A24),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.people_outline,
                color: Colors.grey[600],
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No hay usuarios registrados' : 'Sin resultados',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.neonCyan,
      backgroundColor: const Color(0xFF12121A),
      onRefresh: () async {
        ref.invalidate(adminUsersProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final name = user['full_name'] as String? ?? 'Sin nombre';
    final email = user['email'] as String? ?? '';
    final phone = user['phone'] as String?;
    final createdAt = user['created_at'] as String?;
    final ordersCount = user['orders_count'] ?? 0;
    final totalSpent = (user['total_spent'] as num?)?.toDouble() ?? 0.0;

    // Obtener inicial para avatar
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    // Formatear fecha
    String memberSince = '';
    if (createdAt != null) {
      try {
        final date = DateTime.parse(createdAt);
        memberSince = DateFormat("d MMM yyyy", 'es_ES').format(date);
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.neonCyan, AppColors.neonPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Orders badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neonCyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$ordersCount pedidos',
                  style: const TextStyle(
                    color: AppColors.neonCyan,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 8),

          // Stats row
          Row(
            children: [
              _buildUserStat(
                icon: Icons.phone_outlined,
                value: phone ?? 'Sin teléfono',
              ),
              const SizedBox(width: 16),
              _buildUserStat(
                icon: Icons.euro_outlined,
                value: '€${totalSpent.toStringAsFixed(2)} gastado',
              ),
              if (memberSince.isNotEmpty) ...[
                const SizedBox(width: 16),
                _buildUserStat(
                  icon: Icons.calendar_today_outlined,
                  value: memberSince,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserStat({required IconData icon, required String value}) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
