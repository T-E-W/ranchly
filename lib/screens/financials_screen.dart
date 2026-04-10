import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FinancialsScreen extends StatefulWidget {
  const FinancialsScreen({super.key});

  @override
  State<FinancialsScreen> createState() => _FinancialsScreenState();
}

class _FinancialsScreenState extends State<FinancialsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  Map<String, dynamic>? _overview;
  List<dynamic> _records = [];
  bool _loadingOverview = true;
  bool _loadingRecords = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadOverview();
    _loadRecords();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadOverview() async {
    setState(() => _loadingOverview = true);
    try {
      final data = await ApiService.get('/financials/overview') as Map<String, dynamic>;
      if (mounted) setState(() { _overview = data; _loadingOverview = false; });
    } catch (e) {
      if (mounted) setState(() { _loadingOverview = false; _error = e.toString(); });
    }
  }

  Future<void> _loadRecords() async {
    setState(() => _loadingRecords = true);
    try {
      final data = await ApiService.get('/financials/') as List<dynamic>;
      if (mounted) setState(() { _records = data; _loadingRecords = false; });
    } catch (e) {
      if (mounted) setState(() => _loadingRecords = false);
    }
  }

  Future<void> _refresh() async {
    await Future.wait([_loadOverview(), _loadRecords()]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financials'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh)],
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [Tab(text: 'Overview'), Tab(text: 'Transactions')],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_financials',
        onPressed: () => _showAddRecord(context),
        child: const Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [_overviewTab(), _transactionsTab()],
      ),
    );
  }

  // ── Overview Tab ───────────────────────────────────────────────────────────

  Widget _overviewTab() {
    if (_loadingOverview) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _errorView(_error!);
    if (_overview == null) return const Center(child: Text('No data'));

    final o = _overview!;
    final revenue = (o['total_revenue'] as num?)?.toDouble() ?? 0;
    final expenses = (o['total_expenses'] as num?)?.toDouble() ?? 0;
    final purchases = (o['total_animal_purchases'] as num?)?.toDouble() ?? 0;
    final net = (o['net'] as num?)?.toDouble() ?? 0;
    final byCategory = o['by_category'] as Map<String, dynamic>? ?? {};
    final monthly = o['monthly_cash_flow'] as List<dynamic>? ?? [];

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary cards
          Row(children: [
            Expanded(child: _summaryCard('Revenue', revenue, Colors.green, Icons.trending_up)),
            const SizedBox(width: 10),
            Expanded(child: _summaryCard('Expenses', expenses + purchases, Colors.red, Icons.trending_down)),
          ]),
          const SizedBox(height: 10),
          _netCard(net),
          const SizedBox(height: 16),

          // Category breakdown
          if (byCategory.isNotEmpty) ...[
            const Text('Spending by Category',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: (byCategory.entries.toList()
                    ..sort((a, b) => (b.value as num).compareTo(a.value as num)))
                    .take(8).map((e) => _categoryRow(
                      e.key, (e.value as num).toDouble(),
                      expenses + purchases)).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Monthly cash flow
          if (monthly.isNotEmpty) ...[
            const Text('Monthly Cash Flow',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: monthly.reversed.take(6).map((m) =>
                    _monthRow(m as Map<String, dynamic>)).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryCard(String label, double amount, Color color, IconData icon) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(_fmt(amount),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    ),
  );

  Widget _netCard(double net) {
    final positive = net >= 0;
    final color = positive ? Colors.green : Colors.red;
    return Card(
      color: color.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(positive ? Icons.arrow_upward : Icons.arrow_downward, color: color),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Net Profit / Loss', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(_fmt(net.abs()),
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _categoryRow(String cat, double amount, double total) {
    final pct = total > 0 ? amount / total : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_capitalize(cat), style: const TextStyle(fontSize: 13)),
              Text(_fmt(amount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(const Color(0xFF3a6b35)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _monthRow(Map<String, dynamic> m) {
    final inAmt = (m['in'] as num?)?.toDouble() ?? 0;
    final outAmt = (m['out'] as num?)?.toDouble() ?? 0;
    final net = (m['net'] as num?)?.toDouble() ?? 0;
    final month = m['month']?.toString() ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 64, child: Text(month, style: const TextStyle(fontSize: 12, color: Colors.grey))),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('In: ${_fmt(inAmt)}', style: const TextStyle(fontSize: 11, color: Colors.green)),
            Text('Out: ${_fmt(outAmt)}', style: const TextStyle(fontSize: 11, color: Colors.red)),
          ])),
          Text(_fmt(net),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13,
              color: net >= 0 ? Colors.green : Colors.red)),
        ],
      ),
    );
  }

  // ── Transactions Tab ───────────────────────────────────────────────────────

  Widget _transactionsTab() {
    if (_loadingRecords) return const Center(child: CircularProgressIndicator());
    if (_records.isEmpty) return const Center(child: Text('No transactions recorded'));
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
        itemCount: _records.length,
        itemBuilder: (_, i) => _recordCard(_records[i] as Map<String, dynamic>),
      ),
    );
  }

  Widget _recordCard(Map<String, dynamic> r) {
    final type = r['record_type']?.toString() ?? '';
    final isIncome = type == 'sale';
    final color = isIncome ? Colors.green : Colors.red;
    final amount = (r['amount'] as num?)?.toDouble() ?? 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: color, size: 20),
        ),
        title: Text(
          r['description'] ?? r['category'] ?? _capitalize(type),
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${r['record_date'] ?? ''} · ${_capitalize(r['category'] ?? type)}',
          style: const TextStyle(fontSize: 11)),
        trailing: Text(
          '${isIncome ? '+' : '-'}${_fmt(amount)}',
          style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
      ),
    );
  }

  // ── Add Record Form ────────────────────────────────────────────────────────

  void _showAddRecord(BuildContext context) {
    String _type = 'expense';
    String _category = 'feed';
    DateTime _date = DateTime.now();
    final _amountCtrl = TextEditingController();
    final _descCtrl = TextEditingController();
    final _notesCtrl = TextEditingController();

    final categories = {
      'expense': ['feed', 'veterinary', 'medication', 'equipment', 'fuel', 'labour', 'other'],
      'sale': ['animal_sale', 'wool', 'meat', 'dairy', 'other'],
      'purchase': ['animal_purchase', 'equipment', 'land', 'other'],
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('Add Transaction',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              // Type selector
              Row(children: ['expense', 'sale', 'purchase'].map((t) {
                final selected = _type == t;
                final color = t == 'sale' ? Colors.green : Colors.red;
                return Expanded(child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => setModal(() {
                      _type = t;
                      _category = categories[t]!.first;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? color.withOpacity(0.15) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: selected ? color : Colors.transparent, width: 2),
                      ),
                      child: Center(child: Text(_capitalize(t),
                        style: TextStyle(fontWeight: FontWeight.w600,
                          color: selected ? color : Colors.grey.shade600, fontSize: 13))),
                    ),
                  ),
                ));
              }).toList()),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories[_type]!.map((c) => DropdownMenuItem(
                  value: c, child: Text(_capitalize(c.replaceAll('_', ' '))))).toList(),
                onChanged: (v) => setModal(() => _category = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Amount *', prefixText: '\$'),
              ),
              const SizedBox(height: 12),
              TextField(controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text('${_date.month}/${_date.day}/${_date.year}'),
                trailing: const Icon(Icons.calendar_today, size: 18),
                onTap: () async {
                  final d = await showDatePicker(context: ctx,
                    initialDate: _date, firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 30)));
                  if (d != null) setModal(() => _date = d);
                },
              ),
              TextField(controller: _notesCtrl, maxLines: 2,
                decoration: const InputDecoration(labelText: 'Notes (optional)')),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (_amountCtrl.text.isEmpty) return;
                    final fmt = (DateTime d) =>
                      '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
                    try {
                      await ApiService.post('/financials/', {
                        'record_type': _type,
                        'record_date': fmt(_date),
                        'amount': double.parse(_amountCtrl.text.replaceAll(',', '')),
                        'category': _category,
                        if (_descCtrl.text.isNotEmpty) 'description': _descCtrl.text.trim(),
                        if (_notesCtrl.text.isNotEmpty) 'notes': _notesCtrl.text.trim(),
                        'source': 'manual',
                      });
                      if (mounted) { Navigator.pop(ctx); _refresh(); }
                    } catch (e) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                    }
                  },
                  child: const Text('Save'),
                )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorView(String msg) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
      const SizedBox(height: 12),
      Text(msg, textAlign: TextAlign.center),
      const SizedBox(height: 16),
      FilledButton(onPressed: _refresh, child: const Text('Retry')),
    ]),
  );

  String _fmt(double v) {
    if (v >= 1000000) return '\$${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '\$${(v / 1000).toStringAsFixed(1)}k';
    return '\$${v.toStringAsFixed(2)}';
  }

  String _capitalize(String s) => s.isEmpty ? s
    : s.split(' ').map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1)).join(' ');
}
