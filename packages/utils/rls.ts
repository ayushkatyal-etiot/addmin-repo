// Row-level security utilities for office-based data isolation

export interface RLSContext {
  userId: string;
  officeId: string;
  role: string;
}

export function enforceOfficeScope(officeId: string, userOfficeId: string): boolean {
  return officeId === userOfficeId;
}

export function canAccessOffice(userOfficeIds: string[], officeId: string): boolean {
  return userOfficeIds.includes(officeId);
}

export function canApproveTransaction(role: string): boolean {
  return ["AUTHORIZER", "ADMIN"].includes(role);
}

export function canCheckTransaction(role: string): boolean {
  return ["CHECKER", "AUTHORIZER", "ADMIN"].includes(role);
}

export function canMakeTransaction(role: string): boolean {
  return ["ADMIN", "CHECKER", "AUTHORIZER"].includes(role);
}
