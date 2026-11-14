import '../../core/theme/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_dialog.dart';
import '../../data/repositories/app_repository.dart';

class AddSupplierDialog extends ConsumerStatefulWidget {
  const AddSupplierDialog({super.key});

  @override
  ConsumerState<AddSupplierDialog> createState() => _AddSupplierDialogState();
}

class _AddSupplierDialogState extends ConsumerState<AddSupplierDialog> {
  AppThemeColors get theme => context.appTheme;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _openingBalanceController = TextEditingController(text: '0');
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _openingBalanceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final opening = double.tryParse(_openingBalanceController.text.trim()) ?? 0.0;
    try {
      await ref.read(appRepositoryProvider).addSupplier(
        name: _nameController.text,
        phone: _phoneController.text,
        city: _cityController.text.isNotEmpty ? _cityController.text : null,
        openingBalance: opening,
      );
      if (mounted) {
        Navigator.pop(context);
        AppDialog.showSnackBar(context, 'Supplier created successfully');
      }
    } catch (e) {
      if (mounted) {
        AppDialog.showSnackBar(context, 'Failed to create supplier: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Dialog(
      backgroundColor: theme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusLg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('New Supplier', style: AppTypography.cardTitle),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Supplier Name *',
                  hint: 'e.g. Ramesh Agro Farms',
                  controller: _nameController,
                  validator: (v) => AppValidators.required(v, 'Supplier name is required'),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Phone Number *',
                  hint: '10-digit mobile number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: AppValidators.phone,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'City / Mandi Area',
                  hint: 'e.g. Coimbatore',
                  controller: _cityController,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Opening Balance (₹)',
                  hint: '0',
                  controller: _openingBalanceController,
                  keyboardType: TextInputType.number,
                  prefixText: '₹ ',
                  validator: AppValidators.nonNegativeNumber,
                ),
                const SizedBox(height: 20),
                AppButton(
                  text: 'Save Supplier',
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddCustomerDialog extends ConsumerStatefulWidget {
  const AddCustomerDialog({super.key});

  @override
  ConsumerState<AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends ConsumerState<AddCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _openingBalanceController = TextEditingController(text: '0');
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _openingBalanceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final opening = double.tryParse(_openingBalanceController.text.trim()) ?? 0.0;
    try {
      await ref.read(appRepositoryProvider).addCustomer(
        name: _nameController.text,
        phone: _phoneController.text,
        city: _cityController.text.isNotEmpty ? _cityController.text : null,
        openingBalance: opening,
      );
      if (mounted) {
        Navigator.pop(context);
        AppDialog.showSnackBar(context, 'Customer created successfully');
      }
    } catch (e) {
      if (mounted) {
        AppDialog.showSnackBar(context, 'Failed to create customer: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Dialog(
      backgroundColor: theme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusLg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('New Customer', style: AppTypography.cardTitle),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Customer Name *',
                  hint: 'e.g. Balaji Mart / Kumar',
                  controller: _nameController,
                  validator: (v) => AppValidators.required(v, 'Customer name is required'),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Phone Number *',
                  hint: '10-digit mobile number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: AppValidators.phone,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'City / Market Location',
                  hint: 'e.g. Chennai',
                  controller: _cityController,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Opening Outstanding (₹)',
                  hint: '0',
                  controller: _openingBalanceController,
                  keyboardType: TextInputType.number,
                  prefixText: '₹ ',
                  validator: AppValidators.nonNegativeNumber,
                ),
                const SizedBox(height: 20),
                AppButton(
                  text: 'Save Customer',
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddTransporterDialog extends ConsumerStatefulWidget {
  const AddTransporterDialog({super.key});

  @override
  ConsumerState<AddTransporterDialog> createState() => _AddTransporterDialogState();
}

class _AddTransporterDialogState extends ConsumerState<AddTransporterDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _vehicleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(appRepositoryProvider).addTransporter(
        name: _nameController.text,
        phone: _phoneController.text,
        vehicleNumber: _vehicleController.text.isNotEmpty ? _vehicleController.text : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );
      if (mounted) {
        Navigator.pop(context);
        AppDialog.showSnackBar(context, 'Transporter created successfully');
      }
    } catch (e) {
      if (mounted) {
        AppDialog.showSnackBar(context, 'Failed to create transporter: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Dialog(
      backgroundColor: theme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusLg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('New Transporter', style: AppTypography.cardTitle),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Transporter Name *',
                  hint: 'e.g. Vignesh Logistics',
                  controller: _nameController,
                  validator: (v) => AppValidators.required(v, 'Transporter name is required'),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Phone Number *',
                  hint: '10-digit mobile number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: AppValidators.phone,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Vehicle Number',
                  hint: 'e.g. TN 38 AZ 4492',
                  controller: _vehicleController,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Notes / Vehicle Type',
                  hint: 'e.g. 14ft Open Lorry, Driver Murugan',
                  controller: _notesController,
                ),
                const SizedBox(height: 20),
                AppButton(
                  text: 'Save Transporter',
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

