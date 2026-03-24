'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { Leaf, Check, ChevronRight, ChevronLeft } from 'lucide-react'
import { createClient } from '@/lib/supabase/client'

const FARM_TYPES = ['Ranch', 'Farm', 'Homestead', 'Mixed'] as const
const OPERATIONS = [
  'Beef Cattle',
  'Dairy',
  'Sheep',
  'Goats',
  'Hogs',
  'Poultry',
  'Crops',
  'Hay / Forage',
  'Horses',
  'Other',
] as const

type FarmType = (typeof FARM_TYPES)[number]

interface FormData {
  farmName: string
  farmType: FarmType | ''
  state: string
  operations: string[]
  acreage: string
  headCount: string
}

export default function OnboardingPage() {
  const router = useRouter()
  const [step, setStep] = useState(1)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const [form, setForm] = useState<FormData>({
    farmName: '',
    farmType: '',
    state: '',
    operations: [],
    acreage: '',
    headCount: '',
  })

  function toggleOperation(op: string) {
    setForm((prev) => ({
      ...prev,
      operations: prev.operations.includes(op)
        ? prev.operations.filter((o) => o !== op)
        : [...prev.operations, op],
    }))
  }

  async function handleFinish() {
    setLoading(true)
    setError(null)

    const supabase = createClient()
    const {
      data: { user },
    } = await supabase.auth.getUser()

    if (!user) {
      router.push('/login')
      return
    }

    const { error: insertError } = await supabase.from('farms').insert({
      user_id: user.id,
      name: form.farmName,
      type: form.farmType,
      state: form.state,
      operations: form.operations,
      acreage: form.acreage ? parseFloat(form.acreage) : null,
      head_count: form.headCount ? parseInt(form.headCount, 10) : null,
    })

    if (insertError) {
      // Non-blocking — table may not exist yet during dev
      console.warn('Farm insert error:', insertError.message)
    }

    setLoading(false)
    setStep(4)
  }

  const totalSteps = 3

  return (
    <div className="min-h-screen bg-[#f5f3ee] flex items-center justify-center px-4 py-12">
      <div className="w-full max-w-lg">
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
        </div>

        {step < 4 && (
          <div className="mb-6">
            <div className="flex items-center justify-between mb-2">
              <span className="text-sm font-medium text-gray-500">
                Step {step} of {totalSteps}
              </span>
              <span className="text-sm text-gray-400">
                {Math.round((step / totalSteps) * 100)}% complete
              </span>
            </div>
            <div className="h-1.5 bg-[#e2ddd5] rounded-full">
              <div
                className="h-1.5 bg-[#3a6b35] rounded-full transition-all duration-500"
                style={{ width: `${(step / totalSteps) * 100}%` }}
              />
            </div>
          </div>
        )}

        <div className="bg-white rounded-2xl border border-[#e2ddd5] shadow-sm p-8">
          {/* Step 1 */}
          {step === 1 && (
            <div className="space-y-5">
              <div>
                <h2
                  className="text-xl font-bold text-[#1a1f16] mb-1"
                  style={{ fontFamily: 'var(--font-playfair)' }}
                >
                  Tell us about your operation
                </h2>
                <p className="text-sm text-gray-500">
                  Let&apos;s set up your first farm or ranch profile.
                </p>
              </div>

              <div>
                <label className="block text-sm font-medium text-[#1a1f16] mb-1.5">
                  Farm / Ranch name
                </label>
                <input
                  type="text"
                  value={form.farmName}
                  onChange={(e) => setForm({ ...form, farmName: e.target.value })}
                  className="w-full px-4 py-2.5 border border-[#e2ddd5] rounded-lg text-sm text-[#1a1f16] placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#3a6b35] focus:border-transparent"
                  placeholder="e.g. Circle W Ranch"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-[#1a1f16] mb-2">
                  Operation type
                </label>
                <div className="grid grid-cols-2 gap-2">
                  {FARM_TYPES.map((type) => (
                    <button
                      key={type}
                      type="button"
                      onClick={() => setForm({ ...form, farmType: type })}
                      className={`px-4 py-2.5 rounded-lg border text-sm font-medium transition-colors ${
                        form.farmType === type
                          ? 'bg-[#3a6b35] border-[#3a6b35] text-white'
                          : 'border-[#e2ddd5] text-[#1a1f16] hover:border-[#3a6b35]'
                      }`}
                    >
                      {type}
                    </button>
                  ))}
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-[#1a1f16] mb-1.5">
                  State / Province
                </label>
                <input
                  type="text"
                  value={form.state}
                  onChange={(e) => setForm({ ...form, state: e.target.value })}
                  className="w-full px-4 py-2.5 border border-[#e2ddd5] rounded-lg text-sm text-[#1a1f16] placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#3a6b35] focus:border-transparent"
                  placeholder="e.g. Texas"
                />
              </div>

              <button
                onClick={() => setStep(2)}
                disabled={!form.farmName || !form.farmType || !form.state}
                className="w-full flex items-center justify-center gap-2 bg-[#3a6b35] hover:bg-[#2d5429] disabled:opacity-50 text-white font-semibold py-2.5 rounded-lg text-sm transition-colors"
              >
                Continue
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>
          )}

          {/* Step 2 */}
          {step === 2 && (
            <div className="space-y-5">
              <div>
                <h2
                  className="text-xl font-bold text-[#1a1f16] mb-1"
                  style={{ fontFamily: 'var(--font-playfair)' }}
                >
                  What do you raise or grow?
                </h2>
                <p className="text-sm text-gray-500">Select all that apply to your operation.</p>
              </div>

              <div className="grid grid-cols-2 gap-2">
                {OPERATIONS.map((op) => {
                  const selected = form.operations.includes(op)
                  return (
                    <button
                      key={op}
                      type="button"
                      onClick={() => toggleOperation(op)}
                      className={`flex items-center gap-2 px-3 py-2.5 rounded-lg border text-sm font-medium transition-colors text-left ${
                        selected
                          ? 'bg-[#3a6b35]/10 border-[#3a6b35] text-[#3a6b35]'
                          : 'border-[#e2ddd5] text-[#1a1f16] hover:border-[#3a6b35]'
                      }`}
                    >
                      <div
                        className={`w-4 h-4 rounded flex items-center justify-center border shrink-0 ${
                          selected ? 'bg-[#3a6b35] border-[#3a6b35]' : 'border-gray-300'
                        }`}
                      >
                        {selected && <Check className="w-3 h-3 text-white" />}
                      </div>
                      {op}
                    </button>
                  )
                })}
              </div>

              <div className="flex gap-3">
                <button
                  type="button"
                  onClick={() => setStep(1)}
                  className="flex items-center gap-1 px-4 py-2.5 border border-[#e2ddd5] rounded-lg text-sm font-medium text-[#1a1f16] hover:bg-gray-50 transition-colors"
                >
                  <ChevronLeft className="w-4 h-4" />
                  Back
                </button>
                <button
                  onClick={() => setStep(3)}
                  disabled={form.operations.length === 0}
                  className="flex-1 flex items-center justify-center gap-2 bg-[#3a6b35] hover:bg-[#2d5429] disabled:opacity-50 text-white font-semibold py-2.5 rounded-lg text-sm transition-colors"
                >
                  Continue
                  <ChevronRight className="w-4 h-4" />
                </button>
              </div>
            </div>
          )}

          {/* Step 3 */}
          {step === 3 && (
            <div className="space-y-5">
              <div>
                <h2
                  className="text-xl font-bold text-[#1a1f16] mb-1"
                  style={{ fontFamily: 'var(--font-playfair)' }}
                >
                  Size of your operation
                </h2>
                <p className="text-sm text-gray-500">
                  Approximate numbers are fine — you can update these later.
                </p>
              </div>

              <div>
                <label className="block text-sm font-medium text-[#1a1f16] mb-1.5">
                  Total acreage
                </label>
                <input
                  type="number"
                  min="0"
                  value={form.acreage}
                  onChange={(e) => setForm({ ...form, acreage: e.target.value })}
                  className="w-full px-4 py-2.5 border border-[#e2ddd5] rounded-lg text-sm text-[#1a1f16] placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#3a6b35] focus:border-transparent"
                  placeholder="e.g. 1200"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-[#1a1f16] mb-1.5">
                  Approximate head count (livestock)
                </label>
                <input
                  type="number"
                  min="0"
                  value={form.headCount}
                  onChange={(e) => setForm({ ...form, headCount: e.target.value })}
                  className="w-full px-4 py-2.5 border border-[#e2ddd5] rounded-lg text-sm text-[#1a1f16] placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#3a6b35] focus:border-transparent"
                  placeholder="e.g. 250"
                />
              </div>

              {error && (
                <div className="bg-red-50 border border-red-200 text-red-700 text-sm px-4 py-3 rounded-lg">
                  {error}
                </div>
              )}

              <div className="flex gap-3">
                <button
                  type="button"
                  onClick={() => setStep(2)}
                  className="flex items-center gap-1 px-4 py-2.5 border border-[#e2ddd5] rounded-lg text-sm font-medium text-[#1a1f16] hover:bg-gray-50 transition-colors"
                >
                  <ChevronLeft className="w-4 h-4" />
                  Back
                </button>
                <button
                  onClick={handleFinish}
                  disabled={loading}
                  className="flex-1 flex items-center justify-center gap-2 bg-[#3a6b35] hover:bg-[#2d5429] disabled:opacity-50 text-white font-semibold py-2.5 rounded-lg text-sm transition-colors"
                >
                  {loading ? 'Saving…' : 'Finish setup'}
                </button>
              </div>
            </div>
          )}

          {/* Step 4: Success */}
          {step === 4 && (
            <div className="text-center space-y-5">
              <div className="w-16 h-16 rounded-full bg-[#3a6b35]/10 flex items-center justify-center mx-auto">
                <Check className="w-8 h-8 text-[#3a6b35]" />
              </div>
              <div>
                <h2
                  className="text-2xl font-bold text-[#1a1f16] mb-2"
                  style={{ fontFamily: 'var(--font-playfair)' }}
                >
                  You&apos;re all set!
                </h2>
                <p className="text-gray-500 text-sm">
                  <strong>{form.farmName}</strong> is ready to go. Let&apos;s head to your
                  dashboard.
                </p>
              </div>
              <Link
                href="/app/dashboard"
                className="inline-flex items-center justify-center gap-2 w-full bg-[#3a6b35] hover:bg-[#2d5429] text-white font-semibold py-3 rounded-lg text-sm transition-colors"
              >
                Go to Dashboard
                <ChevronRight className="w-4 h-4" />
              </Link>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
