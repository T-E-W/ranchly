'use client'

import { useState } from 'react'
import { User, Bell, CreditCard, Home } from 'lucide-react'

const tabs = [
  { id: 'farm', label: 'Farm Profile', icon: Home },
  { id: 'account', label: 'Account', icon: User },
  { id: 'subscription', label: 'Subscription', icon: CreditCard },
  { id: 'notifications', label: 'Notifications', icon: Bell },
] as const

type TabId = (typeof tabs)[number]['id']

function FarmProfileTab() {
  return (
    <div className="space-y-6">
      <div>
        <h3 className="text-base font-semibold text-[#1a1f16] mb-4">Farm Details</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-[#1a1f16] mb-1.5">Farm name</label>
            <input
              type="text"
              defaultValue="Circle W Ranch"
              className="w-full px-4 py-2.5 border border-[#e2ddd5] rounded-lg text-sm text-[#1a1f16] focus:outline-none focus:ring-2 focus:ring-[#3a6b35] focus:border-transparent"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-[#1a1f16] mb-1.5">Operation type</label>
            <select className="w-full px-4 py-2.5 border border-[#e2ddd5] rounded-lg text-sm text-[#1a1f16] focus:outline-none focus:ring-2 focus:ring-[#3a6b35] bg-white">
              <option>Ranch</option>
              <option>Farm</option>
              <option>Homestead</option>
              <option>Mixed</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-[#1a1f16] mb-1.5">State / Province</label>
            <input
              type="text"
              defaultValue="Texas"
              className="w-full px-4 py-2.5 border border-[#e2ddd5] rounded-lg text-sm text-[#1a1f16] focus:outline-none focus:ring-2 focus:ring-[#3a6b35] focus:border-transparent"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-[#1a1f16] mb-1.5">Total acreage</label>
            <input
              type="number"
              defaultValue="1240"
              className="w-full px-4 py-2.5 border border-[#e2ddd5] rounded-lg text-sm text-[#1a1f16] focus:outline-none focus:ring-2 focus:ring-[#3a6b35] focus:border-transparent"
            />
          </div>
        </div>
      </div>
      <div className="pt-4 border-t border-[#e2ddd5]">
        <button className="bg-[#3a6b35] hover:bg-[#2d5429] text-white font-semibold text-sm px-5 py-2.5 rounded-lg transition-colors">
          Save changes
        </button>
      </div>
    </div>
  )
}

function AccountTab() {
  return (
    <div className="space-y-6">
      <div>
        <h3 className="text-base font-semibold text-[#1a1f16] mb-4">Personal Information</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-[#1a1f16] mb-1.5">Full name</label>
            <input
              type="text"
              defaultValue="Jane Rancher"
              className="w-full px-4 py-2.5 border border-[#e2ddd5] rounded-lg text-sm text-[#1a1f16] focus:outline-none focus:ring-2 focus:ring-[#3a6b35] focus:border-transparent"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-[#1a1f16] mb-1.5">Email address</label>
            <input
              type="email"
              defaultValue="jane@circlewranch.com"
              className="w-full px-4 py-2.5 border border-[#e2ddd5] rounded-lg text-sm text-[#1a1f16] focus:outline-none focus:ring-2 focus:ring-[#3a6b35] focus:border-transparent"
            />
          </div>
        </div>
      </div>

      <div className="pt-4 border-t border-[#e2ddd5]">
        <h3 className="text-base font-semibold text-[#1a1f16] mb-4">Change Password</h3>
        <div className="space-y-4 max-w-sm">
          <div>
            <label className="block text-sm font-medium text-[#1a1f16] mb-1.5">Current password</label>
            <input
              type="password"
              className="w-full px-4 py-2.5 border border-[#e2ddd5] rounded-lg text-sm text-[#1a1f16] focus:outline-none focus:ring-2 focus:ring-[#3a6b35] focus:border-transparent"
              placeholder="••••••••"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-[#1a1f16] mb-1.5">New password</label>
            <input
              type="password"
              className="w-full px-4 py-2.5 border border-[#e2ddd5] rounded-lg text-sm text-[#1a1f16] focus:outline-none focus:ring-2 focus:ring-[#3a6b35] focus:border-transparent"
              placeholder="At least 8 characters"
            />
          </div>
        </div>
      </div>

      <div className="pt-4 border-t border-[#e2ddd5] flex gap-3">
        <button className="bg-[#3a6b35] hover:bg-[#2d5429] text-white font-semibold text-sm px-5 py-2.5 rounded-lg transition-colors">
          Save changes
        </button>
        <button className="border border-[#c0392b] text-[#c0392b] hover:bg-red-50 font-semibold text-sm px-5 py-2.5 rounded-lg transition-colors">
          Delete account
        </button>
      </div>
    </div>
  )
}

function SubscriptionTab() {
  return (
    <div className="space-y-6">
      <div className="bg-[#3a6b35]/5 border border-[#3a6b35]/20 rounded-xl p-5">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-xs font-semibold uppercase tracking-wide text-[#3a6b35] mb-1">Current Plan</p>
            <h3
              className="text-2xl font-bold text-[#1a1f16]"
              style={{ fontFamily: 'var(--font-playfair)' }}
            >
              Free
            </h3>
            <p className="text-sm text-gray-500 mt-1">1 farm, up to 100 livestock</p>
          </div>
          <div className="text-right">
            <p className="text-3xl font-bold text-[#1a1f16]" style={{ fontFamily: 'var(--font-playfair)' }}>$0</p>
            <p className="text-sm text-gray-400">/ month</p>
          </div>
        </div>
      </div>

      <div>
        <h3 className="text-base font-semibold text-[#1a1f16] mb-3">Upgrade your plan</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="border border-[#e2ddd5] rounded-xl p-5">
            <p className="font-bold text-[#1a1f16]" style={{ fontFamily: 'var(--font-playfair)' }}>Pro</p>
            <p className="text-2xl font-bold text-[#1a1f16] mt-1" style={{ fontFamily: 'var(--font-playfair)' }}>$19 <span className="text-sm font-normal text-gray-400">/ mo</span></p>
            <p className="text-sm text-gray-500 mt-1 mb-4">Up to 3 farms, unlimited livestock</p>
            <button className="w-full bg-[#3a6b35] hover:bg-[#2d5429] text-white text-sm font-semibold py-2.5 rounded-lg transition-colors">
              Upgrade to Pro
            </button>
          </div>
          <div className="border border-[#e2ddd5] rounded-xl p-5">
            <p className="font-bold text-[#1a1f16]" style={{ fontFamily: 'var(--font-playfair)' }}>Ranch</p>
            <p className="text-2xl font-bold text-[#1a1f16] mt-1" style={{ fontFamily: 'var(--font-playfair)' }}>$49 <span className="text-sm font-normal text-gray-400">/ mo</span></p>
            <p className="text-sm text-gray-500 mt-1 mb-4">Unlimited farms, all features</p>
            <button className="w-full bg-[#c8922a] hover:bg-[#a87420] text-white text-sm font-semibold py-2.5 rounded-lg transition-colors">
              Upgrade to Ranch
            </button>
          </div>
        </div>
      </div>

      <p className="text-xs text-gray-400">
        Billing is managed securely. Upgrade and downgrade anytime. No contracts.
      </p>
    </div>
  )
}

function NotificationsTab() {
  const notifItems = [
    { label: 'Weekly summary email', description: 'Receive a weekly digest of your operation activity', defaultOn: true },
    { label: 'Maintenance reminders', description: 'Get notified when equipment service is due', defaultOn: true },
    { label: 'Low inventory alerts', description: 'Alert when feed or supply levels are low', defaultOn: false },
    { label: 'Financial milestones', description: 'Notify when income or expense thresholds are reached', defaultOn: false },
  ]

  return (
    <div className="space-y-5">
      <h3 className="text-base font-semibold text-[#1a1f16]">Notification Preferences</h3>
      <div className="space-y-0 divide-y divide-[#e2ddd5]">
        {notifItems.map((item) => (
          <div key={item.label} className="flex items-center justify-between py-4">
            <div>
              <p className="text-sm font-medium text-[#1a1f16]">{item.label}</p>
              <p className="text-xs text-gray-400 mt-0.5">{item.description}</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer ml-4">
              <input type="checkbox" defaultChecked={item.defaultOn} className="sr-only peer" />
              <div className="w-10 h-5 bg-gray-200 peer-focus:ring-2 peer-focus:ring-[#3a6b35] rounded-full peer peer-checked:after:translate-x-full peer-checked:bg-[#3a6b35] after:content-[''] after:absolute after:top-0.5 after:left-[2px] after:bg-white after:rounded-full after:h-4 after:w-4 after:transition-all" />
            </label>
          </div>
        ))}
      </div>
      <div className="pt-2">
        <button className="bg-[#3a6b35] hover:bg-[#2d5429] text-white font-semibold text-sm px-5 py-2.5 rounded-lg transition-colors">
          Save preferences
        </button>
      </div>
    </div>
  )
}

export default function SettingsPage() {
  const [activeTab, setActiveTab] = useState<TabId>('farm')

  return (
    <div className="max-w-4xl mx-auto">
      <div className="mb-6">
        <h1
          className="text-2xl font-bold text-[#1a1f16]"
          style={{ fontFamily: 'var(--font-playfair)' }}
        >
          Settings
        </h1>
        <p className="text-sm text-gray-500 mt-0.5">Manage your farm profile and account</p>
      </div>

      <div className="flex flex-col md:flex-row gap-6">
        {/* Tab nav */}
        <nav className="md:w-48 shrink-0">
          <ul className="space-y-1">
            {tabs.map(({ id, label, icon: Icon }) => (
              <li key={id}>
                <button
                  onClick={() => setActiveTab(id)}
                  className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors text-left ${
                    activeTab === id
                      ? 'bg-[#3a6b35]/10 text-[#3a6b35]'
                      : 'text-gray-600 hover:bg-gray-100'
                  }`}
                >
                  <Icon className="w-4 h-4 shrink-0" />
                  {label}
                </button>
              </li>
            ))}
          </ul>
        </nav>

        {/* Tab content */}
        <div className="flex-1 bg-white rounded-2xl border border-[#e2ddd5] p-6">
          {activeTab === 'farm' && <FarmProfileTab />}
          {activeTab === 'account' && <AccountTab />}
          {activeTab === 'subscription' && <SubscriptionTab />}
          {activeTab === 'notifications' && <NotificationsTab />}
        </div>
      </div>
    </div>
  )
}
