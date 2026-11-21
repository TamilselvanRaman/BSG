import 'package:flutter/material.dart';
import '../../../data/models/bill_model.dart';
import '../../../data/models/lot_model.dart';

/// Enum for Daily Summary dropdown filter options
enum DailySummaryType {
  allSummary,
  salesSummary,
  purchaseSummary,
  totalReceived,
  totalPaid,
  dailyExpenses,
  transportation,
  totalCoolie,
  rent,
  salesCommission,
}

extension DailySummaryTypeExt on DailySummaryType {
  String get label {
    switch (this) {
      case DailySummaryType.allSummary:
        return 'All Summary';
      case DailySummaryType.salesSummary:
        return 'Sales Summary';
      case DailySummaryType.purchaseSummary:
        return 'Purchase Summary';
      case DailySummaryType.totalReceived:
        return 'Total Received';
      case DailySummaryType.totalPaid:
        return 'Total Paid';
      case DailySummaryType.dailyExpenses:
        return 'Daily Expenses';
      case DailySummaryType.transportation:
        return 'Transportation';
      case DailySummaryType.totalCoolie:
        return 'Total Coolie';
      case DailySummaryType.rent:
        return 'Rent';
      case DailySummaryType.salesCommission:
        return 'Sales Commission';
    }
  }

  IconData get icon {
    switch (this) {
      case DailySummaryType.allSummary:
        return Icons.dashboard_outlined;
      case DailySummaryType.salesSummary:
        return Icons.trending_up_rounded;
      case DailySummaryType.purchaseSummary:
        return Icons.shopping_bag_outlined;
      case DailySummaryType.totalReceived:
        return Icons.arrow_downward_rounded;
      case DailySummaryType.totalPaid:
        return Icons.arrow_upward_rounded;
      case DailySummaryType.dailyExpenses:
        return Icons.receipt_long_rounded;
      case DailySummaryType.transportation:
        return Icons.local_shipping_outlined;
      case DailySummaryType.totalCoolie:
        return Icons.engineering_outlined;
      case DailySummaryType.rent:
        return Icons.store_outlined;
      case DailySummaryType.salesCommission:
        return Icons.percent_rounded;
    }
  }
}

// ----------------- 1. Daily Summary Models -----------------

class DailyReceivedItem {
  final String id;
  final String buyerName;
  final String refNumber;
  final double amount;
  final String paymentMode;
  final DateTime time;

  const DailyReceivedItem({
    required this.id,
    required this.buyerName,
    required this.refNumber,
    required this.amount,
    required this.paymentMode,
    required this.time,
  });
}

class DailyPaidItem {
  final String id;
  final String sellerName;
  final String refNumber;
  final double amount;
  final String paymentMode;
  final String category;
  final DateTime time;

  const DailyPaidItem({
    required this.id,
    required this.sellerName,
    required this.refNumber,
    required this.amount,
    required this.paymentMode,
    required this.category,
    required this.time,
  });
}

class DailySummaryReport {
  final DateTime date;
  final double totalReceived;
  final double totalPaid;
  final double salesAmount;
  final int salesBillsCount;
  final double purchaseAmount;
  final int purchaseLotsCount;
  final double transportation;
  final double totalCoolie;
  final double rent;
  final double salesCommission;
  final double totalExpenses;
  final int expensesCount;
  final List<DailyReceivedItem> receivedItems;
  final List<DailyPaidItem> paidItems;

  const DailySummaryReport({
    required this.date,
    required this.totalReceived,
    required this.totalPaid,
    required this.salesAmount,
    required this.salesBillsCount,
    required this.purchaseAmount,
    required this.purchaseLotsCount,
    required this.transportation,
    required this.totalCoolie,
    required this.rent,
    required this.salesCommission,
    this.totalExpenses = 0.0,
    this.expensesCount = 0,
    required this.receivedItems,
    required this.paidItems,
  });
}

// ----------------- 2. Gross Profit Models -----------------

class ProductProfitItem {
  final String productName;
  final double quantitySold;
  final String unit;
  final double salesValue;
  final double purchaseCost;
  final double grossProfit;
  final double profitPercentage;

  const ProductProfitItem({
    required this.productName,
    required this.quantitySold,
    required this.unit,
    required this.salesValue,
    required this.purchaseCost,
    required this.grossProfit,
    required this.profitPercentage,
  });
}

class TransactionProfitItem {
  final String billNumber;
  final DateTime date;
  final String customerName;
  final String productName;
  final double quantity;
  final String unit;
  final double sellRate;
  final double costRate;
  final double salesValue;
  final double purchaseCost;
  final double grossProfit;

  const TransactionProfitItem({
    required this.billNumber,
    required this.date,
    required this.customerName,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.sellRate,
    required this.costRate,
    required this.salesValue,
    required this.purchaseCost,
    required this.grossProfit,
  });
}

class GrossProfitReport {
  final DateTime fromDate;
  final DateTime toDate;
  final double totalSalesAmount;
  final double totalPurchaseCost;
  final double grossProfit;
  final double profitPercentage;
  final List<ProductProfitItem> productProfits;
  final List<TransactionProfitItem> transactions;

  const GrossProfitReport({
    required this.fromDate,
    required this.toDate,
    required this.totalSalesAmount,
    required this.totalPurchaseCost,
    required this.grossProfit,
    required this.profitPercentage,
    required this.productProfits,
    required this.transactions,
  });
}

// ----------------- 3. Stock Report Models -----------------

class StockMovementItem {
  final DateTime date;
  final String refNumber;
  final String type; // 'INWARD LOT', 'SALES BILL', 'ADJUSTMENT'
  final String productName;
  final double quantity;
  final String unit;
  final double runningStock;

  const StockMovementItem({
    required this.date,
    required this.refNumber,
    required this.type,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.runningStock,
  });
}

class StockReportProductItem {
  final String productName;
  final String unit;
  final double openingStock;
  final double purchasedQuantity;
  final double soldQuantity;
  final double closingStock;
  final double averageRate;
  final double stockValuation;
  final int activeLotsCount;

  const StockReportProductItem({
    required this.productName,
    required this.unit,
    required this.openingStock,
    required this.purchasedQuantity,
    required this.soldQuantity,
    required this.closingStock,
    required this.averageRate,
    required this.stockValuation,
    required this.activeLotsCount,
  });
}

class StockReportData {
  final double totalOpening;
  final double totalPurchased;
  final double totalSold;
  final double totalClosing;
  final double totalStockValuation;
  final List<StockReportProductItem> products;
  final List<StockMovementItem> movements;

  const StockReportData({
    required this.totalOpening,
    required this.totalPurchased,
    required this.totalSold,
    required this.totalClosing,
    required this.totalStockValuation,
    required this.products,
    required this.movements,
  });
}

// ----------------- 4. Sales Report Models -----------------

class SalesByBuyerItem {
  final String buyerId;
  final String buyerName;
  final String phone;
  final int billsCount;
  final double totalSales;
  final double amountReceived;
  final double balanceDue;

  const SalesByBuyerItem({
    required this.buyerId,
    required this.buyerName,
    required this.phone,
    required this.billsCount,
    required this.totalSales,
    required this.amountReceived,
    required this.balanceDue,
  });
}

class SalesByCropItem {
  final String cropName;
  final double totalQuantity;
  final double totalWeight;
  final String unit;
  final double averageRate;
  final double totalSales;

  const SalesByCropItem({
    required this.cropName,
    required this.totalQuantity,
    required this.totalWeight,
    required this.unit,
    required this.averageRate,
    required this.totalSales,
  });
}

class SalesByDateItem {
  final DateTime date;
  final int billsCount;
  final double cashSales;
  final double creditSales;
  final double totalSales;

  const SalesByDateItem({
    required this.date,
    required this.billsCount,
    required this.cashSales,
    required this.creditSales,
    required this.totalSales,
  });
}

class SalesReportData {
  final double totalSales;
  final int totalBills;
  final double totalQuantity;
  final double totalWeight;
  final double totalReceived;
  final double totalOutstanding;
  final List<SalesByBuyerItem> byBuyer;
  final List<SalesByCropItem> byCrop;
  final List<SalesByDateItem> byDate;
  final List<Bill> bills;

  const SalesReportData({
    required this.totalSales,
    required this.totalBills,
    required this.totalQuantity,
    required this.totalWeight,
    required this.totalReceived,
    required this.totalOutstanding,
    required this.byBuyer,
    required this.byCrop,
    required this.byDate,
    required this.bills,
  });
}

// ----------------- 5. Purchase Report Models -----------------

class PurchaseBySellerItem {
  final String sellerId;
  final String sellerName;
  final String phone;
  final int lotsCount;
  final double totalPurchase;
  final double amountPaid;
  final double balancePayable;

  const PurchaseBySellerItem({
    required this.sellerId,
    required this.sellerName,
    required this.phone,
    required this.lotsCount,
    required this.totalPurchase,
    required this.amountPaid,
    required this.balancePayable,
  });
}

class PurchaseByProductItem {
  final String productName;
  final int lotsCount;
  final double totalQuantity;
  final double totalWeight;
  final String unit;
  final double averageCostRate;
  final double totalCost;

  const PurchaseByProductItem({
    required this.productName,
    required this.lotsCount,
    required this.totalQuantity,
    required this.totalWeight,
    required this.unit,
    required this.averageCostRate,
    required this.totalCost,
  });
}

class PurchaseByDateItem {
  final DateTime date;
  final int lotsCount;
  final double totalQuantity;
  final double totalPurchaseAmount;

  const PurchaseByDateItem({
    required this.date,
    required this.lotsCount,
    required this.totalQuantity,
    required this.totalPurchaseAmount,
  });
}

class PurchaseReportData {
  final double totalPurchaseAmount;
  final int totalLots;
  final double totalQuantity;
  final double totalWeight;
  final double amountPaid;
  final double outstandingPayable;
  final List<PurchaseBySellerItem> bySeller;
  final List<PurchaseByProductItem> byProduct;
  final List<PurchaseByDateItem> byDate;
  final List<Lot> lots;

  const PurchaseReportData({
    required this.totalPurchaseAmount,
    required this.totalLots,
    required this.totalQuantity,
    required this.totalWeight,
    required this.amountPaid,
    required this.outstandingPayable,
    required this.bySeller,
    required this.byProduct,
    required this.byDate,
    required this.lots,
  });
}

// ----------------- 6. RMC Report Models -----------------

class RmcTransactionItem {
  final String billNumber;
  final DateTime date;
  final String partnerName;
  final String productName;
  final double quantity;
  final String unit;
  final double taxableAmount;
  final double rmcRatePercent; // e.g. 1.0%
  final double rmcAmount;

  const RmcTransactionItem({
    required this.billNumber,
    required this.date,
    required this.partnerName,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.taxableAmount,
    required this.rmcRatePercent,
    required this.rmcAmount,
  });
}

class RmcDateItem {
  final DateTime date;
  final int transactionsCount;
  final double totalTurnover;
  final double rmcCess;

  const RmcDateItem({
    required this.date,
    required this.transactionsCount,
    required this.totalTurnover,
    required this.rmcCess,
  });
}

class RmcReportData {
  final double totalTaxableTurnover;
  final double rmcRatePercent;
  final double totalRmcFee;
  final double rmcPaid;
  final double rmcPending;
  final List<RmcTransactionItem> transactions;
  final List<RmcDateItem> byDate;

  const RmcReportData({
    required this.totalTaxableTurnover,
    required this.rmcRatePercent,
    required this.totalRmcFee,
    required this.rmcPaid,
    required this.rmcPending,
    required this.transactions,
    required this.byDate,
  });
}

