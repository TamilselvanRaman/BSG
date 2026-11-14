export type UserRole = "SUPER_ADMIN" | "ADMIN" | "BUSINESS_USER";

export interface AuthUser {
  id: string;
  username: string;
  fullName: string;
  email?: string | null;
  phone?: string | null;
  role: UserRole;
  tenantId: string | null;
  tenantName: string | null;
  permissions: string[];
}

export interface SubscriptionPlanDto {
  id: string;
  code: string;
  name: string;
  description?: string;
  monthlyPrice: number | string;
  annualPrice: number | string;
  trialDays: number;
  maxUsers: number;
  maxGoodsRecords: number;
  maxBuyersAndSellers: number;
  maxStorageMb: number;
  enableSmartChart: boolean;
  enableAuctions: boolean;
  enableReports: boolean;
  enablePdfExport: boolean;
  enableBackup: boolean;
  enableWhatsApp: boolean;
  isActive: boolean;
}

export interface PartnerDto {
  id: string;
  code: string;
  name: string;
  phone: string;
  villageOrCity?: string | null;
  address?: string | null;
  gstNumber?: string | null;
  category: string;
  openingBalance: number | string;
  currentBalance: number | string;
  isActive: boolean;
}

export interface GoodsDto {
  id: string;
  code: string;
  name: string;
  unit: string;
  purchasePrice: number | string;
  sellingPrice: number | string;
  currentStock: number | string;
  minimumStock: number | string;
  category?: { id: string; name: string } | null;
}

export interface GoodsLotDto {
  id: string;
  lotNumber: string;
  arrivalDate: string;
  vehicleNumber?: string | null;
  bagsOrCount: number;
  initialQuantity: number | string;
  soldQuantity: number | string;
  remainingQuantity: number | string;
  unit: string;
  unitPrice: number | string;
  totalValue: number | string;
  status: "OPEN" | "PARTIAL" | "SOLD_OUT" | "CLOSED" | "CANCELLED";
  seller: { id: string; name: string; code: string; phone: string; villageOrCity?: string };
  goods: { id: string; name: string; code: string; unit: string };
}
