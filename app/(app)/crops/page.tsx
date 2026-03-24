import Link from 'next/link'
import { Sprout, Plus, ArrowRight } from 'lucide-react'

export default function CropsPage() {
  return (
    <div className="max-w-4xl mx-auto">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1
            className="text-2xl font-bold text-[#1a1f16]"
            style={{ fontFamily: 'var(--font-playfair)' }}
          >
            Crops
          </h1>
          <p className="text-sm text-gray-500 mt-0.5">Plan and track your crop cycles</p>
        </div>
        <Link
          href="#"
          className="inline-flex items-center gap-2 bg-[#3a6b35] hover:bg-[#2d5429] text-white text-sm font-semibold px-4 py-2 rounded-lg transition-colors"
        >
          <Plus className="w-4 h-4" />
          Add Crop
        </Link>
      </div>

      <div className="bg-white rounded-2xl border border-[#e2ddd5] p-16 text-center">
        <div className="w-16 h-16 rounded-2xl bg-[#3a6b35]/10 flex items-center justify-center mx-auto mb-5">
          <Sprout className="w-8 h-8 text-[#3a6b35]" />
        </div>
        <h2
          className="text-xl font-bold text-[#1a1f16] mb-2"
          style={{ fontFamily: 'var(--font-playfair)' }}
        >
          Crop Management
        </h2>
        <p className="text-gray-500 text-sm max-w-md mx-auto mb-2">
          This module is coming in the full build. You&apos;ll be able to:
        </p>
        <ul className="text-sm text-gray-500 space-y-1 mb-8 max-w-sm mx-auto text-left">
          <li className="flex items-start gap-2"><ArrowRight className="w-4 h-4 text-[#3a6b35] mt-0.5 shrink-0" /> Plan crop rotations and planting schedules by field</li>
          <li className="flex items-start gap-2"><ArrowRight className="w-4 h-4 text-[#3a6b35] mt-0.5 shrink-0" /> Log seed varieties, planting dates, and input costs</li>
          <li className="flex items-start gap-2"><ArrowRight className="w-4 h-4 text-[#3a6b35] mt-0.5 shrink-0" /> Track yield per acre at harvest</li>
          <li className="flex items-start gap-2"><ArrowRight className="w-4 h-4 text-[#3a6b35] mt-0.5 shrink-0" /> Monitor hay and forage inventories</li>
        </ul>
        <Link
          href="#"
          className="inline-flex items-center gap-2 bg-[#3a6b35] hover:bg-[#2d5429] text-white text-sm font-semibold px-5 py-2.5 rounded-lg transition-colors"
        >
          <Plus className="w-4 h-4" />
          Add your first crop
        </Link>
      </div>
    </div>
  )
}
