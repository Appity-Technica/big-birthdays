'use client';

import Link from 'next/link';
import { usePeople } from '@/hooks/usePeople';
import { Person, Relationship } from '@/types';
import { daysUntilBirthday, getUpcomingAge, isBirthdayToday, formatDate } from '@/lib/utils';

const ACCENT_COLORS = [
  { bg: 'bg-pink', text: 'text-white' },
  { bg: 'bg-teal', text: 'text-white' },
  { bg: 'bg-orange', text: 'text-white' },
  { bg: 'bg-coral', text: 'text-white' },
  { bg: 'bg-purple-light', text: 'text-white' },
];

const RELATIONSHIP_STYLES: Record<Relationship, { bg: string; text: string; label: string }> = {
  family: { bg: 'bg-pink/15', text: 'text-pink', label: 'Family' },
  friend: { bg: 'bg-teal/15', text: 'text-teal', label: 'Friend' },
  colleague: { bg: 'bg-orange/15', text: 'text-orange', label: 'Colleague' },
  other: { bg: 'bg-purple-light/15', text: 'text-purple-light', label: 'Other' },
};

function getInitials(name: string): string {
  return name
    .split(' ')
    .map((n) => n[0])
    .join('')
    .toUpperCase()
    .slice(0, 2);
}

function Confetti() {
  const pieces = Array.from({ length: 40 }, (_, i) => i);
  const colors = ['#E91E8C', '#F9C74F', '#2EC4B6', '#F4845F', '#FF6B6B', '#7B2D8E', '#FF6BB5', '#FBBF7D'];
  const shapes = ['circle', 'square', 'triangle'];

  return (
    <div className="absolute inset-0 overflow-hidden pointer-events-none" aria-hidden="true">
      {pieces.map((i) => {
        const color = colors[i % colors.length];
        const shape = shapes[i % shapes.length];
        const left = `${(i * 17 + 3) % 100}%`;
        const delay = `${(i * 0.15) % 3}s`;
        const duration = `${3 + (i % 4)}s`;
        const size = 6 + (i % 8);

        return (
          <div
            key={i}
            className="absolute animate-[confetti-fall_var(--duration)_ease-in-out_var(--delay)_infinite]"
            style={{
              left,
              top: '-20px',
              '--delay': delay,
              '--duration': duration,
              animationDelay: delay,
              animationDuration: duration,
            } as React.CSSProperties}
          >
            {shape === 'circle' && (
              <div
                className="rounded-full"
                style={{ width: size, height: size, backgroundColor: color }}
              />
            )}
            {shape === 'square' && (
              <div
                className="rotate-45"
                style={{ width: size, height: size, backgroundColor: color }}
              />
            )}
            {shape === 'triangle' && (
              <div
                style={{
                  width: 0,
                  height: 0,
                  borderLeft: `${size / 2}px solid transparent`,
                  borderRight: `${size / 2}px solid transparent`,
                  borderBottom: `${size}px solid ${color}`,
                }}
              />
            )}
          </div>
        );
      })}
    </div>
  );
}

function BirthdayTodayCard({ person }: { person: Person }) {
  const age = getUpcomingAge(person.dateOfBirth);
  const initials = getInitials(person.name);

  return (
    <div className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-purple via-pink to-coral p-1">
      <div className="relative overflow-hidden rounded-[22px] bg-white p-6 sm:p-8">
        <Confetti />
        <div className="relative z-10 flex flex-col sm:flex-row items-center gap-6 text-center sm:text-left">
          <div className="relative">
            <div className="w-24 h-24 rounded-full bg-gradient-to-br from-yellow to-orange flex items-center justify-center text-white text-3xl font-display font-bold shadow-lg shadow-yellow/30">
              {initials}
            </div>
            <div className="absolute -top-2 -right-2 w-10 h-10 bg-coral rounded-full flex items-center justify-center text-white text-lg animate-bounce shadow-md">
              🎂
            </div>
          </div>
          <div className="flex-1">
            <p className="text-sm font-bold uppercase tracking-widest text-pink mb-1">
              Today&apos;s Birthday
            </p>
            <h3 className="font-display text-3xl sm:text-4xl font-bold text-purple-dark mb-2">
              {person.name}
            </h3>
            <div className="flex flex-wrap items-center justify-center sm:justify-start gap-3">
              {age !== null && (
                <span className="inline-flex items-center gap-1.5 px-4 py-1.5 rounded-full bg-yellow-light text-purple-dark text-sm font-bold">
                  Turning {age}
                </span>
              )}
              <span className={`inline-flex items-center px-3 py-1.5 rounded-full text-xs font-bold ${RELATIONSHIP_STYLES[person.relationship].bg} ${RELATIONSHIP_STYLES[person.relationship].text}`}>
                {RELATIONSHIP_STYLES[person.relationship].label}
              </span>
            </div>
          </div>
          <div className="text-6xl sm:text-7xl animate-[wiggle_1s_ease-in-out_infinite]">
            🎈
          </div>
        </div>
      </div>
    </div>
  );
}

function UpcomingCard({ person, index }: { person: Person; index: number }) {
  const days = daysUntilBirthday(person.dateOfBirth);
  const age = getUpcomingAge(person.dateOfBirth);
  const initials = getInitials(person.name);
  const accent = ACCENT_COLORS[index % ACCENT_COLORS.length];
  const relStyle = RELATIONSHIP_STYLES[person.relationship];

  return (
    <div
      className="group relative rounded-2xl bg-white border-2 border-lavender hover:border-purple/30 transition-all duration-300 hover:shadow-xl hover:shadow-purple/8 hover:-translate-y-1"
      style={{ animationDelay: `${index * 80}ms` }}
    >
      <div className="absolute top-0 right-0 w-20 h-20 opacity-[0.04] pointer-events-none">
        <svg viewBox="0 0 80 80" fill="currentColor" className="text-purple w-full h-full">
          <circle cx="60" cy="20" r="60" />
        </svg>
      </div>

      <div className="relative p-5">
        <div className="flex items-start gap-4">
          <div className={`w-14 h-14 rounded-2xl ${accent.bg} ${accent.text} flex items-center justify-center text-lg font-display font-bold shrink-0 shadow-sm group-hover:scale-105 transition-transform duration-300`}>
            {initials}
          </div>
          <div className="flex-1 min-w-0">
            <h4 className="font-display text-lg font-bold text-foreground truncate">
              {person.name}
            </h4>
            <p className="text-sm text-foreground/50 mt-0.5">
              {formatDate(person.dateOfBirth)}
            </p>
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-2 mt-4">
          {age !== null && (
            <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-yellow-light text-purple-dark text-xs font-bold">
              🎂 Turning {age}
            </span>
          )}
          <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-xs font-bold ${relStyle.bg} ${relStyle.text}`}>
            {relStyle.label}
          </span>
          <span className="ml-auto inline-flex items-center px-3 py-1 rounded-full bg-purple/8 text-purple text-xs font-bold tabular-nums">
            {days === 0 ? 'Today!' : days === 1 ? 'Tomorrow!' : `in ${days} days`}
          </span>
        </div>
      </div>
    </div>
  );
}

function EmptyState() {
  return (
    <div className="relative overflow-hidden rounded-3xl border-2 border-dashed border-lavender bg-gradient-to-br from-lavender/30 via-white to-mint/30 p-10 sm:p-16 text-center">
      <div className="absolute top-6 left-8 text-5xl opacity-20 rotate-[-15deg]">🎈</div>
      <div className="absolute bottom-8 right-10 text-4xl opacity-20 rotate-12">🎁</div>
      <div className="absolute top-12 right-16 text-3xl opacity-15 rotate-6">🎂</div>

      <div className="relative z-10">
        <div className="w-20 h-20 mx-auto mb-6 rounded-full bg-lavender flex items-center justify-center">
          <span className="text-4xl">🎉</span>
        </div>
        <h3 className="font-display text-2xl sm:text-3xl font-bold text-purple mb-3">
          No birthdays yet!
        </h3>
        <p className="text-foreground/60 max-w-md mx-auto mb-8 leading-relaxed">
          Start adding the people you care about and never miss a celebration again.
        </p>
        <Link
          href="/people/new"
          className="inline-flex items-center gap-2 px-8 py-3.5 bg-purple text-white rounded-full font-bold text-sm hover:bg-purple-dark transition-colors shadow-lg shadow-purple/25 hover:shadow-purple/40"
        >
          <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
          </svg>
          Add your first birthday
        </Link>
      </div>
    </div>
  );
}

export default function Home() {
  const { people, loading } = usePeople();

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="w-10 h-10 rounded-full border-4 border-lavender border-t-purple animate-spin" />
      </div>
    );
  }

  const todayBirthdays = people.filter((p) => isBirthdayToday(p.dateOfBirth));
  const upcoming = [...people]
    .sort((a, b) => daysUntilBirthday(a.dateOfBirth) - daysUntilBirthday(b.dateOfBirth))
    .filter((p) => !isBirthdayToday(p.dateOfBirth))
    .slice(0, 8);

  return (
    <>
      <style jsx global>{`
        @keyframes confetti-fall {
          0% { transform: translateY(-20px) rotate(0deg); opacity: 1; }
          50% { opacity: 0.8; }
          100% { transform: translateY(100vh) rotate(720deg); opacity: 0; }
        }
        @keyframes wiggle {
          0%, 100% { transform: rotate(-6deg); }
          50% { transform: rotate(6deg); }
        }
        @keyframes fade-up {
          from { opacity: 0; transform: translateY(20px); }
          to { opacity: 1; transform: translateY(0); }
        }
        .animate-fade-up {
          animation: fade-up 0.5s ease-out both;
        }
      `}</style>

      {/* Hero */}
      <section className="relative overflow-hidden bg-gradient-to-b from-lavender/40 via-white to-white pt-8 pb-12 sm:pt-12 sm:pb-16">
        {/* Decorative shapes */}
        <div className="absolute top-0 right-0 w-72 h-72 bg-pink/5 rounded-full -translate-y-1/3 translate-x-1/3" />
        <div className="absolute bottom-0 left-0 w-56 h-56 bg-teal/5 rounded-full translate-y-1/3 -translate-x-1/4" />
        <div className="absolute top-16 left-[10%] w-4 h-4 bg-yellow rounded-full opacity-40" />
        <div className="absolute top-32 right-[15%] w-3 h-3 bg-pink rounded-full opacity-30" />
        <div className="absolute bottom-20 left-[25%] w-2.5 h-2.5 bg-teal rounded-full opacity-35" />
        <div className="absolute top-24 right-[35%] w-3.5 h-3.5 bg-coral rotate-45 opacity-25" />

        <div className="relative z-10 max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="animate-fade-up flex flex-col sm:flex-row items-center sm:items-start gap-6">
            <img src="/logo.png" alt="Tiaras & Trains" className="w-28 h-28 sm:w-36 sm:h-36 drop-shadow-lg" />
            <div>
              <h1 className="font-display text-4xl sm:text-5xl lg:text-6xl font-bold text-purple leading-tight text-center sm:text-left">
                Tiaras &amp;{' '}
                <span className="bg-gradient-to-r from-pink via-coral to-orange bg-clip-text text-transparent">
                  Trains
                </span>
              </h1>
              <p className="mt-4 text-lg sm:text-xl text-foreground/60 max-w-lg leading-relaxed text-center sm:text-left">
                Track your loved ones&apos; birthdays, never miss a milestone,
                and make every celebration unforgettable.
              </p>
            </div>
          </div>

          <div className="flex flex-wrap gap-3 mt-8 animate-fade-up" style={{ animationDelay: '150ms' }}>
            <Link
              href="/people/new"
              className="inline-flex items-center gap-2 px-6 py-3 bg-purple text-white rounded-full font-bold text-sm hover:bg-purple-dark transition-all shadow-lg shadow-purple/25 hover:shadow-purple/40 hover:-translate-y-0.5"
            >
              <svg className="w-4.5 h-4.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
              </svg>
              Add Birthday
            </Link>
            <Link
              href="/calendar"
              className="inline-flex items-center gap-2 px-6 py-3 bg-white text-purple border-2 border-purple/20 rounded-full font-bold text-sm hover:border-purple/40 hover:bg-lavender/30 transition-all"
            >
              <svg className="w-4.5 h-4.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 012.25-2.25h13.5A2.25 2.25 0 0121 7.5v11.25m-18 0A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75m-18 0v-7.5A2.25 2.25 0 015.25 9h13.5A2.25 2.25 0 0121 11.25v7.5" />
              </svg>
              View Calendar
            </Link>
          </div>

          {/* Stats row */}
          {people.length > 0 && (
            <div className="flex flex-wrap gap-4 mt-10 animate-fade-up" style={{ animationDelay: '300ms' }}>
              <div className="flex items-center gap-2.5 px-5 py-2.5 rounded-2xl bg-white border border-lavender shadow-sm">
                <div className="w-8 h-8 rounded-lg bg-purple/10 flex items-center justify-center text-sm">🎂</div>
                <div>
                  <p className="text-xs text-foreground/50 font-semibold">Tracking</p>
                  <p className="text-lg font-bold text-purple tabular-nums">{people.length}</p>
                </div>
              </div>
              {todayBirthdays.length > 0 && (
                <div className="flex items-center gap-2.5 px-5 py-2.5 rounded-2xl bg-white border border-lavender shadow-sm">
                  <div className="w-8 h-8 rounded-lg bg-coral/10 flex items-center justify-center text-sm">🎉</div>
                  <div>
                    <p className="text-xs text-foreground/50 font-semibold">Today</p>
                    <p className="text-lg font-bold text-coral tabular-nums">{todayBirthdays.length}</p>
                  </div>
                </div>
              )}
              {upcoming.length > 0 && (
                <div className="flex items-center gap-2.5 px-5 py-2.5 rounded-2xl bg-white border border-lavender shadow-sm">
                  <div className="w-8 h-8 rounded-lg bg-teal/10 flex items-center justify-center text-sm">🗓</div>
                  <div>
                    <p className="text-xs text-foreground/50 font-semibold">Next up</p>
                    <p className="text-lg font-bold text-teal tabular-nums">{daysUntilBirthday(upcoming[0].dateOfBirth)} days</p>
                  </div>
                </div>
              )}
            </div>
          )}
        </div>
      </section>

      {/* Main Content */}
      <section className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 pb-20">
        {people.length === 0 ? (
          <EmptyState />
        ) : (
          <div className="space-y-10">
            {/* Today's Birthdays */}
            {todayBirthdays.length > 0 && (
              <div>
                <h2 className="font-display text-2xl font-bold text-purple mb-5 flex items-center gap-2">
                  <span className="w-8 h-8 rounded-lg bg-coral/10 flex items-center justify-center text-base">🎉</span>
                  Today&apos;s Birthdays
                </h2>
                <div className="grid gap-4">
                  {todayBirthdays.map((person) => (
                    <BirthdayTodayCard key={person.id} person={person} />
                  ))}
                </div>
              </div>
            )}

            {/* Upcoming */}
            {upcoming.length > 0 && (
              <div>
                <div className="flex items-center justify-between mb-5">
                  <h2 className="font-display text-2xl font-bold text-purple flex items-center gap-2">
                    <span className="w-8 h-8 rounded-lg bg-purple/10 flex items-center justify-center text-base">🗓</span>
                    Coming Up
                  </h2>
                  <Link
                    href="/people"
                    className="text-sm font-bold text-purple/60 hover:text-purple transition-colors"
                  >
                    View all &rarr;
                  </Link>
                </div>
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
                  {upcoming.map((person, i) => (
                    <UpcomingCard key={person.id} person={person} index={i} />
                  ))}
                </div>
              </div>
            )}
          </div>
        )}
      </section>
    </>
  );
}
