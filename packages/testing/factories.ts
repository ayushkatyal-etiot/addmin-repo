// Test data factories for AddMin

export function createOrganization(overrides = {}) {
  return {
    id: "org_" + Math.random().toString(36).substr(2, 9),
    name: "Test Organization",
    email: "org@example.com",
    website: "https://example.com",
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  };
}

export function createOffice(overrides = {}) {
  return {
    id: "office_" + Math.random().toString(36).substr(2, 9),
    organizationId: "org_test",
    name: "Test Office",
    address: "123 Test St",
    city: "Test City",
    state: "Test State",
    zipCode: "123456",
    country: "India",
    isOwned: false,
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  };
}

export function createUser(overrides = {}) {
  return {
    id: "user_" + Math.random().toString(36).substr(2, 9),
    email: "user@example.com",
    name: "Test User",
    emailVerified: new Date(),
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  };
}

export function createBill(overrides = {}) {
  return {
    id: "bill_" + Math.random().toString(36).substr(2, 9),
    officeId: "office_test",
    utilityId: "utility_test",
    amount: 1000,
    dueDate: new Date(),
    status: "DRAFT",
    madeBy: "user_test",
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  };
}
