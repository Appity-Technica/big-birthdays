'use client';

import { useState } from 'react';
import Link from 'next/link';
import { usePeople } from '@/hooks/usePeople';
import { Person } from '@/types';
import { getUpcomingAge, parseDob } from '@/lib/utils';

const MONTH_NAMES = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

const DAY_NAMES = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

const ACCENT_COLORS = [
  'bg-pink text-white', 'bg-teal text-white', 'bg-orange text-white',
  'bg-coral text-white', 'bg-purple-light text-white',
];

function getInitials(name: string): string {
  return name.split(' ').map((n) => n[0]).join('').toUpperCase().slice(0, 2);
}

function getDaysInMonth(year: number, month: number): number {
  return new Date(year, month + 1, 0).getDate();
}

function getFirstDayOfMonth(year: number, month: number): number {
  return new Date(year, month, 1).getDay();
}

function getBirthdaysForMonth(people: Person[], month: number): Map<number, Person[]> {
  const map = new Map<number, Person[]>();
  for (const person of people) {
    const dob = parseDob(person.dateOfBirth);
    if (dob.month === month) {
      const existing = map.get(dob.day) || [];
      existing.push(person);
      map.set(dob.day, existing);
    }
  }
  return map;
}

export default function CalendarPage() {
  const { people, loading } = usePeople();
  const [currentDate, setCurrentDate] = useState(new Date());

  const year = currentDate.getFullYear();
  const month = currentDate.getMonth();

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="w-10 h-10 rounded-full border-4 border-lavender border-t-purple animate-spin" />
      </div>
    );
  }

  const daysInMonth = getDaysInMonth(year, month);
  const firstDay = getFirstDayOfMonth(year, month);
  const birthdayMap = getBirthdaysForMonth(people, month);
  const today = new Date();
  const isCurrentMonth = today.getFullYear() === year && today.getMonth() === month;

  function prevMonth() {
    setCurrentDate(new Date(year, month - 1, 1));
  }

  function nextMonth() {
    setCurrentDate(new Date(year, month + 1, 1));
  }

  function goToToday() {
    setCurrentDate(new Date());
  }

  // Build calendar grid
  const cells: (number | null)[] = [];
  for (let i = 0; i < firstDay; i++) cells.push(null);
  for (let d = 1; d <= daysInMonth; d++) cells.push(d);
  while (cells.length % 7 !== 0) cells.push(null);

  return (
    <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-8">
        <h1 className="font-display text-3xl sm:text-4xl font-bold text-purple">Calendar</h1>
        <Link
          href="/people/new"
          className="inline-flex items-center gap-2 px-6 py-3 bg-purple text-white rounded-full font-bold text-sm hover:bg-purple-dark transition-all shadow-lg shadow-purple/25 self-start"
        >
          <svg className="w-4.5 h-4.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
          </svg>
          Add Person
        </Link>
      </div>

      {/* Month navigation */}
      <div className="flex items-center justify-between mb-6">
        <button
          onClick={prevMonth}
          className="p-2.5 rounded-xl border-2 border-lavender hover:border-purple/30 hover:bg-lavender/30 transition-all"
        >
          <svg className="w-5 h-5 text-purple" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 19.5L8.25 12l7.5-7.5" />
          </svg>
        </button>
        <div className="flex items-center gap-3">
          <h2 className="font-display text-xl sm:text-2xl font-bold text-foreground">
            {MONTH_NAMES[month]} {year}
          </h2>
          {!isCurrentMonth && (
            <button
              onClick={goToToday}
              className="px-3 py-1 rounded-full bg-purple/8 text-purple text-xs font-bold hover:bg-purple/15 transition-colors"
            >
              Today
            </button>
          )}
        </div>
        <button
          onClick={nextMonth}
          className="p-2.5 rounded-xl border-2 border-lavender hover:border-purple/30 hover:bg-lavender/30 transition-all"
        >
          <svg className="w-5 h-5 text-purple" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M8.25 4.5l7.5 7.5-7.5 7.5" />
          </svg>
        </button>
      </div>

      {/* Calendar grid */}
      <div className="rounded-2xl border-2 border-lavender overflow-hidden bg-surface">
        {/* Day headers */}
        <div className="grid grid-cols-7 bg-lavender/30">
          {DAY_NAMES.map((day) => (
            <div key={day} className="px-2 py-3 text-center text-xs font-bold text-purple/60 uppercase tracking-wider">
              {day}
            </div>
          ))}
        </div>

        {/* Date cells */}
        <div className="grid grid-cols-7">
          {cells.map((day, i) => {
            const birthdays = day ? birthdayMap.get(day) || [] : [];
            const isToday = isCurrentMonth && day === today.getDate();

            return (
              <div
                key={i}
                className={`min-h-[80px] sm:min-h-[100px] border-t border-l border-lavender/60 p-1.5 sm:p-2 transition-colors ${
                  day ? 'hover:bg-lavender/10' : 'bg-lavender/5'
                } ${i % 7 === 0 ? 'border-l-0' : ''}`}
              >
                {day && (
                  <>
                    <span
                      className={`inline-flex items-center justify-center w-7 h-7 rounded-full text-xs font-bold ${
                        isToday
                          ? 'bg-purple text-white'
                          : 'text-foreground/60'
                      }`}
                    >
                      {day}
                    </span>
                    {birthdays.length > 0 && (
                      <div className="mt-1 space-y-1">
                        {birthdays.slice(0, 2).map((person, pi) => (
                          <Link
                            key={person.id}
                            href={`/people/${person.id}`}
                            className={`block px-1.5 py-0.5 rounded-md text-[10px] sm:text-xs font-bold truncate ${ACCENT_COLORS[pi % ACCENT_COLORS.length]} hover:opacity-80 transition-opacity`}
                          >
                            <span className="hidden sm:inline">🎂 </span>
                            {person.name}
                            {getUpcomingAge(person.dateOfBirth) !== null && (
                              <span className="hidden sm:inline"> ({getUpcomingAge(person.dateOfBirth)})</span>
                            )}
                          </Link>
                        ))}
                        {birthdays.length > 2 && (
                          <span className="block text-[10px] font-bold text-purple/50 px-1.5">
                            +{birthdays.length - 2} more
                          </span>
                        )}
                      </div>
                    )}
                  </>
                )}
              </div>
            );
          })}
        </div>
      </div>

      {/* Monthly summary */}
      {(() => {
        const monthBirthdays: { person: Person; day: number }[] = [];
        birthdayMap.forEach((persons, day) => {
          persons.forEach((person) => monthBirthdays.push({ person, day }));
        });
        monthBirthdays.sort((a, b) => a.day - b.day);

        if (monthBirthdays.length === 0) return null;

        return (
          <div className="mt-8">
            <h3 className="font-display text-lg font-bold text-purple mb-4">
              {MONTH_NAMES[month]} Birthdays ({monthBirthdays.length})
            </h3>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              {monthBirthdays.map(({ person, day }) => {
                const upcomingAge = getUpcomingAge(person.dateOfBirth);
                return (
                  <Link
                    key={person.id}
                    href={`/people/${person.id}`}
                    className="flex items-center gap-3 p-3 rounded-xl border-2 border-lavender hover:border-purple/30 bg-surface transition-all hover:shadow-md"
                  >
                    <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-pink to-coral text-white flex items-center justify-center text-sm font-display font-bold">
                      {getInitials(person.name)}
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="font-bold text-sm truncate">{person.name}</p>
                      <p className="text-xs text-foreground/50">
                        {MONTH_NAMES[month]} {day}{upcomingAge !== null ? ` \u00b7 Turning ${upcomingAge}` : ''}
                      </p>
                    </div>
                  </Link>
                );
              })}
            </div>
          </div>
        );
      })()}
    </div>
  );
}
