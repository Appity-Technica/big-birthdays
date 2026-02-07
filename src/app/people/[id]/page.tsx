'use client';

import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { usePeople } from '@/hooks/usePeople';
import { getCurrentAge, daysUntilBirthday, getUpcomingAge, formatDate } from '@/lib/utils';

const RELATIONSHIP_STYLES = {
  family: { bg: 'bg-pink/15', text: 'text-pink', label: 'Family' },
  friend: { bg: 'bg-teal/15', text: 'text-teal', label: 'Friend' },
  colleague: { bg: 'bg-orange/15', text: 'text-orange', label: 'Colleague' },
  other: { bg: 'bg-purple-light/15', text: 'text-purple-light', label: 'Other' },
};

function getInitials(name: string): string {
  return name.split(' ').map((n) => n[0]).join('').toUpperCase().slice(0, 2);
}

export default function PersonDetailPage() {
  const params = useParams();
  const router = useRouter();
  const { getPersonById, deletePerson: removePerson, loading } = usePeople();

  const person = getPersonById(params.id as string);

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="w-10 h-10 rounded-full border-4 border-lavender border-t-purple animate-spin" />
      </div>
    );
  }

  if (!person) {
    return (
      <div className="max-w-2xl mx-auto px-4 py-16 text-center">
        <h1 className="font-display text-2xl font-bold text-purple mb-4">Person not found</h1>
        <Link href="/people" className="text-sm font-bold text-purple/60 hover:text-purple">
          &larr; Back to People
        </Link>
      </div>
    );
  }

  const age = getCurrentAge(person.dateOfBirth);
  const days = daysUntilBirthday(person.dateOfBirth);
  const upcomingAge = getUpcomingAge(person.dateOfBirth);
  const relStyle = RELATIONSHIP_STYLES[person.relationship];

  async function handleDelete() {
    if (confirm(`Remove ${person!.name}? This cannot be undone.`)) {
      await removePerson(person!.id);
      router.push('/people');
    }
  }

  return (
    <div className="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <Link
        href="/people"
        className="inline-flex items-center gap-1.5 text-sm font-semibold text-purple/60 hover:text-purple transition-colors mb-6"
      >
        <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
          <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 19.5L8.25 12l7.5-7.5" />
        </svg>
        Back to People
      </Link>

      {/* Profile header */}
      <div className="flex flex-col sm:flex-row items-center sm:items-start gap-6 mb-8">
        <div className="w-24 h-24 rounded-2xl bg-gradient-to-br from-pink to-coral text-white flex items-center justify-center text-3xl font-display font-bold shadow-lg shadow-pink/20">
          {getInitials(person.name)}
        </div>
        <div className="text-center sm:text-left flex-1">
          <h1 className="font-display text-3xl font-bold text-purple">{person.name}</h1>
          <p className="text-foreground/50 mt-1">Age {age} &middot; {formatDate(person.dateOfBirth)}</p>
          <div className="flex flex-wrap items-center justify-center sm:justify-start gap-2 mt-3">
            <span className={`inline-flex items-center px-3 py-1 rounded-full text-xs font-bold ${relStyle.bg} ${relStyle.text}`}>
              {relStyle.label}
            </span>
            <span className="inline-flex items-center px-3 py-1 rounded-full bg-yellow-light text-purple-dark text-xs font-bold">
              Turning {upcomingAge}
            </span>
            <span className="inline-flex items-center px-3 py-1 rounded-full bg-purple/8 text-purple text-xs font-bold">
              {days === 0 ? 'Birthday today!' : days === 1 ? 'Birthday tomorrow!' : `${days} days away`}
            </span>
          </div>
        </div>
      </div>

      {/* Details */}
      <div className="space-y-6">
        {/* Connection context */}
        {(person.connectedThrough || person.knownFrom) && (
          <div className="p-5 rounded-2xl bg-purple/5 border border-purple/15">
            <h3 className="text-sm font-bold text-purple mb-3">Connection</h3>
            <div className="flex flex-wrap items-center gap-2">
              {person.connectedThrough && (
                <span className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-purple/10 text-purple text-xs font-bold">
                  Via {person.connectedThrough}
                </span>
              )}
              {person.knownFrom && (
                <span className="inline-flex items-center px-3 py-1.5 rounded-full bg-lavender text-purple-dark text-xs font-bold">
                  {person.knownFrom === 'other' && person.knownFromCustom
                    ? person.knownFromCustom
                    : person.knownFrom === 'family-friend'
                    ? 'Family friend'
                    : person.knownFrom.charAt(0).toUpperCase() + person.knownFrom.slice(1)}
                </span>
              )}
            </div>
          </div>
        )}

        {/* Parties */}
        {person.parties && person.parties.length > 0 && (
          <div className="p-5 rounded-2xl bg-mint/30 border border-mint">
            <h3 className="text-sm font-bold text-teal mb-3">Parties</h3>
            <div className="space-y-3">
              {person.parties.map((party, i) => (
                <div key={i} className="p-3 rounded-xl bg-white/70">
                  <div className="flex items-center gap-2 mb-1">
                    <span className="text-sm font-bold text-foreground">{party.year}</span>
                    {party.date && (
                      <span className="text-xs text-foreground/50">
                        {new Date(party.date).toLocaleDateString('en-GB', { day: 'numeric', month: 'short' })}
                      </span>
                    )}
                  </div>
                  {party.invitedNames && party.invitedNames.length > 0 && (
                    <div className="flex flex-wrap gap-1.5 mt-2">
                      <span className="text-xs text-foreground/50 font-semibold mr-1">Invited:</span>
                      {party.invitedNames.map((name) => (
                        <span key={name} className="px-2 py-0.5 rounded-full bg-teal/10 text-teal text-xs font-bold">
                          {name}
                        </span>
                      ))}
                    </div>
                  )}
                  {party.notes && (
                    <p className="text-xs text-foreground/60 mt-1.5">{party.notes}</p>
                  )}
                </div>
              ))}
            </div>
          </div>
        )}

        {person.notes && (
          <div className="p-5 rounded-2xl bg-lavender/30 border border-lavender">
            <h3 className="text-sm font-bold text-purple mb-2">Notes</h3>
            <p className="text-foreground/70 whitespace-pre-wrap">{person.notes}</p>
          </div>
        )}

        {person.interests && person.interests.length > 0 && (
          <div className="p-5 rounded-2xl bg-mint/30 border border-mint">
            <h3 className="text-sm font-bold text-teal mb-3">Interests</h3>
            <div className="flex flex-wrap gap-2">
              {person.interests.map((interest) => (
                <span key={interest} className="px-3 py-1 rounded-full bg-teal/10 text-teal text-xs font-bold">
                  {interest}
                </span>
              ))}
            </div>
          </div>
        )}

        {person.giftIdeas && person.giftIdeas.length > 0 && (
          <div className="p-5 rounded-2xl bg-yellow-light/30 border border-yellow-light">
            <h3 className="text-sm font-bold text-orange mb-3">Gift Ideas</h3>
            <div className="flex flex-wrap gap-2">
              {person.giftIdeas.map((idea) => (
                <span key={idea} className="px-3 py-1 rounded-full bg-orange/10 text-orange text-xs font-bold">
                  {idea}
                </span>
              ))}
            </div>
          </div>
        )}
      </div>

      {/* Actions */}
      <div className="flex items-center gap-3 mt-10 pt-6 border-t border-lavender">
        <button
          onClick={handleDelete}
          className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full border-2 border-coral/30 text-coral text-sm font-bold hover:bg-coral/5 transition-colors"
        >
          <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
            <path strokeLinecap="round" strokeLinejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 01-2.244 2.077H8.084a2.25 2.25 0 01-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 00-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 013.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 00-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 00-7.5 0" />
          </svg>
          Delete
        </button>
      </div>
    </div>
  );
}
