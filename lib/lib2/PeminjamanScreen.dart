import 'package:flutter/material.dart';

class PeminjamanScreen extends StatelessWidget {
  const PeminjamanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy buku yang sedang dipinjam dan riwayat
    final peminjamanAktif = [
      {'judul': 'Flutter UI Design', 'penulis': 'Flutter Dev', 'warna': Colors.green},
      {'judul': 'Dart Programming', 'penulis': 'Google', 'warna': Colors.blueGrey},
      {'judul': 'Web Development', 'penulis': 'Tim Berners-Lee', 'warna': Colors.blue},
      {'judul': 'Mobile App Design', 'penulis': 'UI Expert', 'warna': Colors.orange},
    ];

    final riwayatPeminjaman = [
      {'judul': 'Machine Learning', 'penulis': 'Andrew Ng', 'warna': Colors.purple},
      {'judul': 'Database System', 'penulis': 'Elmasri', 'warna': Colors.teal},
    ];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F5),
        appBar: AppBar(
          title: const Text('Peminjaman Digital 📚'),
          backgroundColor: const Color(0xFF2E7D32),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.book), text: 'Aktif'),
              Tab(icon: Icon(Icons.history), text: 'Riwayat'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // === Halaman Peminjaman Aktif (Grid) ===
            _buildGrid(peminjamanAktif, isHistory: false),
            // === Halaman Riwayat Peminjaman (Grid) ===
            _buildGrid(riwayatPeminjaman, isHistory: true),
          ],
        ),
      ),
    );
  }

  /// Widget grid untuk menampilkan data
  Widget _buildGrid(List<Map<String, dynamic>> data, {required bool isHistory}) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          isHistory ? 'Belum ada riwayat peminjaman' : 'Tidak ada peminjaman aktif',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        itemCount: data.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // jumlah kolom
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.7, // perbandingan lebar : tinggi
        ),
        itemBuilder: (context, index) {
          final item = data[index];
          return _buildBookCard(item, isHistory: isHistory);
        },
      ),
    );
  }

  /// Widget kartu buku
  Widget _buildBookCard(Map<String, dynamic> item, {required bool isHistory}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sampul buku
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: item['warna'] as Color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: Text(
                (item['judul'] as String).split(' ').map((w) => w[0]).join(),
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Detail buku
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['judul'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item['penulis'] as String,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      isHistory ? Icons.check_circle : Icons.access_time,
                      color: isHistory ? Colors.green : Colors.orange,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isHistory ? 'Dikembalikan' : 'Dipinjam',
                      style: TextStyle(
                        fontSize: 12,
                        color: isHistory ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
