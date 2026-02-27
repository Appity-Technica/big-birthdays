'use client';

import { useState, useEffect } from 'react';
import { useParams } from 'next/navigation';
import Link from 'next/link';
import { useAuth } from '@/components/AuthProvider';
import { usePeople } from '@/hooks/usePeople';
import { getPreferences } from '@/lib/db';
import { getGiftSuggestions } from '@/lib/gifts';
import { getCurrentAge, formatDate } from '@/lib/utils';
import { GiftSuggestion, CountryCode } from '@/types';

type PageState = 'idle' | 'loading' | 'results' | 'error';

const CARD_COLORS = [
  'bg-mint/20 border-mint',
  'bg-lavender/20 border-lavender',
  'bg-yellow-light/20 border-yellow-light',
];

export default function GiftSuggestionsPage() {
  const params = useParams();
  const { user, loading: authLoading } = useAuth();
  const { getPersonById, loading: peopleLoading } = usePeople();
  const [state, setState] = useState<PageState>('idle');
  const [suggestions, setSuggestions] = useState<GiftSuggestion[]>([]);
  const [error, setError] = useState('');
  const [country, setCountry] = useState<CountryCode>('AU');

  const person = getPersonById(params.id as string);

  useEffect(() => {
    if (!user) return;
    getPreferences(user.uid).then((prefs) => {
      if (prefs) setCountry(prefs.country);
    });
  }, [user]);

  async function handleGetSuggestions() {
    if (!person) return;
    setState('loading');
    setError('');
    try {
      const results = await getGiftSuggestions(person, country);
      setSuggestions(results);
      setState('results');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Something went wrong. Please try again.');
      setState('error');
    }
  }

  if (authLoading || peopleLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="w-10 h-10 rounded-full border-4 border-lavender border-t-purple animate-spin" />
      </div>
    );
  }

  if (!user) {
    return (
      <div className="max-w-2xl mx-auto px-4 py-16 text-center">
        <h1 className="font-display text-2xl font-bold text-purple mb-4">Sign in required</h1>
        <p className="text-foreground/50 mb-6">You need to be signed in to use gift suggestions.</p>
        <Link href="/login" className="text-sm font-bold text-purple hover:underline">
          Sign in
        </Link>
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

  return (
    <div className="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <Link
        href={`/people/${person.id}`}
        className="inline-flex items-center gap-1.5 text-sm font-semibold text-purple/60 hover:text-purple transition-colors mb-6"
      >
        <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
          <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 19.5L8.25 12l7.5-7.5" />
        </svg>
        Back to {person.name}
      </Link>

      <h1 className="font-display text-3xl sm:text-4xl font-bold text-purple mb-2">
        Gift Ideas for {person.name}
      </h1>
      <p className="text-foreground/50 mb-8">
        {age !== null ? `Age ${age} · ` : ''}{formatDate(person.dateOfBirth)} · {person.relationship}
      </p>

      {state === 'idle' && (
        <>
          {/* Profile review */}
          <div className="space-y-4 mb-8">
            <div className="p-4 rounded-2xl bg-purple/5 border border-purple/15">
              <p className="text-xs font-bold text-purple/60 mb-2">Interests</p>
              {person.interests && person.interests.length > 0 ? (
                <div className="flex flex-wrap gap-1.5">
                  {person.interests.map((i) => (
                    <span key={i} className="px-2.5 py-1 rounded-full bg-teal/10 text-teal text-xs font-bold">{i}</span>
                  ))}
                </div>
              ) : (
                <p className="text-xs text-foreground/30 italic">Not provided — add interests for better results</p>
              )}
            </div>

            <div className="p-4 rounded-2xl bg-purple/5 border border-purple/15">
              <p className="text-xs font-bold text-purple/60 mb-2">Past Gifts</p>
              {person.pastGifts && person.pastGifts.length > 0 ? (
                <div className="flex flex-wrap gap-1.5">
                  {person.pastGifts.map((g, i) => (
                    <span key={i} className="px-2.5 py-1 rounded-full bg-pink/10 text-pink text-xs font-bold">
                      {g.description} ({g.year})
                    </span>
                  ))}
                </div>
              ) : (
                <p className="text-xs text-foreground/30 italic">No past gifts recorded</p>
              )}
            </div>

            <div className="p-4 rounded-2xl bg-purple/5 border border-purple/15">
              <p className="text-xs font-bold text-purple/60 mb-2">Notes & Gift Ideas</p>
              {(person.notes || (person.giftIdeas && person.giftIdeas.length > 0)) ? (
                <div className="space-y-2">
                  {person.notes && <p className="text-sm text-foreground/70">{person.notes}</p>}
                  {person.giftIdeas && person.giftIdeas.length > 0 && (
                    <div className="flex flex-wrap gap-1.5">
                      {person.giftIdeas.map((idea) => (
                        <span key={idea} className="px-2.5 py-1 rounded-full bg-orange/10 text-orange text-xs font-bold">{idea}</span>
                      ))}
                    </div>
                  )}
                </div>
              ) : (
                <p className="text-xs text-foreground/30 italic">Not provided</p>
              )}
            </div>
          </div>

          <div className="p-4 rounded-2xl bg-yellow-light/20 border border-yellow-light mb-6">
            <p className="text-xs font-semibold text-foreground/60">
              The more details you add to {person.name}&apos;s profile (interests, past gifts, notes), the better the suggestions will be.
            </p>
          </div>

          <button
            onClick={handleGetSuggestions}
            className="inline-flex items-center gap-2 px-8 py-3.5 bg-purple text-white rounded-full font-bold text-sm hover:bg-purple-dark transition-all shadow-lg shadow-purple/25"
          >
            <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M9.813 15.904L9 18.75l-.813-2.846a4.5 4.5 0 00-3.09-3.09L2.25 12l2.846-.813a4.5 4.5 0 003.09-3.09L9 5.25l.813 2.846a4.5 4.5 0 003.09 3.09L15.75 12l-2.846.813a4.5 4.5 0 00-3.09 3.09zM18.259 8.715L18 9.75l-.259-1.035a3.375 3.375 0 00-2.455-2.456L14.25 6l1.036-.259a3.375 3.375 0 002.455-2.456L18 2.25l.259 1.035a3.375 3.375 0 002.455 2.456L21.75 6l-1.036.259a3.375 3.375 0 00-2.455 2.456z" />
            </svg>
            Get Gift Ideas
          </button>
        </>
      )}

      {state === 'loading' && (
        <div className="flex flex-col items-center justify-center py-16">
          <div className="w-12 h-12 rounded-full border-4 border-lavender border-t-purple animate-spin mb-4" />
          <p className="text-sm font-semibold text-foreground/50">Finding the perfect gifts...</p>
        </div>
      )}

      {state === 'error' && (
        <div className="text-center py-12">
          <div className="inline-flex items-center justify-center w-14 h-14 rounded-full bg-coral/10 mb-4">
            <svg className="w-7 h-7 text-coral" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v3.75m9-.75a9 9 0 11-18 0 9 9 0 0118 0zm-9 3.75h.008v.008H12v-.008z" />
            </svg>
          </div>
          <p className="text-sm text-foreground/60 mb-6">{error}</p>
          <button
            onClick={handleGetSuggestions}
            className="inline-flex items-center gap-2 px-6 py-3 bg-purple text-white rounded-full font-bold text-sm hover:bg-purple-dark transition-all shadow-lg shadow-purple/25"
          >
            Try Again
          </button>
        </div>
      )}

      {state === 'results' && (
        <>
          <div className="space-y-4 mb-8">
            {suggestions.map((suggestion, i) => (
              <div
                key={i}
                className={`p-5 rounded-2xl border ${CARD_COLORS[i % CARD_COLORS.length]}`}
              >
                <div className="flex items-start justify-between gap-3 mb-2">
                  <h3 className="text-base font-bold text-foreground">{suggestion.name}</h3>
                  <span className="shrink-0 px-3 py-1 rounded-full bg-purple/10 text-purple text-xs font-bold">
                    {suggestion.estimatedPrice}
                  </span>
                </div>
                <p className="text-sm text-foreground/60 mb-3">{suggestion.description}</p>
                {suggestion.purchaseUrl && (
                  <a
                    href={suggestion.purchaseUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="inline-flex items-center gap-1.5 text-xs font-bold text-purple hover:text-purple-dark transition-colors"
                  >
                    Search
                    <svg className="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
                      <path strokeLinecap="round" strokeLinejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
                    </svg>
                  </a>
                )}
              </div>
            ))}
          </div>

          <button
            onClick={handleGetSuggestions}
            className="inline-flex items-center gap-2 px-6 py-3 rounded-full border-2 border-purple/30 text-purple text-sm font-bold hover:bg-purple/5 transition-colors"
          >
            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M16.023 9.348h4.992v-.001M2.985 19.644v-4.992m0 0h4.992m-4.993 0l3.181 3.183a8.25 8.25 0 0013.803-3.7M4.031 9.865a8.25 8.25 0 0113.803-3.7l3.181 3.182M2.985 19.644l3.181-3.182" />
            </svg>
            Get More Ideas
          </button>
        </>
      )}
    </div>
  );
}
