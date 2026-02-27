'use client';

import { useCallback, useEffect, useState } from 'react';
import { useAuth } from '@/components/AuthProvider';
import { Person } from '@/types';
import * as local from '@/lib/localStorage';
import * as firestore from '@/lib/db';

export function usePeople() {
  const { user, loading: authLoading } = useAuth();
  const [people, setPeople] = useState<Person[]>([]);
  const [loading, setLoading] = useState(true);

  const refresh = useCallback(async () => {
    setLoading(true);
    if (user) {
      const data = await firestore.getAllPeopleFirestore(user.uid);
      setPeople(data);
    } else {
      setPeople(local.getAllPeople());
    }
    setLoading(false);
  }, [user]);

  useEffect(() => {
    if (!authLoading) {
      // Load initial data when auth state resolves
      void (async () => {
        setLoading(true);
        if (user) {
          const data = await firestore.getAllPeopleFirestore(user.uid);
          setPeople(data);
        } else {
          setPeople(local.getAllPeople());
        }
        setLoading(false);
      })();
    }
  }, [authLoading, user]);

  async function addPerson(person: Omit<Person, 'id' | 'createdAt' | 'updatedAt'>) {
    if (user) {
      await firestore.addPersonFirestore(user.uid, person);
    } else {
      local.addPerson(person);
    }
    await refresh();
  }

  async function updatePerson(id: string, updates: Partial<Omit<Person, 'id' | 'createdAt'>>) {
    if (user) {
      await firestore.updatePersonFirestore(user.uid, id, updates);
    } else {
      local.updatePerson(id, updates);
    }
    await refresh();
  }

  async function deletePerson(id: string) {
    if (user) {
      await firestore.deletePersonFirestore(user.uid, id);
    } else {
      local.deletePerson(id);
    }
    await refresh();
  }

  function getPersonById(id: string): Person | undefined {
    return people.find((p) => p.id === id);
  }

  return {
    people,
    loading: authLoading || loading,
    addPerson,
    updatePerson,
    deletePerson,
    getPersonById,
    refresh,
  };
}
