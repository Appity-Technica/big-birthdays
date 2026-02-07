import {
  collection,
  doc,
  getDocs,
  getDoc,
  addDoc,
  updateDoc,
  deleteDoc,
  query,
  orderBy,
  serverTimestamp,
} from 'firebase/firestore';
import { db } from './firebase';
import { Person } from '@/types';
import { generateId } from './utils';

function peopleCollection(userId: string) {
  return collection(db, 'users', userId, 'people');
}

/** Strip undefined values — Firestore rejects them. */
function stripUndefined<T extends Record<string, unknown>>(obj: T): T {
  return Object.fromEntries(
    Object.entries(obj).filter(([, v]) => v !== undefined)
  ) as T;
}

export async function getAllPeopleFirestore(userId: string): Promise<Person[]> {
  const q = query(peopleCollection(userId), orderBy('name'));
  const snapshot = await getDocs(q);
  return snapshot.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  })) as Person[];
}

export async function getPersonByIdFirestore(userId: string, personId: string): Promise<Person | undefined> {
  const docRef = doc(db, 'users', userId, 'people', personId);
  const snapshot = await getDoc(docRef);
  if (!snapshot.exists()) return undefined;
  return { id: snapshot.id, ...snapshot.data() } as Person;
}

export async function addPersonFirestore(
  userId: string,
  person: Omit<Person, 'id' | 'createdAt' | 'updatedAt'>
): Promise<Person> {
  const now = new Date().toISOString();
  const data = stripUndefined({
    ...person,
    createdAt: now,
    updatedAt: now,
  });
  const docRef = await addDoc(peopleCollection(userId), data);
  return { ...data, id: docRef.id } as Person;
}

export async function updatePersonFirestore(
  userId: string,
  personId: string,
  updates: Partial<Omit<Person, 'id' | 'createdAt'>>
): Promise<void> {
  const docRef = doc(db, 'users', userId, 'people', personId);
  await updateDoc(docRef, stripUndefined({
    ...updates,
    updatedAt: new Date().toISOString(),
  }));
}

export async function deletePersonFirestore(userId: string, personId: string): Promise<void> {
  const docRef = doc(db, 'users', userId, 'people', personId);
  await deleteDoc(docRef);
}

/**
 * Migrate all people from localStorage to Firestore for a newly signed-in user.
 */
export async function migrateLocalToFirestore(userId: string, localPeople: Person[]): Promise<void> {
  for (const person of localPeople) {
    const { id, ...data } = person;
    await addDoc(peopleCollection(userId), stripUndefined(data as Record<string, unknown>));
  }
}
