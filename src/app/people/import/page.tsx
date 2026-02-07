'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { fetchGoogleContactsWithBirthdays, GoogleContact } from '@/lib/contacts';
import { usePeople } from '@/hooks/usePeople';
import { formatDate } from '@/lib/utils';

export default function ImportContactsPage() {
  const router = useRouter();
  const { people, addPerson } = usePeople();
  const [contacts, setContacts] = useState<GoogleContact[]>([]);
  const [selected, setSelected] = useState<Set<number>>(new Set());
  const [loading, setLoading] = useState(false);
  const [importing, setImporting] = useState(false);
  const [error, setError] = useState('');
  const [step, setStep] = useState<'start' | 'select' | 'done'>('start');
  const [importedCount, setImportedCount] = useState(0);

  // Names already tracked (for dedup hints)
  const existingNames = new Set(people.map((p) => p.name.toLowerCase()));

  async function handleFetch() {
    setLoading(true);
    setError('');
    try {
      const results = await fetchGoogleContactsWithBirthdays();
      setContacts(results);
      // Pre-select contacts that aren't already tracked
      const preSelected = new Set<number>();
      results.forEach((c, i) => {
        if (!existingNames.has(c.name.toLowerCase())) {
          preSelected.add(i);
        }
      });
      setSelected(preSelected);
      setStep('select');
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : 'Something went wrong';
      if (!message.includes('popup-closed')) {
        setError(message.replace('Firebase: ', '').replace(/\(auth\/.*\)/, '').trim());
      }
    } finally {
      setLoading(false);
    }
  }

  function toggleSelect(index: number) {
    setSelected((prev) => {
      const next = new Set(prev);
      if (next.has(index)) {
        next.delete(index);
      } else {
        next.add(index);
      }
      return next;
    });
  }

  function selectAll() {
    setSelected(new Set(contacts.map((_, i) => i)));
  }

  function selectNone() {
    setSelected(new Set());
  }

  async function handleImport() {
    setImporting(true);
    let count = 0;
    for (const index of selected) {
      const contact = contacts[index];
      await addPerson({
        name: contact.name,
        dateOfBirth: contact.dateOfBirth,
        photo: contact.photo,
        relationship: 'friend',
      });
      count++;
    }
    setImportedCount(count);
    setStep('done');
    setImporting(false);
  }

  return (
    <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Back link */}
      <Link
        href="/people"
        className="inline-flex items-center gap-1.5 text-sm font-semibold text-purple/60 hover:text-purple transition-colors mb-6"
      >
        <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
          <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 19.5L8.25 12l7.5-7.5" />
        </svg>
        Back to People
      </Link>

      <h1 className="font-display text-3xl sm:text-4xl font-bold text-purple mb-2">Import Contacts</h1>
      <p className="text-foreground/50 mb-8">
        Import birthdays from your Google Contacts.
      </p>

      {/* Step: Start */}
      {step === 'start' && (
        <div className="text-center py-12">
          <div className="w-20 h-20 mx-auto mb-6 rounded-full bg-lavender flex items-center justify-center">
            <svg className="w-10 h-10 text-purple" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={1.5}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M15 19.128a9.38 9.38 0 002.625.372 9.337 9.337 0 004.121-.952 4.125 4.125 0 00-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 018.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0111.964-3.07M12 6.375a3.375 3.375 0 11-6.75 0 3.375 3.375 0 016.75 0zm8.25 2.25a2.625 2.625 0 11-5.25 0 2.625 2.625 0 015.25 0z" />
            </svg>
          </div>

          {error && (
            <div className="max-w-md mx-auto mb-6 p-3 rounded-xl bg-coral/10 border border-coral/20 text-coral text-sm font-semibold">
              {error}
            </div>
          )}

          <p className="text-foreground/60 max-w-md mx-auto mb-8 leading-relaxed">
            Connect your Google account to find contacts with birthdays.
            Only contacts that have a birthday set will be shown.
          </p>

          <button
            onClick={handleFetch}
            disabled={loading}
            className="inline-flex items-center gap-3 px-8 py-3.5 bg-purple text-white rounded-full font-bold text-sm hover:bg-purple-dark transition-all shadow-lg shadow-purple/25 disabled:opacity-50"
          >
            {loading ? (
              <>
                <div className="w-5 h-5 rounded-full border-2 border-white/30 border-t-white animate-spin" />
                Fetching contacts...
              </>
            ) : (
              <>
                <svg className="w-5 h-5" viewBox="0 0 24 24">
                  <path fill="currentColor" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.06 5.06 0 01-2.2 3.32v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.1z" />
                  <path fill="currentColor" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" />
                  <path fill="currentColor" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" />
                  <path fill="currentColor" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" />
                </svg>
                Connect Google Contacts
              </>
            )}
          </button>
        </div>
      )}

      {/* Step: Select */}
      {step === 'select' && (
        <>
          {contacts.length === 0 ? (
            <div className="text-center py-12">
              <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-lavender flex items-center justify-center">
                <span className="text-3xl">🤷</span>
              </div>
              <h3 className="font-display text-xl font-bold text-purple mb-2">No birthdays found</h3>
              <p className="text-foreground/50 max-w-sm mx-auto">
                None of your Google Contacts have a birthday set. You can add birthdays in Google Contacts and try again.
              </p>
            </div>
          ) : (
            <>
              <div className="flex flex-wrap items-center justify-between gap-3 mb-4">
                <p className="text-sm font-bold text-foreground/60">
                  {contacts.length} contacts with birthdays found &middot; {selected.size} selected
                </p>
                <div className="flex items-center gap-2">
                  <button
                    onClick={selectAll}
                    className="px-3 py-1.5 rounded-full text-xs font-bold text-purple hover:bg-lavender transition-colors"
                  >
                    Select all
                  </button>
                  <button
                    onClick={selectNone}
                    className="px-3 py-1.5 rounded-full text-xs font-bold text-foreground/40 hover:bg-lavender transition-colors"
                  >
                    Select none
                  </button>
                </div>
              </div>

              <div className="grid gap-2 mb-6">
                {contacts.map((contact, i) => {
                  const isSelected = selected.has(i);
                  const isDuplicate = existingNames.has(contact.name.toLowerCase());
                  const initials = contact.name.split(' ').map((n) => n[0]).join('').toUpperCase().slice(0, 2);

                  return (
                    <button
                      key={i}
                      onClick={() => toggleSelect(i)}
                      className={`flex items-center gap-3 p-3 rounded-xl border-2 text-left transition-all ${
                        isSelected
                          ? 'border-purple bg-purple/5'
                          : 'border-lavender hover:border-purple/20'
                      }`}
                    >
                      {/* Checkbox */}
                      <div className={`w-5 h-5 rounded border-2 flex items-center justify-center shrink-0 transition-colors ${
                        isSelected ? 'bg-purple border-purple' : 'border-lavender'
                      }`}>
                        {isSelected && (
                          <svg className="w-3 h-3 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={3}>
                            <path strokeLinecap="round" strokeLinejoin="round" d="M4.5 12.75l6 6 9-13.5" />
                          </svg>
                        )}
                      </div>

                      {/* Avatar */}
                      {contact.photo ? (
                        <img
                          src={contact.photo}
                          alt=""
                          className="w-10 h-10 rounded-lg object-cover shrink-0"
                          referrerPolicy="no-referrer"
                        />
                      ) : (
                        <div className="w-10 h-10 rounded-lg bg-pink text-white flex items-center justify-center text-sm font-display font-bold shrink-0">
                          {initials}
                        </div>
                      )}

                      {/* Info */}
                      <div className="flex-1 min-w-0">
                        <p className="font-bold text-sm text-foreground truncate">
                          {contact.name}
                        </p>
                        <p className="text-xs text-foreground/50">
                          {formatDate(contact.dateOfBirth)}
                        </p>
                      </div>

                      {/* Duplicate hint */}
                      {isDuplicate && (
                        <span className="px-2.5 py-1 rounded-full bg-yellow-light text-purple-dark text-[10px] font-bold shrink-0">
                          Already tracked
                        </span>
                      )}
                    </button>
                  );
                })}
              </div>

              <div className="flex items-center gap-3 sticky bottom-4">
                <button
                  onClick={handleImport}
                  disabled={selected.size === 0 || importing}
                  className="inline-flex items-center gap-2 px-8 py-3.5 bg-purple text-white rounded-full font-bold text-sm hover:bg-purple-dark transition-all shadow-lg shadow-purple/25 disabled:opacity-50"
                >
                  {importing ? (
                    <>
                      <div className="w-5 h-5 rounded-full border-2 border-white/30 border-t-white animate-spin" />
                      Importing...
                    </>
                  ) : (
                    <>
                      Import {selected.size} {selected.size === 1 ? 'contact' : 'contacts'}
                    </>
                  )}
                </button>
                <Link
                  href="/people"
                  className="px-6 py-3.5 text-sm font-bold text-foreground/50 hover:text-foreground transition-colors"
                >
                  Cancel
                </Link>
              </div>
            </>
          )}
        </>
      )}

      {/* Step: Done */}
      {step === 'done' && (
        <div className="text-center py-12">
          <div className="w-20 h-20 mx-auto mb-6 rounded-full bg-mint flex items-center justify-center">
            <svg className="w-10 h-10 text-teal" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <h3 className="font-display text-2xl font-bold text-purple mb-2">
            {importedCount} {importedCount === 1 ? 'birthday' : 'birthdays'} imported!
          </h3>
          <p className="text-foreground/50 mb-8">
            Your contacts have been added to Big Birthdays.
          </p>
          <Link
            href="/people"
            className="inline-flex items-center gap-2 px-8 py-3.5 bg-purple text-white rounded-full font-bold text-sm hover:bg-purple-dark transition-all shadow-lg shadow-purple/25"
          >
            View People
          </Link>
        </div>
      )}
    </div>
  );
}
