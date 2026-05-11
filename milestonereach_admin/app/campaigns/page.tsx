import React from 'react';
import Link from 'next/link';
import { supabase } from '../../lib/supabase';

export const revalidate = 0; // Disable caching to always show live data

export default async function CampaignsPage() {
  // Fetch real data from Supabase
  const { data: campaigns, error } = await supabase
    .from('campaigns')
    .select(`
      id,
      title,
      total_budget,
      status,
      created_at,
      business_profiles (
        company_name
      )
    `)
    .order('created_at', { ascending: false });

  return (
    <div className="min-h-screen p-8 md:p-24 bg-gray-50 dark:bg-zinc-950">
      <div className="max-w-6xl mx-auto">
        <div className="flex justify-between items-center mb-8">
          <div>
            <h1 className="text-3xl font-bold tracking-tight text-gray-900 dark:text-white">Campaign Management</h1>
            <p className="text-sm text-gray-500 mt-1">Review, approve, and monitor brand campaigns.</p>
          </div>
          <Link href="/" className="text-sm font-medium text-blue-600 hover:text-blue-500 dark:text-blue-400">
            &larr; Back to Dashboard
          </Link>
        </div>

        {error && (
          <div className="mb-4 p-4 text-sm text-red-800 rounded-lg bg-red-50 dark:bg-gray-800 dark:text-red-400" role="alert">
            <span className="font-medium">Database Error:</span> {error.message}. Make sure your `.env.local` is configured.
          </div>
        )}

        <div className="bg-white dark:bg-zinc-900 rounded-xl shadow-sm border border-gray-200 dark:border-zinc-800 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="bg-gray-50 dark:bg-zinc-950/50 border-b border-gray-200 dark:border-zinc-800 text-xs uppercase tracking-wider text-gray-500 dark:text-zinc-400">
                  <th className="p-4 font-semibold">Campaign ID</th>
                  <th className="p-4 font-semibold">Brand</th>
                  <th className="p-4 font-semibold">Title</th>
                  <th className="p-4 font-semibold">Budget</th>
                  <th className="p-4 font-semibold">Status</th>
                  <th className="p-4 font-semibold text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200 dark:divide-zinc-800">
                {(!campaigns || campaigns.length === 0) ? (
                  <tr>
                    <td colSpan={6} className="p-8 text-center text-gray-500">No campaigns found.</td>
                  </tr>
                ) : (
                  campaigns.map((camp: any) => (
                    <tr key={camp.id} className="hover:bg-gray-50 dark:hover:bg-zinc-800/50 transition-colors">
                      <td className="p-4 text-sm font-mono text-gray-600 dark:text-zinc-400">{camp.id.split('-')[0]}...</td>
                      <td className="p-4 text-sm font-medium text-gray-900 dark:text-white">
                        {camp.business_profiles?.company_name || 'Unknown'}
                      </td>
                      <td className="p-4 text-sm text-gray-600 dark:text-zinc-300">{camp.title}</td>
                      <td className="p-4 text-sm font-medium text-green-600 dark:text-green-400">₹{camp.total_budget}</td>
                      <td className="p-4 text-sm">
                        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                          camp.status === 'active' ? 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400' :
                          camp.status === 'draft' ? 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-400' :
                          'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400'
                        }`}>
                          {camp.status.charAt(0).toUpperCase() + camp.status.slice(1)}
                        </span>
                      </td>
                      <td className="p-4 text-sm text-right space-x-3">
                        <button className="text-blue-600 hover:text-blue-800 dark:text-blue-400 font-medium">Review</button>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
}
