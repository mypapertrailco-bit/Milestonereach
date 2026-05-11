import Link from 'next/link';
import { FileQuestion, Home } from 'lucide-react';

export default function NotFound() {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-8 text-center bg-gray-50 dark:bg-zinc-950">
      <div className="h-20 w-20 bg-blue-100 dark:bg-blue-900/20 rounded-3xl flex items-center justify-center mb-8 rotate-12">
        <FileQuestion className="h-10 w-10 text-blue-600 dark:text-blue-400" />
      </div>
      <h1 className="text-4xl font-black text-gray-900 dark:text-white mb-4 tracking-tighter">404 - Not Found</h1>
      <p className="text-gray-500 dark:text-zinc-400 max-w-sm mb-10 text-lg">
        The page you are looking for doesn't exist or has been moved to another dimension.
      </p>
      <Link
        href="/"
        className="flex items-center gap-2 px-8 py-4 bg-white dark:bg-zinc-900 text-gray-900 dark:text-white font-bold rounded-2xl border border-gray-200 dark:border-zinc-800 hover:border-blue-500 transition-all shadow-sm"
      >
        <Home className="h-5 w-5" /> Back to Dashboard
      </Link>
    </div>
  );
}
