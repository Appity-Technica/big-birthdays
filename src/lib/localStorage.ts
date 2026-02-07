import { Person } from '@/types';
import { generateId } from './utils';

const STORAGE_KEY = 'big-birthdays-people';

function getPeople(): Person[] {
  if (typeof window === 'undefined') return [];
  const data = localStorage.getItem(STORAGE_KEY);
  return data ? JSON.parse(data) : [];
}

function savePeople(people: Person[]): void {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(people));
}

export function getAllPeople(): Person[] {
  return getPeople();
}

export function getPersonById(id: string): Person | undefined {
  return getPeople().find((p) => p.id === id);
}

export function addPerson(person: Omit<Person, 'id' | 'createdAt' | 'updatedAt'>): Person {
  const now = new Date().toISOString();
  const newPerson: Person = {
    ...person,
    id: generateId(),
    createdAt: now,
    updatedAt: now,
  };
  const people = getPeople();
  people.push(newPerson);
  savePeople(people);
  return newPerson;
}

export function updatePerson(id: string, updates: Partial<Omit<Person, 'id' | 'createdAt'>>): Person | undefined {
  const people = getPeople();
  const index = people.findIndex((p) => p.id === id);
  if (index === -1) return undefined;
  people[index] = {
    ...people[index],
    ...updates,
    updatedAt: new Date().toISOString(),
  };
  savePeople(people);
  return people[index];
}

export function deletePerson(id: string): boolean {
  const people = getPeople();
  const filtered = people.filter((p) => p.id !== id);
  if (filtered.length === people.length) return false;
  savePeople(filtered);
  return true;
}
