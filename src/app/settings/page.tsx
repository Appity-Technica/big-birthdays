'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { useAuth } from '@/components/AuthProvider';
import { getNotificationSettings, saveNotificationSettings, getPreferences, savePreferences } from '@/lib/db';
import { NotificationTiming, NotificationSettings, CountryCode, SUPPORTED_COUNTRIES } from '@/types';

const TIMING_OPTIONS: { value: NotificationTiming; label: string }[] = [
  { value: 'on-the-day', label: 'On the day' },
  { value: '1-day', label: '1 day before' },
  { value: '3-days', label: '3 days before' },
  { value: '1-week', label: '1 week before' },
  { value: '2-weeks', label: '2 weeks before' },
];

export default function SettingsPage() {
  const { user, loading: authLoading } = useAuth();
  const [enabled, setEnabled] = useState(false);
  const [timings, setTimings] = useState<NotificationTiming[]>(['on-the-day', '1-day']);
  const [country, setCountry] = useState<CountryCode>('AU');
  const [fcmToken, setFcmToken] = useState<string | undefined>();
  const [permissionState, setPermissionState] = useState<NotificationPermission | 'unsupported'>('default');
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);

  useEffect(() => {
    if (typeof window !== 'undefined' && 'Notification' in window) {
      setPermissionState(Notification.permission);
    } else {
      setPermissionState('unsupported');
    }
  }, []);

  useEffect(() => {
    if (!user) return;
    Promise.all([
      getNotificationSettings(user.uid),
      getPreferences(user.uid),
    ]).then(([notifSettings, prefs]) => {
      if (notifSettings) {
        setEnabled(notifSettings.enabled);
        setTimings(notifSettings.defaultTimings);
        setFcmToken(notifSettings.fcmToken);
      }
      if (prefs) {
        setCountry(prefs.country);
      }
      setLoading(false);
    });
  }, [user]);

  function toggleTiming(timing: NotificationTiming) {
    setTimings((prev) =>
      prev.includes(timing) ? prev.filter((t) => t !== timing) : [...prev, timing]
    );
  }

  async function handleToggleEnabled() {
    if (!enabled) {
      // Turning on — lazy-load FCM and request permission
      const { requestNotificationPermission } = await import('@/lib/fcm');
      const token = await requestNotificationPermission();
      if (!token) {
        setPermissionState(typeof Notification !== 'undefined' ? Notification.permission : 'unsupported');
        return;
      }
      setFcmToken(token);
      setPermissionState('granted');
      setEnabled(true);
    } else {
      setEnabled(false);
    }
  }

  async function handleSave() {
    if (!user) return;
    setSaving(true);
    const settings: NotificationSettings = {
      enabled,
      defaultTimings: timings,
      fcmToken,
    };
    await Promise.all([
      saveNotificationSettings(user.uid, settings),
      savePreferences(user.uid, { country }),
    ]);
    setSaving(false);
    setSaved(true);
    setTimeout(() => setSaved(false), 2000);
  }

  if (authLoading || loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="w-10 h-10 rounded-full border-4 border-lavender border-t-purple animate-spin" />
      </div>
    );
  }

  if (!user) {
    return (
      <div className="max-w-2xl mx-auto px-4 py-16 text-center">
        <h1 className="font-display text-2xl font-bold text-purple mb-4">Sign in required</h1>
        <p className="text-foreground/50 mb-6">You need to be signed in to manage notification settings.</p>
        <Link href="/login" className="text-sm font-bold text-purple hover:underline">
          Sign in
        </Link>
      </div>
    );
  }

  return (
    <div className="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <Link
        href="/"
        className="inline-flex items-center gap-1.5 text-sm font-semibold text-purple/60 hover:text-purple transition-colors mb-6"
      >
        <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
          <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 19.5L8.25 12l7.5-7.5" />
        </svg>
        Home
      </Link>

      <h1 className="font-display text-3xl sm:text-4xl font-bold text-purple mb-2">Settings</h1>
      <p className="text-foreground/50 mb-8">Manage your preferences.</p>

      <div className="space-y-6">
        {/* Country */}
        <div className="p-5 rounded-2xl bg-mint/20 border border-mint">
          <h2 className="text-sm font-bold text-foreground mb-1">Country</h2>
          <p className="text-xs text-foreground/50 mb-3">Used for gift suggestions and currency</p>
          <select
            value={country}
            onChange={(e) => setCountry(e.target.value as CountryCode)}
            className="w-full sm:w-64 px-4 py-2.5 rounded-xl bg-surface border border-mint text-sm font-semibold text-foreground focus:outline-none focus:ring-2 focus:ring-teal/30"
          >
            {Object.entries(SUPPORTED_COUNTRIES).map(([code, name]) => (
              <option key={code} value={code}>{name}</option>
            ))}
          </select>
        </div>

        {/* Notification toggle */}
        <div className="p-5 rounded-2xl bg-lavender/20 border border-lavender">
          <div className="flex items-center justify-between">
            <div>
              <h2 className="text-sm font-bold text-foreground">Push Notifications</h2>
              <p className="text-xs text-foreground/50 mt-0.5">Get reminded about upcoming birthdays</p>
            </div>
            <button
              onClick={handleToggleEnabled}
              className={`relative w-12 h-7 rounded-full transition-colors ${
                enabled ? 'bg-purple' : 'bg-foreground/20'
              }`}
            >
              <span
                className={`absolute top-0.5 left-0.5 w-6 h-6 rounded-full bg-white shadow transition-transform ${
                  enabled ? 'translate-x-5' : 'translate-x-0'
                }`}
              />
            </button>
          </div>

          {permissionState === 'denied' && (
            <p className="mt-3 text-xs font-bold text-coral">
              Notifications are blocked in your browser. Please enable them in your browser settings.
            </p>
          )}

          {permissionState === 'unsupported' && (
            <p className="mt-3 text-xs font-bold text-orange">
              Your browser does not support push notifications.
            </p>
          )}
        </div>

        {/* Timing options */}
        {enabled && (
          <div className="p-5 rounded-2xl bg-mint/20 border border-mint">
            <h2 className="text-sm font-bold text-foreground mb-3">When to notify (defaults)</h2>
            <p className="text-xs text-foreground/50 mb-4">
              These apply to all people unless overridden individually.
            </p>
            <div className="space-y-2">
              {TIMING_OPTIONS.map((opt) => (
                <label key={opt.value} className="flex items-center gap-3 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={timings.includes(opt.value)}
                    onChange={() => toggleTiming(opt.value)}
                    className="w-5 h-5 rounded border-2 border-lavender text-teal focus:ring-teal/20 accent-teal"
                  />
                  <span className="text-sm font-semibold text-foreground">{opt.label}</span>
                </label>
              ))}
            </div>
            {timings.length === 0 && (
              <p className="mt-3 text-xs font-bold text-orange">Select at least one timing option.</p>
            )}
          </div>
        )}

        {/* Save button */}
        <div className="flex items-center gap-3 pt-2">
          <button
            onClick={handleSave}
            disabled={saving || (enabled && timings.length === 0)}
            className="inline-flex items-center gap-2 px-8 py-3.5 bg-purple text-white rounded-full font-bold text-sm hover:bg-purple-dark transition-all shadow-lg shadow-purple/25 disabled:opacity-50"
          >
            {saving ? (
              <>
                <div className="w-5 h-5 rounded-full border-2 border-white/30 border-t-white animate-spin" />
                Saving...
              </>
            ) : saved ? (
              <>
                <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M4.5 12.75l6 6 9-13.5" />
                </svg>
                Saved!
              </>
            ) : (
              'Save Settings'
            )}
          </button>
        </div>
      </div>
    </div>
  );
}
