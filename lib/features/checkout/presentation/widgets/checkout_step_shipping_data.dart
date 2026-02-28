import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/theme/app_colors.dart';
import '../providers/checkout_providers.dart';

/// Paso 1: Datos de envío
class CheckoutStepShippingData extends ConsumerStatefulWidget {
  final VoidCallback onContinue;

  const CheckoutStepShippingData({
    super.key,
    required this.onContinue,
  });

  @override
  ConsumerState<CheckoutStepShippingData> createState() =>
      _CheckoutStepShippingDataState();
}

class _CheckoutStepShippingDataState
    extends ConsumerState<CheckoutStepShippingData> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _nameController;
  late TextEditingController _streetController;
  late TextEditingController _postalCodeController;
  late TextEditingController _cityController;
  late TextEditingController _provinceController;
  String _selectedCountry = 'ES';
  String? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    final data = ref.read(checkoutDataProvider);
    // Pre-fill email from Supabase auth if not already set
    final authEmail = Supabase.instance.client.auth.currentUser?.email ?? '';
    _emailController = TextEditingController(
      text: data.email.isNotEmpty ? data.email : authEmail,
    );
    _phoneController = TextEditingController(text: data.phone);
    _nameController = TextEditingController(text: data.fullName);
    _streetController = TextEditingController(text: data.street);
    _postalCodeController = TextEditingController(text: data.postalCode);
    _cityController = TextEditingController(text: data.city);
    _provinceController = TextEditingController(text: data.province);
    _selectedCountry = data.country;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _streetController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    super.dispose();
  }

  /// Rellenar formulario con dirección guardada
  void _fillFromSavedAddress(SavedAddress address) {
    setState(() {
      _selectedAddressId = address.id;
      _nameController.text = address.fullName;
      _phoneController.text = address.phone ?? '';
      _streetController.text = address.street;
      _postalCodeController.text = address.postalCode;
      _cityController.text = address.city;
      _provinceController.text = address.province;
      _selectedCountry = address.country;
    });
  }

  void _saveAndContinue() {
    if (_formKey.currentState!.validate()) {
      ref.read(checkoutDataProvider.notifier).setShippingData(
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            fullName: _nameController.text.trim(),
            street: _streetController.text.trim(),
            postalCode: _postalCodeController.text.trim(),
            city: _cityController.text.trim(),
            province: _provinceController.text.trim(),
            country: _selectedCountry,
          );
      widget.onContinue();
    }
  }

  @override
  Widget build(BuildContext context) {
    final savedAddresses = ref.watch(savedAddressesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Direcciones guardadas ===
            savedAddresses.when(
              data: (addresses) {
                if (addresses.isEmpty) return const SizedBox.shrink();
                return _buildSavedAddressesSection(addresses);
              },
              loading: () => const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Center(
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.neonCyan,
                    ),
                  ),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // === Formulario de dirección ===
            _buildSectionCard(
              title: 'Datos de Envío',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _emailController,
                        label: 'Email *',
                        hint: 'tu@email.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requerido';
                          if (!v.contains('@')) return 'Email inválido';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _phoneController,
                        label: 'Teléfono *',
                        hint: '+34 600 000 000',
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Requerido' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _nameController,
                  label: 'Nombre Completo *',
                  hint: 'Juan Pérez',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _streetController,
                  label: 'Dirección *',
                  hint: 'Calle Principal, 123',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _postalCodeController,
                        label: 'CP *',
                        hint: '28001',
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        controller: _cityController,
                        label: 'Ciudad *',
                        hint: 'Madrid',
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Requerido' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _provinceController,
                        label: 'Provincia',
                        hint: 'Madrid',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdown(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAndContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonCyan,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textSubtle),
            filled: true,
            fillColor: AppColors.dark300,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.glassBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.glassBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.neonCyan),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.error),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'País *',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.dark300,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCountry,
              isExpanded: true,
              dropdownColor: AppColors.dark400,
              style: const TextStyle(color: AppColors.textPrimary),
              items: const [
                DropdownMenuItem(value: 'ES', child: Text('España')),
                DropdownMenuItem(value: 'FR', child: Text('Francia')),
                DropdownMenuItem(value: 'PT', child: Text('Portugal')),
                DropdownMenuItem(value: 'IT', child: Text('Italia')),
                DropdownMenuItem(value: 'DE', child: Text('Alemania')),
              ],
              onChanged: (value) {
                setState(() => _selectedCountry = value!);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSavedAddressesSection(List<SavedAddress> addresses) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _buildSectionCard(
        title: 'Mis Direcciones',
        children: [
          const Text(
            'Selecciona una dirección guardada o rellena el formulario manualmente',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 12),
          ...addresses.map((addr) {
            final isSelected = _selectedAddressId == addr.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => _fillFromSavedAddress(addr),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.neonCyan.withValues(alpha: 0.1)
                        : AppColors.dark300,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.neonCyan
                          : AppColors.glassBorder,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected
                            ? AppColors.neonCyan
                            : AppColors.textMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  addr.label,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.neonCyan
                                        : AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                if (addr.isDefault) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.neonCyan.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Predeterminada',
                                      style: TextStyle(
                                        color: AppColors.neonCyan,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${addr.fullName} · ${addr.street}',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${addr.postalCode} ${addr.city}, ${addr.province}',
                              style: const TextStyle(
                                color: AppColors.textSubtle,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedAddressId = null;
                _nameController.clear();
                _phoneController.clear();
                _streetController.clear();
                _postalCodeController.clear();
                _cityController.clear();
                _provinceController.clear();
                _selectedCountry = 'ES';
              });
            },
            icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
            label: const Text('Usar otra dirección'),
            style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
