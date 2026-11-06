import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/responsive/responsive_container.dart';
import '../../data/app_state.dart';

class PartnersScreen extends ConsumerStatefulWidget {
  const PartnersScreen({super.key});

  @override
  ConsumerState<PartnersScreen> createState() => _PartnersScreenState();
}

class _PartnersScreenState extends ConsumerState<PartnersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => context.pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mandi Partners & Brokers',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A)),
            ),
            Text(
              'Commission Agents, Brokers & Market Merchants',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt, color: Color(0xFF1E6B24)),
            tooltip: 'Add Mandi Partner',
            onPressed: () => context.push('/customers/new'),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1E6B24),
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          indicatorColor: const Color(0xFF1E6B24),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Commission Agents & Brokers'),
            Tab(text: 'Market Merchants'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'partners_screen_fab',
        backgroundColor: const Color(0xFF1E6B24),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.handshake_outlined),
        label: const Text('Add Mandi Partner', style: TextStyle(fontWeight: FontWeight.w800)),
        onPressed: () => context.push('/customers/new'),
      ),
      body: Column(
        children: [
          // KPI Metric Banner
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: ResponsiveContainer(
              maxWidth: 960,
              child: Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      'Commission Rate',
                      '5.0% Standard',
                      Icons.percent,
                      const Color(0xFF1E6B24),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildKpiCard(
                      'Partner Network',
                      '8 Mandi Traders',
                      Icons.people_alt,
                      const Color(0xFF0284C7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildKpiCard(
                      'Market Zone',
                      'Tiruppur APMC',
                      Icons.verified_outlined,
                      const Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          // Search Box
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            color: Colors.white,
            child: ResponsiveContainer(
              maxWidth: 960,
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search by Broker Name / License / Phone...',
                  hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
            ),
          ),

          // Tab Views
          Expanded(
            child: ResponsiveContainer(
              maxWidth: 960,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAgentsList(),
                  _buildMerchantsList(customers),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentsList() {
    final agents = [
      {'name': 'R. Natarajan Commission Agent', 'license': 'APMC-TN-8821', 'phone': '98421 11200', 'share': '5% Standard', 'zone': 'Block A - Stall #14'},
      {'name': 'K. Muthusamy & Co.', 'license': 'APMC-TN-7740', 'phone': '94432 99400', 'share': '5% Standard', 'zone': 'Block B - Stall #08'},
      {'name': 'Cauvery Mandi Brokers', 'license': 'APMC-TN-9102', 'phone': '97890 33810', 'share': '4.5% Volume', 'zone': 'Block C - Weighbridge North'},
    ];

    final filteredAgents = agents.where((a) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return a['name']!.toLowerCase().contains(q) ||
          a['license']!.toLowerCase().contains(q) ||
          a['phone']!.contains(q);
    }).toList();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
      itemCount: filteredAgents.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final a = filteredAgents[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.handshake_rounded, color: Color(0xFF1E6B24), size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a['name']!,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                        ),
                        Text('License: ${a['license']!} • Phone: ${a['phone']!}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(a['share']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF16A34A))),
                  ),
                ],
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Location: ${a['zone']!}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        icon: const Icon(Icons.phone, size: 14),
                        label: const Text('Call', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Calling ${a['name']} (${a['phone']})')));
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.chat, size: 14),
                        label: const Text('WhatsApp', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening WhatsApp for ${a['name']}')));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMerchantsList(List customers) {
    final filtered = customers.where((c) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return c.name.toLowerCase().contains(q) ||
          c.phone.contains(q) ||
          c.village.toLowerCase().contains(q);
    }).toList();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final c = filtered[index];
        return InkWell(
          onTap: () => context.push('/customers/${c.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.storefront, color: Color(0xFF334155), size: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                      ),
                      Text('${c.village} • Phone: ${c.phone}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
    );
  }
}
