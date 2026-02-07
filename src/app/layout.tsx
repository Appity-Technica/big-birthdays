import type { Metadata } from "next";
import { Nunito, Baloo_2 } from "next/font/google";
import { Navbar } from "@/components/Navbar";
import { AuthProvider } from "@/components/AuthProvider";
import "./globals.css";

const nunito = Nunito({
  variable: "--font-nunito",
  subsets: ["latin"],
});

const baloo = Baloo_2({
  variable: "--font-baloo",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Tiaras & Trains — Birthday Tracker",
  description: "Track birthdays and celebrate every milestone with joy",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={`${nunito.variable} ${baloo.variable} font-sans antialiased`}>
        <AuthProvider>
          <Navbar />
          <main className="min-h-screen pt-36">
            {children}
          </main>
        </AuthProvider>
      </body>
    </html>
  );
}
