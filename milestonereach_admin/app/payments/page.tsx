'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { supabase } from '@/lib/supabase';

interface PendingPayment {
  id: string;
  user_id?: string;
  creator_id?: string;
  amount: number;
  created_at: string;
  type: string;
  status: string;
  reference_id?: string;
  bank_account_details?: any;
  user_name?: string;
}

export default function PaymentsPage() {
  const [activeTab, setActiveTab] = useState<'deposits' | 'withdrawals'>('deposits');
  const [payments, setPayments] = useState<PendingPayment[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchPayments();
  }, [activeTab]);

  const fetchPayments = async () => {
    setLoading(true);
    let query;
    if (activeTab === 'deposits') {
      query = supabase
        .from('wallet_transactions')
        .select('*')
        .eq('status', 'pending')
        .eq('type', 'deposit')
        .order('created_at', { ascending: false });
    } else {
      query = supabase
        .from('withdrawals')
        .select('*')
        .eq('status', 'pending')
        .order('created_at', { ascending: false });
    }

    const { data, error } = await query;

    if (error) {
      console.error('Error fetching payments:', error);
    } else {
      setPayments(data || []);
    }
    setLoading(false);
  };

  const handleAction = async (id: string, action: 'approved' | 'rejected' | 'processed') => {
    let error;
    if (activeTab === 'deposits') {
      const res = await supabase
        .from('wallet_transactions')
        .update({ status: action === 'approved' ? 'completed' : 'rejected' })
        .eq('id', id);
      error = res.error;
    } else {
      const res = await supabase
        .from('withdrawals')
        .update({ 
          status: action === 'approved' ? 'processed' : 'rejected',
          processed_at: action === 'approved' ? new Date().toISOString() : null
        })
        .eq('id', id);
      error = res.error;
    }

    if (error) {
      alert('Error updating payment: ' + error.message);
    } else {
      setPayments(prev => prev.filter(p => p.id !== id));
    }
  };

  return (
    <div className="min-h-screen bg-[#0A0F1E] text-white p-8">
      <div className="max-w-6xl mx-auto">
        <header className="flex justify-between items-center mb-12">
          <div>
            <Link href="/" className="text-blue-400 hover:text-blue-300 mb-4 inline-block">
              &larr; Back to Dashboard
            </Link>
            <h1 className="text-4xl font-bold">Financial Management</h1>
            <p className="text-gray-400 mt-2">Verify deposits and approve creator withdrawals.</p>
          </div>
        </header>

        <div className="flex gap-4 mb-8">
          <button 
            onClick={() => setActiveTab('deposits')}
            className={`px-6 py-3 rounded-2xl font-bold transition-all ${activeTab === 'deposits' ? 'bg-blue-500 text-white shadow-lg shadow-blue-500/20' : 'bg-white/5 text-gray-400 hover:bg-white/10'}`}
          >
            Pending Deposits
          </button>
          <button 
            onClick={() => setActiveTab('withdrawals')}
            className={`px-6 py-3 rounded-2xl font-bold transition-all ${activeTab === 'withdrawals' ? 'bg-orange-500 text-white shadow-lg shadow-orange-500/20' : 'bg-white/5 text-gray-400 hover:bg-white/10'}`}
          >
            Withdrawal Requests
          </button>
        </div>

        <div className="bg-[#161B2D] rounded-3xl border border-white/5 overflow-hidden">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-white/5">
                <th className="p-6 text-sm font-semibold text-gray-400">User / Details</th>
                <th className="p-6 text-sm font-semibold text-gray-400">Amount</th>
                <th className="p-6 text-sm font-semibold text-gray-400">Requested Date</th>
                <th className="p-6 text-sm font-semibold text-gray-400 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-white/5">
              {payments.map((payment) => (
                <tr key={payment.id} className="hover:bg-white/[0.02] transition-colors">
                  <td className="p-6">
                    <p className="font-bold">{payment.user_id || payment.creator_id}</p>
                    {activeTab === 'deposits' ? (
                      <p className="text-xs text-blue-400 mt-1 font-mono">{payment.reference_id}</p>
                    ) : (
                      <p className="text-xs text-orange-400 mt-1">{payment.bank_account_details?.details || 'No details'}</p>
                    )}
                  </td>
                  <td className="p-6 font-mono text-lg font-bold">₹{payment.amount.toLocaleString()}</td>
                  <td className="p-6 text-sm text-gray-400">{new Date(payment.created_at).toLocaleString()}</td>
                  <td className="p-6 text-right">
                    <div className="flex justify-end gap-3">
                      <button 
                        onClick={() => handleAction(payment.id, 'rejected')}
                        className="bg-red-500/10 hover:bg-red-500/20 text-red-400 px-4 py-2 rounded-xl text-sm font-bold transition-all"
                      >
                        Reject
                      </button>
                      <button 
                        onClick={() => handleAction(payment.id, 'approved')}
                        className={`px-4 py-2 rounded-xl text-sm font-bold transition-all shadow-lg ${activeTab === 'deposits' ? 'bg-blue-500 hover:bg-blue-600 shadow-blue-500/20' : 'bg-orange-500 hover:bg-orange-600 shadow-orange-500/20'} text-white`}
                      >
                        {activeTab === 'deposits' ? 'Verify Deposit' : 'Mark as Paid'}
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          
          {loading ? (
            <div className="p-20 text-center text-gray-500">
              <p className="text-lg animate-pulse">Loading financial records...</p>
            </div>
          ) : payments.length === 0 && (
            <div className="p-20 text-center text-gray-500">
              <p className="text-lg">No pending {activeTab} to process.</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
