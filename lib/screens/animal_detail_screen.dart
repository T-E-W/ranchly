import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../services/api_service.dart';
import 'animals_screen.dart';

class AnimalDetailScreen extends StatefulWidget {
  final Map<String, dynamic> animal;
  final VoidCallback onUpdated;

  const AnimalDetailScreen({super.key, required this.animal, required this.onUpdated});

  @override
  State<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  Map<String, dynamic>? _animal;
  List<dynamic> _healthEvents = [];
  List<dynamic> _weights = [];
  List<dynamic> _famacha = [];
  List<dynamic> _breeding = [];
  List<dynamic> _shearing = [];
  List<dynamic> _progeny = [];
  bool _loadingHealth = true;
  bool _loadingWeights = true;
  bool _loadingFamacha = true;
  bool _loadingBreeding = true;
  bool _loadingShearing = true;
  bool _loadingProgeny = true;

  static const _famachaSpecies = {'sheep', 'goat', 'goats', 'sheep/goat'};
  late final bool _showFamacha;
  late final bool _showBreeding;
  late final bool _showShearing;
  late final bool _showProgeny;

  @override
  void initState() {
    super.initState();
    _animal = widget.animal;
    final species = (_animal?['species'] ?? '').toString().toLowerCase();
    final sex = (_animal?['sex'] ?? _animal?['gender'] ?? '').toString().toLowerCase();
    _showFamacha = _famachaSpecies.any((s) => species.contains(s));
    _showShearing = species.contains('sheep');
    _showBreeding = sex == 'female' || sex == 'ewe' || sex == 'doe' || sex == 'cow' || sex == 'hen';
    _showProgeny = true; // any animal can have offspring
    final tabCount = 3 + (_showFamacha ? 1 : 0) + (_showShearing ? 1 : 0) + (_showBreeding ? 1 : 0) + (_showProgeny ? 1 : 0);
    _tabs = TabController(length: tabCount, vsync: this);
    _tabs.addListener(_onTabChange);
    _loadAnimal();
    _loadHealth();
    if (_showFamacha) _loadFamacha();
    if (_showShearing) _loadShearing();
    if (_showBreeding) _loadBreeding();
    _loadProgeny();
  }

  void _onTabChange() {
    if (_tabs.index == 2 && _weights.isEmpty && !_loadingWeights) _loadWeights();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTabChange);
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadAnimal() async {
    try {
      final data = await ApiService.get('/animals/${_animal!['id']}');
      if (mounted) setState(() => _animal = data as Map<String, dynamic>);
    } catch (_) {}
  }

  Future<void> _loadHealth() async {
    setState(() => _loadingHealth = true);
    try {
      final data = await ApiService.get('/animals/${_animal!['id']}/health') as List<dynamic>;
      if (mounted) setState(() { _healthEvents = data; _loadingHealth = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingHealth = false);
    }
  }

  Future<void> _loadWeights() async {
    setState(() => _loadingWeights = true);
    try {
      final data = await ApiService.get('/animals/${_animal!['id']}/weights') as List<dynamic>;
      if (mounted) setState(() { _weights = data; _loadingWeights = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingWeights = false);
    }
  }

  Future<void> _loadProgeny() async {
    setState(() => _loadingProgeny = true);
    try {
      final data = await ApiService.get('/animals/${_animal!['id']}/progeny') as List<dynamic>;
      if (mounted) setState(() { _progeny = data; _loadingProgeny = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingProgeny = false);
    }
  }

  Future<void> _loadShearing() async {
    setState(() => _loadingShearing = true);
    try {
      final data = await ApiService.get('/animals/${_animal!['id']}/shearing') as List<dynamic>;
      if (mounted) setState(() { _shearing = data; _loadingShearing = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingShearing = false);
    }
  }

  Future<void> _loadBreeding() async {
    setState(() => _loadingBreeding = true);
    try {
      final data = await ApiService.get('/animals/${_animal!['id']}/breeding') as List<dynamic>;
      if (mounted) setState(() { _breeding = data; _loadingBreeding = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingBreeding = false);
    }
  }

  Future<void> _loadFamacha() async {
    setState(() => _loadingFamacha = true);
    try {
      final data = await ApiService.get('/animals/${_animal!['id']}/famacha') as List<dynamic>;
      if (mounted) setState(() { _famacha = data; _loadingFamacha = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingFamacha = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = _animal!;
    final tag = a['tag_number']?.toString() ?? '?';
    final name = (a['name'] != null && (a['name'] as String).isNotEmpty)
        ? a['name'] as String : tag;

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => AnimalFormScreen(
                animal: _animal,
                onSaved: () {
                  widget.onUpdated();
                  _loadAnimal();
                  Navigator.of(context).pop();
                },
              ),
            )),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            const Tab(text: 'Profile'),
            Tab(text: 'Health (${_healthEvents.length})'),
            const Tab(text: 'Weight'),
            if (_showFamacha) Tab(text: 'Famacha (${_famacha.length})'),
            if (_showShearing) Tab(text: 'Shearing (${_shearing.length})'),
            if (_showBreeding) Tab(text: 'Breeding (${_breeding.length})'),
            if (_showProgeny) Tab(text: 'Progeny (${_progeny.length})'),
          ],
        ),
      ),
      floatingActionButton: _QuickActionsFab(
        animal: _animal!,
        showFamacha: _showFamacha,
        showBreeding: _showBreeding,
        onLogged: () {
          _loadHealth();
          if (_showFamacha) _loadFamacha();
          if (_showShearing) _loadShearing();
          if (_showBreeding) _loadBreeding();
          _loadProgeny();
          _loadAnimal();
        },
      ),
      body: Column(
        children: [
          _header(a, tag),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _profileTab(a),
                _healthTab(),
                _weightTab(),
                if (_showFamacha) _famachaTab(),
                if (_showShearing) _shearingTab(),
                if (_showBreeding) _breedingTab(),
                if (_showProgeny) _progenyTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _header(Map<String, dynamic> a, String tag) {
    final species = a['species']?.toString() ?? '';
    final breed = a['breed']?.toString() ?? '';
    final subtitle = [species, breed].where((s) => s.isNotEmpty).join(' · ');

    return Container(
      color: const Color(0xFF3a6b35),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle.isNotEmpty)
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Row(children: [
                  _badge(a['status'] ?? ''),
                  if (a['sex'] != null || a['gender'] != null) ...[
                    const SizedBox(width: 6),
                    _badge(a['sex'] ?? a['gender'] ?? ''),
                  ],
                  if (a['group_name'] != null) ...[
                    const SizedBox(width: 6),
                    _badge(a['group_name']),
                  ],
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.white24,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
  );

  // ── Profile Tab ────────────────────────────────────────────────────────────

  Widget _profileTab(Map<String, dynamic> a) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      _section('Identification', [
        _row('Tag Number', a['tag_number']),
        _row('Name', a['name']),
        _row('EID Tag', a['eid_tag']),
        _row('Group', a['group_name']),
      ]),
      _section('Details', [
        _row('Species', a['species']),
        _row('Breed', a['breed']),
        _row('Gender', a['sex'] ?? a['gender']),
        _row('Color / Markings', a['color']),
        _row('Date of Birth', a['date_of_birth']),
        _row('Age', _calcAge(a['date_of_birth'])),
      ]),
      _section('Weight & Condition', [
        _row('Current Weight', a['current_weight'] != null ? '${a['current_weight']} lbs'
            : a['weight'] != null ? '${a['weight']} lbs' : null),
        _row('Body Condition Score', a['body_condition_score']?.toString()),
      ]),
      _section('Lineage', [
        _row('Sire Tag', a['sire_tag']),
        _row('Dam Tag', a['dam_tag']),
      ]),
      _section('Acquisition', [
        _row('Status', a['status']),
        _row('Acquisition Date', a['acquisition_date']),
        _row('Purchase Price', a['purchase_price'] != null ? '\$${a['purchase_price']}' : null),
        _row('Vendor', a['vendor']),
      ]),
      if (a['notes'] != null && (a['notes'] as String).isNotEmpty)
        _section('Notes', [_noteRow(a['notes'])]),
    ],
  );

  Widget _section(String title, List<Widget> rows) {
    final nonEmpty = rows.where((w) => w is! SizedBox).toList();
    // Don't render section if all rows are empty
    final hasContent = rows.any((w) => w is Padding);
    if (!hasContent) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF3a6b35))),
            const SizedBox(height: 8),
            ...rows,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, dynamic value) {
    if (value == null || value.toString().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
          Expanded(
            child: Text(value.toString(),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _noteRow(String notes) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Text(notes, style: const TextStyle(fontSize: 13)),
  );

  String? _calcAge(dynamic dob) {
    if (dob == null) return null;
    try {
      final d = DateTime.parse(dob.toString());
      final now = DateTime.now();
      final months = (now.year - d.year) * 12 + now.month - d.month;
      if (months < 1) return 'Less than 1 month';
      if (months < 24) return '$months months';
      return '${(months / 12).floor()} years ${months % 12} months';
    } catch (_) { return null; }
  }

  // ── Health Tab ─────────────────────────────────────────────────────────────

  Widget _healthTab() {
    if (_loadingHealth) return const Center(child: CircularProgressIndicator());
    if (_healthEvents.isEmpty) return const Center(child: Text('No health events recorded'));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _healthEvents.length,
      itemBuilder: (_, i) {
        final e = _healthEvents[i] as Map<String, dynamic>;
        final id = e['id'];
        return Slidable(
          key: ValueKey('health_$id'),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.18,
            children: [
              SlidableAction(
                onPressed: (_) async {
                  setState(() => _healthEvents.removeWhere((x) => (x as Map)['id'] == id));
                  try { await ApiService.delete('/health/events/$id'); }
                  catch (_) { if (mounted) _loadHealth(); }
                },
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                icon: Icons.delete_outline,
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
              ),
            ],
          ),
          child: _healthCard(e),
        );
      },
    );
  }


  Widget _healthCard(Map<String, dynamic> e) {
    final type = e['event_type']?.toString() ?? '';
    final color = _typeColor(type);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_typeIcon(type), color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_capitalize(type),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(e['event_date']?.toString() ?? '',
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  if (e['product_name'] != null && e['product_name'].toString().isNotEmpty)
                    Text(e['product_name'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  if (e['dose'] != null && e['dose'].toString().isNotEmpty)
                    Text('Dose: ${e['dose']}', style: const TextStyle(fontSize: 12)),
                  if (e['route'] != null && e['route'].toString().isNotEmpty)
                    Text('Route: ${e['route']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  if (e['notes'] != null && e['notes'].toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(e['notes'],
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ),
                  if (e['whp_active'] == true)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Text('WHP until ${e['whp_end_date']}',
                        style: TextStyle(fontSize: 11, color: Colors.orange.shade800)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Weight Tab ─────────────────────────────────────────────────────────────

  Widget _weightTab() {
    if (_loadingWeights && _weights.isEmpty) {
      _loadWeights();
      return const Center(child: CircularProgressIndicator());
    }
    final current = _animal!['current_weight'] ?? _animal!['weight'];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (current != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.monitor_weight_outlined, color: Color(0xFF3a6b35), size: 32),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Current Weight',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text('$current lbs',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        if (_weights.length >= 2) ...[
          const SizedBox(height: 12),
          _WeightChart(weights: _weights),
        ],
        if (_weights.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('Weight History',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          ..._weights.map((entry) {
            final w = entry as Map<String, dynamic>;
            final id = w['id'];
            return Slidable(
              key: ValueKey('weight_$id'),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.18,
                children: [
                  SlidableAction(
                    onPressed: (_) async {
                      setState(() => _weights.removeWhere((x) => (x as Map)['id'] == id));
                      try { await ApiService.delete('/health/weights/$id'); }
                      catch (_) { if (mounted) _loadWeights(); }
                    },
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    icon: Icons.delete_outline,
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                  ),
                ],
              ),
              child: Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  leading: const Icon(Icons.scale_outlined, color: Color(0xFF3a6b35)),
                  title: Text('${w['weight_kg'] ?? w['weight']} ${w['weight_kg'] != null ? 'kg' : 'lbs'}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: w['notes'] != null && w['notes'].toString().isNotEmpty
                      ? Text(w['notes'], style: const TextStyle(fontSize: 12)) : null,
                  trailing: Text(w['record_date']?.toString() ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ),
              ),
            );
          }),
        ] else if (!_loadingWeights && current == null)
          const Center(child: Padding(
            padding: EdgeInsets.only(top: 32),
            child: Text('No weight records', style: TextStyle(color: Colors.grey)),
          )),
      ],
    );
  }

  // ── Breeding Tab ───────────────────────────────────────────────────────────

  Widget _breedingTab() {
    if (_loadingBreeding) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FilledButton.tonal(
          onPressed: () => _showLogBreeding(),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 18),
              SizedBox(width: 6),
              Text('Log Breeding Record'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_breeding.isEmpty)
          const Center(child: Text('No breeding records', style: TextStyle(color: Colors.grey)))
        else
          ..._breeding.map((r) => _breedingCard(r as Map<String, dynamic>)),
      ],
    );
  }

  Widget _breedingCard(Map<String, dynamic> r) {
    final outcome = r['outcome']?.toString() ?? '';
    final expectedDate = r['expected_lambing_date']?.toString();
    final actualDate = r['actual_lambing_date']?.toString();
    final joiningDate = r['joining_date']?.toString() ?? '';
    final ramTag = r['ram']?['tag_number'] ?? r['ram_notes'] ?? 'Unknown ram';

    final Color outcomeColor;
    final IconData outcomeIcon;
    switch (outcome.toLowerCase()) {
      case 'success':
      case 'lambed':
      case 'kidded':
        outcomeColor = Colors.green;
        outcomeIcon = Icons.check_circle_outline;
        break;
      case 'failed':
      case 'empty':
        outcomeColor = Colors.red;
        outcomeIcon = Icons.cancel_outlined;
        break;
      case 'pending':
      case '':
        outcomeColor = Colors.orange;
        outcomeIcon = Icons.hourglass_empty;
        break;
      default:
        outcomeColor = Colors.blue;
        outcomeIcon = Icons.info_outline;
    }

    // Days until expected lambing
    String? dueLabel;
    if (expectedDate != null && actualDate == null) {
      try {
        final due = DateTime.parse(expectedDate);
        final diff = due.difference(DateTime.now()).inDays;
        if (diff > 0) dueLabel = 'Due in $diff days';
        else if (diff == 0) dueLabel = 'Due today!';
        else dueLabel = '${diff.abs()} days overdue';
      } catch (_) {}
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Joined: $joiningDate',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Row(children: [
                  Icon(outcomeIcon, color: outcomeColor, size: 16),
                  const SizedBox(width: 4),
                  Text(outcome.isEmpty ? 'Pending' : _capitalize(outcome),
                    style: TextStyle(color: outcomeColor, fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
              ],
            ),
            const SizedBox(height: 8),
            _breedingRow('Ram', ramTag),
            if (expectedDate != null) _breedingRow('Expected', expectedDate),
            if (actualDate != null) _breedingRow('Actual', actualDate),
            if (dueLabel != null)
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(dueLabel,
                  style: TextStyle(fontSize: 11, color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
              ),
            if (r['notes'] != null && r['notes'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(r['notes'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _breedingRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 3),
    child: Row(
      children: [
        SizedBox(width: 80,
          child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12))),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    ),
  );

  void _showLogBreeding() {
    final _joiningCtrl = TextEditingController();
    final _ramTagCtrl = TextEditingController();
    final _notesCtrl = TextEditingController();
    DateTime _joiningDate = DateTime.now();
    DateTime? _expectedDate;
    String _outcome = 'pending';

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
              Center(child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
              )),
              const SizedBox(height: 16),
              const Text('Log Breeding Record',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              // Joining date
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Joining Date *'),
                subtitle: Text('${_joiningDate.month}/${_joiningDate.day}/${_joiningDate.year}'),
                trailing: const Icon(Icons.calendar_today, size: 18),
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx, initialDate: _joiningDate,
                    firstDate: DateTime(2000), lastDate: DateTime.now().add(const Duration(days: 365)));
                  if (d != null) setModal(() => _joiningDate = d);
                },
              ),
              // Expected lambing
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Expected Lambing / Kidding'),
                subtitle: Text(_expectedDate == null ? 'Not set'
                  : '${_expectedDate!.month}/${_expectedDate!.day}/${_expectedDate!.year}'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (_expectedDate != null)
                    IconButton(icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => setModal(() => _expectedDate = null)),
                  const Icon(Icons.calendar_today, size: 18),
                ]),
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: _expectedDate ?? _joiningDate.add(const Duration(days: 147)),
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 365)));
                  if (d != null) setModal(() => _expectedDate = d);
                },
              ),
              const Divider(),
              const SizedBox(height: 8),
              TextField(
                controller: _ramTagCtrl,
                decoration: const InputDecoration(labelText: 'Ram / Sire Tag (optional)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _outcome,
                decoration: const InputDecoration(labelText: 'Outcome'),
                items: ['pending', 'success', 'lambed', 'kidded', 'failed', 'empty']
                  .map((o) => DropdownMenuItem(value: o,
                    child: Text(o[0].toUpperCase() + o.substring(1)))).toList(),
                onChanged: (v) => setModal(() => _outcome = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    try {
                      final fmt = (DateTime d) =>
                        '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
                      await ApiService.post('/breeding/', {
                        'ewe_id': _animal!['id'],
                        'joining_date': fmt(_joiningDate),
                        if (_expectedDate != null) 'expected_lambing_date': fmt(_expectedDate!),
                        'outcome': _outcome,
                        if (_ramTagCtrl.text.trim().isNotEmpty) 'ram_notes': _ramTagCtrl.text.trim(),
                        if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
                      });
                      if (mounted) { Navigator.pop(ctx); _loadBreeding(); }
                    } catch (e) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                    }
                  },
                  child: const Text('Save Record'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Famacha Tab ────────────────────────────────────────────────────────────

  Widget _famachaTab() {
    if (_loadingFamacha) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Latest score card
        if (_famacha.isNotEmpty) _latestFamachaCard(_famacha.first),
        const SizedBox(height: 12),
        // Log button
        FilledButton.tonal(
          onPressed: () => _showLogFamacha(),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 18),
              SizedBox(width: 6),
              Text('Log Famacha Score'),
            ],
          ),
        ),
        if (_famacha.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Score History',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          ..._famacha.map((e) => _famachaHistoryRow(e as Map<String, dynamic>)),
        ],
        if (_famacha.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 32),
            child: Center(child: Text('No FAMACHA scores recorded',
              style: TextStyle(color: Colors.grey))),
          ),
      ],
    );
  }

  Widget _latestFamachaCard(Map<String, dynamic> scan) {
    final score = scan['score'] as int? ?? 0;
    final color = _famachaColor(score);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Center(
                child: Text('$score',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Latest Score', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(_famachaLabel(score),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                  Text(scan['scan_date']?.toString() ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  if (scan['notes'] != null && scan['notes'].toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(scan['notes'],
                        style: const TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            ),
            _famachaActionChip(score),
          ],
        ),
      ),
    );
  }

  Widget _famachaHistoryRow(Map<String, dynamic> scan) {
    final score = scan['score'] as int? ?? 0;
    final color = _famachaColor(score);
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
          child: Center(
            child: Text('$score',
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ),
        ),
        title: Text(_famachaLabel(score),
          style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 13)),
        subtitle: scan['notes'] != null && scan['notes'].toString().isNotEmpty
            ? Text(scan['notes'], style: const TextStyle(fontSize: 12)) : null,
        trailing: Text(scan['scan_date']?.toString() ?? '',
          style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ),
    );
  }

  Widget _famachaActionChip(int score) {
    if (score <= 2) return const SizedBox.shrink();
    final urgent = score >= 4;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: urgent ? Colors.red.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: urgent ? Colors.red.shade200 : Colors.orange.shade200),
      ),
      child: Text(
        urgent ? 'Treat Now' : 'Monitor',
        style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: urgent ? Colors.red.shade700 : Colors.orange.shade700,
        ),
      ),
    );
  }

  Color _famachaColor(int score) {
    switch (score) {
      case 1: return Colors.green;
      case 2: return Colors.lightGreen;
      case 3: return Colors.orange;
      case 4: return Colors.deepOrange;
      case 5: return Colors.red;
      default: return Colors.grey;
    }
  }

  String _famachaLabel(int score) {
    switch (score) {
      case 1: return 'Score 1 — Healthy';
      case 2: return 'Score 2 — Acceptable';
      case 3: return 'Score 3 — Monitor';
      case 4: return 'Score 4 — Treat';
      case 5: return 'Score 5 — Treat Urgently';
      default: return 'Score $score';
    }
  }

  void _showLogFamacha() {
    int _score = 1;
    final _notesCtrl = TextEditingController();
    DateTime _date = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
              )),
              const SizedBox(height: 16),
              const Text('Log FAMACHA Score',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('1 = Healthy (red), 5 = Severely anaemic (white)',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 16),
              // Score selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (i) {
                  final s = i + 1;
                  final color = _famachaColor(s);
                  final selected = _score == s;
                  return GestureDetector(
                    onTap: () => setModal(() => _score = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: selected ? 54 : 46,
                      height: selected ? 54 : 46,
                      decoration: BoxDecoration(
                        color: selected ? color : color.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: selected ? 3 : 1),
                      ),
                      child: Center(
                        child: Text('$s',
                          style: TextStyle(
                            fontSize: selected ? 22 : 18,
                            fontWeight: FontWeight.bold,
                            color: selected ? Colors.white : color,
                          )),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Center(child: Text(_famachaLabel(_score),
                style: TextStyle(color: _famachaColor(_score), fontWeight: FontWeight.w600))),
              const SizedBox(height: 16),
              // Date
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text('${_date.month}/${_date.day}/${_date.year}'),
                trailing: const Icon(Icons.calendar_today, size: 18),
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (d != null) setModal(() => _date = d);
                },
              ),
              const Divider(),
              const SizedBox(height: 8),
              TextField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'Condition, treatment given...',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    try {
                      await ApiService.post('/health/famacha', {
                        'animal_id': _animal!['id'],
                        'scan_date': '${_date.year}-${_date.month.toString().padLeft(2,'0')}-${_date.day.toString().padLeft(2,'0')}',
                        'score': _score,
                        if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
                      });
                      if (mounted) {
                        Navigator.pop(ctx);
                        _loadFamacha();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                      }
                    }
                  },
                  child: const Text('Save Score'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'vaccination': return Colors.blue;
      case 'treatment': return Colors.orange;
      case 'checkup': return Colors.green;
      case 'injury': return Colors.red;
      case 'drench': return Colors.purple;
      case 'birth': return Colors.pink;
      default: return Colors.grey;
    }
  }

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'vaccination': return Icons.vaccines;
      case 'treatment': return Icons.medical_services_outlined;
      case 'checkup': return Icons.monitor_heart_outlined;
      case 'injury': return Icons.healing_outlined;
      case 'drench': return Icons.water_drop_outlined;
      case 'birth': return Icons.child_friendly_outlined;
      default: return Icons.health_and_safety_outlined;
    }
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  // ── Progeny Tab ────────────────────────────────────────────────────────────

  Widget _progenyTab() {
    if (_loadingProgeny) return const Center(child: CircularProgressIndicator());
    if (_progeny.isEmpty) return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.family_restroom, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('No offspring recorded', style: TextStyle(color: Colors.grey)),
        ]),
      ),
    );
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _progeny.length,
      itemBuilder: (_, i) => _progenyCard(_progeny[i] as Map<String, dynamic>),
    );
  }

  Widget _progenyCard(Map<String, dynamic> p) {
    final tag = p['tag_number']?.toString() ?? '?';
    final name = p['name']?.toString() ?? '';
    final title = name.isNotEmpty ? '$name ($tag)' : tag;
    final sex = p['sex']?.toString() ?? '';
    final dob = p['date_of_birth']?.toString() ?? '';
    final status = p['status']?.toString() ?? '';
    final birthType = p['birth_type']?.toString() ?? '';
    final birthWeight = p['birth_weight_kg'];
    final role = p['parent_role']?.toString() ?? '';

    final statusColor = status == 'active' ? Colors.green
        : status == 'sold' ? Colors.blue : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF3a6b35).withOpacity(0.1),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Text(tag.substring(0, tag.length.clamp(0, 4)),
                style: const TextStyle(color: Color(0xFF3a6b35),
                  fontWeight: FontWeight.bold, fontSize: 11)),
            ),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${p['breed'] ?? ''} · ${sex.isNotEmpty ? sex : ''}'.trim().replaceAll(RegExp(r'^·\s*|·\s*$'), ''),
              style: const TextStyle(fontSize: 11)),
            if (dob.isNotEmpty) Text('Born: $dob', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Row(children: [
              if (birthType.isNotEmpty) _smallBadge(birthType, Colors.blue),
              if (birthWeight != null) ...[
                const SizedBox(width: 4),
                _smallBadge('${birthWeight}kg', Colors.teal),
              ],
              if (role == 'sire') ...[
                const SizedBox(width: 4),
                _smallBadge('via sire', Colors.purple),
              ],
            ]),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600)),
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _smallBadge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
  );

  // ── Shearing Tab ───────────────────────────────────────────────────────────

  Widget _shearingTab() {
    if (_loadingShearing) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FilledButton.tonal(
          onPressed: () => _showLogShearing(),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 18),
              SizedBox(width: 6),
              Text('Log Shearing'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_shearing.isEmpty)
          const Center(child: Text('No shearing records', style: TextStyle(color: Colors.grey)))
        else
          ..._shearing.map((r) => _shearingCard(r as Map<String, dynamic>)),
      ],
    );
  }

  Widget _shearingCard(Map<String, dynamic> r) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF3a6b35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.content_cut, color: Color(0xFF3a6b35), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r['shearing_date']?.toString() ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (r['fleece_weight_kg'] != null)
                      Text('${r['fleece_weight_kg']} kg',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3a6b35))),
                  ],
                ),
                if (r['staple_length_mm'] != null)
                  Text('Staple: ${r['staple_length_mm']} mm', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                if (r['fibre_diameter_micron'] != null)
                  Text('Fibre: ${r['fibre_diameter_micron']} micron', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                if (r['wool_quality_notes'] != null && r['wool_quality_notes'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(r['wool_quality_notes'], style: const TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  void _showLogShearing() {
    DateTime _date = DateTime.now();
    final _weightCtrl = TextEditingController();
    final _stapleCtrl = TextEditingController();
    final _fibreCtrl = TextEditingController();
    final _notesCtrl = TextEditingController();

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
              Center(child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('Log Shearing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Shearing Date *'),
                subtitle: Text('${_date.month}/${_date.day}/${_date.year}'),
                trailing: const Icon(Icons.calendar_today, size: 18),
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx, initialDate: _date,
                    firstDate: DateTime(2000), lastDate: DateTime.now());
                  if (d != null) setModal(() => _date = d);
                },
              ),
              const Divider(),
              const SizedBox(height: 8),
              TextField(controller: _weightCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Fleece Weight (kg)', suffixText: 'kg')),
              const SizedBox(height: 12),
              TextField(controller: _stapleCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Staple Length (mm)', suffixText: 'mm')),
              const SizedBox(height: 12),
              TextField(controller: _fibreCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Fibre Diameter (micron)', suffixText: 'µm')),
              const SizedBox(height: 12),
              TextField(controller: _notesCtrl, maxLines: 2,
                decoration: const InputDecoration(labelText: 'Wool Quality Notes')),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    try {
                      final fmt = (DateTime d) =>
                        '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
                      await ApiService.post('/health/shearing', {
                        'animal_id': _animal!['id'],
                        'shearing_date': fmt(_date),
                        if (_weightCtrl.text.isNotEmpty) 'fleece_weight_kg': double.tryParse(_weightCtrl.text),
                        if (_stapleCtrl.text.isNotEmpty) 'staple_length_mm': double.tryParse(_stapleCtrl.text),
                        if (_fibreCtrl.text.isNotEmpty) 'fibre_diameter_micron': double.tryParse(_fibreCtrl.text),
                        if (_notesCtrl.text.isNotEmpty) 'wool_quality_notes': _notesCtrl.text.trim(),
                      });
                      if (mounted) { Navigator.pop(ctx); _loadShearing(); }
                    } catch (e) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                    }
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Quick Actions FAB ─────────────────────────────────────────────────────────

class _QuickActionsFab extends StatefulWidget {
  final Map<String, dynamic> animal;
  final bool showFamacha;
  final bool showBreeding;
  final VoidCallback onLogged;

  const _QuickActionsFab({
    required this.animal,
    required this.showFamacha,
    required this.showBreeding,
    required this.onLogged,
  });

  @override
  State<_QuickActionsFab> createState() => _QuickActionsFabState();
}

class _QuickActionsFabState extends State<_QuickActionsFab>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_open) ...[
          _miniAction('Log Health Event', Icons.health_and_safety_outlined, Colors.blue, _logHealth),
          const SizedBox(height: 8),
          _miniAction('Record Weight', Icons.monitor_weight_outlined, Colors.teal, _logWeight),
          if (widget.showFamacha) ...[
            const SizedBox(height: 8),
            _miniAction('Log Famacha', Icons.remove_red_eye_outlined, Colors.purple, _logFamacha),
          ],
          const SizedBox(height: 12),
        ],
        FloatingActionButton(
          heroTag: 'fab_detail',
          onPressed: _toggle,
          backgroundColor: const Color(0xFF3a6b35),
          child: AnimatedRotation(
            turns: _open ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _miniAction(String label, IconData icon, Color color, VoidCallback onTap) =>
    ScaleTransition(
      scale: _scale,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            heroTag: label,
            onPressed: () { _toggle(); onTap(); },
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ],
      ),
    );

  void _logHealth() {
    final eventTypes = ['checkup', 'vaccination', 'treatment', 'injury', 'drench', 'other'];
    String _type = 'checkup';
    DateTime _date = DateTime.now();
    final _productCtrl = TextEditingController();
    final _doseCtrl = TextEditingController();
    final _notesCtrl = TextEditingController();

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
              Text('Log Health Event — ${widget.animal['tag_number'] ?? ''}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Event Type'),
                items: eventTypes.map((t) => DropdownMenuItem(value: t,
                  child: Text(t[0].toUpperCase() + t.substring(1)))).toList(),
                onChanged: (v) => setModal(() => _type = v!),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text('${_date.month}/${_date.day}/${_date.year}'),
                trailing: const Icon(Icons.calendar_today, size: 18),
                onTap: () async {
                  final d = await showDatePicker(context: ctx, initialDate: _date,
                    firstDate: DateTime(2000), lastDate: DateTime.now());
                  if (d != null) setModal(() => _date = d);
                },
              ),
              const Divider(),
              TextField(controller: _productCtrl,
                decoration: const InputDecoration(labelText: 'Product / Medication')),
              const SizedBox(height: 10),
              TextField(controller: _doseCtrl,
                decoration: const InputDecoration(labelText: 'Dose')),
              const SizedBox(height: 10),
              TextField(controller: _notesCtrl, maxLines: 2,
                decoration: const InputDecoration(labelText: 'Notes')),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final fmt = (DateTime d) =>
                      '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
                    try {
                      await ApiService.post('/health/events', {
                        'animal_id': widget.animal['id'],
                        'event_type': _type,
                        'event_date': fmt(_date),
                        if (_productCtrl.text.isNotEmpty) 'product_name': _productCtrl.text.trim(),
                        if (_doseCtrl.text.isNotEmpty) 'dose': _doseCtrl.text.trim(),
                        if (_notesCtrl.text.isNotEmpty) 'notes': _notesCtrl.text.trim(),
                      });
                      if (mounted) { Navigator.pop(ctx); widget.onLogged(); }
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

  void _logWeight() {
    final _weightCtrl = TextEditingController();
    final _notesCtrl = TextEditingController();
    DateTime _date = DateTime.now();

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
              Text('Record Weight — ${widget.animal['tag_number'] ?? ''}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              TextField(controller: _weightCtrl, keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Weight (kg) *', suffixText: 'kg')),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text('${_date.month}/${_date.day}/${_date.year}'),
                trailing: const Icon(Icons.calendar_today, size: 18),
                onTap: () async {
                  final d = await showDatePicker(context: ctx, initialDate: _date,
                    firstDate: DateTime(2000), lastDate: DateTime.now());
                  if (d != null) setModal(() => _date = d);
                },
              ),
              TextField(controller: _notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes (optional)')),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (_weightCtrl.text.isEmpty) return;
                    final fmt = (DateTime d) =>
                      '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
                    try {
                      await ApiService.post('/health/weights', {
                        'animal_id': widget.animal['id'],
                        'weight_kg': double.parse(_weightCtrl.text),
                        'record_date': fmt(_date),
                        if (_notesCtrl.text.isNotEmpty) 'notes': _notesCtrl.text.trim(),
                      });
                      if (mounted) { Navigator.pop(ctx); widget.onLogged(); }
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

  void _logFamacha() {
    int _score = 1;
    final _notesCtrl = TextEditingController();
    DateTime _date = DateTime.now();
    final famachaColors = [Colors.green, Colors.lightGreen, Colors.orange, Colors.deepOrange, Colors.red];
    final famachaLabels = ['Healthy', 'Acceptable', 'Monitor', 'Treat', 'Treat Urgently'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text('Famacha Score — ${widget.animal['tag_number'] ?? ''}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (i) {
                  final s = i + 1;
                  final color = famachaColors[i];
                  final selected = _score == s;
                  return GestureDetector(
                    onTap: () => setModal(() => _score = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: selected ? 52 : 44,
                      height: selected ? 52 : 44,
                      decoration: BoxDecoration(
                        color: selected ? color : color.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: selected ? 3 : 1),
                      ),
                      child: Center(child: Text('$s', style: TextStyle(
                        fontSize: selected ? 20 : 16,
                        fontWeight: FontWeight.bold,
                        color: selected ? Colors.white : color))),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 6),
              Center(child: Text('${famachaLabels[_score - 1]}',
                style: TextStyle(color: famachaColors[_score - 1], fontWeight: FontWeight.w600))),
              const SizedBox(height: 12),
              TextField(controller: _notesCtrl, maxLines: 2,
                decoration: const InputDecoration(labelText: 'Notes (optional)')),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final fmt = (DateTime d) =>
                      '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
                    try {
                      await ApiService.post('/health/famacha', {
                        'animal_id': widget.animal['id'],
                        'scan_date': fmt(_date),
                        'score': _score,
                        if (_notesCtrl.text.isNotEmpty) 'notes': _notesCtrl.text.trim(),
                      });
                      if (mounted) { Navigator.pop(ctx); widget.onLogged(); }
                    } catch (e) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                    }
                  },
                  child: const Text('Save Score'),
                )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Weight Chart ──────────────────────────────────────────────────────────────

class _WeightChart extends StatelessWidget {
  final List<dynamic> weights;
  const _WeightChart({required this.weights});

  @override
  Widget build(BuildContext context) {
    final sorted = [...weights];
    sorted.sort((a, b) {
      final da = DateTime.tryParse((a as Map)['record_date']?.toString() ?? '') ?? DateTime(0);
      final db = DateTime.tryParse((b as Map)['record_date']?.toString() ?? '') ?? DateTime(0);
      return da.compareTo(db);
    });

    final values = sorted.map((w) {
      final v = (w as Map)['weight_kg'] ?? w['weight'];
      return (v as num?)?.toDouble() ?? 0.0;
    }).toList();

    if (values.length < 2) return const SizedBox.shrink();

    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final isGain = values.last >= values.first;
    final diff = (values.last - values.first).abs();
    final color = isGain ? Colors.green : Colors.red;
    final unit = (sorted.last as Map)['weight_kg'] != null ? 'kg' : 'lbs';

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Weight Trend',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Row(children: [
                  Icon(isGain ? Icons.trending_up : Icons.trending_down, color: color, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${isGain ? '+' : '-'}${diff.toStringAsFixed(1)} $unit',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
                  ),
                ]),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: CustomPaint(
                painter: _LinePainter(values: values, minVal: minVal, maxVal: maxVal, color: color),
                size: Size.infinite,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_shortDate((sorted.first as Map)['record_date']),
                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
                Text('${values.length} records',
                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
                Text(_shortDate((sorted.last as Map)['record_date']),
                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _shortDate(dynamic d) {
    try {
      final dt = DateTime.parse(d.toString());
      return '${dt.month}/${dt.day}/${dt.year.toString().substring(2)}';
    } catch (_) { return ''; }
  }
}

class _LinePainter extends CustomPainter {
  final List<double> values;
  final double minVal, maxVal;
  final Color color;

  const _LinePainter({required this.values, required this.minVal, required this.maxVal, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final range = maxVal - minVal;
    final effectiveRange = range < 0.1 ? 1.0 : range;
    final vPad = effectiveRange * 0.2;

    double xOf(int i) => i / (values.length - 1) * size.width;
    double yOf(double v) => size.height * (1 - (v - minVal + vPad) / (effectiveRange + 2 * vPad));

    // Fill under line
    final fill = Path();
    fill.moveTo(xOf(0), size.height);
    for (int i = 0; i < values.length; i++) fill.lineTo(xOf(i), yOf(values[i]));
    fill.lineTo(xOf(values.length - 1), size.height);
    fill.close();
    canvas.drawPath(fill, Paint()..color = color.withOpacity(0.08)..style = PaintingStyle.fill);

    // Line
    final line = Path();
    line.moveTo(xOf(0), yOf(values[0]));
    for (int i = 1; i < values.length; i++) line.lineTo(xOf(i), yOf(values[i]));
    canvas.drawPath(line, Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);

    // Dots with white fill
    final dotFill = Paint()..color = Colors.white;
    final dotStroke = Paint()..color = color;
    for (int i = 0; i < values.length; i++) {
      final pt = Offset(xOf(i), yOf(values[i]));
      canvas.drawCircle(pt, 4, dotFill);
      canvas.drawCircle(pt, 3, dotStroke);
    }

    // Max label
    final maxI = values.indexOf(maxVal);
    _drawLabel(canvas, size, xOf(maxI), yOf(maxVal) - 14,
      maxVal.toStringAsFixed(1), color);
    // Min label (if different point)
    final minI = values.indexOf(minVal);
    if (minI != maxI) {
      _drawLabel(canvas, size, xOf(minI), yOf(minVal) + 6,
        minVal.toStringAsFixed(1), Colors.grey.shade500);
    }
  }

  void _drawLabel(Canvas canvas, Size size, double x, double y, String text, Color color) {
    final tp = TextPainter(
      text: TextSpan(text: text,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 50);
    final dx = (x - tp.width / 2).clamp(0.0, size.width - tp.width);
    final dy = y.clamp(0.0, size.height - tp.height);
    tp.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(_LinePainter old) => old.values != values;
}
