import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _stats;
  List<dynamic> _alerts = [];
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
      ]);
      if (!mounted) return;
      final statsRaw = results[0];
      final alertsRaw = results[1];
      setState(() {
        _stats = statsRaw is Map<String, dynamic> ? statsRaw : {};
        _alerts = alertsRaw is List ? alertsRaw : [];
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
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
                      const SizedBox(height: 16),
                      if (_alerts.isNotEmpty) ...[
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
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));

  Widget _alertCard(dynamic alert) {
    final severity = alert['severity'] ?? 'info';
    final color = severity == 'critical' ? Colors.red
        : severity == 'warning' ? Colors.orange
        : Colors.blue;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.circle, color: color, size: 12),
        title: Text(alert['message'] ?? '', style: const TextStyle(fontSize: 14)),
        subtitle: alert['animal_tag'] != null
            ? Text(alert['animal_tag'], style: const TextStyle(fontSize: 12))
            : null,
      ),
    );
  }
}

class _StatItem {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatItem(this.label, this.value, this.icon, this.color);
}
