/**
 * Get the next birthday date for a person given their date of birth.
 * Returns the upcoming birthday in the current or next year.
 */
export function getNextBirthday(dateOfBirth: string): Date {
  const today = new Date();
  const dob = new Date(dateOfBirth);
  const nextBirthday = new Date(today.getFullYear(), dob.getMonth(), dob.getDate());

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
 */
export function getUpcomingAge(dateOfBirth: string): number {
  const dob = new Date(dateOfBirth);
  const next = getNextBirthday(dateOfBirth);
  return next.getFullYear() - dob.getFullYear();
}

/**
 * Get a person's current age.
 */
export function getCurrentAge(dateOfBirth: string): number {
  const today = new Date();
  const dob = new Date(dateOfBirth);
  let age = today.getFullYear() - dob.getFullYear();
  const monthDiff = today.getMonth() - dob.getMonth();
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < dob.getDate())) {
    age--;
  }
  return age;
}

/**
 * Check if today is a person's birthday.
 */
export function isBirthdayToday(dateOfBirth: string): boolean {
  const today = new Date();
  const dob = new Date(dateOfBirth);
  return today.getMonth() === dob.getMonth() && today.getDate() === dob.getDate();
}

/**
 * Format a date of birth for display.
 */
export function formatDate(dateString: string): string {
  return new Date(dateString).toLocaleDateString('en-GB', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  });
}

/**
 * Generate a unique ID.
 */
export function generateId(): string {
  return crypto.randomUUID();
}
