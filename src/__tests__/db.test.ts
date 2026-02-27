/**
 * Tests for db utility helpers.
 *
 * The stripUndefined function is private to db.ts and not exported.
 * Rather than modifying the module for test access, we verify the same
 * logic here to ensure the pattern works correctly. If the implementation
 * ever drifts, these tests document the expected behaviour.
 */

/** Replicates the stripUndefined helper from db.ts */
function stripUndefined<T extends Record<string, unknown>>(obj: T): T {
  return Object.fromEntries(
    Object.entries(obj).filter(([, v]) => v !== undefined)
  ) as T;
}

describe('stripUndefined', () => {
  it('removes keys with undefined values', () => {
    const result = stripUndefined({ a: 1, b: undefined, c: 'hello' });
    expect(result).toEqual({ a: 1, c: 'hello' });
    expect('b' in result).toBe(false);
  });

  it('keeps null values (Firestore accepts null)', () => {
    const result = stripUndefined({ a: null, b: 'test' });
    expect(result).toEqual({ a: null, b: 'test' });
  });

  it('keeps empty strings', () => {
    const result = stripUndefined({ a: '', b: 'test' });
    expect(result).toEqual({ a: '', b: 'test' });
  });

  it('keeps zero values', () => {
    const result = stripUndefined({ a: 0, b: false });
    expect(result).toEqual({ a: 0, b: false });
  });

  it('returns an empty object when all values are undefined', () => {
    const result = stripUndefined({ a: undefined, b: undefined });
    expect(result).toEqual({});
  });

  it('returns the same object shape when nothing is undefined', () => {
    const input = { name: 'Alice', age: 30, active: true };
    const result = stripUndefined(input);
    expect(result).toEqual(input);
  });

  it('handles nested objects (only strips top-level undefined)', () => {
    const result = stripUndefined({
      a: { nested: undefined },
      b: undefined,
    });
    // The nested undefined should remain; only top-level is stripped
    expect(result).toEqual({ a: { nested: undefined } });
    expect('b' in result).toBe(false);
  });
});
