import 'package:flutter/material.dart';

class PeminjamanScreen extends StatelessWidget {
  const PeminjamanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data sederhana
    final peminjamanAktif = [
      {'judul': 'Flutter UI Design', 'penulis': 'Flutter Dev', 'warna': Colors.green},
      {'judul': 'Dart Programming', 'penulis': 'Google', 'warna': Colors.blueGrey},
      {'judul': 'Web Development', 'penulis': 'Tim Berners-Lee', 'warna': Colors.blue},
    ];

    final riwayatPeminjaman = [
      {'judul': 'Mobile App Design', 'penulis': 'UI Expert', 'warna': Colors.orange},
    ];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Peminjaman Digital 📖'),
          backgroundColor: const Color(0xFF2E7D32),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Aktif', icon: Icon(Icons.book)),
              Tab(text: 'Riwayat', icon: Icon(Icons.history)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab Peminjaman Aktif
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: peminjamanAktif.length,
              itemBuilder: (context, index) {
                final item = peminjamanAktif[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 70,
                      decoration: BoxDecoration(
                        color: item['warna'] as Color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          (item['judul'] as String).split(' ').map((w) => w[0]).join(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    title: Text(item['judul'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item['penulis'] as String),
                    trailing: const Icon(Icons.access_time, color: Colors.green),
                  ),
                );
              },
            ),

            // Tab Riwayat
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: riwayatPeminjaman.length,
              itemBuilder: (context, index) {
                final item = riwayatPeminjaman[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 70,
                      decoration: BoxDecoration(
                        color: (item['warna'] as Color).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          (item['judul'] as String).split(' ').map((w) => w[0]).join(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    title: Text(item['judul'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['penulis'] as String),
                        const SizedBox(height: 4),
                        const Row(
                          children: [
                            Icon(Icons.check_circle, size: 14, color: Colors.green),
                            SizedBox(width: 4),
                            Text(
                              'Sudah dikembalikan',
                              style: TextStyle(fontSize: 12, color: Colors.green),
                            ),
                          ],
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
