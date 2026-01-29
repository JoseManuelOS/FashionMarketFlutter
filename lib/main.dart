import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/router/app_router.dart';
import 'config/theme/app_theme.dart';
import 'shared/services/local_storage_service.dart';
import 'shared/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar servicios
  await SupabaseService.initialize();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Override del provider de SharedPreferences con la instancia real
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const FashionMarketApp(),
    ),
  );
}

/// Aplicación principal de Fashion Market
class FashionMarketApp extends ConsumerWidget {
  const FashionMarketApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Fashion Market',
      debugShowCheckedModeBanner: false,
      
      // Temas
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // Router
      routerConfig: AppRouter.router,
    );
  }
}
