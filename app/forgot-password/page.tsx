'use client'

import { useState } from 'react'
import Link from 'next/link'
import { Leaf, ArrowLeft } from 'lucide-react'
import { createClient } from '@/lib/supabase/client'

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState(false)
  const [loading, setLoading] = useState(false)

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setError(null)
    setLoading(true)

    const supabase = createClient()
    const { error: resetError } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/app/settings`,
    })

    if (resetError) {
      setError(resetError.message)
      setLoading(false)
      return
    }

    setSuccess(true)
    setLoading(false)
  }

  return (
    <div className="min-h-screen bg-[#f5f3ee] flex items-center justify-center px-4">
      <div className="w-full max-w-md">
        {/* Logo */}
        <div className="text-center mb-8">
          <Link href="/" className="inline-flex items-center gap-2 justify-center">
            <div className="w-10 h-10 rounded-xl bg-[#3a6b35] flex items-center justify-center">
              <Leaf className="w-5 h-5 text-white" />
            </div>
            <span
              className="text-2xl font-bold text-[#3a6b35]"
              style={{ fontFamily: 'var(--font-playfair)' }}
            >
              Ranchly
            </span>
          </Link>
          <p className="mt-3 text-gray-500 text-sm">Reset your password</p>
        </div>

        <div className="bg-white rounded-2xl border border-[#e2ddd5] shadow-sm p-8">
          {success ? (
            <div className="text-center">
              <div className="w-14 h-14 bg-[#3a6b35]/10 rounded-full flex items-center justify-center mx-auto mb-4">
                <Leaf className="w-6 h-6 text-[#3a6b35]" />
              </div>
              <h2 className="text-lg font-semibold text-[#1a1f16] mb-2">Check your inbox</h2>
              <p className="text-sm text-gray-500 mb-6">
                We sent a password reset link to <strong>{email}</strong>. Check your email and
                follow the link to reset your password.
              </p>
              <Link
                href="/login"
                className="inline-flex items-center gap-2 text-sm text-[#3a6b35] font-medium hover:text-[#2d5429]"
              >
                <ArrowLeft className="w-4 h-4" />
                Back to sign in
              </Link>
            </div>
          ) : (
            <form onSubmit={handleSubmit} className="space-y-5">
              <p className="text-sm text-gray-500">
                Enter your email address and we&apos;ll send you a link to reset your password.
              </p>

              {error && (
                <div className="bg-red-50 border border-red-200 text-red-700 text-sm px-4 py-3 rounded-lg">
                  {error}
                </div>
              )}

              <div>
                <label htmlFor="email" className="block text-sm font-medium text-[#1a1f16] mb-1.5">
                  Email address
                </label>
                <input
                  id="email"
                  type="email"
                  required
                  autoComplete="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="w-full px-4 py-2.5 border border-[#e2ddd5] rounded-lg text-sm text-[#1a1f16] bg-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#3a6b35] focus:border-transparent transition"
                  placeholder="you@example.com"
                />
              </div>

              <button
                type="submit"
                disabled={loading}
                className="w-full bg-[#3a6b35] hover:bg-[#2d5429] disabled:opacity-60 text-white font-semibold py-2.5 rounded-lg text-sm transition-colors"
              >
                {loading ? 'Sending…' : 'Send reset link'}
              </button>
            </form>
          )}
        </div>

        {!success && (
          <p className="text-center text-sm text-gray-500 mt-6">
            Remember your password?{' '}
            <Link href="/login" className="text-[#3a6b35] font-medium hover:text-[#2d5429]">
              Sign in
            </Link>
          </p>
        )}
      </div>
    </div>
  )
}
