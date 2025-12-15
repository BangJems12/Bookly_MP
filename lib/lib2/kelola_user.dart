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

    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('profiles')
          .select('user_id, username, email, role, created_at')
          .order('created_at', ascending: false);

      setState(() {
        _users = List<Map<String, dynamic>>.from(response);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // ===================== HAPUS USER =====================
  Future<void> _deleteUser(String userId, String username, String email) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus User"),
        content: Text(
          'Yakin ingin menghapus user "$username" ($email)?\n\n'
          'Peringatan: Data peminjaman user ini juga akan terhapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final supabase = Supabase.instance.client;

        await supabase.from('peminjaman').delete().eq('user_id', userId);
        await supabase.from('bukti_transfer').delete().eq('user_id', userId);
        await supabase.from('profiles').delete().eq('user_id', userId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User "$username" berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );

        _loadUsers();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menghapus user: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ===================== RESPONSIVE =====================
  int _getCrossAxisCount(double width) {
    if (width >= 1400) return 3;
    if (width >= 900) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final total = _users.length;
    final admins = _users.where((u) => u['role'] == 'admin').length;
    final regularUsers = total - admins;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola User', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $_error',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUsers,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUsers,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // ===================== STATISTIK =====================
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: _getCrossAxisCount(screenWidth),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 2.5,
                        children: [
                          _buildStatCard(
                              'Total Pengguna', '$total', Icons.people,
                              Colors.blue),
                          _buildStatCard(
                              'Admin', '$admins',
                              Icons.admin_panel_settings, Colors.orange),
                          _buildStatCard(
                              'User Biasa', '$regularUsers',
                              Icons.person, Colors.green),
                        ],
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Daftar Pengguna',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (_users.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('Belum ada pengguna terdaftar'),
                          ),
                        )
                      else
                        ..._users.map(_buildUserCard),
                    ],
                  ),
                ),
    );
  }

  // ===================== STAT CARD =====================
  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        TextStyle(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===================== USER CARD =====================
  Widget _buildUserCard(Map<String, dynamic> user) {
    final userId = user['user_id']?.toString() ?? '-';
    final username = user['username']?.toString() ?? '-';
    final email = user['email']?.toString() ?? '-';
    final role = user['role']?.toString() ?? 'user';
    final createdAt = user['created_at']?.toString().split('T').first ?? '-';

    final isAdmin = role == 'admin';
    final roleColor = isAdmin ? Colors.orange : Colors.blue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: roleColor.withOpacity(0.1),
                  child: Icon(
                    isAdmin
                        ? Icons.admin_panel_settings
                        : Icons.person,
                    color: roleColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(username,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      Text(email,
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: TextStyle(
                        color: roleColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Terdaftar: $createdAt',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey[600]),
                ),
                TextButton.icon(
                  onPressed: () =>
                      _deleteUser(userId, username, email),
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Hapus'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
