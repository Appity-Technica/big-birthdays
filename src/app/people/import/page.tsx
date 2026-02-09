'use client';

import { useState, useRef } from 'react';
import Link from 'next/link';
import { fetchGoogleContactsWithBirthdays } from '@/lib/contacts';
import { parseFile } from '@/lib/csv';
import { usePeople } from '@/hooks/usePeople';
import { formatDate } from '@/lib/utils';

type Contact = { name: string; dateOfBirth: string; photo?: string };

export default function ImportContactsPage() {
  const { people, addPerson } = usePeople();
  const [contacts, setContacts] = useState<Contact[]>([]);
  const [selected, setSelected] = useState<Set<number>>(new Set());
  const [loading, setLoading] = useState(false);
  const [importing, setImporting] = useState(false);
  const [error, setError] = useState('');
  const [step, setStep] = useState<'start' | 'select' | 'done'>('start');
  const [importedCount, setImportedCount] = useState(0);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const existingNames = new Set(people.map((p) => p.name.toLowerCase()));

  function loadContacts(results: Contact[]) {
    setContacts(results);
    const preSelected = new Set<number>();
    results.forEach((c, i) => {
      if (!existingNames.has(c.name.toLowerCase())) {
        preSelected.add(i);
      }
    });
    setSelected(preSelected);
    setStep('select');
  }

  async function handleGoogleFetch() {
    setLoading(true);
    setError('');
    try {
      const results = await fetchGoogleContactsWithBirthdays();
      loadContacts(results);
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : 'Something went wrong';
      if (!message.includes('popup-closed')) {
        setError(message.replace('Firebase: ', '').replace(/\(auth\/.*\)/, '').trim());
      }
    } finally {
      setLoading(false);
    }
  }

  function handleFileSelect(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;

    setError('');
    const reader = new FileReader();
    reader.onload = () => {
      try {
        const text = reader.result as string;
        const results = parseFile(text, file.name);
        loadContacts(results);
      } catch (err: unknown) {
        setError(err instanceof Error ? err.message : 'Could not parse file');
      }
    };
    reader.readAsText(file);

    // Reset so the same file can be re-selected
    e.target.value = '';
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
        Import birthdays from Google Contacts or a file.
      </p>

      {/* Hidden file input */}
      <input
        ref={fileInputRef}
        type="file"
        accept=".csv,.json"
        onChange={handleFileSelect}
        className="hidden"
      />

      {/* Step: Start */}
      {step === 'start' && (
        <div className="py-8">
          {error && (
            <div className="max-w-md mx-auto mb-6 p-3 rounded-xl bg-coral/10 border border-coral/20 text-coral text-sm font-semibold">
              {error}
            </div>
          )}

          <div className="grid sm:grid-cols-2 gap-4">
            {/* Google Contacts card */}
            <button
              onClick={handleGoogleFetch}
              disabled={loading}
              className="group flex flex-col items-center gap-4 p-8 rounded-2xl border-2 border-lavender hover:border-purple/30 bg-surface transition-all hover:shadow-lg hover:shadow-purple/5 text-center disabled:opacity-50"
            >
              <div className="w-16 h-16 rounded-full bg-lavender group-hover:bg-purple/10 flex items-center justify-center transition-colors">
                {loading ? (
                  <div className="w-8 h-8 rounded-full border-3 border-purple/20 border-t-purple animate-spin" />
                ) : (
                  <svg className="w-8 h-8" viewBox="0 0 24 24">
                    <path fill="#7B2D8E" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.06 5.06 0 01-2.2 3.32v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.1z" />
                    <path fill="#2EC4B6" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" />
                    <path fill="#F9C74F" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" />
                    <path fill="#E91E8C" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" />
                  </svg>
                )}
              </div>
              <div>
                <h3 className="font-display text-lg font-bold text-foreground mb-1">Google Contacts</h3>
                <p className="text-xs text-foreground/50 leading-relaxed">
                  Connect your Google account to find contacts with birthdays
                </p>
              </div>
            </button>

            {/* CSV / JSON card */}
            <button
              onClick={() => fileInputRef.current?.click()}
              className="group flex flex-col items-center gap-4 p-8 rounded-2xl border-2 border-lavender hover:border-teal/30 bg-surface transition-all hover:shadow-lg hover:shadow-teal/5 text-center"
            >
              <div className="w-16 h-16 rounded-full bg-mint group-hover:bg-teal/10 flex items-center justify-center transition-colors">
                <svg className="w-8 h-8 text-teal" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 00-3.375-3.375h-1.5A1.125 1.125 0 0113.5 7.125v-1.5a3.375 3.375 0 00-3.375-3.375H8.25m6.75 12l-3-3m0 0l-3 3m3-3v6m-1.5-15H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 00-9-9z" />
                </svg>
              </div>
              <div>
                <h3 className="font-display text-lg font-bold text-foreground mb-1">CSV or JSON File</h3>
                <p className="text-xs text-foreground/50 leading-relaxed">
                  Upload a file with name and date of birth columns
                </p>
              </div>
            </button>
          </div>

          {/* Format help */}
          <div className="mt-8 p-4 rounded-xl bg-lavender/20 border border-lavender">
            <h4 className="text-sm font-bold text-purple mb-2">Supported file formats</h4>
            <div className="grid sm:grid-cols-2 gap-4 text-xs text-foreground/60">
              <div>
                <p className="font-bold text-foreground/70 mb-1">CSV example:</p>
                <code className="block bg-surface/80 rounded-lg p-2.5 text-[11px] leading-relaxed font-mono">
                  Name,Date of Birth<br />
                  Alice Smith,15/03/2010<br />
                  Bob Jones,2008-07-22
                </code>
              </div>
              <div>
                <p className="font-bold text-foreground/70 mb-1">JSON example:</p>
                <code className="block bg-surface/80 rounded-lg p-2.5 text-[11px] leading-relaxed font-mono">
                  {'[{"name": "Alice Smith",'}
                  <br />
                  {'  "birthday": "15/03/2010"}]'}
                </code>
              </div>
            </div>
            <p className="text-[11px] text-foreground/40 mt-2">
              Dates can be DD/MM/YYYY, YYYY-MM-DD, or most common formats.
            </p>
          </div>
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
                No valid contacts with birthdays were found. Check your file format and try again.
              </p>
              <button
                onClick={() => { setStep('start'); setContacts([]); }}
                className="mt-4 px-6 py-2.5 rounded-full text-sm font-bold text-purple hover:bg-lavender transition-colors"
              >
                Try again
              </button>
            </div>
          ) : (
            <>
              <div className="flex flex-wrap items-center justify-between gap-3 mb-4">
                <p className="text-sm font-bold text-foreground/60">
                  {contacts.length} contacts found &middot; {selected.size} selected
                </p>
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => { setStep('start'); setContacts([]); }}
                    className="px-3 py-1.5 rounded-full text-xs font-bold text-foreground/40 hover:bg-lavender transition-colors"
                  >
                    Back
                  </button>
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
                      <div className={`w-5 h-5 rounded border-2 flex items-center justify-center shrink-0 transition-colors ${
                        isSelected ? 'bg-purple border-purple' : 'border-lavender'
                      }`}>
                        {isSelected && (
                          <svg className="w-3 h-3 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={3}>
                            <path strokeLinecap="round" strokeLinejoin="round" d="M4.5 12.75l6 6 9-13.5" />
                          </svg>
                        )}
                      </div>

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

                      <div className="flex-1 min-w-0">
                        <p className="font-bold text-sm text-foreground truncate">
                          {contact.name}
                        </p>
                        <p className="text-xs text-foreground/50">
                          {formatDate(contact.dateOfBirth)}
                        </p>
                      </div>

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
            Your contacts have been added to Tiaras &amp; Trains.
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
