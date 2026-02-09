'use client';

import { useState } from 'react';
import Link from 'next/link';
import { usePeople } from '@/hooks/usePeople';
import { Relationship, KnownFrom } from '@/types';
import { daysUntilBirthday, getUpcomingAge, getCurrentAge, formatDate } from '@/lib/utils';

const ACCENT_COLORS = [
  'bg-pink', 'bg-teal', 'bg-orange', 'bg-coral', 'bg-purple-light',
];

const RELATIONSHIP_STYLES: Record<Relationship, { bg: string; text: string; label: string }> = {
  family: { bg: 'bg-pink/15', text: 'text-pink', label: 'Family' },
  friend: { bg: 'bg-teal/15', text: 'text-teal', label: 'Friend' },
  colleague: { bg: 'bg-orange/15', text: 'text-orange', label: 'Colleague' },
  other: { bg: 'bg-purple-light/15', text: 'text-purple-light', label: 'Other' },
};

function getInitials(name: string): string {
  return name.split(' ').map((n) => n[0]).join('').toUpperCase().slice(0, 2);
}

export default function PeoplePage() {
  const { people, loading, deletePerson: removePerson } = usePeople();
  const [filter, setFilter] = useState<Relationship | 'all'>('all');
  const [knownFromFilter, setKnownFromFilter] = useState<KnownFrom | 'all'>('all');
  const [sortBy, setSortBy] = useState<'name' | 'upcoming'>('upcoming');

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="w-10 h-10 rounded-full border-4 border-lavender border-t-purple animate-spin" />
      </div>
    );
  }

  const filtered = people
    .filter((p) => filter === 'all' || p.relationship === filter)
    .filter((p) => knownFromFilter === 'all' || p.knownFrom === knownFromFilter);
  const sorted = [...filtered].sort((a, b) => {
    if (sortBy === 'name') return a.name.localeCompare(b.name);
    return daysUntilBirthday(a.dateOfBirth) - daysUntilBirthday(b.dateOfBirth);
  });

  function handleDelete(id: string, name: string) {
    if (confirm(`Remove ${name}? This cannot be undone.`)) {
      removePerson(id);
    }
  }

  return (
    <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-8">
        <div>
          <h1 className="font-display text-3xl sm:text-4xl font-bold text-purple">People</h1>
          <p className="text-foreground/50 mt-1">
            {people.length} {people.length === 1 ? 'person' : 'people'} tracked
          </p>
        </div>
        <div className="flex items-center gap-2 self-start">
          <Link
            href="/people/export"
            className="inline-flex items-center gap-2 px-5 py-3 bg-surface text-purple border-2 border-purple/20 rounded-full font-bold text-sm hover:border-purple/40 hover:bg-lavender/30 transition-all"
          >
            <svg className="w-4.5 h-4.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5M16.5 12L12 16.5m0 0L7.5 12m4.5 4.5V3" />
            </svg>
            Export
          </Link>
          <Link
            href="/people/import"
            className="inline-flex items-center gap-2 px-5 py-3 bg-surface text-purple border-2 border-purple/20 rounded-full font-bold text-sm hover:border-purple/40 hover:bg-lavender/30 transition-all"
          >
            <svg className="w-4.5 h-4.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5m-13.5-9L12 3m0 0l4.5 4.5M12 3v13.5" />
            </svg>
            Import
          </Link>
          <Link
            href="/people/new"
            className="inline-flex items-center gap-2 px-6 py-3 bg-purple text-white rounded-full font-bold text-sm hover:bg-purple-dark transition-all shadow-lg shadow-purple/25"
          >
            <svg className="w-4.5 h-4.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
            </svg>
            Add Person
          </Link>
        </div>
      </div>

      {/* Filters & Sort */}
      {people.length > 0 && (
        <div className="flex flex-wrap items-center gap-3 mb-6">
          <div className="flex items-center gap-1 bg-lavender/40 rounded-full p-1">
            {(['all', 'family', 'friend', 'colleague', 'other'] as const).map((f) => (
              <button
                key={f}
                onClick={() => setFilter(f)}
                className={`px-3.5 py-1.5 rounded-full text-xs font-bold transition-colors ${
                  filter === f
                    ? 'bg-purple text-white'
                    : 'text-purple-dark hover:bg-lavender'
                }`}
              >
                {f === 'all' ? 'All' : f.charAt(0).toUpperCase() + f.slice(1)}
              </button>
            ))}
          </div>
          {/* Known from filter */}
          {(() => {
            const knownFromValues = [...new Set(people.map((p) => p.knownFrom).filter(Boolean))] as KnownFrom[];
            if (knownFromValues.length === 0) return null;
            const labels: Record<string, string> = {
              school: 'School', dance: 'Dance', sports: 'Sports', scouts: 'Scouts',
              neighbourhood: 'Neighbourhood', work: 'Work', church: 'Church',
              'family-friend': 'Family friend', other: 'Other',
            };
            return (
              <div className="flex items-center gap-1 bg-mint/40 rounded-full p-1">
                <button
                  onClick={() => setKnownFromFilter('all')}
                  className={`px-3.5 py-1.5 rounded-full text-xs font-bold transition-colors ${
                    knownFromFilter === 'all' ? 'bg-teal text-white' : 'text-teal hover:bg-mint'
                  }`}
                >
                  All
                </button>
                {knownFromValues.map((kf) => (
                  <button
                    key={kf}
                    onClick={() => setKnownFromFilter(kf)}
                    className={`px-3.5 py-1.5 rounded-full text-xs font-bold transition-colors ${
                      knownFromFilter === kf ? 'bg-teal text-white' : 'text-teal hover:bg-mint'
                    }`}
                  >
                    {labels[kf] || kf}
                  </button>
                ))}
              </div>
            );
          })()}

          <div className="flex items-center gap-1 bg-lavender/40 rounded-full p-1 ml-auto">
            <button
              onClick={() => setSortBy('upcoming')}
              className={`px-3.5 py-1.5 rounded-full text-xs font-bold transition-colors ${
                sortBy === 'upcoming' ? 'bg-purple text-white' : 'text-purple-dark hover:bg-lavender'
              }`}
            >
              Upcoming
            </button>
            <button
              onClick={() => setSortBy('name')}
              className={`px-3.5 py-1.5 rounded-full text-xs font-bold transition-colors ${
                sortBy === 'name' ? 'bg-purple text-white' : 'text-purple-dark hover:bg-lavender'
              }`}
            >
              A-Z
            </button>
          </div>
        </div>
      )}

      {/* People list */}
      {sorted.length === 0 ? (
        <div className="text-center py-16">
          <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-lavender flex items-center justify-center">
            <span className="text-3xl">🎉</span>
          </div>
          <h3 className="font-display text-xl font-bold text-purple mb-2">
            {people.length === 0 ? 'No people yet' : 'No matches'}
          </h3>
          <p className="text-foreground/50">
            {people.length === 0
              ? 'Add someone to start tracking birthdays!'
              : 'Try a different filter.'}
          </p>
        </div>
      ) : (
        <div className="grid gap-3">
          {sorted.map((person, i) => {
            const days = daysUntilBirthday(person.dateOfBirth);
            const age = getCurrentAge(person.dateOfBirth);
            const upcomingAge = getUpcomingAge(person.dateOfBirth);
            const initials = getInitials(person.name);
            const accent = ACCENT_COLORS[i % ACCENT_COLORS.length];
            const relStyle = RELATIONSHIP_STYLES[person.relationship];

            return (
              <div
                key={person.id}
                className="group flex items-center gap-4 p-4 rounded-2xl bg-surface border-2 border-lavender hover:border-purple/30 transition-all hover:shadow-lg hover:shadow-purple/5"
              >
                <Link href={`/people/${person.id}`} className="flex items-center gap-4 flex-1 min-w-0">
                  <div className={`w-12 h-12 rounded-xl ${accent} text-white flex items-center justify-center text-base font-display font-bold shrink-0`}>
                    {initials}
                  </div>
                  <div className="flex-1 min-w-0">
                    <h3 className="font-display text-lg font-bold text-foreground truncate">
                      {person.name}
                    </h3>
                    <p className="text-sm text-foreground/50">
                      {age !== null ? `Age ${age} \u00b7 ` : ''}{formatDate(person.dateOfBirth)}
                      {(person.connectedThrough || person.knownFrom) && (
                        <span className="text-foreground/40">
                          {' '}&middot;{' '}
                          {[
                            person.connectedThrough ? `Via ${person.connectedThrough}` : null,
                            person.knownFrom
                              ? person.knownFrom === 'other' && person.knownFromCustom
                                ? person.knownFromCustom
                                : person.knownFrom === 'family-friend'
                                ? 'Family friend'
                                : person.knownFrom.charAt(0).toUpperCase() + person.knownFrom.slice(1)
                              : null,
                          ].filter(Boolean).join(' · ')}
                        </span>
                      )}
                    </p>
                  </div>
                </Link>
                <div className="hidden sm:flex items-center gap-2">
                  <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-xs font-bold ${relStyle.bg} ${relStyle.text}`}>
                    {relStyle.label}
                  </span>
                  {upcomingAge !== null && (
                    <span className="inline-flex items-center px-3 py-1 rounded-full bg-yellow-light text-purple-dark text-xs font-bold">
                      Turning {upcomingAge}
                    </span>
                  )}
                  <span className="inline-flex items-center px-3 py-1 rounded-full bg-purple/8 text-purple text-xs font-bold tabular-nums min-w-[80px] justify-center">
                    {days === 0 ? 'Today!' : days === 1 ? 'Tomorrow!' : `${days} days`}
                  </span>
                </div>
                <Link
                  href={`/people/${person.id}/edit`}
                  className="opacity-0 group-hover:opacity-100 p-2 rounded-lg hover:bg-purple/10 text-purple transition-all"
                  title="Edit"
                  onClick={(e) => e.stopPropagation()}
                >
                  <svg className="w-4.5 h-4.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                    <path strokeLinecap="round" strokeLinejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L10.582 16.07a4.5 4.5 0 0 1-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 0 1 1.13-1.897l8.932-8.931Zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0 1 15.75 21H5.25A2.25 2.25 0 0 1 3 18.75V8.25A2.25 2.25 0 0 1 5.25 6H10" />
                  </svg>
                </Link>
                <button
                  onClick={() => handleDelete(person.id, person.name)}
                  className="opacity-0 group-hover:opacity-100 p-2 rounded-lg hover:bg-coral/10 text-coral transition-all"
                  title="Delete"
                >
                  <svg className="w-4.5 h-4.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                    <path strokeLinecap="round" strokeLinejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 01-2.244 2.077H8.084a2.25 2.25 0 01-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 00-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 013.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 00-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 00-7.5 0" />
                  </svg>
                </button>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
