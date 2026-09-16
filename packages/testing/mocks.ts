// Mock implementations for testing (use with Vitest)

export const createMockRepository = () => ({
  organization: {
    findUnique: async () => null,
    findMany: async () => [],
    create: async (data: any) => ({ id: "test", ...data }),
    update: async (data: any) => ({ id: "test", ...data }),
    delete: async () => ({ id: "test" }),
  },
  office: {
    findUnique: async () => null,
    findMany: async () => [],
    create: async (data: any) => ({ id: "test", ...data }),
    update: async (data: any) => ({ id: "test", ...data }),
    delete: async () => ({ id: "test" }),
  },
  user: {
    findUnique: async () => null,
    findMany: async () => [],
    create: async (data: any) => ({ id: "test", ...data }),
    update: async (data: any) => ({ id: "test", ...data }),
    delete: async () => ({ id: "test" }),
  },
  bill: {
    findUnique: async () => null,
    findMany: async () => [],
    create: async (data: any) => ({ id: "test", ...data }),
    update: async (data: any) => ({ id: "test", ...data }),
    delete: async () => ({ id: "test" }),
  },
});

export const mockSession = {
  user: {
    id: "user_test",
    email: "test@example.com",
    name: "Test User",
  },
  expires: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
};
