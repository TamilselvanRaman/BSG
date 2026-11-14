import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_extension.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../data/repositories/app_repository.dart';

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final today = AppFormatters.date(DateTime.now());
    final theme = context.appTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        titleSpacing: 16,
        backgroundColor: theme.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?.businessName ?? 'BSG Trading Corp',
              style: AppTypography.cardTitle.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              today,
              style: AppTypography.labelMuted.copyWith(color: theme.textMuted),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Appearance & Themes',
            icon: Icon(Icons.palette_outlined, size: 22, color: theme.text),
            onPressed: () => context.push('/appearance'),
          ),
          IconButton(
            tooltip: 'Global Search',
            icon: Icon(Icons.search, size: 22, color: theme.text),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            tooltip: 'User Profile',
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: theme.accent,
              child: Text(
                (user?.name.isNotEmpty == true ? user!.name[0] : 'U').toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: theme.text,
                ),
              ),
            ),
            onPressed: () => _showUserSheet(context, ref),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: theme.border,
            height: 1,
          ),
        ),
      ),
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.surface,
          border: Border(top: BorderSide(color: theme.border, width: 1.0)),
        ),
        child: NavigationBar(
          backgroundColor: theme.surface,
          indicatorColor: theme.accent,
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: theme.textSecondary),
              selectedIcon: Icon(Icons.home_rounded, color: theme.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined, color: theme.textSecondary),
              selectedIcon: Icon(Icons.receipt_long_rounded, color: theme.primary),
              label: 'Bills',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined, color: theme.textSecondary),
              selectedIcon: Icon(Icons.account_balance_wallet_rounded, color: theme.primary),
              label: 'Expenses',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline_rounded, color: theme.textSecondary),
              selectedIcon: Icon(Icons.people_rounded, color: theme.primary),
              label: 'Users',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined, color: theme.textSecondary),
              selectedIcon: Icon(Icons.bar_chart_rounded, color: theme.primary),
              label: 'Reports',
            ),
          ],
        ),
      ),
    );
  }

  void _showUserSheet(BuildContext context, WidgetRef ref) {
    final user = ref.read(currentUserProvider);
    final theme = context.appTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.primary,
                    child: Text(
                      (user?.name.isNotEmpty == true ? user!.name[0] : 'U').toUpperCase(),
                      style: TextStyle(
                        color: theme.isDark && theme.id == 'midnight' ? Colors.black : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? 'Admin User', style: AppTypography.cardTitle.copyWith(color: theme.text)),
                        Text(user?.phone ?? '', style: AppTypography.label.copyWith(color: theme.textSecondary)),
                        Text(user?.businessName ?? '', style: AppTypography.labelMuted.copyWith(color: theme.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(color: theme.border),
              const SizedBox(height: 6),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.palette_outlined, color: theme.primary, size: 20),
                ),
                title: Text(
                  'Appearance & Themes',
                  style: TextStyle(color: theme.text, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Choose from 5 color themes',
                  style: TextStyle(color: theme.textSecondary, fontSize: 12),
                ),
                trailing: Icon(Icons.chevron_right, size: 20, color: theme.textSecondary),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/appearance');
                },
              ),
              const SizedBox(height: 4),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.error.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.logout_rounded, color: theme.error, size: 20),
                ),
                title: Text('Sign Out', style: TextStyle(color: theme.error, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(appRepositoryProvider).logout();
                  context.go('/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
