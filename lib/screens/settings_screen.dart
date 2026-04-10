import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _urlCtrl = TextEditingController();
  final _farmNameCtrl = TextEditingController();
  String _weightUnit = 'lbs';
  bool _saving = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final url = await ApiService.baseUrl;
    if (!mounted) return;
    setState(() {
      _urlCtrl.text = url;
      _farmNameCtrl.text = prefs.getString('farm_name') ?? '';
      _weightUnit = prefs.getString('weight_unit') ?? 'lbs';
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _farmNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      ApiService.setBaseUrl(_urlCtrl.text.trim()),
      prefs.setString('farm_name', _farmNameCtrl.text.trim()),
      prefs.setString('weight_unit', _weightUnit),
    ]);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')));
      setState(() => _saving = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sign Out')),
        ],
      ),
    );
    if (confirm == true) {
      await ApiService.clearToken();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Farm ──────────────────────────────────────────────────────────
          _sectionHeader('Farm'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _farmNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Farm Name',
                      hintText: 'e.g. Sunrise Sheep Station',
                      prefixIcon: Icon(Icons.agriculture_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Weight Unit',
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'lbs', label: Text('lbs'), icon: Icon(Icons.scale_outlined)),
                      ButtonSegment(value: 'kg', label: Text('kg'), icon: Icon(Icons.scale_outlined)),
                    ],
                    selected: {_weightUnit},
                    onSelectionChanged: (s) => setState(() => _weightUnit = s.first),
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Connection ────────────────────────────────────────────────────
          _sectionHeader('Connection'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Backend server URL.',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _urlCtrl,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: 'Server URL',
                      hintText: 'http://192.168.x.x:8000',
                      prefixIcon: Icon(Icons.dns_outlined),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Save ──────────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Settings'),
            ),
          ),
          const SizedBox(height: 20),

          // ── About ─────────────────────────────────────────────────────────
          _sectionHeader('About'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _infoRow('App', 'Ranchly'),
                  _infoRow('Version', '1.0.0'),
                  _infoRow('Platform', 'Flutter'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Danger zone ───────────────────────────────────────────────────
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                  onTap: _logout,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(title,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
        color: Colors.grey.shade600, letterSpacing: 0.5)),
  );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(width: 80,
          child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    ),
  );
}
