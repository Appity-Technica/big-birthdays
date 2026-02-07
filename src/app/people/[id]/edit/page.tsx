'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { usePeople } from '@/hooks/usePeople';
import { Relationship, KnownFrom, Party, PastGift } from '@/types';
import { parseDob, buildDob } from '@/lib/utils';

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

interface PartyForm {
  year: string;
  date: string;
  invitedNames: string;
  notes: string;
}

function emptyPartyForm(): PartyForm {
  return { year: new Date().getFullYear().toString(), date: '', invitedNames: '', notes: '' };
}

function partyToForm(p: Party): PartyForm {
  return {
    year: p.year.toString(),
    date: p.date || '',
    invitedNames: p.invitedNames?.join(', ') || '',
    notes: p.notes || '',
  };
}

function formToParty(f: PartyForm): Party | null {
  const year = parseInt(f.year);
  if (!year) return null;
  return {
    year,
    date: f.date || undefined,
    invitedNames: f.invitedNames.trim() ? f.invitedNames.split(',').map((s) => s.trim()).filter(Boolean) : undefined,
    notes: f.notes.trim() || undefined,
  };
}

interface PastGiftForm {
  year: string;
  description: string;
  url: string;
}

function emptyGiftForm(): PastGiftForm {
  return { year: new Date().getFullYear().toString(), description: '', url: '' };
}

function giftToForm(g: PastGift): PastGiftForm {
  return { year: g.year.toString(), description: g.description, url: g.url || '' };
}

function formToGift(f: PastGiftForm): PastGift | null {
  const year = parseInt(f.year);
  if (!year || !f.description.trim()) return null;
  return { year, description: f.description.trim(), url: f.url.trim() || undefined };
}

export default function EditPersonPage() {
  const params = useParams();
  const router = useRouter();
  const { getPersonById, updatePerson, loading } = usePeople();
  const personId = params.id as string;
  const person = getPersonById(personId);

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
  const [parties, setParties] = useState<PartyForm[]>([]);
  const [pastGifts, setPastGifts] = useState<PastGiftForm[]>([]);
  const [saving, setSaving] = useState(false);
  const [initialised, setInitialised] = useState(false);

  // Populate form when person data loads
  useEffect(() => {
    if (person && !initialised) {
      setName(person.name);
      const dob = parseDob(person.dateOfBirth);
      setDobDay(String(dob.day));
      setDobMonth(String(dob.month));
      setDobYear(dob.year !== null ? String(dob.year) : '');
      setRelationship(person.relationship);
      setConnectedThrough(person.connectedThrough || '');
      setKnownFrom(person.knownFrom || '');
      setKnownFromCustom(person.knownFromCustom || '');
      setNotes(person.notes || '');
      setInterests(person.interests?.join(', ') || '');
      setGiftIdeas(person.giftIdeas?.join(', ') || '');
      setParties(person.parties?.map(partyToForm) || []);
      setPastGifts(person.pastGifts?.map(giftToForm) || []);
      setInitialised(true);
    }
  }, [person, initialised]);

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

  function updateParty(index: number, field: keyof PartyForm, value: string) {
    setParties((prev) => prev.map((p, i) => i === index ? { ...p, [field]: value } : p));
  }

  function removeParty(index: number) {
    setParties((prev) => prev.filter((_, i) => i !== index));
  }

  function addParty() {
    setParties((prev) => [...prev, emptyPartyForm()]);
  }

  function updateGift(index: number, field: keyof PastGiftForm, value: string) {
    setPastGifts((prev) => prev.map((g, i) => i === index ? { ...g, [field]: value } : g));
  }

  function removeGift(index: number) {
    setPastGifts((prev) => prev.filter((_, i) => i !== index));
  }

  function addGift() {
    setPastGifts((prev) => [...prev, emptyGiftForm()]);
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim() || !dobDay || !dobMonth) return;

    setSaving(true);

    const dateOfBirth = buildDob(
      dobYear ? parseInt(dobYear, 10) : null,
      parseInt(dobMonth, 10),
      parseInt(dobDay, 10),
    );

    const parsedParties = parties.map(formToParty).filter((p): p is Party => p !== null);
    const parsedGifts = pastGifts.map(formToGift).filter((g): g is PastGift => g !== null);

    await updatePerson(personId, {
      name: name.trim(),
      dateOfBirth,
      relationship,
      connectedThrough: connectedThrough.trim() || undefined,
      knownFrom: knownFrom || undefined,
      knownFromCustom: knownFrom === 'other' && knownFromCustom.trim() ? knownFromCustom.trim() : undefined,
      notes: notes.trim() || undefined,
      interests: interests.trim() ? interests.split(',').map((s) => s.trim()).filter(Boolean) : undefined,
      giftIdeas: giftIdeas.trim() ? giftIdeas.split(',').map((s) => s.trim()).filter(Boolean) : undefined,
      parties: parsedParties.length > 0 ? parsedParties : undefined,
      pastGifts: parsedGifts.length > 0 ? parsedGifts : undefined,
    });

    router.push(`/people/${personId}`);
  }

  return (
    <div className="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <Link
        href={`/people/${personId}`}
        className="inline-flex items-center gap-1.5 text-sm font-semibold text-purple/60 hover:text-purple transition-colors mb-6"
      >
        <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
          <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 19.5L8.25 12l7.5-7.5" />
        </svg>
        Back to {person.name}
      </Link>

      <h1 className="font-display text-3xl sm:text-4xl font-bold text-purple mb-2">Edit Person</h1>
      <p className="text-foreground/50 mb-8">Update {person.name}&rsquo;s details.</p>

      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Name */}
        <div>
          <label htmlFor="name" className="block text-sm font-bold text-foreground mb-2">Name *</label>
          <input
            id="name"
            type="text"
            required
            value={name}
            onChange={(e) => setName(e.target.value)}
            className="w-full px-4 py-3 rounded-xl border-2 border-lavender bg-white text-foreground placeholder:text-foreground/30 focus:outline-none focus:border-purple focus:ring-2 focus:ring-purple/10 transition-all"
          />
        </div>

        {/* Date of Birth */}
        <div>
          <label className="block text-sm font-bold text-foreground mb-2">Birthday *</label>
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
          <label className="block text-sm font-bold text-foreground mb-2">Relationship</label>
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

          <div>
            <label className="block text-sm font-bold text-foreground mb-2">Known from</label>
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

        {/* Parties */}
        <fieldset className="space-y-4 p-5 rounded-2xl bg-mint/20 border border-mint">
          <legend className="text-sm font-bold text-teal px-1">Parties</legend>

          {parties.map((party, i) => (
            <div key={i} className="space-y-3 p-4 rounded-xl bg-white/70 border border-mint/50 relative">
              <div className="flex items-center justify-between mb-1">
                <span className="text-xs font-bold text-teal">Party {i + 1}</span>
                <button
                  type="button"
                  onClick={() => removeParty(i)}
                  className="text-xs font-bold text-coral hover:text-coral/80 transition-colors"
                >
                  Remove
                </button>
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-sm font-bold text-foreground mb-1">Year</label>
                  <input
                    type="number"
                    value={party.year}
                    onChange={(e) => updateParty(i, 'year', e.target.value)}
                    min="2000"
                    max={new Date().getFullYear() + 1}
                    className="w-full px-4 py-3 rounded-xl border-2 border-lavender bg-white text-foreground focus:outline-none focus:border-teal focus:ring-2 focus:ring-teal/10 transition-all"
                  />
                </div>
                <div>
                  <label className="block text-sm font-bold text-foreground mb-1">Date (optional)</label>
                  <input
                    type="date"
                    value={party.date}
                    onChange={(e) => updateParty(i, 'date', e.target.value)}
                    className="w-full px-4 py-3 rounded-xl border-2 border-lavender bg-white text-foreground focus:outline-none focus:border-teal focus:ring-2 focus:ring-teal/10 transition-all"
                  />
                </div>
              </div>
              <div>
                <label className="block text-sm font-bold text-foreground mb-1">Who was invited?</label>
                <input
                  type="text"
                  value={party.invitedNames}
                  onChange={(e) => updateParty(i, 'invitedNames', e.target.value)}
                  placeholder="e.g. Emma, Lily, Jack (comma separated)"
                  className="w-full px-4 py-3 rounded-xl border-2 border-lavender bg-white text-foreground placeholder:text-foreground/30 focus:outline-none focus:border-teal focus:ring-2 focus:ring-teal/10 transition-all"
                />
              </div>
              <div>
                <label className="block text-sm font-bold text-foreground mb-1">Party notes</label>
                <input
                  type="text"
                  value={party.notes}
                  onChange={(e) => updateParty(i, 'notes', e.target.value)}
                  placeholder="e.g. Soft play venue, unicorn theme"
                  className="w-full px-4 py-3 rounded-xl border-2 border-lavender bg-white text-foreground placeholder:text-foreground/30 focus:outline-none focus:border-teal focus:ring-2 focus:ring-teal/10 transition-all"
                />
              </div>
            </div>
          ))}

          <button
            type="button"
            onClick={addParty}
            className="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl border-2 border-dashed border-teal/30 text-xs font-bold text-teal hover:bg-teal/5 transition-colors"
          >
            <svg className="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
            </svg>
            Add party
          </button>
        </fieldset>

        {/* Notes */}
        <div>
          <label htmlFor="notes" className="block text-sm font-bold text-foreground mb-2">Notes</label>
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
          <label htmlFor="interests" className="block text-sm font-bold text-foreground mb-2">Interests</label>
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
          <label htmlFor="giftIdeas" className="block text-sm font-bold text-foreground mb-2">Gift Ideas</label>
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
                  onClick={() => removeGift(i)}
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
            onClick={addGift}
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
            disabled={saving}
            className="inline-flex items-center gap-2 px-8 py-3.5 bg-purple text-white rounded-full font-bold text-sm hover:bg-purple-dark transition-all shadow-lg shadow-purple/25 disabled:opacity-50"
          >
            {saving ? (
              <>
                <div className="w-5 h-5 rounded-full border-2 border-white/30 border-t-white animate-spin" />
                Saving...
              </>
            ) : (
              <>
                <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M4.5 12.75l6 6 9-13.5" />
                </svg>
                Save Changes
              </>
            )}
          </button>
          <Link
            href={`/people/${personId}`}
            className="px-6 py-3.5 text-sm font-bold text-foreground/50 hover:text-foreground transition-colors"
          >
            Cancel
          </Link>
        </div>
      </form>
    </div>
  );
}
