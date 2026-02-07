'use client';

import Image from 'next/image';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useAuth } from './AuthProvider';
import { signOut } from '@/lib/auth';

export function Navbar() {
  const pathname = usePathname();
  const { user, loading } = useAuth();

  const links = [
    { href: '/', label: 'Home' },
    { href: '/people', label: 'People' },
    { href: '/calendar', label: 'Calendar' },
    { href: '/settings', label: 'Settings' },
  ];

  return (
    <nav className="fixed top-0 left-0 right-0 z-50 bg-white/90 backdrop-blur-sm border-b border-lavender">
      <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between py-2">
          <Link href="/" className="flex items-center">
            <Image src="/logo.png" alt="Tiaras & Trains" width={256} height={256} className="w-32 h-32 rounded-3xl border-3 border-purple" />
          </Link>
          <div className="flex items-center gap-1">
            {links.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                className={`px-4 py-2 rounded-full text-sm font-semibold transition-colors ${
                  pathname === link.href
                    ? 'bg-purple text-white'
                    : 'text-purple-dark hover:bg-lavender'
                }`}
              >
                {link.label}
              </Link>
            ))}
            {!loading && (
              <>
                {user ? (
                  <button
                    onClick={() => signOut()}
                    className="ml-1 px-4 py-2 rounded-full text-sm font-semibold text-purple-dark hover:bg-lavender transition-colors"
                  >
                    Sign out
                  </button>
                ) : (
                  <Link
                    href="/login"
                    className="ml-2 px-4 py-2 rounded-full text-sm font-semibold bg-purple/10 text-purple hover:bg-purple/20 transition-colors"
                  >
                    Sign in
                  </Link>
                )}
              </>
            )}
          </div>
        </div>
      </div>
    </nav>
  );
}
