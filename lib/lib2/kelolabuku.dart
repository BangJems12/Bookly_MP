import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'editbuku.dart';

class KelolaBukuScreen extends StatefulWidget {
  const KelolaBukuScreen({super.key});

  @override
  State<KelolaBukuScreen> createState() => _KelolaBukuScreenState();
}

class _KelolaBukuScreenState extends State<KelolaBukuScreen> {
  /// Fungsi hapus buku
  Future<void> hapusBuku(String id, String judul) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: Text("Yakin ingin menghapus buku \"$judul\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Check for peminjaman that reference this book
        final refs = await Supabase.instance.client
            .from('peminjaman')
            .select('id')
            .eq('book_id', id);

        final List? refsList = refs as List?;
        if (refsList != null && refsList.isNotEmpty) {
          final count = refsList.length;
          // Ask the user whether to delete related peminjaman as well
          final deleteRefs = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Referensi Ditemukan"),
              content: Text(
                "Terdapat $count peminjaman yang merujuk buku ini.\nApakah Anda ingin menghapus semua peminjaman terkait lalu menghapus buku?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Batal"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    "Hapus semua",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );

          if (deleteRefs != true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Penghapusan dibatalkan")),
            );
            return;
          }

          // Delete related peminjaman first
          try {
            await Supabase.instance.client
                .from('peminjaman')
                .delete()
                .eq('book_id', id);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Gagal menghapus peminjaman terkait: $e")),
            );
            return;
          }
        }

        // Now delete the book
        final deleted = await Supabase.instance.client
            .from('books')
            .delete()
            .eq('id', id)
            .select();

        final List? deletedList = deleted as List?;
        if (deletedList != null && deletedList.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Buku \"$judul\" berhasil dihapus")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Tidak ada buku dengan id $id")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal menghapus: $e")));
      }
    }
  }

  /// Fungsi lihat detail buku
  void lihatDetail(Map<String, dynamic> buku) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(buku['judul']),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Penulis: ${buku['penulis'] ?? '-'}"),
            Text("Tahun: ${buku['tahun'] ?? '-'}"),
            Text("Genre: ${buku['genre'] ?? '-'}"),
            Text("Status: ${buku['status'] ?? '-'}"),
            Text("Ditambahkan: ${buku['created_at'] ?? '-'}"),
            Text("ID: ${buku['id']}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Buku'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: _BookSearchDelegate());
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client
            .from('books')
            .stream(primaryKey: ['id'])
            .order('created_at'),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final bukuList = snapshot.data!;
          if (bukuList.isEmpty)
            return const Center(child: Text('Belum ada buku'));

          return Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.7,
              ),
              itemCount: bukuList.length,
              itemBuilder: (context, index) {
                final buku = bukuList[index];
                final cover = buku['cover_url'] as String?;
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10),
                          ),
                          child: cover != null && cover.isNotEmpty
                              ? Image.network(
                                  cover,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _fallbackCover(buku),
                                )
                              : _fallbackCover(buku),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              buku['judul'] ?? '-',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              buku['penulis'] ?? '-',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.visibility,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  onPressed: () => lihatDetail(buku),
                                  tooltip: 'Lihat Detail',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            EditBukuScreen(buku: buku),
                                      ),
                                    );
                                    // Stream will automatically update if result is true
                                    if (result == true) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Buku berhasil diperbarui',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  tooltip: 'Edit Buku',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      hapusBuku(buku['id'], buku['judul']),
                                  tooltip: 'Hapus Buku',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _fallbackCover(Map<String, dynamic> buku) {
    final title = (buku['judul'] ?? '').toString();
    return Container(
      color: Colors.green.shade400,
      child: Center(
        child: Text(
          title.isNotEmpty ? title[0] : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _BookSearchDelegate extends SearchDelegate<String> {
  _BookSearchDelegate() : super(searchFieldLabel: 'Cari buku...');

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // basic result: show query text
    return Center(child: Text('Cari: "$query" — reload halaman untuk filter'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(child: Text('Ketik untuk mencari buku...'));
  }
}
