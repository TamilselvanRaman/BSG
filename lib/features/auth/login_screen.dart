import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/localization/language_provider.dart';
import '../../core/localization/language_selector_button.dart';

enum StaffRole {
  admin(title: 'Mandi Admin / Proprietor', subtitle: 'Full financial & operational access'),
  clerk(title: 'Billing & Weighing Clerk', subtitle: 'Fast auction billing & entry access');

  final String title;
  final String subtitle;
  const StaffRole({required this.title, required this.subtitle});
}

class StaffUser {
  final String id;
  final String name;
  final String phone;
  final StaffRole role;

  const StaffUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
  });
}

class StaffUserNotifier extends Notifier<StaffUser?> {
  @override
  StaffUser? build() => const StaffUser(
        id: 'staff-admin',
        name: 'Ramanathan (Proprietor)',
        phone: '98421 00000',
        role: StaffRole.admin,
      );

  void setUser(StaffUser? user) {
    state = user;
  }
}

final currentStaffUserProvider = NotifierProvider<StaffUserNotifier, StaffUser?>(StaffUserNotifier.new);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController(text: '9842100000');
  final _pinCtrl = TextEditingController(text: '1234');
  StaffRole _selectedRole = StaffRole.admin;
  bool _obscurePin = true;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  void _performLogin({required StaffRole role, String? name}) {
    ref.read(currentStaffUserProvider.notifier).setUser(StaffUser(
      id: role == StaffRole.admin ? 'staff-admin' : 'staff-clerk',
      name: name ?? (role == StaffRole.admin ? 'Ramanathan (Proprietor)' : 'Karthik (Billing Clerk)'),
      phone: _phoneCtrl.text.trim(),
      role: role,
    ));

    try {
      context.go('/dashboard');
    } catch (_) {}
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged in as ${role.title}'),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top language toggle
                  const Align(
                    alignment: Alignment.topRight,
                    child: LanguageSelectorButton(),
                  ),
                  const SizedBox(height: 16),

                  // Brand Header Container
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.storefront_rounded, size: 40, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    ref.tr('bsgAgroMandi'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ref.tr('mandiStaffLogin'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Main Form Card
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ref.tr('selectRole'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Role selection
                          Row(
                            children: [
                              Expanded(
                                child: _buildRoleSelectorTile(
                                  role: StaffRole.admin,
                                  title: 'Proprietor',
                                  icon: Icons.admin_panel_settings_outlined,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildRoleSelectorTile(
                                  role: StaffRole.clerk,
                                  title: 'Billing Clerk',
                                  icon: Icons.receipt_long_outlined,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Mobile input
                          const Text(
                            'Staff Mobile Number',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: Color(0xFF64748B)),
                              hintText: 'Enter registered mobile',
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5)),
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? 'Enter mobile number' : null,
                          ),
                          const SizedBox(height: 14),

                          // Security PIN input
                          const Text(
                            '4-Digit Security PIN',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _pinCtrl,
                            keyboardType: TextInputType.number,
                            obscureText: _obscurePin,
                            maxLength: 4,
                            decoration: InputDecoration(
                              counterText: '',
                              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: Color(0xFF64748B)),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePin ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                                onPressed: () => setState(() => _obscurePin = !_obscurePin),
                              ),
                              hintText: '• • • •',
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5)),
                            ),
                            validator: (v) => (v == null || v.length < 4) ? 'Enter 4-digit PIN' : null,
                          ),
                          const SizedBox(height: 20),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E6B24),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _performLogin(role: _selectedRole);
                                }
                              },
                              child: const Text('Login to Mandi Terminal', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Quick 1-Tap Demo Logins Bar (Ensures seamless testing for everyone)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreenSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.bolt_rounded, color: AppColors.primaryGreen, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                ref.tr('quickDemoLogin'),
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primaryGreenDark),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primaryGreenDark,
                                  side: const BorderSide(color: AppColors.primaryGreen),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                onPressed: () => _performLogin(role: StaffRole.admin, name: 'Admin Ramanathan'),
                                child: const Text('Admin', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF2563EB),
                                  side: const BorderSide(color: Color(0xFF2563EB)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                onPressed: () => _performLogin(role: StaffRole.clerk, name: 'Clerk Karthik'),
                                child: const Text('Weighing Clerk', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelectorTile({
    required StaffRole role,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;
    return InkWell(
      onTap: () => setState(() => _selectedRole = role),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightGreenSurface : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : const Color(0xFFE2E8F0),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primaryGreen : const Color(0xFF64748B), size: 22),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 12.5,
                color: isSelected ? AppColors.primaryGreenDark : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
