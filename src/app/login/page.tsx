'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { useAuth } from '@/components/AuthProvider';
import { signInWithEmail, signUpWithEmail, signInWithGoogle } from '@/lib/auth';
import { migrateLocalToFirestore } from '@/lib/db';
import { getAllPeople } from '@/lib/localStorage';

export default function LoginPage() {
  const router = useRouter();
  const { user } = useAuth();
  const [isSignUp, setIsSignUp] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [migrating, setMigrating] = useState(false);

  // Already signed in — redirect
  if (user) {
    router.push('/');
    return null;
  }

  async function handleMigration(userId: string) {
    const localPeople = getAllPeople();
    if (localPeople.length > 0) {
      setMigrating(true);
      await migrateLocalToFirestore(userId, localPeople);
      // Clear local storage after successful migration
      localStorage.removeItem('big-birthdays-people');
      setMigrating(false);
    }
  }

  async function handleEmailSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError('');
    try {
      const result = isSignUp
        ? await signUpWithEmail(email, password)
        : await signInWithEmail(email, password);
      await handleMigration(result.user.uid);
      router.push('/');
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : 'Something went wrong';
      setError(message.replace('Firebase: ', '').replace(/\(auth\/.*\)/, '').trim());
    }
  }

  async function handleGoogle() {
    setError('');
    try {
      const result = await signInWithGoogle();
      await handleMigration(result.user.uid);
      router.push('/');
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : 'Something went wrong';
      if (!message.includes('popup-closed')) {
        setError(message.replace('Firebase: ', '').replace(/\(auth\/.*\)/, '').trim());
      }
    }
  }

  if (migrating) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center gap-4">
        <div className="w-10 h-10 rounded-full border-4 border-lavender border-t-purple animate-spin" />
        <p className="text-sm font-semibold text-purple">Migrating your data...</p>
      </div>
    );
  }

  return (
    <div className="min-h-[80vh] flex items-center justify-center px-4">
      <div className="w-full max-w-md">
        <div className="text-center mb-8">
          <h1 className="font-display text-3xl sm:text-4xl font-bold text-purple mb-2">
            {isSignUp ? 'Create Account' : 'Welcome Back'}
          </h1>
          <p className="text-foreground/50">
            {isSignUp
              ? 'Sign up to sync your birthdays across devices'
              : 'Sign in to access your birthdays everywhere'}
          </p>
        </div>

        {/* Google sign-in */}
        <button
          onClick={handleGoogle}
          className="w-full flex items-center justify-center gap-3 px-6 py-3.5 bg-surface border-2 border-lavender rounded-xl font-bold text-sm text-foreground hover:border-purple/30 hover:shadow-md transition-all mb-6"
        >
          <svg className="w-5 h-5" viewBox="0 0 24 24">
            <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.06 5.06 0 01-2.2 3.32v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.1z" />
            <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" />
            <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" />
            <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" />
          </svg>
          Continue with Google
        </button>

        <div className="flex items-center gap-3 mb-6">
          <div className="flex-1 h-px bg-lavender" />
          <span className="text-xs font-bold text-foreground/30 uppercase">or</span>
          <div className="flex-1 h-px bg-lavender" />
        </div>

        {/* Email form */}
        <form onSubmit={handleEmailSubmit} className="space-y-4">
          {error && (
            <div className="p-3 rounded-xl bg-coral/10 border border-coral/20 text-coral text-sm font-semibold">
              {error}
            </div>
          )}

          <div>
            <label htmlFor="email" className="block text-sm font-bold text-foreground mb-2">
              Email
            </label>
            <input
              id="email"
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="you@example.com"
              className="w-full px-4 py-3 rounded-xl border-2 border-lavender bg-surface text-foreground placeholder:text-foreground/30 focus:outline-none focus:border-purple focus:ring-2 focus:ring-purple/10 transition-all"
            />
          </div>

          <div>
            <label htmlFor="password" className="block text-sm font-bold text-foreground mb-2">
              Password
            </label>
            <input
              id="password"
              type="password"
              required
              minLength={6}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="At least 6 characters"
              className="w-full px-4 py-3 rounded-xl border-2 border-lavender bg-surface text-foreground placeholder:text-foreground/30 focus:outline-none focus:border-purple focus:ring-2 focus:ring-purple/10 transition-all"
            />
          </div>

          <button
            type="submit"
            className="w-full px-6 py-3.5 bg-purple text-white rounded-xl font-bold text-sm hover:bg-purple-dark transition-all shadow-lg shadow-purple/25"
          >
            {isSignUp ? 'Create Account' : 'Sign In'}
          </button>
        </form>

        <p className="text-center text-sm text-foreground/50 mt-6">
          {isSignUp ? 'Already have an account?' : "Don't have an account?"}{' '}
          <button
            onClick={() => { setIsSignUp(!isSignUp); setError(''); }}
            className="font-bold text-purple hover:text-purple-dark"
          >
            {isSignUp ? 'Sign in' : 'Sign up'}
          </button>
        </p>

        <div className="text-center mt-4">
          <Link href="/" className="text-sm font-semibold text-foreground/40 hover:text-foreground/60">
            Continue without an account &rarr;
          </Link>
        </div>
      </div>
    </div>
  );
}
