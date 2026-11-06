import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mock_repository.dart';
import 'models/customer.dart';
import 'models/goods_entry.dart';
import 'models/bill.dart';
import 'models/payment.dart';
import 'models/dashboard_metrics.dart';
import 'models/daily_summary.dart';
import 'models/ledger_entry.dart';
import 'models/commodity.dart';
import 'models/seller_load.dart';

// Repository instance provider
final repositoryProvider = Provider<MockRepository>((ref) {
  return MockRepository();
});

// App State Notifier to trigger UI updates across screens
class AppStateNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void refresh() {
    state++;
  }

  void resetDemoData() {
    ref.read(repositoryProvider).resetDemoData();
    refresh();
  }

  void addCustomer(Customer customer) {
    ref.read(repositoryProvider).addCustomer(customer);
    refresh();
  }

  void updateCustomer(Customer customer) {
    ref.read(repositoryProvider).updateCustomer(customer);
    refresh();
  }

  void addGoodsEntry(GoodsEntry entry) {
    ref.read(repositoryProvider).addGoodsEntry(entry);
    refresh();
  }

  void updateGoodsEntry(GoodsEntry entry) {
    ref.read(repositoryProvider).updateGoodsEntry(entry);
    refresh();
  }

  void createBill(Bill bill) {
    ref.read(repositoryProvider).createBill(bill);
    refresh();
  }

  void addBill(Bill bill) => createBill(bill);

  void updateBill(Bill bill) {
    ref.read(repositoryProvider).updateBill(bill);
    refresh();
  }

  void cancelBill(String billId, {required String reason, required String cancelledBy}) {
    ref.read(repositoryProvider).cancelBill(billId, reason: reason, cancelledBy: cancelledBy);
    refresh();
  }

  void recordPayment(Payment payment) {
    ref.read(repositoryProvider).recordPayment(payment);
    refresh();
  }

  void addSellerLoad(SellerLoad load) {
    ref.read(repositoryProvider).addSellerLoad(load);
    refresh();
  }

  void updateSellerLoad(SellerLoad load) {
    ref.read(repositoryProvider).updateSellerLoad(load);
    refresh();
  }

  void addCommodity(Commodity commodity) {
    ref.read(repositoryProvider).addCommodity(commodity);
    refresh();
  }

  void updateCommodity(Commodity commodity) {
    ref.read(repositoryProvider).updateCommodity(commodity);
    refresh();
  }
}

final appStateProvider = NotifierProvider<AppStateNotifier, int>(AppStateNotifier.new);

// Reactive Derived Providers
final customersProvider = Provider<List<Customer>>((ref) {
  ref.watch(appStateProvider);
  return ref.read(repositoryProvider).getCustomers();
});

final sellerLoadsProvider = Provider<List<SellerLoad>>((ref) {
  ref.watch(appStateProvider);
  return ref.read(repositoryProvider).getSellerLoads();
});

final goodsEntriesProvider = Provider<List<GoodsEntry>>((ref) {
  ref.watch(appStateProvider);
  return ref.read(repositoryProvider).getGoodsEntries();
});

final commoditiesProvider = Provider<List<Commodity>>((ref) {
  ref.watch(appStateProvider);
  return ref.read(repositoryProvider).getCommodities();
});

final billsProvider = Provider<List<Bill>>((ref) {
  ref.watch(appStateProvider);
  return ref.read(repositoryProvider).getBills();
});

final paymentsProvider = Provider<List<Payment>>((ref) {
  ref.watch(appStateProvider);
  return ref.read(repositoryProvider).getPayments();
});

final dashboardMetricsProvider = Provider<DashboardMetrics>((ref) {
  ref.watch(appStateProvider);
  return ref.read(repositoryProvider).getDashboardMetrics();
});

final customerBalanceProvider = Provider.family<double, String>((ref, customerId) {
  ref.watch(appStateProvider);
  return ref.read(repositoryProvider).getCustomerBalance(customerId);
});

final customerLedgerProvider = Provider.family<List<LedgerEntry>, String>((ref, customerId) {
  ref.watch(appStateProvider);
  return ref.read(repositoryProvider).getCustomerLedger(customerId);
});

class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime date) {
    state = date;
  }
}

final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

final dailySummaryProvider = Provider<DailySummary>((ref) {
  ref.watch(appStateProvider);
  final date = ref.watch(selectedDateProvider);
  return ref.read(repositoryProvider).getDailySummary(date);
});
