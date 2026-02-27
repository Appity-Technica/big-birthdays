import { daysUntilBirthday } from '../src/utils';

describe('daysUntilBirthday', () => {
  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('returns 0 when the birthday is today', () => {
    const today = new Date(2026, 2, 15); // March 15 2026
    jest.useFakeTimers({ now: today });
    expect(daysUntilBirthday('1990-03-15')).toBe(0);
    jest.useRealTimers();
  });

  it('returns 1 when the birthday is tomorrow', () => {
    // Set "today" to midnight March 15 2026
    const today = new Date(2026, 2, 15, 0, 0, 0, 0);
    jest.useFakeTimers({ now: today });
    expect(daysUntilBirthday('1990-03-16')).toBe(1);
    jest.useRealTimers();
  });

  it('returns 364 or 365 when the birthday was yesterday (wraps to next year)', () => {
    // "Today" is March 15. Birthday was March 14 => next occurrence is March 14 next year
    const today = new Date(2026, 2, 15, 0, 0, 0, 0);
    jest.useFakeTimers({ now: today });
    const days = daysUntilBirthday('1990-03-14');
    // March 14 2027 is 364 days from March 15 2026
    expect(days).toBe(364);
    jest.useRealTimers();
  });

  it('handles birthdays later in the same year', () => {
    const today = new Date(2026, 0, 1, 0, 0, 0, 0); // Jan 1
    jest.useFakeTimers({ now: today });
    // June 15 is 165 days from Jan 1 in a non-leap year
    const days = daysUntilBirthday('2000-06-15');
    expect(days).toBe(165);
    jest.useRealTimers();
  });

  it('handles a birthday in December when today is January', () => {
    const today = new Date(2026, 0, 1, 0, 0, 0, 0); // Jan 1
    jest.useFakeTimers({ now: today });
    // Dec 25 is 358 days from Jan 1
    const days = daysUntilBirthday('1995-12-25');
    expect(days).toBe(358);
    jest.useRealTimers();
  });

  it('handles a Feb 29 birthday in a non-leap year (treated as March 1)', () => {
    // 2026 is not a leap year. new Date(2026, 1, 29) rolls over to March 1
    const today = new Date(2026, 0, 1, 0, 0, 0, 0); // Jan 1 2026
    jest.useFakeTimers({ now: today });
    const days = daysUntilBirthday('2000-02-29');
    // Feb 29 in JS for 2026 becomes March 1 = 59 days from Jan 1
    expect(days).toBe(59);
    jest.useRealTimers();
  });
});
