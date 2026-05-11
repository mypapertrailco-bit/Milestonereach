'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { supabase } from '../../lib/supabase';
import { CheckCircle, XCircle, ExternalLink, User, Loader2 } from 'lucide-react';

interface Submission {
  id: string;
  campaign_id: string;
  creator_id: string;
  status: string;
  post_url: string;
  current_impressions: number;
  earned_amount: number;
  created_at: string;
  campaigns: {
    title: string;
    business_id: string;
  };
  creator_profiles: {
    full_name: string;
    username: string;
  };
}

export default function SubmissionsPage() {
  const [submissions, setSubmissions] = useState<Submission[]>([]);
  const [loading, setLoading] = useState(true);
  const [processingId, setProcessingId] = useState<string | null>(null);

  useEffect(() => {
    fetchSubmissions();
  }, []);

  const fetchSubmissions = async () => {
    setLoading(true);
    const { data, error } = await supabase
      .from('campaign_participants')
      .select(`
        *,
        campaigns (title, business_id),
        creator_profiles (full_name, username)
      `)
      .eq('status', 'under_review')
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Error fetching submissions:', error);
    } else {
      setSubmissions(data as any || []);
    }
    setLoading(false);
  };

  const handleApprove = async (sub: Submission) => {
    setProcessingId(sub.id);
    try {
      // 1. Call RPC to release escrow funds
      const { data, error: rpcError } = await supabase.rpc('release_escrow_to_creator', {
        p_business_id: sub.campaigns.business_id,
        p_creator_id: sub.creator_id,
        p_campaign_id: sub.campaign_id,
        p_amount: sub.earned_amount || 500, // Fallback to a mock amount if 0
      });

      if (rpcError) throw rpcError;

      // 2. Update status to 'completed'
      const { error: updateError } = await supabase
        .from('campaign_participants')
        .update({ status: 'completed' })
        .eq('id', sub.id);

      if (updateError) throw updateError;

      setSubmissions(prev => prev.filter(s => s.id !== sub.id));
      alert('Submission approved and funds released!');
    } catch (err: any) {
      alert('Error approving submission: ' + err.message);
    } finally {
      setProcessingId(null);
    }
  };

  const handleReject = async (id: string) => {
    const { error } = await supabase
      .from('campaign_participants')
      .update({ status: 'rejected' })
      .eq('id', id);

    if (error) {
      alert('Error rejecting: ' + error.message);
    } else {
      setSubmissions(prev => prev.filter(s => s.id !== id));
    }
  };

  return (
    <div className="p-8 min-h-screen bg-[#0A0F1E] text-white">
      <div className="flex justify-between items-center mb-12">
        <div>
          <Link href="/" className="text-blue-400 hover:text-blue-300 mb-4 inline-block">
            &larr; Back to Dashboard
          </Link>
          <h1 className="text-4xl font-bold">Milestone Submissions</h1>
          <p className="text-gray-400 mt-2">Verify creator evidence to release locked escrow funds.</p>
        </div>
      </div>

      <div className="bg-[#161B2D] rounded-3xl border border-white/5 overflow-hidden">
        <table className="w-full text-left">
          <thead className="bg-white/5">
            <tr>
              <th className="px-6 py-4 text-xs font-semibold text-gray-400 uppercase tracking-wider">Creator & Campaign</th>
              <th className="px-6 py-4 text-xs font-semibold text-gray-400 uppercase tracking-wider">Metrics</th>
              <th className="px-6 py-4 text-xs font-semibold text-gray-400 uppercase tracking-wider">Evidence</th>
              <th className="px-6 py-4 text-xs font-semibold text-gray-400 uppercase tracking-wider">Reward</th>
              <th className="px-6 py-4 text-xs font-semibold text-gray-400 uppercase tracking-wider text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-white/5">
            {submissions.map((sub) => (
              <tr key={sub.id} className="hover:bg-white/[0.02] transition-colors">
                <td className="px-6 py-4">
                  <div className="flex items-center gap-3">
                    <div className="h-10 w-10 rounded-full bg-blue-500/10 flex items-center justify-center">
                      <User className="h-5 w-5 text-blue-400" />
                    </div>
                    <div>
                      <div className="font-bold">{sub.creator_profiles?.full_name}</div>
                      <div className="text-xs text-gray-400">{sub.campaigns?.title}</div>
                    </div>
                  </div>
                </td>
                <td className="px-6 py-4">
                  <div className="text-sm font-medium">{sub.current_impressions.toLocaleString()} Impr.</div>
                  <div className="text-[10px] text-gray-500">{new Date(sub.created_at).toLocaleDateString()}</div>
                </td>
                <td className="px-6 py-4">
                  <a href={sub.post_url} target="_blank" rel="noopener noreferrer" className="flex items-center gap-1 text-blue-400 hover:underline text-sm font-medium">
                    View Link <ExternalLink className="h-3 w-3" />
                  </a>
                </td>
                <td className="px-6 py-4 font-mono text-green-400 font-bold">
                  ₹{sub.earned_amount?.toLocaleString() || '0'}
                </td>
                <td className="px-6 py-4 text-right">
                  <div className="flex justify-end gap-3">
                    <button 
                      onClick={() => handleReject(sub.id)}
                      className="p-2 text-red-400 hover:bg-red-500/10 rounded-xl transition-colors"
                      disabled={processingId === sub.id}
                    >
                      <XCircle className="h-6 w-6" />
                    </button>
                    <button 
                      onClick={() => handleApprove(sub)}
                      className="p-2 text-green-400 hover:bg-green-500/10 rounded-xl transition-colors"
                      disabled={processingId === sub.id}
                    >
                      {processingId === sub.id ? (
                        <Loader2 className="h-6 w-6 animate-spin text-blue-400" />
                      ) : (
                        <CheckCircle className="h-6 w-6" />
                      )}
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        
        {loading ? (
          <div className="p-20 text-center text-gray-500 flex flex-col items-center gap-4">
            <Loader2 className="h-10 w-10 animate-spin text-blue-500" />
            <p className="text-lg">Fetching submissions...</p>
          </div>
        ) : submissions.length === 0 && (
          <div className="p-20 text-center text-gray-500">
            <p className="text-lg">All caught up! No pending submissions.</p>
          </div>
        )}
      </div>
    </div>
  );
}
