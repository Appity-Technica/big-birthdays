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
                  <>
                    <Link
                      href="/settings"
                      className={`ml-1 p-2 rounded-full transition-colors ${
                        pathname === '/settings'
                          ? 'bg-purple text-white'
                          : 'text-purple-dark hover:bg-lavender'
                      }`}
                      title="Settings"
                    >
                      <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                        <path strokeLinecap="round" strokeLinejoin="round" d="M9.594 3.94c.09-.542.56-.94 1.11-.94h2.593c.55 0 1.02.398 1.11.94l.213 1.281c.063.374.313.686.645.87.074.04.147.083.22.127.325.196.72.257 1.075.124l1.217-.456a1.125 1.125 0 011.37.49l1.296 2.247a1.125 1.125 0 01-.26 1.431l-1.003.827c-.293.241-.438.613-.43.992a7.723 7.723 0 010 .255c-.008.378.137.75.43.991l1.004.827c.424.35.534.955.26 1.43l-1.298 2.247a1.125 1.125 0 01-1.369.491l-1.217-.456c-.355-.133-.75-.072-1.076.124a6.47 6.47 0 01-.22.128c-.331.183-.581.495-.644.869l-.213 1.281c-.09.543-.56.941-1.11.941h-2.594c-.55 0-1.019-.398-1.11-.94l-.213-1.281c-.062-.374-.312-.686-.644-.87a6.52 6.52 0 01-.22-.127c-.325-.196-.72-.257-1.076-.124l-1.217.456a1.125 1.125 0 01-1.369-.49l-1.297-2.247a1.125 1.125 0 01.26-1.431l1.004-.827c.292-.24.437-.613.43-.991a6.932 6.932 0 010-.255c.007-.38-.138-.751-.43-.992l-1.004-.827a1.125 1.125 0 01-.26-1.43l1.297-2.247a1.125 1.125 0 011.37-.491l1.216.456c.356.133.751.072 1.076-.124.072-.044.146-.086.22-.128.332-.183.582-.495.644-.869l.214-1.28z" />
                        <path strokeLinecap="round" strokeLinejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                      </svg>
                    </Link>
                    <button
                      onClick={() => signOut()}
                      className="ml-1 px-4 py-2 rounded-full text-sm font-semibold text-purple-dark hover:bg-lavender transition-colors"
                    >
                      Sign out
                    </button>
                  </>
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
