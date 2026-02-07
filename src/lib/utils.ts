const UNKNOWN_YEAR = '0000';

/** Parse a dateOfBirth string into parts. Year is null when unknown (0000). */
export function parseDob(dateOfBirth: string): { year: number | null; month: number; day: number } {
  const [yearStr, monthStr, dayStr] = dateOfBirth.split('-');
  return {
    year: yearStr === UNKNOWN_YEAR ? null : parseInt(yearStr, 10),
    month: parseInt(monthStr, 10) - 1, // 0-indexed for Date compat
    day: parseInt(dayStr, 10),
  };
}

/** Build a dateOfBirth string. Pass null for year if unknown. */
export function buildDob(year: number | null, month: number, day: number): string {
  const y = year !== null ? String(year).padStart(4, '0') : UNKNOWN_YEAR;
  const m = String(month + 1).padStart(2, '0'); // month is 0-indexed input
  const d = String(day).padStart(2, '0');
  return `${y}-${m}-${d}`;
}

export function hasKnownYear(dateOfBirth: string): boolean {
  return !dateOfBirth.startsWith(UNKNOWN_YEAR + '-');
}

/**
 * Get the next birthday date for a person given their date of birth.
 */
export function getNextBirthday(dateOfBirth: string): Date {
  const today = new Date();
  const { month, day } = parseDob(dateOfBirth);
  const nextBirthday = new Date(today.getFullYear(), month, day);

  if (nextBirthday < today) {
    nextBirthday.setFullYear(today.getFullYear() + 1);
  }

  return nextBirthday;
}

/**
 * Get the number of days until a person's next birthday.
 */
export function daysUntilBirthday(dateOfBirth: string): number {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const next = getNextBirthday(dateOfBirth);
  next.setHours(0, 0, 0, 0);
  const diff = next.getTime() - today.getTime();
  return Math.ceil(diff / (1000 * 60 * 60 * 24));
}

/**
 * Get the age a person is turning on their next birthday.
 * Returns null if birth year is unknown.
 */
export function getUpcomingAge(dateOfBirth: string): number | null {
  const { year } = parseDob(dateOfBirth);
  if (year === null) return null;
  const next = getNextBirthday(dateOfBirth);
  return next.getFullYear() - year;
}

/**
 * Get a person's current age. Returns null if birth year is unknown.
 */
export function getCurrentAge(dateOfBirth: string): number | null {
  const { year, month, day } = parseDob(dateOfBirth);
  if (year === null) return null;
  const today = new Date();
  let age = today.getFullYear() - year;
  const monthDiff = today.getMonth() - month;
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < day)) {
    age--;
  }
  return age;
}

/**
 * Check if today is a person's birthday.
 */
export function isBirthdayToday(dateOfBirth: string): boolean {
  const today = new Date();
  const { month, day } = parseDob(dateOfBirth);
  return today.getMonth() === month && today.getDate() === day;
}

/**
 * Format a date of birth for display.
 * Omits the year when it is unknown.
 */
export function formatDate(dateString: string): string {
  const { year, month, day } = parseDob(dateString);
  const d = new Date(2000, month, day); // use 2000 just for formatting
  const dayMonth = d.toLocaleDateString('en-GB', { day: 'numeric', month: 'long' });
  if (year === null) return dayMonth;
  return `${dayMonth} ${year}`;
}

/**
 * Generate a unique ID.
 */
export function generateId(): string {
  return crypto.randomUUID();
}
