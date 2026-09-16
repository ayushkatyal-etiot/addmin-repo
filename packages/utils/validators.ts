import { z } from "zod";

export const organizationSchema = z.object({
  name: z.string().min(2, "Organization name must be at least 2 characters"),
  email: z.string().email("Invalid email address"),
  website: z.string().url().optional().nullable(),
});

export const officeSchema = z.object({
  name: z.string().min(2, "Office name must be at least 2 characters"),
  address: z.string().min(5, "Address must be at least 5 characters"),
  city: z.string().min(2, "City must be at least 2 characters"),
  state: z.string().min(2, "State must be at least 2 characters"),
  zipCode: z.string().min(3, "Zip code must be at least 3 characters"),
  country: z.string().default("India"),
  isOwned: z.boolean(),
});

export const billSchema = z.object({
  amount: z.coerce.number().positive("Amount must be positive"),
  dueDate: z.coerce.date(),
  invoiceNum: z.string().optional(),
  remarks: z.string().optional(),
});

export const userInviteSchema = z.object({
  email: z.string().email("Invalid email address"),
  role: z.enum(["ADMIN", "CHECKER", "AUTHORIZER", "COMPLIANCE", "VENDOR_MGR", "FACILITY_STAFF"]),
});

export type Organization = z.infer<typeof organizationSchema>;
export type Office = z.infer<typeof officeSchema>;
export type Bill = z.infer<typeof billSchema>;
export type UserInvite = z.infer<typeof userInviteSchema>;
