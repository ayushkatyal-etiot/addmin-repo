import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "AddMin - Office Administration Management",
  description: "Process-first office administration platform for managing utilities, compliance, lease, and assets.",
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
