import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      appBar: AppBar(title: const Text("Kelola Buku")),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client
            .from('books')
            .stream(primaryKey: ['id'])
            .order('created_at'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final bukuList = snapshot.data!;
          if (bukuList.isEmpty) {
            return const Center(child: Text("Belum ada buku"));
          }

          return ListView.builder(
            itemCount: bukuList.length,
            itemBuilder: (context, index) {
              final buku = bukuList[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.book),
                  title: Text(buku['judul']),
                  subtitle: Text(
                    "${buku['penulis'] ?? '-'} • ${buku['tahun'] ?? '-'} • ${buku['genre'] ?? '-'}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.blue),
                        onPressed: () => lihatDetail(buku),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => hapusBuku(buku['id'], buku['judul']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
