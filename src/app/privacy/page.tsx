import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Privacy Policy — Tiaras & Trains",
  description: "Privacy policy for the Tiaras & Trains birthday tracker app by Appity Technica.",
};

export default function PrivacyPage() {
  const lastUpdated = "27 February 2026";

  return (
    <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-10 pb-20">
      {/* Header */}
      <div className="mb-10">
        <p className="text-xs font-bold uppercase tracking-widest text-purple/60 mb-2">
          Appity Technica
        </p>
        <h1 className="font-display text-4xl sm:text-5xl font-bold text-purple mb-3">
          Privacy Policy
        </h1>
        <p className="text-sm text-foreground/50">
          Last updated: {lastUpdated}
        </p>
      </div>

      {/* Intro */}
      <div className="p-5 rounded-2xl bg-lavender/20 border border-lavender mb-8">
        <p className="text-sm leading-relaxed text-foreground/80">
          This privacy policy describes how <strong className="text-foreground">Appity Technica</strong> collects,
          uses, and protects information when you use <strong className="text-foreground">Tiaras &amp; Trains</strong>{" "}
          (also known as <strong className="text-foreground">Big Birthdays</strong>), a birthday tracking
          application available on web, iOS, and Android. By using the app, you agree to the practices
          described in this policy.
        </p>
      </div>

      <div className="space-y-8">

        {/* Section 1 */}
        <section>
          <h2 className="font-display text-xl font-bold text-purple mb-3">
            1. Information We Collect
          </h2>
          <div className="space-y-4">
            <div className="p-5 rounded-2xl bg-mint/20 border border-mint">
              <h3 className="text-sm font-bold text-foreground mb-2">Account Information</h3>
              <p className="text-sm text-foreground/70 leading-relaxed">
                When you create an account we collect your <strong className="text-foreground">name</strong> and{" "}
                <strong className="text-foreground">email address</strong> via Firebase Authentication.
                You may sign in using email/password or a supported third-party identity provider.
              </p>
            </div>

            <div className="p-5 rounded-2xl bg-mint/20 border border-mint">
              <h3 className="text-sm font-bold text-foreground mb-2">Birthday &amp; Contact Data</h3>
              <p className="text-sm text-foreground/70 leading-relaxed">
                For each person you choose to track, you may provide their{" "}
                <strong className="text-foreground">name</strong>,{" "}
                <strong className="text-foreground">date of birth</strong>,{" "}
                <strong className="text-foreground">relationship to you</strong>,{" "}
                <strong className="text-foreground">interests</strong>,{" "}
                <strong className="text-foreground">personal notes</strong>, and{" "}
                <strong className="text-foreground">gift ideas</strong>. This information is stored
                under your account and is never shared with other users.
              </p>
            </div>

            <div className="p-5 rounded-2xl bg-mint/20 border border-mint">
              <h3 className="text-sm font-bold text-foreground mb-2">Device Contacts (Optional)</h3>
              <p className="text-sm text-foreground/70 leading-relaxed">
                With your explicit permission, the app can read your device contacts to help you
                import birthday information. Contact data is read locally on your device solely
                to pre-fill the import form; it is not uploaded or retained beyond your import session.
              </p>
            </div>

            <div className="p-5 rounded-2xl bg-mint/20 border border-mint">
              <h3 className="text-sm font-bold text-foreground mb-2">Usage &amp; Analytics Data</h3>
              <p className="text-sm text-foreground/70 leading-relaxed">
                We use <strong className="text-foreground">Firebase Analytics</strong> to collect
                anonymised usage information such as feature interactions and crash reports.
                This data helps us improve the app and does not identify you personally.
              </p>
            </div>

            <div className="p-5 rounded-2xl bg-mint/20 border border-mint">
              <h3 className="text-sm font-bold text-foreground mb-2">Push Notification Tokens</h3>
              <p className="text-sm text-foreground/70 leading-relaxed">
                If you enable push notifications, we store a{" "}
                <strong className="text-foreground">Firebase Cloud Messaging (FCM) token</strong>{" "}
                for your device. This token is used only to deliver birthday reminders to you.
              </p>
            </div>
          </div>
        </section>

        {/* Section 2 */}
        <section>
          <h2 className="font-display text-xl font-bold text-purple mb-3">
            2. How We Use Your Information
          </h2>
          <ul className="space-y-2.5">
            {[
              "Authenticate you and secure your account.",
              "Store and display your tracked birthdays and associated notes.",
              "Send birthday reminder notifications at the times you configure.",
              "Generate personalised gift suggestions using AI (see Section 3).",
              "Improve app performance, fix bugs, and develop new features through anonymised analytics.",
              "Respond to support requests you send us.",
            ].map((item) => (
              <li key={item} className="flex gap-3 text-sm text-foreground/70 leading-relaxed">
                <span className="mt-0.5 flex-shrink-0 w-5 h-5 rounded-full bg-purple/10 flex items-center justify-center">
                  <svg className="w-3 h-3 text-purple" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={3}>
                    <path strokeLinecap="round" strokeLinejoin="round" d="M4.5 12.75l6 6 9-13.5" />
                  </svg>
                </span>
                {item}
              </li>
            ))}
          </ul>
        </section>

        {/* Section 3 */}
        <section>
          <h2 className="font-display text-xl font-bold text-purple mb-3">
            3. AI-Powered Gift Suggestions
          </h2>
          <div className="p-5 rounded-2xl bg-lavender/20 border border-lavender">
            <p className="text-sm text-foreground/70 leading-relaxed mb-3">
              When you request gift ideas for a person, the app sends a limited set of details — their{" "}
              <strong className="text-foreground">name</strong>,{" "}
              <strong className="text-foreground">age</strong>,{" "}
              <strong className="text-foreground">interests</strong>, and{" "}
              <strong className="text-foreground">previously recorded gift ideas</strong> — to the{" "}
              <strong className="text-foreground">Anthropic Claude API</strong> via a secure
              Firebase Cloud Function. This data is transmitted solely to generate suggestions
              and is not stored by Anthropic beyond the duration of the request.
            </p>
            <p className="text-sm text-foreground/70 leading-relaxed">
              Anthropic processes this data in accordance with their own privacy policy. We encourage
              you to review it at{" "}
              <a
                href="https://www.anthropic.com/legal/privacy"
                target="_blank"
                rel="noopener noreferrer"
                className="font-semibold text-purple hover:underline"
              >
                anthropic.com/legal/privacy
              </a>
              . You are never required to use the gift suggestion feature.
            </p>
          </div>
        </section>

        {/* Section 4 */}
        <section>
          <h2 className="font-display text-xl font-bold text-purple mb-3">
            4. Data Storage &amp; Security
          </h2>
          <p className="text-sm text-foreground/70 leading-relaxed mb-4">
            Your data is stored in <strong className="text-foreground">Google Cloud Firestore</strong>{" "}
            in the <strong className="text-foreground">europe-west4 (Netherlands)</strong> region.
            Access is restricted by Firebase Security Rules so that only you can read or write your
            own data.
          </p>
          <p className="text-sm text-foreground/70 leading-relaxed">
            All data in transit is encrypted using TLS. Firebase Authentication and Firestore
            security rules are used to ensure that your account and data cannot be accessed by
            other users. While we take reasonable measures to protect your information, no system
            can guarantee absolute security.
          </p>
        </section>

        {/* Section 5 */}
        <section>
          <h2 className="font-display text-xl font-bold text-purple mb-3">
            5. Data Sharing &amp; Third Parties
          </h2>
          <div className="p-5 rounded-2xl bg-mint/20 border border-mint mb-4">
            <p className="text-sm font-bold text-foreground mb-1">
              We do not sell your personal data. Ever.
            </p>
            <p className="text-sm text-foreground/70 leading-relaxed">
              We do not share your personal data with third parties for advertising or marketing purposes.
            </p>
          </div>
          <p className="text-sm text-foreground/70 leading-relaxed mb-3">
            We use the following third-party services, each operating under their own privacy policies:
          </p>
          <div className="space-y-3">
            {[
              {
                name: "Google Firebase",
                description: "Authentication, database (Firestore), Cloud Functions, Cloud Messaging, and Analytics.",
                url: "https://firebase.google.com/support/privacy",
                urlLabel: "firebase.google.com/support/privacy",
              },
              {
                name: "Anthropic",
                description: "AI-powered gift suggestions via the Claude API (see Section 3).",
                url: "https://www.anthropic.com/legal/privacy",
                urlLabel: "anthropic.com/legal/privacy",
              },
            ].map((service) => (
              <div key={service.name} className="p-4 rounded-xl bg-surface border border-lavender/40">
                <p className="text-sm font-bold text-foreground mb-0.5">{service.name}</p>
                <p className="text-xs text-foreground/60 leading-relaxed mb-1">{service.description}</p>
                <a
                  href={service.url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-xs font-semibold text-purple hover:underline"
                >
                  {service.urlLabel}
                </a>
              </div>
            ))}
          </div>
        </section>

        {/* Section 6 */}
        <section>
          <h2 className="font-display text-xl font-bold text-purple mb-3">
            6. Your Rights &amp; Choices
          </h2>
          <div className="space-y-3">
            {[
              {
                title: "Access &amp; Correction",
                body: "You can view and update all of your personal information directly within the app at any time.",
              },
              {
                title: "Delete People",
                body: "You can remove any tracked person — and all associated data — from within the app.",
              },
              {
                title: "Delete Your Account",
                body: "You can permanently delete your account and all associated data from the app settings. This action is irreversible and removes your data from our systems within 30 days.",
              },
              {
                title: "Notifications",
                body: "You can disable push notifications at any time from the app settings or your device notification settings.",
              },
              {
                title: "Contacts Access",
                body: "Contacts access is optional and can be revoked at any time through your device settings.",
              },
              {
                title: "Analytics",
                body: "Firebase Analytics can be limited by enabling the \"Limit Ad Tracking\" or equivalent privacy setting on your device.",
              },
            ].map((item) => (
              <div key={item.title} className="p-4 rounded-xl border border-lavender/40 bg-lavender/10">
                <p
                  className="text-sm font-bold text-foreground mb-1"
                  dangerouslySetInnerHTML={{ __html: item.title }}
                />
                <p className="text-sm text-foreground/70 leading-relaxed">{item.body}</p>
              </div>
            ))}
          </div>
        </section>

        {/* Section 7 */}
        <section>
          <h2 className="font-display text-xl font-bold text-purple mb-3">
            7. Children&apos;s Privacy
          </h2>
          <p className="text-sm text-foreground/70 leading-relaxed">
            Tiaras &amp; Trains is not directed at children under 13. We do not knowingly collect
            personal information from children under 13. If you believe a child under 13 has
            provided us with personal data, please contact us and we will delete it promptly.
          </p>
        </section>

        {/* Section 8 */}
        <section>
          <h2 className="font-display text-xl font-bold text-purple mb-3">
            8. Data Retention
          </h2>
          <p className="text-sm text-foreground/70 leading-relaxed">
            We retain your data for as long as your account is active. If you delete your account,
            we delete your personal data from Firestore within 30 days. Anonymised analytics data
            may be retained for longer periods in accordance with Google&apos;s standard retention policies.
          </p>
        </section>

        {/* Section 9 */}
        <section>
          <h2 className="font-display text-xl font-bold text-purple mb-3">
            9. Changes to This Policy
          </h2>
          <p className="text-sm text-foreground/70 leading-relaxed">
            We may update this privacy policy from time to time. When we do, we will revise the
            &ldquo;Last updated&rdquo; date at the top of this page. For significant changes, we
            will notify you via the app or by email. Your continued use of the app after changes
            are posted constitutes your acceptance of the updated policy.
          </p>
        </section>

        {/* Section 10 */}
        <section>
          <h2 className="font-display text-xl font-bold text-purple mb-3">
            10. Contact Us
          </h2>
          <div className="p-5 rounded-2xl bg-lavender/20 border border-lavender">
            <p className="text-sm text-foreground/70 leading-relaxed mb-3">
              If you have any questions or concerns about this privacy policy or how we handle
              your data, please contact us:
            </p>
            <p className="text-sm font-bold text-foreground">Appity Technica</p>
            <p className="text-sm text-foreground/70">
              Developer of Tiaras &amp; Trains (Big Birthdays)
            </p>
            <a
              href="mailto:privacy@appitytechnica.com"
              className="mt-2 inline-block text-sm font-semibold text-purple hover:underline"
            >
              privacy@appitytechnica.com
            </a>
          </div>
        </section>

      </div>

      {/* Footer note */}
      <div className="mt-12 pt-8 border-t border-lavender/40">
        <p className="text-xs text-foreground/40 text-center">
          &copy; {new Date().getFullYear()} Appity Technica. Tiaras &amp; Trains (Big Birthdays).
          All rights reserved.
        </p>
      </div>
    </div>
  );
}
