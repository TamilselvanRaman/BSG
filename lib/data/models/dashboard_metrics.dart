class DashboardMetrics {
  final double todaySales;
  final double todayInitialPayments;
  final double todayOtherPayments;
  final double todayTotalCollections;
  final double outstandingBuyerBalances;
  final int totalBuyers;
  final int totalGoodsEntries;
  final int billsGenerated;
  final int pendingBills;
  final int cancelledBills;

  const DashboardMetrics({
    required this.todaySales,
    required this.todayInitialPayments,
    required this.todayOtherPayments,
    required this.todayTotalCollections,
    required this.outstandingBuyerBalances,
    required this.totalBuyers,
    required this.totalGoodsEntries,
    required this.billsGenerated,
    required this.pendingBills,
    required this.cancelledBills,
  });
}
