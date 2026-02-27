import { parseCSV, parseJSON, parseFile, generateCSV, generateJSON } from '@/lib/csv';

describe('parseCSV', () => {
  it('parses a valid CSV with standard headers', () => {
    const csv = `Name,Date of Birth
Alice,1990-03-15
Bob,1985-12-25`;
    const result = parseCSV(csv);
    expect(result).toEqual([
      { name: 'Alice', dateOfBirth: '1990-03-15' },
      { name: 'Bob', dateOfBirth: '1985-12-25' },
    ]);
  });

  it('returns results sorted by name', () => {
    const csv = `Name,Birthday
Zara,2000-01-01
Alice,1995-06-15`;
    const result = parseCSV(csv);
    expect(result[0].name).toBe('Alice');
    expect(result[1].name).toBe('Zara');
  });

  it('returns an empty array for a file with only a header', () => {
    const csv = `Name,Date of Birth`;
    const result = parseCSV(csv);
    expect(result).toEqual([]);
  });

  it('returns an empty array for an empty file', () => {
    const result = parseCSV('');
    expect(result).toEqual([]);
  });

  it('returns an empty array for a single empty line', () => {
    const result = parseCSV('\n');
    expect(result).toEqual([]);
  });

  it('throws when exceeding 10,000 row limit', () => {
    const header = 'Name,DOB';
    const rows = Array.from({ length: 10001 }, (_, i) => `Person${i},1990-01-01`);
    const csv = [header, ...rows].join('\n');
    expect(() => parseCSV(csv)).toThrow('File exceeds maximum of 10,000 rows');
  });

  it('handles quoted fields with commas', () => {
    const csv = `Name,Date of Birth
"Last, First",1990-03-15`;
    const result = parseCSV(csv);
    expect(result).toHaveLength(1);
    expect(result[0].name).toBe('Last, First');
    expect(result[0].dateOfBirth).toBe('1990-03-15');
  });

  it('handles quoted fields with escaped double quotes', () => {
    const csv = `Name,Birthday
"She said ""hi""",1990-01-01`;
    const result = parseCSV(csv);
    expect(result[0].name).toBe('She said "hi"');
  });

  it('recognises alternative column headers', () => {
    const csv = `Full Name,DOB
Charlie,2001-07-04`;
    const result = parseCSV(csv);
    expect(result).toEqual([{ name: 'Charlie', dateOfBirth: '2001-07-04' }]);
  });

  it('throws when required columns are missing', () => {
    const csv = `First,Last,Email
Alice,Smith,alice@example.com`;
    expect(() => parseCSV(csv)).toThrow('Could not find required columns');
  });

  it('handles DD/MM/YYYY date format', () => {
    const csv = `Name,Birthday
Alice,15/03/1990`;
    const result = parseCSV(csv);
    expect(result[0].dateOfBirth).toBe('1990-03-15');
  });

  it('handles DD-MM-YYYY date format', () => {
    const csv = `Name,Birthday
Alice,15-03-1990`;
    const result = parseCSV(csv);
    expect(result[0].dateOfBirth).toBe('1990-03-15');
  });

  it('skips rows with empty name or date', () => {
    const csv = `Name,Birthday
Alice,1990-03-15
,1990-01-01
Bob,`;
    const result = parseCSV(csv);
    expect(result).toHaveLength(1);
    expect(result[0].name).toBe('Alice');
  });

  it('handles Windows-style line endings (\\r\\n)', () => {
    const csv = "Name,Birthday\r\nAlice,1990-03-15\r\nBob,1985-12-25";
    const result = parseCSV(csv);
    expect(result).toHaveLength(2);
  });
});

describe('parseJSON', () => {
  it('parses a valid JSON array', () => {
    const json = JSON.stringify([
      { name: 'Alice', birthday: '1990-03-15' },
      { name: 'Bob', dob: '1985-12-25' },
    ]);
    const result = parseJSON(json);
    expect(result).toEqual([
      { name: 'Alice', dateOfBirth: '1990-03-15' },
      { name: 'Bob', dateOfBirth: '1985-12-25' },
    ]);
  });

  it('throws on invalid JSON', () => {
    expect(() => parseJSON('not json')).toThrow('Invalid JSON');
  });

  it('throws when no valid contacts are found', () => {
    const json = JSON.stringify([{ foo: 'bar' }]);
    expect(() => parseJSON(json)).toThrow('No valid contacts found');
  });
});

describe('parseFile', () => {
  it('delegates to parseJSON for .json files', () => {
    const json = JSON.stringify([{ name: 'Alice', birthday: '1990-01-01' }]);
    const result = parseFile(json, 'contacts.json');
    expect(result[0].name).toBe('Alice');
  });

  it('delegates to parseCSV for .csv files', () => {
    const csv = `Name,Birthday\nAlice,1990-01-01`;
    const result = parseFile(csv, 'contacts.csv');
    expect(result[0].name).toBe('Alice');
  });
});

describe('generateCSV', () => {
  it('generates valid CSV with headers', () => {
    const csv = generateCSV([
      { name: 'Alice', dateOfBirth: '1990-03-15', relationship: 'friend' },
    ]);
    expect(csv).toContain('Name,Date of Birth');
    expect(csv).toContain('Alice,1990-03-15,friend');
  });

  it('escapes fields containing commas', () => {
    const csv = generateCSV([
      { name: 'Last, First', dateOfBirth: '1990-03-15', relationship: 'friend' },
    ]);
    expect(csv).toContain('"Last, First"');
  });
});

describe('generateJSON', () => {
  it('generates valid JSON with required fields', () => {
    const json = generateJSON([
      { name: 'Alice', dateOfBirth: '1990-03-15', relationship: 'friend' },
    ]);
    const parsed = JSON.parse(json);
    expect(parsed).toHaveLength(1);
    expect(parsed[0].name).toBe('Alice');
    expect(parsed[0].dateOfBirth).toBe('1990-03-15');
    expect(parsed[0].relationship).toBe('friend');
  });

  it('includes optional fields when present', () => {
    const json = generateJSON([
      {
        name: 'Alice',
        dateOfBirth: '1990-03-15',
        relationship: 'friend',
        interests: ['cooking'],
        notes: 'Likes red',
      },
    ]);
    const parsed = JSON.parse(json);
    expect(parsed[0].interests).toEqual(['cooking']);
    expect(parsed[0].notes).toBe('Likes red');
  });

  it('omits optional fields when not present', () => {
    const json = generateJSON([
      { name: 'Alice', dateOfBirth: '1990-03-15', relationship: 'friend' },
    ]);
    const parsed = JSON.parse(json);
    expect(parsed[0].interests).toBeUndefined();
    expect(parsed[0].notes).toBeUndefined();
  });
});
