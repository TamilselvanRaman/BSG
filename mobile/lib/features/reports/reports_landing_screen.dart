import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_extension.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/customer_picker_sheet.dart';
import '../../data/models/partner_models.dart';
import '../../data/repositories/app_repository.dart';
import '../catalogue/widgets/product_crop_selector_sheet.dart';
import 'widgets/report_category_card.dart';

class ReportsLandingScreen extends ConsumerStatefulWidget {
  const ReportsLandingScreen({super.key});

  @override
  ConsumerState<ReportsLandingScreen> createState() => _ReportsLandingScreenState();
}

class _ReportsLandingScreenState extends ConsumerState<ReportsLandingScreen> {
  // Only one category expanded at a time (null = none)
  int? _expandedCategoryIndex = 0; // Daily Summary expanded by default for quick access
  String _selectedFilter = 'All';

  void _handleCategoryToggle(int index) {
    setState(() {
      if (_expandedCategoryIndex == index) {
        _expandedCategoryIndex = null; // collapse if tapped again
      } else {
        _expandedCategoryIndex = index; // expand only this one
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final repo = ref.watch(appRepositoryProvider);

    // Live corporate executive metrics
    final gp = repo.getGrossProfitReport();
    final daily = repo.getDailySummaryReport(DateTime.now());
    final activeLots = repo.getLots().where((l) => l.remainingQuantity > 0).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reports & Analytics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: theme.text,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Executive financial statements & operational ledgers',
              style: TextStyle(
                fontSize: 11,
                color: theme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE2E8F0)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        children: [
          // -------------------------------------------------------------------
          // 1. Executive Performance KPI Bar (Corporate Standard)
          // -------------------------------------------------------------------
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'MANDI TRADING OVERVIEW',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      AppFormatters.date(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildKpiItem('Turnover', AppFormatters.currency(daily.salesAmount, showDecimals: false), const Color(0xFF0F172A)),
                    _buildDivider(),
                    _buildKpiItem('Collections', AppFormatters.currency(daily.totalReceived, showDecimals: false), const Color(0xFF059669)),
                    _buildDivider(),
                    _buildKpiItem('Margin', '${gp.profitPercentage.toStringAsFixed(1)}%', const Color(0xFF2563EB)),
                    _buildDivider(),
                    _buildKpiItem('Active Lots', '$activeLots Lots', const Color(0xFF7C3AED)),
                  ],
                ),
              ],
            ),
          ),

          // -------------------------------------------------------------------
          // 2. Filter Pills
          // -------------------------------------------------------------------
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterPill('All', '7'),
                const SizedBox(width: 8),
                _buildFilterPill('Financial', '3'),
                const SizedBox(width: 8),
                _buildFilterPill('Inventory', '2'),
                const SizedBox(width: 8),
                _buildFilterPill('Compliance', '1'),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // -------------------------------------------------------------------
          // 3. Reports List (Corporate Redesigned Cards)
          // -------------------------------------------------------------------

          // 1. Daily Summary
          if (_selectedFilter == 'All' || _selectedFilter == 'Financial')
            ReportCategoryCard(
              title: 'Daily Summary',
              subtitle: 'Cash, bills, coolie, transportation & vouchers',
              icon: Icons.calendar_today_rounded,
              accentColor: const Color(0xFF059669),
              badgeText: 'Executive',
              isExpanded: _expandedCategoryIndex == 0,
              onToggle: () => _handleCategoryToggle(0),
              submenus: [
                SubmenuOption(
                  title: 'Daily Summary',
                  subtitle: 'Executive overview & transaction vouchers',
                  icon: Icons.dashboard_outlined,
                  onTap: () => context.push('/reports/daily-summary'),
                ),
              ],
            ),

          // 2. Gross Profit
          if (_selectedFilter == 'All' || _selectedFilter == 'Financial')
            ReportCategoryCard(
              title: 'Gross Profit',
              subtitle: 'Purchase cost vs sales margin analysis',
              icon: Icons.auto_graph_rounded,
              accentColor: const Color(0xFF2563EB),
              badgeText: '${gp.profitPercentage.toStringAsFixed(1)}% ROI',
              isExpanded: _expandedCategoryIndex == 1,
              onToggle: () => _handleCategoryToggle(1),
              submenus: [
                SubmenuOption(
                  title: 'Gross Profit',
                  subtitle: 'Product-wise & transaction profit margins',
                  icon: Icons.percent_rounded,
                  onTap: () => context.push('/reports/gross-profit'),
                ),
              ],
            ),

          // 3. Stock Report
          if (_selectedFilter == 'All' || _selectedFilter == 'Inventory')
            ReportCategoryCard(
              title: 'Stock Report',
              subtitle: 'Warehouse inventory, inward arrivals & closing stock',
              icon: Icons.inventory_2_outlined,
              accentColor: const Color(0xFF0D9488),
              badgeText: '$activeLots Lots In Stock',
              isExpanded: _expandedCategoryIndex == 2,
              onToggle: () => _handleCategoryToggle(2),
              submenus: [
                SubmenuOption(
                  title: 'Stock Summary',
                  subtitle: 'Total inward vs outward physical stock',
                  icon: Icons.warehouse_outlined,
                  onTap: () => context.push('/reports/stock?tab=0'),
                ),
                SubmenuOption(
                  title: 'Daily Stock Summary',
                  subtitle: 'Opening + Purchases - Sales reconciliation',
                  icon: Icons.assignment_outlined,
                  onTap: () => context.push('/reports/stock?tab=1'),
                ),
                SubmenuOption(
                  title: 'Product-wise Stock',
                  subtitle: 'Commodity stock valuation and remaining lots',
                  icon: Icons.format_list_bulleted_rounded,
                  onTap: () => context.push('/reports/stock?tab=0'),
                ),
              ],
            ),

          // 4. Sales Report
          if (_selectedFilter == 'All' || _selectedFilter == 'Financial')
            ReportCategoryCard(
              title: 'Sales Report',
              subtitle: 'Turnover, buyer ledgers, crop & bill details',
              icon: Icons.trending_up_rounded,
              accentColor: const Color(0xFF16A34A),
              badgeText: '6 Views',
              isExpanded: _expandedCategoryIndex == 3,
              onToggle: () => _handleCategoryToggle(3),
              submenus: [
                SubmenuOption(
                  title: 'Sales Summary',
                  subtitle: 'Aggregate sales volume and collections',
                  icon: Icons.bar_chart_rounded,
                  onTap: () => context.push('/reports/sales?tab=0'),
                ),
                SubmenuOption(
                  title: 'By Buyer',
                  subtitle: 'Select buyer to view complete sales statement & bills',
                  icon: Icons.people_outline_rounded,
                  onTap: () async {
                    final chosen = await CustomerPickerSheet.show(context, allowCounterSale: false);
                    if (!context.mounted) return;
                    if (chosen is Customer) {
                      context.push('/reports/sales?tab=1&buyerId=${chosen.id}');
                    } else {
                      context.push('/reports/sales?tab=1');
                    }
                  },
                ),
                SubmenuOption(
                  title: 'By Crop',
                  subtitle: 'Select commodity to filter sales volume & revenue',
                  icon: Icons.agriculture_outlined,
                  onTap: () async {
                    final chosen = await ProductCropSelectorSheet.show(context, allowMultiple: false);
                    if (!context.mounted) return;
                    if (chosen != null && chosen.isNotEmpty) {
                      context.push('/reports/sales?tab=2&crop=${Uri.encodeComponent(chosen.first.name)}');
                    } else {
                      context.push('/reports/sales?tab=2');
                    }
                  },
                ),
                SubmenuOption(
                  title: 'By Product',
                  subtitle: 'Grade-wise quantity and average selling rates',
                  icon: Icons.category_outlined,
                  onTap: () async {
                    final chosen = await ProductCropSelectorSheet.show(context, allowMultiple: false);
                    if (!context.mounted) return;
                    if (chosen != null && chosen.isNotEmpty) {
                      context.push('/reports/sales?tab=2&crop=${Uri.encodeComponent(chosen.first.name)}');
                    } else {
                      context.push('/reports/sales?tab=2');
                    }
                  },
                ),
                SubmenuOption(
                  title: 'By Date',
                  subtitle: 'Daily cash and credit invoicing timeline',
                  icon: Icons.calendar_month_outlined,
                  onTap: () => context.push('/reports/sales?tab=3'),
                ),
                SubmenuOption(
                  title: 'Sales Bill Details',
                  subtitle: 'Complete bill register with drill-down',
                  icon: Icons.receipt_long_outlined,
                  onTap: () => context.push('/reports/sales?tab=4'),
                ),
                SubmenuOption(
                  title: 'Custom Sales Report',
                  subtitle: 'Multi-filter date range and payment type query',
                  icon: Icons.tune_rounded,
                  onTap: () => context.push('/reports/sales?tab=5'),
                ),
              ],
            ),

          // 5. Purchase Reports
          if (_selectedFilter == 'All' || _selectedFilter == 'Inventory')
            ReportCategoryCard(
              title: 'Purchase Reports',
              subtitle: 'Inward lot arrivals, seller payables & procurement',
              icon: Icons.shopping_bag_outlined,
              accentColor: const Color(0xFF7C3AED),
              badgeText: '5 Views',
              isExpanded: _expandedCategoryIndex == 4,
              onToggle: () => _handleCategoryToggle(4),
              submenus: [
                SubmenuOption(
                  title: 'Purchase Summary',
                  subtitle: 'Procurement turnover and outstanding payables',
                  icon: Icons.summarize_outlined,
                  onTap: () => context.push('/reports/purchase?tab=0'),
                ),
                SubmenuOption(
                  title: 'By Seller',
                  subtitle: 'Supplier & farmer inward lot ledger breakdown',
                  icon: Icons.person_outline_rounded,
                  onTap: () => context.push('/reports/purchase?tab=1'),
                ),
                SubmenuOption(
                  title: 'By Product',
                  subtitle: 'Commodity procurement volume and cost rates',
                  icon: Icons.grid_view_rounded,
                  onTap: () => context.push('/reports/purchase?tab=2'),
                ),
                SubmenuOption(
                  title: 'By Date',
                  subtitle: 'Daily arrival log and inward valuations',
                  icon: Icons.date_range_outlined,
                  onTap: () => context.push('/reports/purchase?tab=3'),
                ),
                SubmenuOption(
                  title: 'Purchase Bill Details',
                  subtitle: 'Lot entry records with freight & labour details',
                  icon: Icons.receipt_outlined,
                  onTap: () => context.push('/reports/purchase?tab=4'),
                ),
                SubmenuOption(
                  title: 'Custom Purchase Report',
                  subtitle: 'Custom supplier, product and date range audit',
                  icon: Icons.filter_alt_outlined,
                  onTap: () => context.push('/reports/purchase?tab=5'),
                ),
              ],
            ),

          // 6. RMC Reports
          if (_selectedFilter == 'All' || _selectedFilter == 'Compliance')
            ReportCategoryCard(
              title: 'RMC Reports',
              subtitle: 'Regulated Market Committee cess & statutory mandi fees',
              icon: Icons.account_balance_outlined,
              accentColor: const Color(0xFFD97706),
              badgeText: '1.0% Cess',
              isExpanded: _expandedCategoryIndex == 5,
              onToggle: () => _handleCategoryToggle(5),
              submenus: [
                SubmenuOption(
                  title: 'RMC Summary',
                  subtitle: 'Statutory 1.0% mandi fee liability summary',
                  icon: Icons.pie_chart_outline_rounded,
                  onTap: () => context.push('/reports/rmc?tab=0'),
                ),
                SubmenuOption(
                  title: 'RMC Sales Report',
                  subtitle: 'Eligible produce turnover and cess assessment',
                  icon: Icons.receipt_long_outlined,
                  onTap: () => context.push('/reports/rmc?tab=1'),
                ),
                SubmenuOption(
                  title: 'RMC Transaction History',
                  subtitle: 'Chronological bill-wise market cess ledger',
                  icon: Icons.history_rounded,
                  onTap: () => context.push('/reports/rmc?tab=2'),
                ),
                SubmenuOption(
                  title: 'Date-wise RMC Report',
                  subtitle: 'Daily mandi turnover and committee fee log',
                  icon: Icons.event_note_outlined,
                  onTap: () => context.push('/reports/rmc?tab=3'),
                ),
                SubmenuOption(
                  title: 'RMC Details',
                  subtitle: 'Complete statutory calculation assessment',
                  icon: Icons.description_outlined,
                  onTap: () => context.push('/reports/rmc?tab=4'),
                ),
              ],
            ),

          // 7. Daily Tally
          if (_selectedFilter == 'All' || _selectedFilter == 'Financial')
            ReportCategoryCard(
              title: 'Daily Tally',
              subtitle: 'Daily cash register, opening balance, receipts, expenses & cash reconciliation.',
              icon: Icons.calculate_outlined,
              accentColor: const Color(0xFF0284C7),
              badgeText: 'Cash Register',
              isExpanded: _expandedCategoryIndex == 6,
              onToggle: () => _handleCategoryToggle(6),
              submenus: [
                SubmenuOption(
                  title: 'Daily Tally Dashboard',
                  subtitle: 'Cash summary, available balance & reconciliation audit',
                  icon: Icons.dashboard_outlined,
                  onTap: () => context.push('/daily-tally'),
                ),
                SubmenuOption(
                  title: 'Create Daily Tally',
                  subtitle: 'Record end-of-day register, collections & expenses',
                  icon: Icons.add_circle_outline_rounded,
                  onTap: () => context.push('/daily-tally/create'),
                ),
                SubmenuOption(
                  title: 'Daily Cash Reconciliation',
                  subtitle: 'Denomination calculator & cash variance verification',
                  icon: Icons.account_balance_wallet_outlined,
                  onTap: () => context.push('/daily-tally/reconciliation'),
                ),
                SubmenuOption(
                  title: 'Daily Tally History',
                  subtitle: 'Past tallies, opening balances & closing audit log',
                  icon: Icons.history_rounded,
                  onTap: () => context.push('/daily-tally/history'),
                ),
              ],
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildKpiItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      color: const Color(0xFFE2E8F0),
      margin: const EdgeInsets.symmetric(horizontal: 6),
    );
  }

  Widget _buildFilterPill(String filter, String count) {
    final isSelected = _selectedFilter == filter;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = filter),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              filter,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
