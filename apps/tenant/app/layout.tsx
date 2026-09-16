import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "AddMin - Office Management",
  description: "Manage utilities, compliance, lease, facilities, and assets for your office.",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
