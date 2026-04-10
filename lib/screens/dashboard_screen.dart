import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'animal_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _stats;
  List<dynamic> _alerts = [];
  List<dynamic> _dueTasks = [];
  Map<String, int> _herd = {};
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
      final results = await Future.wait([
        ApiService.get('/dashboard/stats'),
        ApiService.get('/dashboard/alerts'),
        ApiService.get('/tasks/'),
        ApiService.get('/animals/'),
      ]);
      if (!mounted) return;
      final today = _todayStr();
      setState(() {
        _stats = results[0] is Map<String, dynamic> ? results[0] as Map<String, dynamic> : {};
        _alerts = results[1] is List ? results[1] as List : [];
        final allTasks = results[2] is List ? results[2] as List : [];
        _dueTasks = allTasks.where((t) {
          if (t['completed'] == true) return false;
          final due = t['due_date'] as String?;
          return due == null || due.compareTo(today) <= 0;
        }).toList();
        final allAnimals = results[3] is List ? results[3] as List : [];
        final herd = <String, int>{};
        for (final a in allAnimals) {
          if ((a as Map)['status'] != 'active') continue;
          final s = (a['species'] ?? 'Unknown').toString();
          herd[s] = (herd[s] ?? 0) + 1;
        }
        _herd = Map.fromEntries(
          herd.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  String _todayStr() {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
  }

  Future<void> _toggleTask(Map<String, dynamic> task) async {
    final newVal = !(task['completed'] == true);
    setState(() => task['completed'] = newVal);
    try {
      await ApiService.patch('/tasks/${task['id']}/complete', {'completed': newVal});
      if (mounted) _load();
    } catch (_) {
      if (mounted) setState(() => task['completed'] = !newVal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranchly'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _errorView()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_stats != null) _statsGrid(),
                      if (_herd.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _sectionHeader('Active Herd'),
                        const SizedBox(height: 8),
                        _herdCard(),
                      ],
                      if (_dueTasks.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _sectionHeader('Due & Overdue Tasks'),
                            Text('${_dueTasks.length} pending',
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ..._dueTasks.take(5).map(_dueTaskRow),
                        if (_dueTasks.length > 5)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('+${_dueTasks.length - 5} more — check Tasks tab',
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ),
                      ],
                      if (_alerts.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _sectionHeader('Alerts'),
                        const SizedBox(height: 8),
                        ..._alerts.map(_alertCard),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _errorView() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
        const SizedBox(height: 12),
        Text(_error ?? 'Failed to load', textAlign: TextAlign.center),
        const SizedBox(height: 16),
        FilledButton(onPressed: _load, child: const Text('Retry')),
      ]),
    ),
  );

  Widget _statsGrid() {
    final s = _stats!;
    final items = [
      _StatItem('Total Animals', '${s['total_animals'] ?? 0}', Icons.pets, const Color(0xFF3a6b35)),
      _StatItem('Tasks Due', '${s['tasks_due_today'] ?? 0}', Icons.checklist, Colors.orange),
      _StatItem('Health Events', '${s['health_events_30d'] ?? 0}', Icons.health_and_safety, Colors.blue),
      _StatItem('Overdue Tasks', '${s['tasks_overdue'] ?? 0}', Icons.warning_amber, Colors.red),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: items.map(_statCard).toList(),
    );
  }

  Widget _statCard(_StatItem item) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(item.icon, color: item.color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(item.label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _sectionHeader(String title) => Text(title,
    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold));

  Widget _dueTaskRow(dynamic task) {
    final t = task as Map<String, dynamic>;
    final due = t['due_date'] as String?;
    final today = _todayStr();
    final isOverdue = due != null && due.compareTo(today) < 0;
    final priority = t['priority'] ?? 'normal';
    final priorityColor = priority == 'high' ? Colors.red
        : priority == 'medium' ? Colors.orange
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: Checkbox(
          value: t['completed'] == true,
          onChanged: (_) => _toggleTask(t),
          activeColor: const Color(0xFF3a6b35),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        title: Text(t['title'] ?? 'Task',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: priorityColor,
          ),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
        subtitle: due != null
          ? Text(isOverdue ? 'Overdue: $due' : 'Due: $due',
              style: TextStyle(fontSize: 11,
                color: isOverdue ? Colors.red : Colors.grey,
                fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal))
          : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _herdCard() {
    final total = _herd.values.fold(0, (a, b) => a + b);
    final colors = [
      const Color(0xFF3a6b35), Colors.blue, Colors.orange,
      Colors.purple, Colors.teal, Colors.red, Colors.brown,
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: _herd.entries.toList().asMap().entries.map((entry) {
            final i = entry.key;
            final species = entry.value.key;
            final count = entry.value.value;
            final pct = total > 0 ? count / total : 0.0;
            final color = colors[i % colors.length];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(species, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      Text('$count  (${(pct * 100).toStringAsFixed(0)}%)',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _alertCard(dynamic alert) {
    final severity = alert['severity'] ?? 'info';
    final color = severity == 'critical' ? Colors.red
        : severity == 'warning' ? Colors.orange
        : Colors.blue;
    final hasAnimal = alert['animal_id'] != null;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: hasAnimal ? () => _openAnimal(alert['animal_id']) : null,
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: color.withOpacity(0.12),
          child: Icon(
            severity == 'critical' ? Icons.warning_rounded
                : severity == 'warning' ? Icons.info_outline
                : Icons.notifications_none,
            color: color, size: 18),
        ),
        title: Text(alert['message'] ?? '', style: const TextStyle(fontSize: 14)),
        subtitle: alert['animal_tag'] != null
            ? Row(children: [
                Text(alert['animal_tag'], style: const TextStyle(fontSize: 12)),
                if (hasAnimal) const Icon(Icons.chevron_right, size: 14, color: Colors.grey),
              ])
            : null,
      ),
    );
  }

  Future<void> _openAnimal(dynamic animalId) async {
    try {
      final animal = await ApiService.get('/animals/$animalId') as Map<String, dynamic>;
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => AnimalDetailScreen(animal: animal, onUpdated: _load),
      ));
    } catch (_) {}
  }
}


class _StatItem {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatItem(this.label, this.value, this.icon, this.color);
}
