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
  String? _filterSpecies;
  String? _filterStatus;

  List<String> get _species => _animals
      .map((a) => (a['species'] ?? '').toString())
      .where((s) => s.isNotEmpty)
      .toSet().toList()..sort();

  List<String> get _statuses => _animals
      .map((a) => (a['status'] ?? '').toString())
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
      final data = await ApiService.get('/animals/') as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _animals = data;
        _applyFilters();
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  void _applyFilters() {
    final q = _search.toLowerCase();
    _filtered = _animals.where((a) {
      if (q.isNotEmpty) {
        final tag = (a['tag_number'] ?? '').toString().toLowerCase();
        final name = (a['name'] ?? '').toString().toLowerCase();
        final species = (a['species'] ?? '').toString().toLowerCase();
        if (!tag.contains(q) && !name.contains(q) && !species.contains(q)) return false;
      }
      if (_filterSpecies != null &&
          (a['species'] ?? '').toString().toLowerCase() != _filterSpecies!.toLowerCase()) return false;
      if (_filterStatus != null &&
          (a['status'] ?? '').toString().toLowerCase() != _filterStatus!.toLowerCase()) return false;
      return true;
    }).toList();
  }

  void _filter(String q) => setState(() { _search = q; _applyFilters(); });

  @override
  Widget build(BuildContext context) {
    final hasFilters = _filterSpecies != null || _filterStatus != null;
    final title = _loading
        ? 'Animals'
        : 'Animals (${_filtered.length}${_animals.length != _filtered.length ? '/${_animals.length}' : ''})';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (hasFilters)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              tooltip: 'Clear filters',
              onPressed: () => setState(() {
                _filterSpecies = null;
                _filterStatus = null;
                _applyFilters();
              }),
            ),
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
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by tag, name, species...',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
              onChanged: _filter,
            ),
          ),
          if (!_loading && _animals.isNotEmpty) _filterRow(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _errorView()
                    : _filtered.isEmpty
                        ? Center(child: Text(hasFilters || _search.isNotEmpty
                            ? 'No animals match your filters'
                            : 'No animals found'))
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                              itemCount: _filtered.length,
                              itemBuilder: (_, i) => _animalCard(_filtered[i]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _filterRow() {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        children: [
          // Status chips
          ..._statuses.map((s) {
            final selected = _filterStatus == s;
            final color = s == 'active' ? Colors.green
                : s == 'sold' ? Colors.blue
                : s == 'deceased' ? Colors.red
                : Colors.grey;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                label: Text(_capitalize(s)),
                selected: selected,
                selectedColor: color.withOpacity(0.2),
                checkmarkColor: color,
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: selected ? color : null,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
                onSelected: (_) => setState(() {
                  _filterStatus = selected ? null : s;
                  _applyFilters();
                }),
              ),
            );
          }),
          // Divider between status and species
          if (_statuses.isNotEmpty && _species.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: VerticalDivider(width: 1),
            ),
          // Species chips
          ..._species.map((s) {
            final selected = _filterSpecies == s;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                label: Text(s),
                selected: selected,
                selectedColor: const Color(0xFF3a6b35).withOpacity(0.15),
                checkmarkColor: const Color(0xFF3a6b35),
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: selected ? const Color(0xFF3a6b35) : null,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
                onSelected: (_) => setState(() {
                  _filterSpecies = selected ? null : s;
                  _applyFilters();
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

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
