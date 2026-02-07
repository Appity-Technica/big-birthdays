import { GoogleAuthProvider, signInWithPopup } from 'firebase/auth';
import { auth } from './firebase';

export interface GoogleContact {
  name: string;
  dateOfBirth: string; // ISO date string YYYY-MM-DD
  photo?: string;
}

/**
 * Request access to the user's Google Contacts and fetch those with birthdays.
 * Uses a separate signInWithPopup flow with the contacts.readonly scope.
 * Returns the access token result along with contacts.
 */
export async function fetchGoogleContactsWithBirthdays(): Promise<GoogleContact[]> {
  const provider = new GoogleAuthProvider();
  provider.addScope('https://www.googleapis.com/auth/contacts.readonly');

  const result = await signInWithPopup(auth, provider);
  const credential = GoogleAuthProvider.credentialFromResult(result);
  const accessToken = credential?.accessToken;

  if (!accessToken) {
    throw new Error('Could not get access token for Google Contacts');
  }

  const contacts: GoogleContact[] = [];
  let nextPageToken: string | undefined;

  do {
    const url = new URL('https://people.googleapis.com/v1/people/me/connections');
    url.searchParams.set('personFields', 'names,birthdays,photos');
    url.searchParams.set('pageSize', '100');
    if (nextPageToken) {
      url.searchParams.set('pageToken', nextPageToken);
    }

    const response = await fetch(url.toString(), {
      headers: { Authorization: `Bearer ${accessToken}` },
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Google Contacts API error: ${error}`);
    }

    const data = await response.json();

    for (const person of data.connections || []) {
      const name = person.names?.[0]?.displayName;
      const birthday = person.birthdays?.[0]?.date;

      if (!name || !birthday || !birthday.month || !birthday.day) continue;

      // Google returns { year?, month, day } — year may be missing
      const year = birthday.year || 2000; // default year if not provided
      const month = String(birthday.month).padStart(2, '0');
      const day = String(birthday.day).padStart(2, '0');
      const dateOfBirth = `${year}-${month}-${day}`;

      const photo = person.photos?.[0]?.url;

      contacts.push({ name, dateOfBirth, photo });
    }

    nextPageToken = data.nextPageToken;
  } while (nextPageToken);

  return contacts.sort((a, b) => a.name.localeCompare(b.name));
}
