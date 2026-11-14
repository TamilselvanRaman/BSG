enum ExpensePaymentMethod { cash, bank, upi }

class Expense {
  final String id;
  final String expenseNumber;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final ExpensePaymentMethod method;
  final String? paidTo;
  final String? referenceNumber;
  final String? notes;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.expenseNumber,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.method = ExpensePaymentMethod.cash,
    this.paidTo,
    this.referenceNumber,
    this.notes,
    required this.createdAt,
  });

  Expense copyWith({
    String? id,
    String? expenseNumber,
    String? title,
    String? category,
    double? amount,
    DateTime? date,
    ExpensePaymentMethod? method,
    String? paidTo,
    String? referenceNumber,
    String? notes,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      expenseNumber: expenseNumber ?? this.expenseNumber,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      method: method ?? this.method,
      paidTo: paidTo ?? this.paidTo,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

