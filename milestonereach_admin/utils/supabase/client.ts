import { createBrowserClient } from "@supabase/ssr";

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://oapwmqwcjnwvzknxfpnv.supabase.co';
const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9hcHdtcXdjam53dnprbnhmcG52Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg1MDE5MjcsImV4cCI6MjA5NDA3NzkyN30.blLEG-hsjbSVlJcTDgA55pILqL8y5ZXQ-CqtNnIzD4U';

export const createClient = () =>
  createBrowserClient(
    supabaseUrl!,
    supabaseKey!,
  );
