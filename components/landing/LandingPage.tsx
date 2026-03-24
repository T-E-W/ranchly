'use client'

import Link from 'next/link'
import {
  BarChart2,
  DollarSign,
  Leaf,
  Map,
  Wrench,
  Users,
  Check,
  ChevronRight,
  Beef,
  Sprout,
  Menu,
  X,
} from 'lucide-react'
import { useState } from 'react'

const features = [
  {
    icon: Beef,
    title: 'Livestock Tracking',
    description:
      'Track every animal by group, breed, weight, and health status. Log births, deaths, purchases, and sales with full history.',
  },
  {
    icon: DollarSign,
    title: 'Financial Ledger',
    description:
      'Record income and expenses, reconcile accounts, and get a real-time picture of your operation\'s financial health.',
  },
  {
    icon: Sprout,
    title: 'Crop Management',
    description:
      'Plan and track crop cycles from planting to harvest. Monitor yields, inputs, and soil treatments by field.',
  },
  {
    icon: Map,
    title: 'Land & Pasture',
    description:
      'Map your acreage, manage pasture rotations, track soil tests, and monitor grazing pressure across every parcel.',
  },
  {
    icon: Wrench,
    title: 'Equipment',
    description:
      'Log maintenance schedules, repair history, and operating costs for every piece of machinery on your operation.',
  },
  {
    icon: BarChart2,
    title: 'Reports & Analytics',
    description:
      'Turn your data into insight. Generate P&L reports, herd performance summaries, and custom exports in seconds.',
  },
]

const pricingTiers = [
  {
    name: 'Free',
    price: '$0',
    period: 'forever',
    description: 'Perfect for getting started with one farm or ranch.',
    features: [
      '1 farm or ranch',
      'Up to 100 livestock',
      'Basic financial tracking',
      'Community support',
    ],
    cta: 'Get Started Free',
    href: '/signup',
    highlight: false,
  },
  {
    name: 'Pro',
    price: '$19',
    period: 'per month',
    description: 'For growing operations that need more power.',
    features: [
      'Up to 3 farms or ranches',
      'Unlimited livestock',
      'Full financial ledger',
      'Crop & land management',
      'Email support',
    ],
    cta: 'Start Pro Trial',
    href: '/signup',
    highlight: true,
  },
  {
    name: 'Ranch',
    price: '$49',
    period: 'per month',
    description: 'For large operations and multi-family ranches.',
    features: [
      'Unlimited farms & ranches',
      'Unlimited livestock',
      'All Pro features',
      'Equipment management',
      'Advanced analytics',
      'Priority support',
    ],
    cta: 'Start Ranch Trial',
    href: '/signup',
    highlight: false,
  },
]

export default function LandingPage() {
  const [mobileOpen, setMobileOpen] = useState(false)

  return (
    <div className="flex flex-col min-h-screen bg-[#f5f3ee]">
      {/* Navbar */}
      <header className="sticky top-0 z-50 bg-white border-b border-[#e2ddd5] shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            {/* Logo */}
            <Link href="/" className="flex items-center gap-2">
              <div className="w-8 h-8 rounded-md bg-[#3a6b35] flex items-center justify-center">
                <Leaf className="w-4 h-4 text-white" />
              </div>
              <span
                className="text-xl font-bold text-[#3a6b35]"
                style={{ fontFamily: 'var(--font-playfair)' }}
              >
                Ranchly
              </span>
            </Link>

            {/* Desktop nav */}
            <nav className="hidden md:flex items-center gap-8">
              <a
                href="#features"
                className="text-sm font-medium text-[#1a1f16] hover:text-[#3a6b35] transition-colors"
              >
                Features
              </a>
              <a
                href="#pricing"
                className="text-sm font-medium text-[#1a1f16] hover:text-[#3a6b35] transition-colors"
              >
                Pricing
              </a>
              <a
                href="#about"
                className="text-sm font-medium text-[#1a1f16] hover:text-[#3a6b35] transition-colors"
              >
                About
              </a>
            </nav>

            {/* Desktop CTA */}
            <div className="hidden md:flex items-center gap-3">
              <Link
                href="/login"
                className="text-sm font-medium text-[#1a1f16] hover:text-[#3a6b35] transition-colors px-4 py-2"
              >
                Log in
              </Link>
              <Link
                href="/signup"
                className="text-sm font-semibold bg-[#3a6b35] text-white px-4 py-2 rounded-lg hover:bg-[#2d5429] transition-colors"
              >
                Start Free
              </Link>
            </div>

            {/* Mobile menu toggle */}
            <button
              className="md:hidden p-2 rounded-md text-[#1a1f16]"
              onClick={() => setMobileOpen(!mobileOpen)}
              aria-label="Toggle menu"
            >
              {mobileOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
            </button>
          </div>
        </div>

        {/* Mobile menu */}
        {mobileOpen && (
          <div className="md:hidden border-t border-[#e2ddd5] bg-white px-4 pb-4 pt-2 space-y-3">
            <a href="#features" className="block text-sm font-medium text-[#1a1f16] py-2">
              Features
            </a>
            <a href="#pricing" className="block text-sm font-medium text-[#1a1f16] py-2">
              Pricing
            </a>
            <a href="#about" className="block text-sm font-medium text-[#1a1f16] py-2">
              About
            </a>
            <div className="flex flex-col gap-2 pt-2 border-t border-[#e2ddd5]">
              <Link href="/login" className="text-sm font-medium text-center py-2 border border-[#e2ddd5] rounded-lg">
                Log in
              </Link>
              <Link href="/signup" className="text-sm font-semibold text-center bg-[#3a6b35] text-white py-2 rounded-lg">
                Start Free
              </Link>
            </div>
          </div>
        )}
      </header>

      <main className="flex-1">
        {/* Hero */}
        <section className="bg-[#1a1f16] text-white py-24 md:py-36 px-4">
          <div className="max-w-4xl mx-auto text-center">
            <div className="inline-flex items-center gap-2 bg-[#3a6b35]/30 border border-[#3a6b35]/50 text-[#4d8a47] px-3 py-1 rounded-full text-xs font-semibold tracking-wide uppercase mb-6">
              <Leaf className="w-3 h-3" />
              Built for farmers. By farmers.
            </div>
            <h1
              className="text-4xl md:text-6xl font-bold leading-tight mb-6"
              style={{ fontFamily: 'var(--font-playfair)' }}
            >
              The operating system
              <br />
              <span className="text-[#c8922a]">for your ranch.</span>
            </h1>
            <p className="text-lg md:text-xl text-gray-300 max-w-2xl mx-auto mb-10 leading-relaxed">
              Ranchly brings your livestock, finances, crops, land, and equipment into one
              simple platform — so you can spend less time on paperwork and more time doing
              what matters.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link
                href="/signup"
                className="inline-flex items-center justify-center gap-2 bg-[#3a6b35] hover:bg-[#2d5429] text-white font-semibold px-8 py-4 rounded-lg text-base transition-colors"
              >
                Start for free
                <ChevronRight className="w-4 h-4" />
              </Link>
              <a
                href="#features"
                className="inline-flex items-center justify-center gap-2 border border-white/20 hover:border-white/40 text-white font-semibold px-8 py-4 rounded-lg text-base transition-colors"
              >
                See how it works
              </a>
            </div>
            <p className="mt-4 text-sm text-gray-400">No credit card required. Free forever plan available.</p>
          </div>
        </section>

        {/* Features */}
        <section id="features" className="py-24 px-4 bg-[#f5f3ee]">
          <div className="max-w-7xl mx-auto">
            <div className="text-center mb-16">
              <h2
                className="text-3xl md:text-4xl font-bold text-[#1a1f16] mb-4"
                style={{ fontFamily: 'var(--font-playfair)' }}
              >
                Everything your operation needs
              </h2>
              <p className="text-lg text-gray-600 max-w-2xl mx-auto">
                From first calf to final sale, Ranchly covers every corner of your operation.
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {features.map((feature) => {
                const Icon = feature.icon
                return (
                  <div
                    key={feature.title}
                    className="bg-white rounded-xl border border-[#e2ddd5] p-6 hover:shadow-md transition-shadow"
                  >
                    <div className="w-11 h-11 rounded-lg bg-[#3a6b35]/10 flex items-center justify-center mb-4">
                      <Icon className="w-5 h-5 text-[#3a6b35]" />
                    </div>
                    <h3 className="text-lg font-semibold text-[#1a1f16] mb-2">{feature.title}</h3>
                    <p className="text-sm text-gray-600 leading-relaxed">{feature.description}</p>
                  </div>
                )
              })}
            </div>
          </div>
        </section>

        {/* Social proof strip */}
        <section className="bg-[#3a6b35] py-12 px-4">
          <div className="max-w-5xl mx-auto text-center">
            <div className="flex flex-col sm:flex-row items-center justify-center gap-8 sm:gap-16 text-white">
              <div>
                <div className="text-3xl font-bold" style={{ fontFamily: 'var(--font-playfair)' }}>2,400+</div>
                <div className="text-sm text-green-200 mt-1">Ranches managed</div>
              </div>
              <div className="hidden sm:block w-px h-12 bg-white/20" />
              <div>
                <div className="text-3xl font-bold" style={{ fontFamily: 'var(--font-playfair)' }}>180k+</div>
                <div className="text-sm text-green-200 mt-1">Livestock tracked</div>
              </div>
              <div className="hidden sm:block w-px h-12 bg-white/20" />
              <div>
                <div className="text-3xl font-bold" style={{ fontFamily: 'var(--font-playfair)' }}>$42M+</div>
                <div className="text-sm text-green-200 mt-1">Revenue recorded</div>
              </div>
            </div>
          </div>
        </section>

        {/* Pricing */}
        <section id="pricing" className="py-24 px-4 bg-[#f5f3ee]">
          <div className="max-w-6xl mx-auto">
            <div className="text-center mb-16">
              <h2
                className="text-3xl md:text-4xl font-bold text-[#1a1f16] mb-4"
                style={{ fontFamily: 'var(--font-playfair)' }}
              >
                Simple, honest pricing
              </h2>
              <p className="text-lg text-gray-600 max-w-xl mx-auto">
                Start free and scale as your operation grows. No hidden fees, no surprises.
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              {pricingTiers.map((tier) => (
                <div
                  key={tier.name}
                  className={`rounded-xl border p-8 flex flex-col ${
                    tier.highlight
                      ? 'bg-[#3a6b35] border-[#3a6b35] text-white shadow-xl ring-4 ring-[#3a6b35]/20 relative'
                      : 'bg-white border-[#e2ddd5]'
                  }`}
                >
                  {tier.highlight && (
                    <div className="absolute -top-3 left-1/2 -translate-x-1/2">
                      <span className="bg-[#c8922a] text-white text-xs font-bold px-3 py-1 rounded-full uppercase tracking-wide">
                        Most Popular
                      </span>
                    </div>
                  )}
                  <div className="mb-6">
                    <h3
                      className={`text-xl font-bold mb-1 ${tier.highlight ? 'text-white' : 'text-[#1a1f16]'}`}
                      style={{ fontFamily: 'var(--font-playfair)' }}
                    >
                      {tier.name}
                    </h3>
                    <p className={`text-sm mb-4 ${tier.highlight ? 'text-green-200' : 'text-gray-500'}`}>
                      {tier.description}
                    </p>
                    <div className="flex items-baseline gap-1">
                      <span
                        className={`text-4xl font-bold ${tier.highlight ? 'text-white' : 'text-[#1a1f16]'}`}
                        style={{ fontFamily: 'var(--font-playfair)' }}
                      >
                        {tier.price}
                      </span>
                      <span className={`text-sm ${tier.highlight ? 'text-green-200' : 'text-gray-500'}`}>
                        / {tier.period}
                      </span>
                    </div>
                  </div>

                  <ul className="space-y-3 mb-8 flex-1">
                    {tier.features.map((f) => (
                      <li key={f} className="flex items-start gap-2 text-sm">
                        <Check
                          className={`w-4 h-4 mt-0.5 shrink-0 ${
                            tier.highlight ? 'text-green-300' : 'text-[#3a6b35]'
                          }`}
                        />
                        <span className={tier.highlight ? 'text-green-100' : 'text-gray-600'}>{f}</span>
                      </li>
                    ))}
                  </ul>

                  <Link
                    href={tier.href}
                    className={`text-center font-semibold py-3 rounded-lg transition-colors text-sm ${
                      tier.highlight
                        ? 'bg-white text-[#3a6b35] hover:bg-green-50'
                        : 'bg-[#3a6b35] text-white hover:bg-[#2d5429]'
                    }`}
                  >
                    {tier.cta}
                  </Link>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* About */}
        <section id="about" className="py-24 px-4 bg-white border-t border-[#e2ddd5]">
          <div className="max-w-3xl mx-auto text-center">
            <h2
              className="text-3xl md:text-4xl font-bold text-[#1a1f16] mb-6"
              style={{ fontFamily: 'var(--font-playfair)' }}
            >
              Built for people who work the land
            </h2>
            <p className="text-lg text-gray-600 leading-relaxed mb-8">
              Ranchly was born out of frustration with spreadsheets, notebooks, and disconnected
              apps. We believe every rancher and farmer — from a 50-acre homestead to a 50,000-acre
              cattle operation — deserves software that actually fits how they work.
            </p>
            <div className="flex items-center justify-center gap-2">
              <Users className="w-5 h-5 text-[#3a6b35]" />
              <span className="text-sm text-gray-500">Proudly independent. Farmer-funded.</span>
            </div>
          </div>
        </section>

        {/* Final CTA */}
        <section className="bg-[#1a1f16] py-20 px-4 text-center text-white">
          <h2
            className="text-3xl md:text-4xl font-bold mb-4"
            style={{ fontFamily: 'var(--font-playfair)' }}
          >
            Ready to run a smarter operation?
          </h2>
          <p className="text-gray-400 mb-8 max-w-xl mx-auto">
            Join thousands of ranchers and farmers who trust Ranchly to keep their
            operation organized.
          </p>
          <Link
            href="/signup"
            className="inline-flex items-center gap-2 bg-[#c8922a] hover:bg-[#a87420] text-white font-semibold px-8 py-4 rounded-lg text-base transition-colors"
          >
            Get started for free
            <ChevronRight className="w-4 h-4" />
          </Link>
        </section>
      </main>

      {/* Footer */}
      <footer className="bg-[#1a1f16] border-t border-white/10 py-10 px-4">
        <div className="max-w-7xl mx-auto">
          <div className="flex flex-col md:flex-row items-center justify-between gap-6">
            <Link href="/" className="flex items-center gap-2">
              <div className="w-7 h-7 rounded-md bg-[#3a6b35] flex items-center justify-center">
                <Leaf className="w-3.5 h-3.5 text-white" />
              </div>
              <span
                className="text-lg font-bold text-white"
                style={{ fontFamily: 'var(--font-playfair)' }}
              >
                Ranchly
              </span>
            </Link>

            <div className="flex flex-wrap items-center justify-center gap-6 text-sm text-gray-400">
              <a href="#features" className="hover:text-white transition-colors">Features</a>
              <a href="#pricing" className="hover:text-white transition-colors">Pricing</a>
              <a href="#about" className="hover:text-white transition-colors">About</a>
              <Link href="/login" className="hover:text-white transition-colors">Login</Link>
              <Link href="/signup" className="hover:text-white transition-colors">Sign Up</Link>
            </div>

            <p className="text-sm text-gray-500">
              &copy; {new Date().getFullYear()} Ranchly. All rights reserved.
            </p>
          </div>
        </div>
      </footer>
    </div>
  )
}
