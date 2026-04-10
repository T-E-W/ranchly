import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'animal_detail_screen.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  List<dynamic> _events = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  String? _error;
  String _search = '';
  String? _filterType;

  List<String> get _types => _events
      .map((e) => (e['event_type'] ?? '').toString())
      .where((s) => s.isNotEmpty)
      .toSet().toList()..sort();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.get('/health/events/all') as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _events = data;
        _applyFilters();
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  void _applyFilters() {
    final q = _search.toLowerCase();
    _filtered = _events.where((e) {
      if (q.isNotEmpty) {
        final tag = (e['animal_tag'] ?? '').toString().toLowerCase();
        final name = (e['animal_name'] ?? '').toString().toLowerCase();
        final notes = (e['notes'] ?? '').toString().toLowerCase();
        if (!tag.contains(q) && !name.contains(q) && !notes.contains(q)) return false;
      }
      if (_filterType != null &&
          (e['event_type'] ?? '').toString().toLowerCase() != _filterType!.toLowerCase()) return false;
      return true;
    }).toList();
  }

  Future<void> _openAnimal(Map<String, dynamic> event) async {
    final animalId = event['animal_id'];
    if (animalId == null) return;
    try {
      final animal = await ApiService.get('/animals/$animalId') as Map<String, dynamic>;
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => AnimalDetailScreen(animal: animal, onUpdated: _load),
      ));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final hasFilter = _filterType != null;
    final title = _loading
        ? 'Health Log'
        : 'Health Log (${_filtered.length}${_events.length != _filtered.length ? '/${_events.length}' : ''})';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (hasFilter)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              onPressed: () => setState(() { _filterType = null; _applyFilters(); }),
            ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_health',
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => HealthEventFormScreen(onSaved: _load),
        )),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by tag, animal name, notes...',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
              onChanged: (q) => setState(() { _search = q; _applyFilters(); }),
            ),
          ),
          if (!_loading && _types.isNotEmpty) _filterRow(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _errorView()
                    : _filtered.isEmpty
                        ? Center(child: Text(hasFilter || _search.isNotEmpty
                            ? 'No events match your filters'
                            : 'No health events recorded'))
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                              itemCount: _filtered.length,
                              itemBuilder: (_, i) => _eventCard(_filtered[i]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _filterRow() => SizedBox(
    height: 42,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      children: _types.map((t) {
        final selected = _filterType == t;
        final color = _typeColor(t);
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: FilterChip(
            label: Text(_capitalize(t)),
            selected: selected,
            selectedColor: color.withOpacity(0.2),
            checkmarkColor: color,
            labelStyle: TextStyle(
              fontSize: 12,
              color: selected ? color : null,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
            onSelected: (_) => setState(() {
              _filterType = selected ? null : t;
              _applyFilters();
            }),
          ),
        );
      }).toList(),
    ),
  );

  Widget _eventCard(Map<String, dynamic> e) {
    final type = e['event_type'] ?? '';
    final typeColor = _typeColor(type);
    final tag = e['animal_tag']?.toString();
    final name = e['animal_name']?.toString();
    final animalLabel = name != null && name.isNotEmpty
        ? '$name ($tag)'
        : tag != null ? 'Tag $tag' : null;
    final hasAnimal = e['animal_id'] != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: hasAnimal ? () => _openAnimal(e) : null,
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_typeIcon(type), color: typeColor, size: 20),
        ),
        title: Row(
          children: [
            Text(_capitalize(type),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            if (e['product_name'] != null && e['product_name'].toString().isNotEmpty) ...[
              const SizedBox(width: 6),
              Flexible(
                child: Text('· ${e['product_name']}',
                  style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.grey),
                  overflow: TextOverflow.ellipsis),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (animalLabel != null)
              Row(children: [
                const Icon(Icons.pets, size: 11, color: Colors.grey),
                const SizedBox(width: 3),
                Text(animalLabel,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
                if (hasAnimal)
                  const Padding(
                    padding: EdgeInsets.only(left: 2),
                    child: Icon(Icons.chevron_right, size: 12, color: Colors.grey)),
              ]),
            if (e['notes'] != null && (e['notes'] as String).isNotEmpty)
              Text(e['notes'], style: const TextStyle(fontSize: 12),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: Text(
          _formatDate(e['event_date'] ?? e['created_at'] ?? ''),
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        isThreeLine: animalLabel != null &&
            e['notes'] != null && (e['notes'] as String).isNotEmpty,
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

  String _formatDate(String s) {
    if (s.isEmpty) return '';
    try {
      final d = DateTime.parse(s);
      return '${d.month}/${d.day}/${d.year}';
    } catch (_) { return s; }
  }

  Widget _errorView() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
      const SizedBox(height: 12),
      Text(_error ?? 'Failed to load'),
      const SizedBox(height: 16),
      FilledButton(onPressed: _load, child: const Text('Retry')),
    ]),
  );
}

// ── Health Event Form ─────────────────────────────────────────────────────────

class HealthEventFormScreen extends StatefulWidget {
  final VoidCallback onSaved;
  const HealthEventFormScreen({super.key, required this.onSaved});

  @override
  State<HealthEventFormScreen> createState() => _HealthEventFormScreenState();
}

class _HealthEventFormScreenState extends State<HealthEventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesCtrl = TextEditingController();
  final _medicationCtrl = TextEditingController();
  String _eventType = 'checkup';
  DateTime _date = DateTime.now();
  bool _saving = false;
  Map<String, dynamic>? _selectedAnimal;

  List<dynamic> _animals = [];
  final _types = ['checkup', 'vaccination', 'treatment', 'drench', 'injury', 'birth', 'other'];

  @override
  void initState() {
    super.initState();
    ApiService.get('/animals/').then((data) {
      if (mounted) setState(() => _animals = data as List<dynamic>);
    });
  }

  @override
  void dispose() {
    _notesCtrl.dispose(); _medicationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final body = {
      'event_type': _eventType,
      'event_date': _date.toIso8601String().split('T').first,
      if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
      if (_selectedAnimal != null) 'animal_id': _selectedAnimal!['id'],
      if (_medicationCtrl.text.trim().isNotEmpty) 'product_name': _medicationCtrl.text.trim(),
    };
    try {
      await ApiService.post('/health/events', body);
      if (!mounted) return;
      widget.onSaved();
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Health Event')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Animal selector
            DropdownButtonFormField<Map<String, dynamic>>(
              value: _selectedAnimal,
              decoration: const InputDecoration(
                labelText: 'Animal (optional)',
                prefixIcon: Icon(Icons.pets_outlined),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('— No specific animal —')),
                ..._animals.map((a) {
                  final tag = a['tag_number']?.toString() ?? '';
                  final name = a['name']?.toString() ?? '';
                  final label = name.isNotEmpty ? '$name ($tag)' : tag;
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: a as Map<String, dynamic>,
                    child: Text(label, overflow: TextOverflow.ellipsis),
                  );
                }),
              ],
              onChanged: (v) => setState(() => _selectedAnimal = v),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _eventType,
              decoration: const InputDecoration(labelText: 'Event Type'),
              items: _types.map((t) => DropdownMenuItem(value: t,
                child: Text(t[0].toUpperCase() + t.substring(1)))).toList(),
              onChanged: (v) => setState(() => _eventType = v!),
            ),
            const SizedBox(height: 14),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text('${_date.month}/${_date.day}/${_date.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const Divider(),
            const SizedBox(height: 8),
            TextFormField(
              controller: _medicationCtrl,
              decoration: const InputDecoration(labelText: 'Product / Vaccine (optional)'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
