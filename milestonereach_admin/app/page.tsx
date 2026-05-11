import React from 'react';
import Link from 'next/link';

export default function AdminDashboard() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24 bg-[#0A0F1E] text-white">
      <div className="z-10 max-w-5xl w-full items-center justify-between font-mono text-sm lg:flex">
        <p className="fixed left-0 top-0 flex w-full justify-center border-b border-gray-300 bg-gradient-to-b from-zinc-200 pb-6 pt-8 backdrop-blur-2xl dark:border-neutral-800 dark:bg-zinc-800/30 dark:from-inherit lg:static lg:w-auto  lg:rounded-xl lg:border lg:bg-gray-200 lg:p-4 lg:dark:bg-zinc-800/30 text-black dark:text-white">
          MilestoneReach Admin Dashboard&nbsp;
        </p>
      </div>

      <div className="relative flex place-items-center mt-12">
        <h1 className="text-4xl font-bold text-center">
          Overview Metrics
        </h1>
      </div>

      <div className="mb-32 grid text-center lg:max-w-5xl lg:w-full lg:mb-0 lg:grid-cols-4 lg:text-left mt-16 gap-4">
        <Link href="/users" className="group rounded-2xl border border-white/5 px-5 py-6 transition-all hover:bg-white/5 hover:border-blue-500/50">
          <h2 className={`mb-3 text-2xl font-semibold`}>
            Users{" "}
            <span className="inline-block transition-transform group-hover:translate-x-1 motion-reduce:transform-none">
              -&gt;
            </span>
          </h2>
          <p className={`m-0 max-w-[30ch] text-sm opacity-50`}>
            Manage creators and businesses.
          </p>
        </Link>

        <Link href="/campaigns" className="group rounded-2xl border border-white/5 px-5 py-6 transition-all hover:bg-white/5 hover:border-blue-500/50">
          <h2 className={`mb-3 text-2xl font-semibold`}>
            Campaigns{" "}
            <span className="inline-block transition-transform group-hover:translate-x-1 motion-reduce:transform-none">
              -&gt;
            </span>
          </h2>
          <p className={`m-0 max-w-[30ch] text-sm opacity-50`}>
            Monitor active and completed campaigns.
          </p>
        </Link>

        <Link href="/fraud" className="group rounded-2xl border border-white/5 px-5 py-6 transition-all hover:bg-white/5 hover:border-blue-500/50">
          <h2 className={`mb-3 text-2xl font-semibold`}>
            Fraud Alerts{" "}
            <span className="inline-block transition-transform group-hover:translate-x-1 motion-reduce:transform-none">
              -&gt;
            </span>
          </h2>
          <p className={`m-0 max-w-[30ch] text-sm opacity-50`}>
            Review suspicious activity and reports.
          </p>
        </Link>

        <Link href="/payments" className="group rounded-2xl border border-blue-500/30 bg-blue-500/5 px-5 py-6 transition-all hover:bg-blue-500/10 hover:border-blue-500/50">
          <h2 className={`mb-3 text-2xl font-semibold text-blue-400`}>
            Payments{" "}
            <span className="inline-block transition-transform group-hover:translate-x-1 motion-reduce:transform-none">
              -&gt;
            </span>
          </h2>
          <p className={`m-0 max-w-[30ch] text-sm opacity-70`}>
            Verify deposits and process releases.
          </p>
        </Link>
      </div>
    </main>
  );
}
