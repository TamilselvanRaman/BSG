class LedgerEntry {
  final String id;
  final String customerId;
  final DateTime date;
  final String transactionReference;
  final String description;
  final double debit;  // Charges / Bills (increases buyer's balance)
  final double credit; // Payments / Advances / Reversals (decreases balance)
  final double runningBalance;
  final String? relatedBillId;
  final String? relatedEntryId;

  const LedgerEntry({
    required this.id,
    required this.customerId,
    required this.date,
    required this.transactionReference,
    required this.description,
    this.debit = 0.0,
    this.credit = 0.0,
    required this.runningBalance,
    this.relatedBillId,
    this.relatedEntryId,
  });
}
