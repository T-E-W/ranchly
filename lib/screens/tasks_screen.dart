import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  List<dynamic> _tasks = [];
  bool _loading = true;
  String? _error;
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.get('/tasks/') as List<dynamic>;
      if (!mounted) return;
      setState(() { _tasks = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  List<dynamic> _forTab(int tab) {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
    switch (tab) {
      case 0: // Today + overdue
        return _tasks.where((t) {
          if (t['completed'] == true) return false;
          final due = t['due_date'] as String?;
          return due == null || due.compareTo(todayStr) <= 0;
        }).toList();
      case 1: // Upcoming
        return _tasks.where((t) {
          if (t['completed'] == true) return false;
          final due = t['due_date'] as String?;
          return due != null && due.compareTo(todayStr) > 0;
        }).toList();
      case 2: // Done
        return _tasks.where((t) => t['completed'] == true).toList();
      default: return [];
    }
  }

  Future<void> _toggle(Map<String, dynamic> task) async {
    final newVal = !(task['completed'] == true);
    setState(() => task['completed'] = newVal);
    try {
      await ApiService.patch('/tasks/${task['id']}/complete', {'completed': newVal});
    } catch (_) {
      if (mounted) setState(() => task['completed'] = !newVal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Due (${_forTab(0).length})'),
            Tab(text: 'Upcoming (${_forTab(1).length})'),
            const Tab(text: 'Done'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_tasks',
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => TaskFormScreen(onSaved: _load),
        )),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _errorView()
              : TabBarView(
                  controller: _tabs,
                  children: List.generate(3, (i) => _taskList(_forTab(i))),
                ),
    );
  }

  Widget _taskList(List<dynamic> tasks) {
    if (tasks.isEmpty) return const Center(child: Text('Nothing here'));
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
        itemCount: tasks.length,
        itemBuilder: (_, i) => _taskCard(tasks[i]),
      ),
    );
  }

  Widget _taskCard(Map<String, dynamic> t) {
    final done = t['completed'] == true;
    final due = t['due_date'] as String?;
    final isOverdue = !done && due != null && due.compareTo(_todayStr()) < 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: done,
          onChanged: (_) => _toggle(t),
          activeColor: const Color(0xFF3a6b35),
        ),
        title: Text(
          t['title'] ?? 'Task',
          style: TextStyle(
            decoration: done ? TextDecoration.lineThrough : null,
            color: done ? Colors.grey : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (due != null)
              Text(
                'Due: $due',
                style: TextStyle(
                  fontSize: 12,
                  color: isOverdue ? Colors.red : Colors.grey,
                  fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            if (t['notes'] != null && (t['notes'] as String).isNotEmpty)
              Text(t['notes'], style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: _priorityChip(t['priority'] ?? 'normal'),
        isThreeLine: due != null,
      ),
    );
  }

  Widget _priorityChip(String priority) {
    final color = priority == 'high' ? Colors.red
        : priority == 'medium' ? Colors.orange
        : Colors.grey;
    if (priority == 'normal' || priority == 'low') return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(priority, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }

  String _todayStr() {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
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

// ── Task Form ─────────────────────────────────────────────────────────────────

class TaskFormScreen extends StatefulWidget {
  final VoidCallback onSaved;
  const TaskFormScreen({super.key, required this.onSaved});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _priority = 'normal';
  DateTime? _dueDate;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _dueDate = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final body = {
      'title': _titleCtrl.text.trim(),
      'priority': _priority,
      if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
      if (_dueDate != null)
        'due_date': '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2,'0')}-${_dueDate!.day.toString().padLeft(2,'0')}',
    };
    try {
      await ApiService.post('/tasks/', body);
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
      appBar: AppBar(title: const Text('New Task')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Task Title *'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              autofocus: true,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: ['low', 'normal', 'medium', 'high'].map((p) => DropdownMenuItem(
                value: p, child: Text(p[0].toUpperCase() + p.substring(1)))).toList(),
              onChanged: (v) => setState(() => _priority = v!),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Due Date'),
              subtitle: Text(_dueDate == null ? 'No date set'
                  : '${_dueDate!.month}/${_dueDate!.day}/${_dueDate!.year}'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                if (_dueDate != null)
                  IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _dueDate = null)),
                const Icon(Icons.calendar_today),
              ]),
              onTap: _pickDate,
            ),
            const Divider(),
            const SizedBox(height: 8),
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
                  : const Text('Create Task'),
            ),
          ],
        ),
      ),
    );
  }
}
