import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/responsive/responsive_container.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../data/app_state.dart';
import '../../data/models/customer.dart';

class AddCustomerScreen extends ConsumerStatefulWidget {
  final Customer? initialCustomer; // Non-null when editing

  const AddCustomerScreen({super.key, this.initialCustomer});

  @override
  ConsumerState<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends ConsumerState<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _villageController;
  late TextEditingController _phoneController;
  late TextEditingController _openingBalController;
  late TextEditingController _notesController;

  CustomerType _customerType = CustomerType.buyer;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.initialCustomer;
    _nameController = TextEditingController(text: c?.name ?? '');
    _villageController = TextEditingController(text: c?.village ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _openingBalController = TextEditingController(
      text: c != null && c.openingBalance > 0 ? c.openingBalance.toStringAsFixed(0) : '',
    );
    _notesController = TextEditingController(text: c?.notes ?? '');
    if (c != null) {
      _customerType = c.customerType;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _villageController.dispose();
    _phoneController.dispose();
    _openingBalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveCustomer() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    final village = _villageController.text.trim();
    final phone = _phoneController.text.trim();
    final opening = double.tryParse(_openingBalController.text.trim()) ?? 0.0;
    final notes = _notesController.text.trim();

    // Check for accidental duplicate warning
    final existing = ref.read(customersProvider);
    final isDuplicate = existing.any((c) =>
        c.id != widget.initialCustomer?.id &&
        (c.phone == phone || c.name.toLowerCase() == name.toLowerCase()));

    if (isDuplicate && widget.initialCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Warning: A customer with this phone number or name already exists!'),
          backgroundColor: AppColors.pending,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    if (widget.initialCustomer != null) {
      final updated = widget.initialCustomer!.copyWith(
        name: name,
        village: village,
        phone: phone,
        customerType: _customerType,
        openingBalance: opening,
        notes: notes,
        updatedAt: DateTime.now(),
      );
      ref.read(appStateProvider.notifier).updateCustomer(updated);
    } else {
      final newCustomer = Customer(
        id: 'cust-${const Uuid().v4().substring(0, 8)}',
        name: name,
        village: village,
        phone: phone,
        customerType: _customerType,
        openingBalance: opening,
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      ref.read(appStateProvider.notifier).addCustomer(newCustomer);
    }

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.initialCustomer != null
              ? 'Customer details updated successfully!'
              : 'Customer added successfully!',
        ),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialCustomer != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Customer' : 'Add New Customer'),
      ),
      body: ResponsiveContainer(
        maxWidth: 760,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Basic Information', style: AppTypography.titleMedium),
                    const SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      label: 'Full Name *',
                      hint: 'e.g. Murugan Traders (P. Murugan)',
                      controller: _nameController,
                      prefixIcon: Icons.person_outline,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Please enter customer name' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      label: 'Village / Market Location *',
                      hint: 'e.g. Mecheri, Salem',
                      controller: _villageController,
                      prefixIcon: Icons.location_on_outlined,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Please enter village or location' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      label: 'Phone Number *',
                      hint: 'e.g. 98421 55670',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Please enter phone number';
                        if (val.trim().length < 8) return 'Please enter valid phone number';
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Business & Classification', style: AppTypography.titleMedium),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Customer Type',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<CustomerType>(
                      segments: const [
                        ButtonSegment(
                          value: CustomerType.buyer,
                          label: Text('Buyer'),
                          icon: Icon(Icons.shopping_bag_outlined),
                        ),
                        ButtonSegment(
                          value: CustomerType.seller,
                          label: Text('Seller'),
                          icon: Icon(Icons.agriculture_outlined),
                        ),
                        ButtonSegment(
                          value: CustomerType.both,
                          label: Text('Both'),
                          icon: Icon(Icons.sync_alt),
                        ),
                      ],
                      selected: {_customerType},
                      onSelectionChanged: (set) => setState(() => _customerType = set.first),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppColors.lightGreenSurface;
                          }
                          return AppColors.cardSurface;
                        }),
                        foregroundColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppColors.primaryGreen;
                          }
                          return AppColors.textSecondary;
                        }),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CustomTextField(
                      label: 'Opening Balance (₹)',
                      hint: '0',
                      controller: _openingBalController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.currency_rupee,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Any previous dues owed by buyer brought forward.',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CustomTextField(
                      label: 'Notes / Remarks',
                      hint: 'e.g. Regular buyer for country tomatoes',
                      controller: _notesController,
                      maxLines: 2,
                      prefixIcon: Icons.notes_outlined,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Cancel',
                      isOutlined: true,
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: isEditing ? 'Update Customer' : 'Save Customer',
                      isLoading: _isSaving,
                      onPressed: _saveCustomer,
                      icon: Icons.check,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    ),
  );
}
}
