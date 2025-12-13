import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'db_helper.dart';

class TambahBukuScreen extends StatefulWidget {
  const TambahBukuScreen({super.key});

  @override
  State<TambahBukuScreen> createState() => _TambahBukuScreenState();
}

class _TambahBukuScreenState extends State<TambahBukuScreen> {
  final judulController = TextEditingController();
  final penulisController = TextEditingController();
  final coverController = TextEditingController();

  String? selectedYear;
  String? selectedGenre;
  String? selectedStatus;

  final List<String> years =
      List.generate(30, (index) => (2000 + index).toString()); // 2000–2029
  final List<String> genres = [
    'Fiksi',
    'Non-Fiksi',
    'Sejarah',
    'Teknologi',
    'Sains',
    'Biografi'
  ];
  final List<String> statuses = [
    'Tersedia',
    'Tidak Tersedia',
  ];

  /// Simpan data buku ke Supabase + SQLite
  Future<void> tambahBuku() async {
    if (judulController.text.trim().isEmpty ||
        penulisController.text.trim().isEmpty ||
        selectedYear == null ||
        selectedGenre == null ||
        selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua field wajib diisi")),
      );
      return;
    }

    final data = {
      'judul': judulController.text.trim(),
      'penulis': penulisController.text.trim(),
      'tahun': int.tryParse(selectedYear!),
      'genre': selectedGenre,
      'status': selectedStatus, // status = Tersedia / Tidak Tersedia
      'cover_url': coverController.text.trim().isEmpty
          ? null
          : coverController.text.trim(),
    };

    try {
      await Supabase.instance.client.from('books').insert(data);
      await DBHelper.insertBook(data);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Buku berhasil ditambahkan")),
      );

      judulController.clear();
      penulisController.clear();
      coverController.clear();
      setState(() {
        selectedYear = null;
        selectedGenre = null;
        selectedStatus = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Buku")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: judulController,
                decoration: const InputDecoration(labelText: "Judul")),
            TextField(
                controller: penulisController,
                decoration: const InputDecoration(labelText: "Penulis")),
            DropdownButtonFormField<String>(
              value: selectedYear,
              items: years
                  .map((year) =>
                      DropdownMenuItem(value: year, child: Text(year)))
                  .toList(),
              onChanged: (val) => setState(() => selectedYear = val),
              decoration: const InputDecoration(labelText: "Tahun Terbit"),
            ),
            DropdownButtonFormField<String>(
              value: selectedGenre,
              items: genres
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (val) => setState(() => selectedGenre = val),
              decoration: const InputDecoration(labelText: "Genre"),
            ),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              items: statuses
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => setState(() => selectedStatus = val),
              decoration: const InputDecoration(labelText: "Status"),
            ),
            TextField(
                controller: coverController,
                decoration: const InputDecoration(labelText: "Cover URL")),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: tambahBuku, child: const Text("Simpan")),
          ],
        ),
      ),
    );
  }
}