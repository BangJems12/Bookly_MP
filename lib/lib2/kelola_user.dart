import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KelolaUserScreen extends StatefulWidget {
  const KelolaUserScreen({super.key});

  @override
  State<KelolaUserScreen> createState() => _KelolaUserScreenState();
}

class _KelolaUserScreenState extends State<KelolaUserScreen> {
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loading = true;
      _error = null;
      _users = [];
    });

    final supabase = Supabase.instance.client;
    bool fetched = false;
    String? friendlyError;

    try {
      // Try common application table first (recommended: `profiles` or `users`)
      try {
        final res = await supabase
            .from('users')
            .select('id, email, role, status, last_sign_in, created_at')
            .order('created_at', ascending: false);

        final List? resList = res as List?;
        if (resList != null && resList.isNotEmpty) {
          setState(() => _users = List<Map<String, dynamic>>.from(resList));
          fetched = true;
          return;
        }
      } catch (_) {
        // ignore and try auth.users next
      }

      // Try auth.users as a fallback, but this is often restricted by RLS
      try {
        final res2 = await supabase
            .from('auth.users')
            .select('id, email, raw_user_meta_data, created_at');

        final List? res2List = res2 as List?;
        if (res2List != null && res2List.isNotEmpty) {
          setState(() => _users = List<Map<String, dynamic>>.from(res2List));
          fetched = true;
          return;
        }
      } catch (e) {
        final s = e.toString();
        if (s.contains('Could not find the table') ||
            s.contains('PGRST205') ||
            s.contains('auth.users')) {
          friendlyError =
              'Tidak dapat mengakses auth.users dari client. Buat tabel `profiles` di schema publik atau gunakan server-side endpoint dengan service_role untuk melihat daftar pengguna.';
        } else {
          friendlyError = s;
        }
      }
    } finally {
      setState(() {
        _loading = false;
        if (!fetched) _error = friendlyError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _users.length;
    final active = _users.where((u) {
      if (u.containsKey('status')) {
        final s = (u['status'] ?? '').toString().toLowerCase();
        return s == 'aktif' || s == 'active';
      }
      // fallback: consider presence of created_at as active
      return u.containsKey('created_at');
    }).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola User')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : RefreshIndicator(
              onRefresh: _loadUsers,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  Card(
                    child: ListTile(
                      title: const Text('Total pengguna'),
                      trailing: Text('$total'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Pengguna aktif (heuristik)'),
                      trailing: Text('$active'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Daftar pengguna',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._users.map((u) => _buildUserTile(u)),
                  if (_users.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(
                        child: Text('Belum ada pengguna terdaftar'),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> u) {
    final id = u['id']?.toString() ?? '-';
    final email =
        u['email']?.toString() ?? u['raw_user_meta_data']?.toString() ?? '-';
    final role = u['role']?.toString() ?? '-';
    final status = u['status']?.toString() ?? '-';
    final created = u['created_at']?.toString() ?? '-';

    return Card(
      child: ListTile(
        title: Text(email),
        subtitle: Text('ID: $id\nRole: $role • Status: $status'),
        isThreeLine: true,
        trailing: Text(created.split('T').first),
      ),
    );
  }
}
