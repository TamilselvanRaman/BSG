import Link from "next/link";

export default function NotFound() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-slate-50 px-4 text-center">
      <div className="rounded-2xl border border-slate-200 bg-white p-8 shadow-sm max-w-md w-full">
        <h1 className="text-4xl font-extrabold text-slate-900">404</h1>
        <h2 className="mt-2 text-lg font-bold text-slate-800">Page Not Found</h2>
        <p className="mt-2 text-xs text-slate-500">
          The page you requested could not be found or has been moved.
        </p>
        <div className="mt-6 flex justify-center gap-3">
          <Link
            href="/"
            className="rounded-lg bg-blue-600 px-4 py-2 text-xs font-semibold text-white hover:bg-blue-700 transition"
          >
            Back to Home
          </Link>
          <Link
            href="/login"
            className="rounded-lg border border-slate-300 bg-white px-4 py-2 text-xs font-semibold text-slate-700 hover:bg-slate-50 transition"
          >
            Sign In
          </Link>
        </div>
      </div>
    </div>
  );
}
