// Shared types across AddMin applications

export type Role = "ADMIN" | "CHECKER" | "AUTHORIZER" | "COMPLIANCE" | "VENDOR_MGR" | "FACILITY_STAFF";

export type WorkflowStatus =
  | "DRAFT"
  | "PENDING_CHECKER"
  | "PENDING_AUTHORIZER"
  | "APPROVED"
  | "REJECTED"
  | "RETURNED"
  | "PAID";

export interface Organization {
  id: string;
  name: string;
  email: string;
  website?: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface Office {
  id: string;
  organizationId: string;
  name: string;
  address: string;
  city: string;
  state: string;
  zipCode: string;
  country: string;
  isOwned: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface User {
  id: string;
  email: string;
  name?: string;
  emailVerified?: Date;
  createdAt: Date;
  updatedAt: Date;
}

export interface OfficeUser {
  id: string;
  userId: string;
  officeId: string;
  role: Role;
  createdAt: Date;
}
