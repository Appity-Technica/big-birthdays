'use client';

import { useState } from 'react';
import Link from 'next/link';
import { usePeople } from '@/hooks/usePeople';
import { generateCSV, generateJSON } from '@/lib/csv';
import { formatDate } from '@/lib/utils';

type Format = 'csv' | 'json';

function downloadFile(content: string, filename: string, mime: string) {
  const blob = new Blob([content], { type: `${mime};charset=utf-8` });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
}

export default function ExportPeoplePage() {
  const { people, loading } = usePeople();
  const [selected, setSelected] = useState<Set<number>>(new Set());
  const [format, setFormat] = useState<Format | null>(null);
  const [step, setStep] = useState<'start' | 'select' | 'done'>('start');
  const [exportedCount, setExportedCount] = useState(0);
  const [initialized, setInitialized] = useState(false);

  // Pre-select all people once loaded
  if (!loading && people.length > 0 && !initialized) {
    setSelected(new Set(people.map((_, i) => i)));
    setInitialized(true);
  }

  function handleFormatSelect(f: Format) {
    setFormat(f);
    setStep('select');
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
    setSelected(new Set(people.map((_, i) => i)));
  }

  function selectNone() {
    setSelected(new Set());
  }

  function handleExport() {
    const selectedPeople = people.filter((_, i) => selected.has(i));
    const date = new Date().toISOString().slice(0, 10);

    if (format === 'csv') {
      const content = generateCSV(selectedPeople);
      downloadFile(content, `birthdays-${date}.csv`, 'text/csv');
    } else {
      const content = generateJSON(selectedPeople);
      downloadFile(content, `birthdays-${date}.json`, 'application/json');
    }

    setExportedCount(selectedPeople.length);
    setStep('done');
  }

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="w-10 h-10 rounded-full border-4 border-lavender border-t-purple animate-spin" />
      </div>
    );
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

      <h1 className="font-display text-3xl sm:text-4xl font-bold text-purple mb-2">Export People</h1>
      <p className="text-foreground/50 mb-8">
        Export your birthday data as a CSV or JSON file.
      </p>

      {/* Step: Start - choose format */}
      {step === 'start' && (
        <div className="py-8">
          {people.length === 0 ? (
            <div className="text-center py-12">
              <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-lavender flex items-center justify-center">
                <span className="text-3xl">🤷</span>
              </div>
              <h3 className="font-display text-xl font-bold text-purple mb-2">No people to export</h3>
              <p className="text-foreground/50 max-w-sm mx-auto">
                Add some people first, then come back to export your data.
              </p>
              <Link
                href="/people/new"
                className="mt-4 inline-flex items-center gap-2 px-6 py-2.5 rounded-full text-sm font-bold text-purple hover:bg-lavender transition-colors"
              >
                Add a person
              </Link>
            </div>
          ) : (
            <div className="grid sm:grid-cols-2 gap-4">
              {/* CSV card */}
              <button
                onClick={() => handleFormatSelect('csv')}
                className="group flex flex-col items-center gap-4 p-8 rounded-2xl border-2 border-lavender hover:border-purple/30 bg-white transition-all hover:shadow-lg hover:shadow-purple/5 text-center"
              >
                <div className="w-16 h-16 rounded-full bg-lavender group-hover:bg-purple/10 flex items-center justify-center transition-colors">
                  <svg className="w-8 h-8 text-purple" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
                    <path strokeLinecap="round" strokeLinejoin="round" d="M3.375 19.5h17.25m-17.25 0a1.125 1.125 0 01-1.125-1.125M3.375 19.5h7.5c.621 0 1.125-.504 1.125-1.125m-9.75 0V5.625m0 12.75v-1.5c0-.621.504-1.125 1.125-1.125m18.375 2.625V5.625m0 12.75c0 .621-.504 1.125-1.125 1.125m1.125-1.125v-1.5c0-.621-.504-1.125-1.125-1.125m0 3.75h-7.5A1.125 1.125 0 0112 18.375m9.75-12.75c0-.621-.504-1.125-1.125-1.125H3.375c-.621 0-1.125.504-1.125 1.125m19.5 0v1.5c0 .621-.504 1.125-1.125 1.125M2.25 5.625v1.5c0 .621.504 1.125 1.125 1.125m0 0h17.25m-17.25 0h7.5c.621 0 1.125.504 1.125 1.125M3.375 8.25c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125m17.25-3.75h-7.5c-.621 0-1.125.504-1.125 1.125m8.625-1.125c.621 0 1.125.504 1.125 1.125v1.5c0 .621-.504 1.125-1.125 1.125m-17.25 0h7.5m-7.5 0c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125M12 10.875v-1.5m0 1.5c0 .621-.504 1.125-1.125 1.125M12 10.875c0 .621.504 1.125 1.125 1.125m-2.25 0c.621 0 1.125.504 1.125 1.125M13.125 12h7.5m-7.5 0c-.621 0-1.125.504-1.125 1.125M20.625 12c.621 0 1.125.504 1.125 1.125v1.5c0 .621-.504 1.125-1.125 1.125m-17.25 0h7.5M12 14.625v-1.5m0 1.5c0 .621-.504 1.125-1.125 1.125M12 14.625c0 .621.504 1.125 1.125 1.125m-2.25 0c.621 0 1.125.504 1.125 1.125m0 0v.75" />
                  </svg>
                </div>
                <div>
                  <h3 className="font-display text-lg font-bold text-foreground mb-1">CSV Spreadsheet</h3>
                  <p className="text-xs text-foreground/50 leading-relaxed">
                    Export as a CSV file you can open in Excel, Google Sheets, or Numbers
                  </p>
                </div>
              </button>

              {/* JSON card */}
              <button
                onClick={() => handleFormatSelect('json')}
                className="group flex flex-col items-center gap-4 p-8 rounded-2xl border-2 border-lavender hover:border-teal/30 bg-white transition-all hover:shadow-lg hover:shadow-teal/5 text-center"
              >
                <div className="w-16 h-16 rounded-full bg-mint group-hover:bg-teal/10 flex items-center justify-center transition-colors">
                  <svg className="w-8 h-8 text-teal" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
                    <path strokeLinecap="round" strokeLinejoin="round" d="M17.25 6.75L22.5 12l-5.25 5.25m-10.5 0L1.5 12l5.25-5.25m7.5-3l-4.5 16.5" />
                  </svg>
                </div>
                <div>
                  <h3 className="font-display text-lg font-bold text-foreground mb-1">JSON Data</h3>
                  <p className="text-xs text-foreground/50 leading-relaxed">
                    Export as a JSON file with full details including past gifts and notes
                  </p>
                </div>
              </button>
            </div>
          )}
        </div>
      )}

      {/* Step: Select people */}
      {step === 'select' && (
        <>
          <div className="flex flex-wrap items-center justify-between gap-3 mb-4">
            <p className="text-sm font-bold text-foreground/60">
              {people.length} {people.length === 1 ? 'person' : 'people'} &middot; {selected.size} selected
            </p>
            <div className="flex items-center gap-2">
              <button
                onClick={() => { setStep('start'); setFormat(null); }}
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
            {people.map((person, i) => {
              const isSelected = selected.has(i);
              const initials = person.name.split(' ').map((n) => n[0]).join('').toUpperCase().slice(0, 2);

              return (
                <button
                  key={person.id}
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

                  <div className="w-10 h-10 rounded-lg bg-pink text-white flex items-center justify-center text-sm font-display font-bold shrink-0">
                    {initials}
                  </div>

                  <div className="flex-1 min-w-0">
                    <p className="font-bold text-sm text-foreground truncate">
                      {person.name}
                    </p>
                    <p className="text-xs text-foreground/50">
                      {formatDate(person.dateOfBirth)}
                    </p>
                  </div>

                  <span className={`px-2.5 py-1 rounded-full text-[10px] font-bold shrink-0 ${
                    person.relationship === 'family' ? 'bg-pink/15 text-pink' :
                    person.relationship === 'friend' ? 'bg-teal/15 text-teal' :
                    person.relationship === 'colleague' ? 'bg-orange/15 text-orange' :
                    'bg-purple-light/15 text-purple-light'
                  }`}>
                    {person.relationship.charAt(0).toUpperCase() + person.relationship.slice(1)}
                  </span>
                </button>
              );
            })}
          </div>

          <div className="flex items-center gap-3 sticky bottom-4">
            <button
              onClick={handleExport}
              disabled={selected.size === 0}
              className="inline-flex items-center gap-2 px-8 py-3.5 bg-purple text-white rounded-full font-bold text-sm hover:bg-purple-dark transition-all shadow-lg shadow-purple/25 disabled:opacity-50"
            >
              <svg className="w-4.5 h-4.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5M16.5 12L12 16.5m0 0L7.5 12m4.5 4.5V3" />
              </svg>
              Export {selected.size} {selected.size === 1 ? 'person' : 'people'} as {format?.toUpperCase()}
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

      {/* Step: Done */}
      {step === 'done' && (
        <div className="text-center py-12">
          <div className="w-20 h-20 mx-auto mb-6 rounded-full bg-mint flex items-center justify-center">
            <svg className="w-10 h-10 text-teal" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <h3 className="font-display text-2xl font-bold text-purple mb-2">
            {exportedCount} {exportedCount === 1 ? 'person' : 'people'} exported!
          </h3>
          <p className="text-foreground/50 mb-8">
            Your {format?.toUpperCase()} file has been downloaded.
          </p>
          <div className="flex items-center justify-center gap-3">
            <Link
              href="/people"
              className="inline-flex items-center gap-2 px-8 py-3.5 bg-purple text-white rounded-full font-bold text-sm hover:bg-purple-dark transition-all shadow-lg shadow-purple/25"
            >
              View People
            </Link>
            <button
              onClick={() => { setStep('start'); setFormat(null); }}
              className="px-6 py-3.5 rounded-full text-sm font-bold text-purple/60 hover:text-purple hover:bg-lavender/30 transition-colors"
            >
              Export again
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
