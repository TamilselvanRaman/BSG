import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_dialog.dart';
import '../../data/repositories/app_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '9876543210');
  final _passwordController = TextEditingController(text: 'admin123');
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final repo = ref.read(appRepositoryProvider);
    final success = await repo.login(_phoneController.text, _passwordController.text);
    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        context.go('/home');
      } else {
        AppDialog.showSnackBar(context, 'Invalid phone number or password', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brand mark
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAction,
                          borderRadius: AppSpacing.borderRadiusMd,
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Sign in to BSG', style: AppTypography.pageTitle),
                    const SizedBox(height: 6),
                    const Text(
                      'Manage lots, suppliers, customers, bills, stock and reports.',
                      style: AppTypography.bodySecondary,
                    ),
                    const SizedBox(height: 32),

                    // Inputs Card
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.cardPadding),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppSpacing.borderRadiusMd,
                        border: Border.all(color: AppColors.border, width: 1.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextField(
                            label: 'Mobile Number',
                            hint: 'Enter 10-digit number',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: AppColors.textMuted),
                            validator: AppValidators.phone,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: 'Password',
                            hint: 'Enter password',
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.textMuted),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                size: 20,
                                color: AppColors.textMuted,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            validator: (v) => AppValidators.required(v, 'Password is required'),
                            onSubmitted: (_) => _handleLogin(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    AppButton(
                      text: 'Sign In',
                      isLoading: _isLoading,
                      onPressed: _handleLogin,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Demo access: 9876543210 / admin123',
                        style: AppTypography.labelMuted.copyWith(color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

