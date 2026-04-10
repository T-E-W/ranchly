import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  List<dynamic> _events = [];
  bool _loading = true;
  String? _error;

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
      setState(() { _events = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Log'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_health',
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => HealthEventFormScreen(onSaved: _load),
        )),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _errorView()
              : _events.isEmpty
                  ? const Center(child: Text('No health events recorded'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                        itemCount: _events.length,
                        itemBuilder: (_, i) => _eventCard(_events[i]),
                      ),
                    ),
    );
  }

  Widget _eventCard(Map<String, dynamic> e) {
    final typeColor = _typeColor(e['event_type'] ?? '');
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_typeIcon(e['event_type'] ?? ''), color: typeColor, size: 20),
        ),
        title: Text(
          _capitalize(e['event_type'] ?? 'Event'),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (e['animal_tag'] != null) Text('Tag: ${e['animal_tag']}', style: const TextStyle(fontSize: 12)),
            if (e['notes'] != null && (e['notes'] as String).isNotEmpty)
              Text(e['notes'], style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: Text(
          _formatDate(e['event_date'] ?? e['created_at'] ?? ''),
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        isThreeLine: e['notes'] != null && (e['notes'] as String).isNotEmpty,
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'vaccination': return Colors.blue;
      case 'treatment': return Colors.orange;
      case 'checkup': return Colors.green;
      case 'injury': return Colors.red;
      case 'birth': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'vaccination': return Icons.vaccines;
      case 'treatment': return Icons.medical_services_outlined;
      case 'checkup': return Icons.monitor_heart_outlined;
      case 'injury': return Icons.healing_outlined;
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
  final _tagCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _medicationCtrl = TextEditingController();
  String _eventType = 'checkup';
  DateTime _date = DateTime.now();
  bool _saving = false;

  List<dynamic> _animals = [];

  final _types = ['checkup', 'vaccination', 'treatment', 'injury', 'birth', 'other'];

  @override
  void initState() {
    super.initState();
    ApiService.get('/animals/').then((data) {
      if (mounted) setState(() => _animals = data as List<dynamic>);
    });
  }

  @override
  void dispose() {
    _tagCtrl.dispose(); _notesCtrl.dispose(); _medicationCtrl.dispose();
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
    // Find animal ID from tag
    final animal = _animals.firstWhere(
      (a) => a['tag_number'] == _tagCtrl.text.trim(),
      orElse: () => null,
    );
    final body = {
      'event_type': _eventType,
      'event_date': _date.toIso8601String().split('T').first,
      'notes': _notesCtrl.text.trim(),
      if (animal != null) 'animal_id': animal['id'],
      if (_medicationCtrl.text.trim().isNotEmpty) 'medication': _medicationCtrl.text.trim(),
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
            // Animal tag autocomplete
            Autocomplete<String>(
              optionsBuilder: (v) {
                if (v.text.isEmpty) return const [];
                return _animals
                    .map((a) => a['tag_number'] as String)
                    .where((t) => t.toLowerCase().contains(v.text.toLowerCase()));
              },
              onSelected: (v) => _tagCtrl.text = v,
              fieldViewBuilder: (_, ctrl, focusNode, __) => TextFormField(
                controller: ctrl,
                focusNode: focusNode,
                decoration: const InputDecoration(labelText: 'Animal Tag *'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onChanged: (v) => _tagCtrl.text = v,
              ),
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
              decoration: const InputDecoration(labelText: 'Medication / Vaccine (optional)'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Notes'),
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
