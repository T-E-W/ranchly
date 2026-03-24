'use client'

import {
  Beef,
  DollarSign,
  TrendingUp,
  Map,
  Plus,
  ArrowUpRight,
  ArrowDownRight,
  Sprout,
  Activity,
} from 'lucide-react'
import Link from 'next/link'
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  Legend,
} from 'recharts'

const plData = [
  { month: 'Oct', income: 18400, expenses: 12200 },
  { month: 'Nov', income: 14200, expenses: 9800 },
  { month: 'Dec', income: 22100, expenses: 15600 },
  { month: 'Jan', income: 9800, expenses: 11200 },
  { month: 'Feb', income: 13500, expenses: 10100 },
  { month: 'Mar', income: 19700, expenses: 13400 },
]

const expenseData = [
  { name: 'Feed & Hay', value: 4200, color: '#3a6b35' },
  { name: 'Veterinary', value: 1800, color: '#c8922a' },
  { name: 'Equipment', value: 2100, color: '#1a1f16' },
  { name: 'Labor', value: 3100, color: '#4d8a47' },
  { name: 'Utilities', value: 900, color: '#a87420' },
  { name: 'Other', value: 1300, color: '#9ca3af' },
]

const kpiCards = [
  {
    label: 'Total Livestock',
    value: '248',
    unit: 'head',
    delta: '+12',
    deltaUp: true,
    icon: Beef,
    color: '#3a6b35',
    bg: '#3a6b35',
  },
  {
    label: 'Livestock Value',
    value: '$312,400',
    unit: '',
    delta: '+$8,200',
    deltaUp: true,
    icon: DollarSign,
    color: '#c8922a',
    bg: '#c8922a',
  },
  {
    label: 'Expenses (MTD)',
    value: '$13,400',
    unit: '',
    delta: '+$1,200',
    deltaUp: false,
    icon: ArrowDownRight,
    color: '#c0392b',
    bg: '#c0392b',
  },
  {
    label: 'Income (MTD)',
    value: '$19,700',
    unit: '',
    delta: '+$3,100',
    deltaUp: true,
    icon: ArrowUpRight,
    color: '#3a6b35',
    bg: '#3a6b35',
  },
  {
    label: 'Net P&L (MTD)',
    value: '+$6,300',
    unit: '',
    delta: '+$1,900',
    deltaUp: true,
    icon: TrendingUp,
    color: '#3a6b35',
    bg: '#3a6b35',
  },
  {
    label: 'Total Acreage',
    value: '1,240',
    unit: 'ac',
    delta: 'No change',
    deltaUp: null,
    icon: Map,
    color: '#1a1f16',
    bg: '#1a1f16',
  },
]

const quickActions = [
  { label: 'Add Livestock Group', href: '/app/livestock', icon: Beef, color: '#3a6b35' },
  { label: 'Log Expense', href: '/app/finance', icon: ArrowDownRight, color: '#c0392b' },
  { label: 'Record Sale', href: '/app/finance', icon: DollarSign, color: '#c8922a' },
  { label: 'Add Crop', href: '/app/crops', icon: Sprout, color: '#4d8a47' },
]

const recentActivity = [
  { text: 'Herd 7 — 14 head moved to South Pasture', time: '2 hours ago', type: 'livestock' },
  { text: 'Expense logged: $840 veterinary — Herd 3', time: '5 hours ago', type: 'finance' },
  { text: 'Sale recorded: 8 steers @ $1,420/hd', time: 'Yesterday', type: 'sale' },
  { text: 'Soil test results uploaded — Field B', time: '2 days ago', type: 'land' },
  { text: 'Equipment service: John Deere 6155M', time: '3 days ago', type: 'equipment' },
]

function getHour() {
  const h = new Date().getHours()
  if (h < 12) return 'morning'
  if (h < 17) return 'afternoon'
  return 'evening'
}

export default function DashboardPage() {
  return (
    <div className="space-y-6 max-w-7xl mx-auto">
      {/* Welcome banner */}
      <div className="bg-gradient-to-r from-[#1a1f16] to-[#2d5429] rounded-2xl px-6 py-5 text-white flex items-center justify-between">
        <div>
          <h1
            className="text-xl md:text-2xl font-bold mb-0.5"
            style={{ fontFamily: 'var(--font-playfair)' }}
          >
            Good {getHour()}, Circle W Ranch
          </h1>
          <p className="text-green-300 text-sm">Here&apos;s a snapshot of your operation today.</p>
        </div>
        <div className="hidden md:flex items-center gap-2 text-green-300 text-sm">
          <Activity className="w-4 h-4" />
          <span>All systems normal</span>
        </div>
      </div>

      {/* KPI grid */}
      <div className="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-6 gap-4">
        {kpiCards.map((kpi) => {
          const Icon = kpi.icon
          return (
            <div
              key={kpi.label}
              className="bg-white rounded-xl border border-[#e2ddd5] p-4 flex flex-col gap-2"
            >
              <div className="flex items-center justify-between">
                <span className="text-xs font-medium text-gray-500">{kpi.label}</span>
                <div
                  className="w-7 h-7 rounded-lg flex items-center justify-center"
                  style={{ backgroundColor: kpi.bg + '18' }}
                >
                  <Icon className="w-3.5 h-3.5" style={{ color: kpi.color }} />
                </div>
              </div>
              <div>
                <div className="text-lg font-bold text-[#1a1f16]">
                  {kpi.value}
                  {kpi.unit && <span className="text-sm font-normal text-gray-500 ml-1">{kpi.unit}</span>}
                </div>
                <div
                  className={`text-xs mt-0.5 ${
                    kpi.deltaUp === true
                      ? 'text-[#3a6b35]'
                      : kpi.deltaUp === false
                      ? 'text-[#c0392b]'
                      : 'text-gray-400'
                  }`}
                >
                  {kpi.delta}
                </div>
              </div>
            </div>
          )
        })}
      </div>

      {/* Quick actions */}
      <div>
        <h2 className="text-sm font-semibold text-gray-500 uppercase tracking-wide mb-3">
          Quick Actions
        </h2>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          {quickActions.map((action) => {
            const Icon = action.icon
            return (
              <Link
                key={action.label}
                href={action.href}
                className="flex items-center gap-3 bg-white border border-[#e2ddd5] rounded-xl px-4 py-3.5 hover:shadow-sm hover:border-[#3a6b35]/30 transition-all group"
              >
                <div
                  className="w-8 h-8 rounded-lg flex items-center justify-center shrink-0"
                  style={{ backgroundColor: action.color + '15' }}
                >
                  <Icon className="w-4 h-4" style={{ color: action.color }} />
                </div>
                <span className="text-sm font-medium text-[#1a1f16] group-hover:text-[#3a6b35]">
                  {action.label}
                </span>
                <Plus className="w-4 h-4 text-gray-300 ml-auto group-hover:text-[#3a6b35]" />
              </Link>
            )
          })}
        </div>
      </div>

      {/* Charts row */}
      <div className="grid grid-cols-1 lg:grid-cols-5 gap-6">
        {/* Monthly P&L bar chart */}
        <div className="lg:col-span-3 bg-white rounded-2xl border border-[#e2ddd5] p-6">
          <h3 className="text-sm font-semibold text-[#1a1f16] mb-1">Monthly P&L</h3>
          <p className="text-xs text-gray-400 mb-4">Income vs. Expenses — last 6 months</p>
          <ResponsiveContainer width="100%" height={200}>
            <BarChart data={plData} barGap={4}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f0ede8" />
              <XAxis dataKey="month" tick={{ fontSize: 11, fill: '#9ca3af' }} axisLine={false} tickLine={false} />
              <YAxis
                tick={{ fontSize: 11, fill: '#9ca3af' }}
                axisLine={false}
                tickLine={false}
                tickFormatter={(v) => `$${(v / 1000).toFixed(0)}k`}
              />
              <Tooltip
                formatter={(value) => [`$${Number(value).toLocaleString()}`, '']}
                contentStyle={{ border: '1px solid #e2ddd5', borderRadius: 8, fontSize: 12 }}
              />
              <Bar dataKey="income" name="Income" fill="#3a6b35" radius={[3, 3, 0, 0]} />
              <Bar dataKey="expenses" name="Expenses" fill="#c8922a" radius={[3, 3, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Expense breakdown donut */}
        <div className="lg:col-span-2 bg-white rounded-2xl border border-[#e2ddd5] p-6">
          <h3 className="text-sm font-semibold text-[#1a1f16] mb-1">Expense Breakdown</h3>
          <p className="text-xs text-gray-400 mb-4">Month to date</p>
          <ResponsiveContainer width="100%" height={200}>
            <PieChart>
              <Pie
                data={expenseData}
                cx="50%"
                cy="50%"
                innerRadius={55}
                outerRadius={80}
                paddingAngle={3}
                dataKey="value"
              >
                {expenseData.map((entry, index) => (
                  <Cell key={index} fill={entry.color} />
                ))}
              </Pie>
              <Tooltip
                formatter={(value) => [`$${Number(value).toLocaleString()}`, '']}
                contentStyle={{ border: '1px solid #e2ddd5', borderRadius: 8, fontSize: 12 }}
              />
              <Legend
                formatter={(value) => (
                  <span style={{ fontSize: 11, color: '#6b7280' }}>{value}</span>
                )}
              />
            </PieChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Recent activity */}
      <div className="bg-white rounded-2xl border border-[#e2ddd5] p-6">
        <h3 className="text-sm font-semibold text-[#1a1f16] mb-4">Recent Activity</h3>
        <div className="space-y-0">
          {recentActivity.map((item, i) => (
            <div
              key={i}
              className={`flex items-start gap-4 py-3 ${
                i < recentActivity.length - 1 ? 'border-b border-[#e2ddd5]' : ''
              }`}
            >
              <div className="w-2 h-2 rounded-full bg-[#3a6b35] mt-1.5 shrink-0" />
              <div className="flex-1 min-w-0">
                <p className="text-sm text-[#1a1f16]">{item.text}</p>
                <p className="text-xs text-gray-400 mt-0.5">{item.time}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
