import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "AddMin Operator - Control Plane",
  description: "SaaS control plane for managing AddMin platform and organizations.",
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
