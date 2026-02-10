import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../../config/constants/app_constants.dart';
import '../../config/theme/app_colors.dart';

/// Clave Hive para marcar si ya se mostró/subscribed el newsletter
const _kNewsletterShownKey = 'newsletter_popup_shown';
const _kNewsletterSubscribedKey = 'newsletter_subscribed';

/// Provider para saber si el popup debería mostrarse
final shouldShowNewsletterProvider = Provider<bool>((ref) {
  final box = Hive.box('user_preferences');
  return !(box.get(_kNewsletterShownKey, defaultValue: false) as bool);
});

/// Suscribir al newsletter vía API de FashionStore
/// (la API inserta en BD + envía email de bienvenida con código WELCOME10 via Resend)
Future<Map<String, dynamic>> subscribeToNewsletter(String email) async {
  final response = await http.post(
    Uri.parse('${AppConstants.fashionStoreBaseUrl}/api/newsletter/subscribe'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'source': 'flutter_app'}),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  } else {
    throw Exception('Error al suscribirse');
  }
}

/// Marcar que el popup ya se mostró
Future<void> markNewsletterShown() async {
  final box = Hive.box('user_preferences');
  await box.put(_kNewsletterShownKey, true);
}

/// Marcar que el usuario se suscribió
Future<void> markNewsletterSubscribed() async {
  final box = Hive.box('user_preferences');
  await box.put(_kNewsletterSubscribedKey, true);
  await box.put(_kNewsletterShownKey, true);
}

/// Muestra el bottom sheet de suscripción al newsletter
void showNewsletterPopup(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const _NewsletterBottomSheet(),
  );
}

class _NewsletterBottomSheet extends StatefulWidget {
  const _NewsletterBottomSheet();

  @override
  State<_NewsletterBottomSheet> createState() => _NewsletterBottomSheetState();
}

class _NewsletterBottomSheetState extends State<_NewsletterBottomSheet> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _success = false;
  String? _promoCode;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _subscribe() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Introduce un email válido');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await subscribeToNewsletter(email);
      await markNewsletterSubscribed();

      setState(() {
        _success = true;
        _promoCode = result['promo_code'] as String?;
      });
    } catch (e) {
      setState(() => _error = 'No se pudo completar la suscripción');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.dark500,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            if (_success) ...[
              // ═══ SUCCESS STATE ═══
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.green, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                '¡Bienvenido al club!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Recibirás nuestras novedades y ofertas exclusivas',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
                textAlign: TextAlign.center,
              ),
              if (_promoCode != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.neonCyan.withOpacity(0.15),
                        AppColors.neonFuchsia.withOpacity(0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.neonCyan.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Tu código de descuento:',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _promoCode!,
                        style: const TextStyle(
                          color: AppColors.neonCyan,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonCyan,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '¡Genial!',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
            ] else ...[
              // ═══ FORM STATE ═══
              // Icon
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradient.createShader(bounds),
                child: const Icon(Icons.email_outlined, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'Únete a nuestra newsletter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Recibe ofertas exclusivas, novedades y un 10% de descuento en tu primera compra',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Email input
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'tu@email.com',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.mail_outline, color: Colors.grey[500]),
                  filled: true,
                  fillColor: AppColors.dark400,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.neonCyan),
                  ),
                  errorText: _error,
                  errorStyle: const TextStyle(color: AppColors.neonFuchsia),
                ),
                onSubmitted: (_) => _subscribe(),
              ),
              const SizedBox(height: 16),

              // Subscribe button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _subscribe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonCyan,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: AppColors.neonCyan.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          'Suscribirme y obtener mi 10%',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),
              TextButton(
                onPressed: () async {
                  await markNewsletterShown();
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: Text(
                  'No, gracias',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
