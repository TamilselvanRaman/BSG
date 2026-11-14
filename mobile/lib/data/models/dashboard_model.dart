import 'bill_model.dart';
import 'lot_model.dart';
import 'payment_model.dart';
import 'expense_model.dart';

class DashboardSummary {
  final double dailyCashSales;
  final double dailyCreditSales;
  final double dailyTotalSales;
  final double dailyReceivedAmount;
  final double totalOutstanding;
  final double dailyExpenses;
  final List<Bill> recentBills;
  final List<Lot> recentLots;
  final List<Payment> recentPayments;
  final List<Expense> recentExpenses;

  const DashboardSummary({
    required this.dailyCashSales,
    required this.dailyCreditSales,
    required this.dailyTotalSales,
    required this.dailyReceivedAmount,
    required this.totalOutstanding,
    required this.dailyExpenses,
    required this.recentBills,
    required this.recentLots,
    required this.recentPayments,
    required this.recentExpenses,
  });
}

