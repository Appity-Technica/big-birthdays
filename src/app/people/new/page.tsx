'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { usePeople } from '@/hooks/usePeople';
import { Relationship, KnownFrom, PastGift } from '@/types';
import { buildDob } from '@/lib/utils';

const MONTHS = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

const RELATIONSHIPS: { value: Relationship; label: string; icon: string }[] = [
  { value: 'family', label: 'Family', icon: '👨‍👩‍👧' },
  { value: 'friend', label: 'Friend', icon: '🤝' },
  { value: 'colleague', label: 'Colleague', icon: '💼' },
  { value: 'other', label: 'Other', icon: '🌟' },
];

const KNOWN_FROM_OPTIONS: { value: KnownFrom; label: string }[] = [
  { value: 'school', label: 'School' },
  { value: 'dance', label: 'Dance' },
  { value: 'sports', label: 'Sports' },
  { value: 'scouts', label: 'Scouts' },
  { value: 'neighbourhood', label: 'Neighbourhood' },
  { value: 'work', label: 'Work' },
  { value: 'church', label: 'Church' },
  { value: 'family-friend', label: 'Family friend' },
  { value: 'other', label: 'Other' },
];

export default function NewPersonPage() {
  const router = useRouter();
  const { addPerson } = usePeople();
  const [name, setName] = useState('');
  const [dobDay, setDobDay] = useState('');
  const [dobMonth, setDobMonth] = useState('');
  const [dobYear, setDobYear] = useState('');
  const [relationship, setRelationship] = useState<Relationship>('friend');
  const [connectedThrough, setConnectedThrough] = useState('');
  const [knownFrom, setKnownFrom] = useState<KnownFrom | ''>('');
  const [knownFromCustom, setKnownFromCustom] = useState('');
  const [notes, setNotes] = useState('');
  const [interests, setInterests] = useState('');
  const [giftIdeas, setGiftIdeas] = useState('');
  const [hasParty, setHasParty] = useState(false);
  const [partyYear, setPartyYear] = useState(new Date().getFullYear().toString());
  const [partyDate, setPartyDate] = useState('');
  const [partyInvited, setPartyInvited] = useState('');
  const [partyNotes, setPartyNotes] = useState('');
  const [pastGifts, setPastGifts] = useState<{ year: string; description: string; url: string }[]>([]);

  function updateGift(index: number, field: 'year' | 'description' | 'url', value: string) {
    setPastGifts((prev) => prev.map((g, i) => i === index ? { ...g, [field]: value } : g));
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim() || !dobDay || !dobMonth) return;

    const dateOfBirth = buildDob(
      dobYear ? parseInt(dobYear, 10) : null,
      parseInt(dobMonth, 10),
      parseInt(dobDay, 10),
    );

    const parties = hasParty
      ? [{
          year: parseInt(partyYear) || new Date().getFullYear(),
          date: partyDate || undefined,
          invitedNames: partyInvited.trim() ? partyInvited.split(',').map((s) => s.trim()).filter(Boolean) : undefined,
          notes: partyNotes.trim() || undefined,
        }]
      : undefined;

    await addPerson({
      name: name.trim(),
      dateOfBirth,
      relationship,
      connectedThrough: connectedThrough.trim() || undefined,
      knownFrom: knownFrom || undefined,
      knownFromCustom: knownFrom === 'other' && knownFromCustom.trim() ? knownFromCustom.trim() : undefined,
      notes: notes.trim() || undefined,
      interests: interests.trim() ? interests.split(',').map((s) => s.trim()).filter(Boolean) : undefined,
      giftIdeas: giftIdeas.trim() ? giftIdeas.split(',').map((s) => s.trim()).filter(Boolean) : undefined,
      parties,
      pastGifts: pastGifts
        .filter((g) => g.description.trim() && parseInt(g.year))
        .map((g) => ({ year: parseInt(g.year), description: g.description.trim(), url: g.url.trim() || undefined })) || undefined,
    });

    router.push('/people');
  }

  return (
    <div className="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
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

      <h1 className="font-display text-3xl sm:text-4xl font-bold text-purple mb-2">Add Birthday</h1>
      <p className="text-foreground/50 mb-8">Add someone special so you never miss their big day.</p>

      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Name */}
        <div>
          <label htmlFor="name" className="block text-sm font-bold text-foreground mb-2">
            Name *
          </label>
          <input
            id="name"
            type="text"
            required
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="e.g. Sarah Johnson"
            className="w-full px-4 py-3 rounded-xl border-2 border-lavender bg-white text-foreground placeholder:text-foreground/30 focus:outline-none focus:border-purple focus:ring-2 focus:ring-purple/10 transition-all"
          />
        </div>

        {/* Date of Birth */}
        <div>
          <label className="block text-sm font-bold text-foreground mb-2">
            Birthday *
          </label>
          <div className="grid grid-cols-3 gap-3">
            <div>
              <label htmlFor="dobDay" className="block text-xs text-foreground/50 mb-1">Day</label>
              <input
                id="dobDay"
                type="number"
                required
                min={1}
                max={31}
                value={dobDay}
                onChange={(e) => setDobDay(e.target.value)}
                placeholder="DD"
                className="w-full px-4 py-3 rounded-xl border-2 border-lavender bg-white text-foreground placeholder:text-foreground/30 focus:outline-none focus:border-purple focus:ring-2 focus:ring-purple/10 transition-all"
              />
            </div>
            <div>
              <label htmlFor="dobMonth" className="block text-xs text-foreground/50 mb-1">Month</label>
              <select
                id="dobMonth"
                required
                value={dobMonth}
                onChange={(e) => setDobMonth(e.target.value)}
                className="w-full px-4 py-3 rounded-xl border-2 border-lavender bg-white text-foreground focus:outline-none focus:border-purple focus:ring-2 focus:ring-purple/10 transition-all"
              >
                <option value="">Month</option>
                {MONTHS.map((m, i) => (
                  <option key={m} value={i}>{m}</option>
                ))}
              </select>
            </div>
            <div>
              <label htmlFor="dobYear" className="block text-xs text-foreground/50 mb-1">Year (optional)</label>
              <input
                id="dobYear"
                type="number"
                min={1900}
                max={new Date().getFullYear()}
                value={dobYear}
                onChange={(e) => setDobYear(e.target.value)}
                placeholder="YYYY"
                className="w-full px-4 py-3 rounded-xl border-2 border-lavender bg-white text-foreground placeholder:text-foreground/30 focus:outline-none focus:border-purple focus:ring-2 focus:ring-purple/10 transition-all"
              />
            </div>
          </div>
          <p className="text-xs text-foreground/40 mt-1.5">Leave year blank if you don&rsquo;t know it.</p>
        </div>

        {/* Relationship */}
        <div>
          <label className="block text-sm font-bold text-foreground mb-2">
            Relationship
          </label>
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
            {RELATIONSHIPS.map((rel) => (
              <button
                key={rel.value}
                type="button"
                onClick={() => setRelationship(rel.value)}
                className={`flex items-center gap-2 px-4 py-3 rounded-xl border-2 text-sm font-bold transition-all ${
                  relationship === rel.value
                    ? 'border-purple bg-purple/5 text-purple'
                    : 'border-lavender text-foreground/60 hover:border-purple/30'
                }`}
              >
                <span>{rel.icon}</span>
                {rel.label}
              </button>
            ))}
          </div>
        </div>

        {/* How do you know them? */}
        <fieldset className="space-y-4 p-5 rounded-2xl bg-lavender/20 border border-lavender">
          <legend className="text-sm font-bold text-purple px-1">How do you know them?</legend>

          {/* Connected through */}
          <div>
            <label htmlFor="connectedThrough" className="block text-sm font-bold text-foreground mb-2">
              Connected through
            </label>
            <input
              id="connectedThrough"
              type="text"
              value={connectedThrough}
              onChange={(e) => setConnectedThrough(e.target.value)}
              placeholder="e.g. Emma, Mum's bridge club, Dad's side"
              className="w-full px-4 py-3 rounded-xl border-2 border-lavender bg-white text-foreground placeholder:text-foreground/30 focus:outline-none focus:border-purple focus:ring-2 focus:ring-purple/10 transition-all"
            />
          </div>

          {/* Known from */}
          <div>
            <label className="block text-sm font-bold text-foreground mb-2">
              Known from
            </label>
            <div className="flex flex-wrap gap-2">
              {KNOWN_FROM_OPTIONS.map((opt) => (
                <button
                  key={opt.value}
                  type="button"
                  onClick={() => setKnownFrom(knownFrom === opt.value ? '' : opt.value)}
                  className={`px-3.5 py-2 rounded-xl border-2 text-xs font-bold transition-all ${
                    knownFrom === opt.value
                      ? 'border-purple bg-purple/5 text-purple'
                      : 'border-lavender text-foreground/60 hover:border-purple/30'
                  }`}
                >
                  {opt.label}
                </button>
              ))}
            </div>
            {knownFrom === 'other' && (
              <input
                type="text"
                value={knownFromCustom}
                onChange={(e) => setKnownFromCustom(e.target.value)}
                placeholder="Where do you know them from?"
                className="mt-2 w-full px-4 py-3 rounded-xl border-2 border-lavender bg-white text-foreground placeholder:text-foreground/30 focus:outline-none focus:border-purple focus:ring-2 focus:ring-purple/10 transition-all"
              />
            )}
          </div>
        </fieldset>

        {/* Party */}
        <fieldset className="space-y-4 p-5 rounded-2xl bg-mint/20 border border-mint">
          <legend className="text-sm font-bold text-teal px-1">Party</legend>

          <label className="flex items-center gap-3 cursor-pointer">
            <input
              type="checkbox"
              checked={hasParty}
              onChange={(e) => setHasParty(e.target.checked)}
              className="w-5 h-5 rounded border-2 border-lavender text-purple focus:ring-purple/20 accent-purple"
            />
            <span className="text-sm font-bold text-foreground">Have they had a party?</span>
          </label>

          {hasParty && (
            <div className="space-y-4 pl-8">
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label htmlFor="partyYear" className="block text-sm font-bold text-foreground mb-2">
                    Year
                  </label>
                  <input
                    id="partyYear"
                    type="number"
                    value={partyYear}
                    onChange={(e) => setPartyYear(e.target.value)}
                    min="2000"
                    max={new Date().getFullYear() + 1}
                    className="w-full px-4 py-3 rounded-xl border-2 border-lavender bg-white text-foreground focus:outline-none focus:border-teal focus:ring-2 focus:ring-teal/10 transition-all"
                  />
                </div>
                <div>
                  <label htmlFor="partyDate" className="block text-sm font-bold text-foreground mb-2">
                    Date (optional)
                  </label>
                  <input
                    id="partyDate"
                    type="date"
                    value={partyDate}
                    onChange={(e) => setPartyDate(e.target.value)}
                    className="w-full px-4 py-3 rounded-xl border-2 border-lavender bg-white text-foreground focus:outline-none focus:border-teal focus:ring-2 focus:ring-teal/10 transition-all"
                  />
                </div>
              </div>
              <div>
                <label htmlFor="partyInvited" className="block text-sm font-bold text-foreground mb-2">
                  Who was invited?
                </label>
                <input
                  id="partyInvited"
                  type="text"
                  value={partyInvited}
                  onChange={(e) => setPartyInvited(e.target.value)}
                  placeholder="e.g. Emma, Lily, Jack (comma separated)"
                  className="w-full px-4 py-3 rounded-xl border-2 border-lavender bg-white text-foreground placeholder:text-foreground/30 focus:outline-none focus:border-teal focus:ring-2 focus:ring-teal/10 transition-all"
                />
              </div>
              <div>
                <label htmlFor="partyNotes" className="block text-sm font-bold text-foreground mb-2">
                  Party notes
                </label>
                <input
                  id="partyNotes"
                  type="text"
                  value={partyNotes}
                  onChange={(e) => setPartyNotes(e.target.value)}
                  placeholder="e.g. Soft play venue, unicorn theme"
                  className="w-full px-4 py-3 rounded-xl border-2 border-lavender bg-white text-foreground placeholder:text-foreground/30 focus:outline-none focus:border-teal focus:ring-2 focus:ring-teal/10 transition-all"
                />
              </div>
            </div>
          )}
        </fieldset>

        {/* Notes */}
        <div>
          <label htmlFor="notes" className="block text-sm font-bold text-foreground mb-2">
            Notes
          </label>
          <textarea
            id="notes"
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            placeholder="Any helpful notes about this person..."
            rows={3}
            className="w-full px-4 py-3 rounded-xl border-2 border-lavender bg-white text-foreground placeholder:text-foreground/30 focus:outline-none focus:border-purple focus:ring-2 focus:ring-purple/10 transition-all resize-none"
          />
        </div>

        {/* Interests */}
        <div>
          <label htmlFor="interests" className="block text-sm font-bold text-foreground mb-2">
            Interests
          </label>
          <input
            id="interests"
            type="text"
            value={interests}
            onChange={(e) => setInterests(e.target.value)}
            placeholder="e.g. cooking, hiking, books (comma separated)"
            className="w-full px-4 py-3 rounded-xl border-2 border-lavender bg-white text-foreground placeholder:text-foreground/30 focus:outline-none focus:border-purple focus:ring-2 focus:ring-purple/10 transition-all"
          />
        </div>

        {/* Gift Ideas */}
        <div>
          <label htmlFor="giftIdeas" className="block text-sm font-bold text-foreground mb-2">
            Gift Ideas
          </label>
          <input
            id="giftIdeas"
            type="text"
            value={giftIdeas}
            onChange={(e) => setGiftIdeas(e.target.value)}
            placeholder="e.g. new headphones, book voucher (comma separated)"
            className="w-full px-4 py-3 rounded-xl border-2 border-lavender bg-white text-foreground placeholder:text-foreground/30 focus:outline-none focus:border-purple focus:ring-2 focus:ring-purple/10 transition-all"
          />
        </div>

        {/* Past Gifts */}
        <fieldset className="space-y-4 p-5 rounded-2xl bg-pink/5 border border-pink/20">
          <legend className="text-sm font-bold text-pink px-1">Past Gifts</legend>

          {pastGifts.map((gift, i) => (
            <div key={i} className="space-y-3 p-4 rounded-xl bg-white/70 border border-pink/10">
              <div className="flex items-center justify-between mb-1">
                <span className="text-xs font-bold text-pink">Gift {i + 1}</span>
                <button
                  type="button"
                  onClick={() => setPastGifts((prev) => prev.filter((_, j) => j !== i))}
                  className="text-xs font-bold text-coral hover:text-coral/80 transition-colors"
                >
                  Remove
                </button>
              </div>
              <div className="grid grid-cols-3 gap-3">
                <div>
                  <label className="block text-sm font-bold text-foreground mb-1">Year</label>
                  <input
                    type="number"
                    value={gift.year}
                    onChange={(e) => updateGift(i, 'year', e.target.value)}
                    min="2000"
                    max={new Date().getFullYear()}
                    className="w-full px-4 py-3 rounded-xl border-2 border-lavender bg-white text-foreground focus:outline-none focus:border-pink focus:ring-2 focus:ring-pink/10 transition-all"
                  />
                </div>
                <div className="col-span-2">
                  <label className="block text-sm font-bold text-foreground mb-1">What was it?</label>
                  <input
                    type="text"
                    value={gift.description}
                    onChange={(e) => updateGift(i, 'description', e.target.value)}
                    placeholder="e.g. LEGO City set"
                    className="w-full px-4 py-3 rounded-xl border-2 border-lavender bg-white text-foreground placeholder:text-foreground/30 focus:outline-none focus:border-pink focus:ring-2 focus:ring-pink/10 transition-all"
                  />
                </div>
              </div>
              <div>
                <label className="block text-sm font-bold text-foreground mb-1">Link (optional)</label>
                <input
                  type="url"
                  value={gift.url}
                  onChange={(e) => updateGift(i, 'url', e.target.value)}
                  placeholder="https://..."
                  className="w-full px-4 py-3 rounded-xl border-2 border-lavender bg-white text-foreground placeholder:text-foreground/30 focus:outline-none focus:border-pink focus:ring-2 focus:ring-pink/10 transition-all"
                />
              </div>
            </div>
          ))}

          <button
            type="button"
            onClick={() => setPastGifts((prev) => [...prev, { year: new Date().getFullYear().toString(), description: '', url: '' }])}
            className="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl border-2 border-dashed border-pink/30 text-xs font-bold text-pink hover:bg-pink/5 transition-colors"
          >
            <svg className="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
            </svg>
            Add past gift
          </button>
        </fieldset>

        {/* Submit */}
        <div className="flex items-center gap-3 pt-2">
          <button
            type="submit"
            className="inline-flex items-center gap-2 px-8 py-3.5 bg-purple text-white rounded-full font-bold text-sm hover:bg-purple-dark transition-all shadow-lg shadow-purple/25"
          >
            <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
            </svg>
            Add Birthday
          </button>
          <Link
            href="/people"
            className="px-6 py-3.5 text-sm font-bold text-foreground/50 hover:text-foreground transition-colors"
          >
            Cancel
          </Link>
        </div>
      </form>
    </div>
  );
}
