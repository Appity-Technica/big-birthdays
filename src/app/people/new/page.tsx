'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { addPerson } from '@/lib/localStorage';
import { Relationship } from '@/types';

const RELATIONSHIPS: { value: Relationship; label: string; icon: string }[] = [
  { value: 'family', label: 'Family', icon: '👨‍👩‍👧' },
  { value: 'friend', label: 'Friend', icon: '🤝' },
  { value: 'colleague', label: 'Colleague', icon: '💼' },
  { value: 'other', label: 'Other', icon: '🌟' },
];

export default function NewPersonPage() {
  const router = useRouter();
  const [name, setName] = useState('');
  const [dateOfBirth, setDateOfBirth] = useState('');
  const [relationship, setRelationship] = useState<Relationship>('friend');
  const [notes, setNotes] = useState('');
  const [interests, setInterests] = useState('');
  const [giftIdeas, setGiftIdeas] = useState('');

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!name.trim() || !dateOfBirth) return;

    addPerson({
      name: name.trim(),
      dateOfBirth,
      relationship,
      notes: notes.trim() || undefined,
      interests: interests.trim() ? interests.split(',').map((s) => s.trim()).filter(Boolean) : undefined,
      giftIdeas: giftIdeas.trim() ? giftIdeas.split(',').map((s) => s.trim()).filter(Boolean) : undefined,
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
          <label htmlFor="dob" className="block text-sm font-bold text-foreground mb-2">
            Date of Birth *
          </label>
          <input
            id="dob"
            type="date"
            required
            value={dateOfBirth}
            onChange={(e) => setDateOfBirth(e.target.value)}
            max={new Date().toISOString().split('T')[0]}
            className="w-full px-4 py-3 rounded-xl border-2 border-lavender bg-white text-foreground focus:outline-none focus:border-purple focus:ring-2 focus:ring-purple/10 transition-all"
          />
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
