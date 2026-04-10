import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'animal_detail_screen.dart';

class AnimalsScreen extends StatefulWidget {
  const AnimalsScreen({super.key});

  @override
  State<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> {
  List<dynamic> _animals = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  String? _error;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.get('/animals/') as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _animals = data;
        _filtered = data;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  void _filter(String q) {
    setState(() {
      _search = q;
      _filtered = q.isEmpty
          ? _animals
          : _animals.where((a) =>
              (a['tag_number'] ?? '').toString().toLowerCase().contains(q.toLowerCase()) ||
              (a['name'] ?? '').toString().toLowerCase().contains(q.toLowerCase()) ||
              (a['species'] ?? '').toString().toLowerCase().contains(q.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animals'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_animals',
        onPressed: () => _showAddAnimal(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by tag, name, species...',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
              onChanged: _filter,
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _errorView()
                    : _filtered.isEmpty
                        ? const Center(child: Text('No animals found'))
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                              itemCount: _filtered.length,
                              itemBuilder: (_, i) => _animalCard(_filtered[i]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _animalCard(Map<String, dynamic> a) {
    final statusColor = a['status'] == 'active' ? Colors.green
        : a['status'] == 'sold' ? Colors.blue
        : Colors.grey;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF3a6b35).withOpacity(0.1),
          child: Text(
            (a['tag_number'] ?? '?').toString().substring(0, (a['tag_number'] ?? '?').toString().length.clamp(0, 2)),
            style: const TextStyle(color: Color(0xFF3a6b35), fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        title: Text(
          a['name'] != null && (a['name'] as String).isNotEmpty
              ? '${a['name']} (${a['tag_number']})'
              : a['tag_number'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${a['species'] ?? ''} · ${a['breed'] ?? ''}'.trim().replaceAll(RegExp(r'^·\s*|·\s*$'), '')),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(a['status'] ?? '',
            style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
        ),
        onTap: () => _showAnimalDetail(context, a),
      ),
    );
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

  void _showAnimalDetail(BuildContext context, Map<String, dynamic> animal) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AnimalDetailScreen(animal: animal, onUpdated: _load),
    ));
  }


  void _showAddAnimal(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AnimalFormScreen(onSaved: _load),
    ));
  }
}

// ── Animal Form ──────────────────────────────────────────────────────────────

class AnimalFormScreen extends StatefulWidget {
  final Map<String, dynamic>? animal;
  final VoidCallback onSaved;

  const AnimalFormScreen({super.key, this.animal, required this.onSaved});

  @override
  State<AnimalFormScreen> createState() => _AnimalFormScreenState();
}

class _AnimalFormScreenState extends State<AnimalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tag, _name, _breed, _weight, _notes;
  String _species = 'Sheep';
  String _gender = 'Female';
  String _status = 'active';
  bool _saving = false;

  final _speciesList = ['Sheep', 'Goat', 'Cattle', 'Pig', 'Horse', 'Chicken', 'Other'];
  final _genderList = ['Female', 'Male'];
  final _statusList = ['active', 'sold', 'deceased', 'archived'];

  @override
  void initState() {
    super.initState();
    final a = widget.animal;
    _tag = TextEditingController(text: a?['tag_number'] ?? '');
    _name = TextEditingController(text: a?['name'] ?? '');
    _breed = TextEditingController(text: a?['breed'] ?? '');
    _weight = TextEditingController(text: a?['weight']?.toString() ?? '');
    _notes = TextEditingController(text: a?['notes'] ?? '');
    if (a != null) {
      final rawSpecies = a['species']?.toString() ?? '';
      _species = _speciesList.firstWhere(
        (s) => s.toLowerCase() == rawSpecies.toLowerCase(),
        orElse: () => _speciesList.last,
      );
      final rawGender = a['gender']?.toString() ?? '';
      _gender = _genderList.firstWhere(
        (g) => g.toLowerCase() == rawGender.toLowerCase(),
        orElse: () => _genderList.first,
      );
      final rawStatus = a['status']?.toString() ?? '';
      _status = _statusList.firstWhere(
        (s) => s.toLowerCase() == rawStatus.toLowerCase(),
        orElse: () => _statusList.first,
      );
    }
  }

  @override
  void dispose() {
    _tag.dispose(); _name.dispose(); _breed.dispose();
    _weight.dispose(); _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final body = {
      'tag_number': _tag.text.trim(),
      'name': _name.text.trim(),
      'species': _species,
      'gender': _gender,
      'breed': _breed.text.trim(),
      'status': _status,
      if (_weight.text.trim().isNotEmpty) 'weight': double.tryParse(_weight.text.trim()),
      if (_notes.text.trim().isNotEmpty) 'notes': _notes.text.trim(),
    };
    try {
      if (widget.animal != null) {
        await ApiService.put('/animals/${widget.animal!['id']}', body);
      } else {
        await ApiService.post('/animals/', body);
      }
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
    final isEdit = widget.animal != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Animal' : 'Add Animal')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field('Tag Number', _tag, required: true),
            _field('Name', _name),
            _dropdown('Species', _species, _speciesList, (v) => setState(() => _species = v!)),
            _dropdown('Gender', _gender, _genderList, (v) => setState(() => _gender = v!)),
            _field('Breed', _breed),
            if (isEdit) _dropdown('Status', _status, _statusList, (v) => setState(() => _status = v!)),
            _field('Weight (lbs)', _weight, keyboardType: TextInputType.number),
            _field('Notes', _notes, maxLines: 3),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(isEdit ? 'Save Changes' : 'Add Animal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {bool required = false, TextInputType? keyboardType, int maxLines = 1}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        validator: required ? (v) => v == null || v.isEmpty ? 'Required' : null : null,
      ),
    );

  Widget _dropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
}
