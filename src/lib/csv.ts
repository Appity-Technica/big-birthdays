export interface ImportContact {
  name: string;
  dateOfBirth: string; // ISO YYYY-MM-DD
}

/**
 * Parse a CSV string into contacts with names and birthdays.
 * Handles flexible column headers and common date formats.
 */
export function parseCSV(text: string): ImportContact[] {
  const lines = text.split(/\r?\n/).filter((l) => l.trim());
  if (lines.length < 2) return [];

  const headers = parseCSVRow(lines[0]).map((h) => h.toLowerCase().trim());

  const nameCol = headers.findIndex((h) =>
    ['name', 'full name', 'fullname', 'person', 'contact'].includes(h)
  );
  const dobCol = headers.findIndex((h) =>
    ['date of birth', 'dateofbirth', 'date_of_birth', 'dob', 'birthday', 'birth date', 'birthdate', 'birth_date'].includes(h)
  );

  if (nameCol === -1 || dobCol === -1) {
    throw new Error(
      `Could not find required columns. Expected a "Name" column and a "Date of Birth" (or "Birthday" / "DOB") column. Found: ${headers.join(', ')}`
    );
  }

  const contacts: ImportContact[] = [];

  for (let i = 1; i < lines.length; i++) {
    const cols = parseCSVRow(lines[i]);
    const name = cols[nameCol]?.trim();
    const rawDate = cols[dobCol]?.trim();

    if (!name || !rawDate) continue;

    const dateOfBirth = normaliseDate(rawDate);
    if (!dateOfBirth) continue;

    contacts.push({ name, dateOfBirth });
  }

  return contacts.sort((a, b) => a.name.localeCompare(b.name));
}

/** Parse a single CSV row, respecting quoted fields. */
function parseCSVRow(line: string): string[] {
  const fields: string[] = [];
  let current = '';
  let inQuotes = false;

  for (let i = 0; i < line.length; i++) {
    const ch = line[i];
    if (inQuotes) {
      if (ch === '"' && line[i + 1] === '"') {
        current += '"';
        i++;
      } else if (ch === '"') {
        inQuotes = false;
      } else {
        current += ch;
      }
    } else {
      if (ch === '"') {
        inQuotes = true;
      } else if (ch === ',') {
        fields.push(current);
        current = '';
      } else {
        current += ch;
      }
    }
  }
  fields.push(current);
  return fields;
}

/**
 * Normalise a date string into YYYY-MM-DD (or 0000-MM-DD when year is unknown).
 * Supports: YYYY-MM-DD, DD/MM/YYYY, DD-MM-YYYY, DD.MM.YYYY, DD/MM, DD-MM,
 * and natural formats like "1 Jan 2000", "January 1", "15 March".
 */
function normaliseDate(raw: string): string | null {
  // Already ISO: YYYY-MM-DD
  if (/^\d{4}-\d{2}-\d{2}$/.test(raw)) return raw;

  // DD/MM/YYYY or DD-MM-YYYY or DD.MM.YYYY (with year)
  const dmy = raw.match(/^(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4})$/);
  if (dmy) {
    const [, d, m, y] = dmy;
    return `${y}-${m.padStart(2, '0')}-${d.padStart(2, '0')}`;
  }

  // DD/MM or DD-MM or DD.MM (no year)
  const dmOnly = raw.match(/^(\d{1,2})[/\-.](\d{1,2})$/);
  if (dmOnly) {
    const [, d, m] = dmOnly;
    return `0000-${m.padStart(2, '0')}-${d.padStart(2, '0')}`;
  }

  // Try JS Date parse as fallback (handles "Jan 1, 2000", "15 March 1990" etc.)
  const parsed = new Date(raw);
  if (!isNaN(parsed.getTime()) && parsed.getFullYear() > 1900) {
    const y = parsed.getFullYear();
    const m = String(parsed.getMonth() + 1).padStart(2, '0');
    const d = String(parsed.getDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
  }

  // Try without year: "15 March", "March 15", "1 Jan"
  const withFakeYear = new Date(`${raw} 2000`);
  if (!isNaN(withFakeYear.getTime())) {
    const m = String(withFakeYear.getMonth() + 1).padStart(2, '0');
    const d = String(withFakeYear.getDate()).padStart(2, '0');
    return `0000-${m}-${d}`;
  }

  return null;
}

// ── JSON import ──────────────────────────────────────────

const NAME_KEYS = ['name', 'fullname', 'full_name', 'full name', 'person', 'contact'];
const DOB_KEYS = ['dateofbirth', 'date_of_birth', 'date of birth', 'dob', 'birthday', 'birthdate', 'birth_date', 'birth date'];

/**
 * Parse a JSON string (array of objects) into contacts.
 * Flexible key matching for name and date fields.
 */
export function parseJSON(text: string): ImportContact[] {
  let data: unknown;
  try {
    data = JSON.parse(text);
  } catch {
    throw new Error('Invalid JSON. Expected an array of objects like [{"name": "...", "birthday": "..."}]');
  }

  const arr = Array.isArray(data) ? data : [data];
  if (arr.length === 0 || typeof arr[0] !== 'object' || arr[0] === null) {
    throw new Error('Expected an array of objects with "name" and "birthday" (or "dob") fields.');
  }

  const contacts: ImportContact[] = [];

  for (const item of arr) {
    if (typeof item !== 'object' || item === null) continue;
    const obj = item as Record<string, unknown>;

    const nameKey = Object.keys(obj).find((k) => NAME_KEYS.includes(k.toLowerCase().trim()));
    const dobKey = Object.keys(obj).find((k) => DOB_KEYS.includes(k.toLowerCase().trim()));

    if (!nameKey || !dobKey) continue;

    const name = String(obj[nameKey] ?? '').trim();
    const rawDate = String(obj[dobKey] ?? '').trim();
    if (!name || !rawDate) continue;

    const dateOfBirth = normaliseDate(rawDate);
    if (!dateOfBirth) continue;

    contacts.push({ name, dateOfBirth });
  }

  if (contacts.length === 0) {
    throw new Error('No valid contacts found. Each object needs a "name" and a date field ("birthday", "dob", or "date_of_birth").');
  }

  return contacts.sort((a, b) => a.name.localeCompare(b.name));
}

/**
 * Auto-detect format and parse file contents.
 */
export function parseFile(text: string, filename: string): ImportContact[] {
  const ext = filename.toLowerCase().split('.').pop();
  if (ext === 'json') return parseJSON(text);
  return parseCSV(text);
}

// ── Export ────────────────────────────────────────────────

interface ExportPerson {
  name: string;
  dateOfBirth: string;
  relationship: string;
  connectedThrough?: string;
  knownFrom?: string;
  knownFromCustom?: string;
  notes?: string;
  interests?: string[];
  giftIdeas?: string[];
  pastGifts?: { year: number; description: string; url?: string; rating?: number }[];
}

/** Escape a value for CSV (wrap in quotes if it contains comma, quote, or newline). */
function escapeCSV(value: string): string {
  if (value.includes(',') || value.includes('"') || value.includes('\n')) {
    return `"${value.replace(/"/g, '""')}"`;
  }
  return value;
}

/**
 * Generate a CSV string from people data.
 * Columns: Name, Date of Birth, Relationship, Connected Through, Known From, Notes, Interests, Gift Ideas
 */
export function generateCSV(people: ExportPerson[]): string {
  const headers = ['Name', 'Date of Birth', 'Relationship', 'Connected Through', 'Known From', 'Notes', 'Interests', 'Gift Ideas'];
  const rows = people.map((p) => [
    escapeCSV(p.name),
    escapeCSV(p.dateOfBirth),
    escapeCSV(p.relationship),
    escapeCSV(p.connectedThrough || ''),
    escapeCSV(p.knownFrom === 'other' && p.knownFromCustom ? p.knownFromCustom : p.knownFrom || ''),
    escapeCSV(p.notes || ''),
    escapeCSV((p.interests || []).join(', ')),
    escapeCSV((p.giftIdeas || []).join(', ')),
  ]);

  return [headers.join(','), ...rows.map((r) => r.join(','))].join('\n');
}

/**
 * Generate a JSON string from people data.
 * Includes all person fields except internal IDs and timestamps.
 */
export function generateJSON(people: ExportPerson[]): string {
  const exported = people.map((p) => {
    const obj: Record<string, unknown> = {
      name: p.name,
      dateOfBirth: p.dateOfBirth,
      relationship: p.relationship,
    };
    if (p.connectedThrough) obj.connectedThrough = p.connectedThrough;
    if (p.knownFrom) obj.knownFrom = p.knownFrom;
    if (p.knownFromCustom) obj.knownFromCustom = p.knownFromCustom;
    if (p.notes) obj.notes = p.notes;
    if (p.interests?.length) obj.interests = p.interests;
    if (p.giftIdeas?.length) obj.giftIdeas = p.giftIdeas;
    if (p.pastGifts?.length) obj.pastGifts = p.pastGifts;
    return obj;
  });
  return JSON.stringify(exported, null, 2);
}
