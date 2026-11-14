export interface BillLineInput {
  bagsCount?: number;
  grossWeight: number;
  tareWeight?: number;
  unitPrice: number;
  costPrice?: number;
}

export interface BillCalculationInput {
  items: BillLineInput[];
  labourCharge?: number;
  rmcCessPercent?: number;
  isRmcApplicable?: boolean;
  otherCharges?: number;
  discountAmount?: number;
  taxAmount?: number;
  paidOrReceivedAmount?: number;
  previousBalance?: number;
}

export interface ComputedBillLine {
  bagsCount: number;
  grossWeight: number;
  tareWeight: number;
  netQuantity: number;
  unitPrice: number;
  costPrice: number;
  lineTotal: number;
}

export interface ComputedBillTotals {
  lines: ComputedBillLine[];
  totalBags: number;
  totalNetQuantity: number;
  subtotal: number;
  labourCharge: number;
  rmcCessAmount: number;
  otherCharges: number;
  discountAmount: number;
  taxAmount: number;
  grandTotal: number;
  paidOrReceivedAmount: number;
  outstandingAmount: number;
  previousBalance: number;
  closingBalance: number;
  status: "CONFIRMED" | "PARTIALLY_PAID" | "PAID";
}

export function round2(value: number): number {
  return Math.round((value + Number.EPSILON) * 100) / 100;
}

export function round3(value: number): number {
  return Math.round((value + Number.EPSILON) * 1000) / 1000;
}

/**
 * Deterministic server-side calculation for Purchase & Sales Bills,
 * including Tare Deduction, Labour Charges, RMC Market Cess, On-Spot Payment,
 * and Previous/Closing Balance carry-forward.
 */
export function calculateBillTotals(input: BillCalculationInput): ComputedBillTotals {
  const lines: ComputedBillLine[] = input.items.map((item) => {
    const bagsCount = Math.max(0, Math.floor(item.bagsCount ?? 1));
    const grossWeight = round3(Math.max(0, item.grossWeight));
    const tareWeight = round3(Math.max(0, item.tareWeight ?? 0));
    const netQuantity = round3(Math.max(0, grossWeight - tareWeight));
    const unitPrice = round2(Math.max(0, item.unitPrice));
    const costPrice = round2(Math.max(0, item.costPrice ?? 0));
    const lineTotal = round2(netQuantity * unitPrice);

    return {
      bagsCount,
      grossWeight,
      tareWeight,
      netQuantity,
      unitPrice,
      costPrice,
      lineTotal,
    };
  });

  const totalBags = lines.reduce((sum, l) => sum + l.bagsCount, 0);
  const totalNetQuantity = round3(lines.reduce((sum, l) => sum + l.netQuantity, 0));
  const subtotal = round2(lines.reduce((sum, l) => sum + l.lineTotal, 0));
  const labourCharge = round2(Math.max(0, input.labourCharge ?? 0));
  const rmcCessPercent = Math.max(0, input.rmcCessPercent ?? 0);
  const rmcCessAmount = input.isRmcApplicable
    ? round2((subtotal * rmcCessPercent) / 100)
    : 0;
  const otherCharges = round2(Math.max(0, input.otherCharges ?? 0));
  const discountAmount = round2(Math.max(0, input.discountAmount ?? 0));
  const taxAmount = round2(Math.max(0, input.taxAmount ?? 0));

  const grandTotal = round2(
    Math.max(0, subtotal + labourCharge + rmcCessAmount + otherCharges + taxAmount - discountAmount)
  );
  const paidOrReceivedAmount = round2(Math.max(0, input.paidOrReceivedAmount ?? 0));
  const outstandingAmount = round2(Math.max(0, grandTotal - paidOrReceivedAmount));
  const previousBalance = round2(input.previousBalance ?? 0);
  const closingBalance = round2(previousBalance + outstandingAmount);

  let status: "CONFIRMED" | "PARTIALLY_PAID" | "PAID" = "CONFIRMED";
  if (paidOrReceivedAmount >= grandTotal && grandTotal > 0) {
    status = "PAID";
  } else if (paidOrReceivedAmount > 0) {
    status = "PARTIALLY_PAID";
  }

  return {
    lines,
    totalBags,
    totalNetQuantity,
    subtotal,
    labourCharge,
    rmcCessAmount,
    otherCharges,
    discountAmount,
    taxAmount,
    grandTotal,
    paidOrReceivedAmount,
    outstandingAmount,
    previousBalance,
    closingBalance,
    status,
  };
}
