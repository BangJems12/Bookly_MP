import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
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

  // File upload variables
  PlatformFile? selectedFile;
  bool isUploading = false;

  final List<String> years = List.generate(
    30,
    (index) => (2000 + index).toString(),
  ); // 2000–2029
  final List<String> genres = [
    'Fiksi',
    'Non-Fiksi',
    'Sejarah',
    'Teknologi',
    'Sains',
    'Biografi',
  ];
  final List<String> statuses = ['Tersedia', 'Tidak Tersedia'];

  /// Pick file for cover image
  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          selectedFile = result.files.first;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error picking file: $e")));
    }
  }

  /// Upload file to Supabase storage
  Future<String?> uploadFile() async {
    if (selectedFile == null) return null;

    // Ensure the user is authenticated — storage INSERT policy requires authenticated
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login sebelum mengunggah file')),
      );
      return null;
    }

    try {
      setState(() => isUploading = true);

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${selectedFile!.name}';
      final filePath = 'book_covers/$fileName';

      // For web, use bytes; for mobile, use File
      if (kIsWeb) {
        await Supabase.instance.client.storage
            .from('covers') // upload to original bucket covers
            .uploadBinary(filePath, selectedFile!.bytes!);
      } else {
        final file = File(selectedFile!.path!);
        await Supabase.instance.client.storage
            .from('covers')
            .upload(filePath, file);
      }

      // Get public URL
      final publicUrl = Supabase.instance.client.storage
          .from('covers')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error uploading file: $e")));
      return null;
    } finally {
      setState(() => isUploading = false);
    }
  }

  /// Simpan data buku ke Supabase + SQLite
  Future<void> tambahBuku() async {
    if (judulController.text.trim().isEmpty ||
        penulisController.text.trim().isEmpty ||
        selectedYear == null ||
        selectedGenre == null ||
        selectedStatus == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua field wajib diisi")));
      return;
    }

    String? coverUrl;

    // Upload file if selected
    if (selectedFile != null) {
      coverUrl = await uploadFile();
      coverUrl ??= coverController.text.trim().isEmpty
          ? null
          : coverController.text.trim();
    } else {
      // Use manual URL
      coverUrl = coverController.text.trim().isEmpty
          ? null
          : coverController.text.trim();
    }

    final data = {
      'judul': judulController.text.trim(),
      'penulis': penulisController.text.trim(),
      'tahun': int.tryParse(selectedYear!),
      'genre': selectedGenre,
      'status': selectedStatus, // status = Tersedia / Tidak Tersedia
      'cover_url': coverUrl,
    };

    try {
      // Insert to Supabase and get the inserted data with ID
      final response = await Supabase.instance.client
          .from('books')
          .insert(data)
          .select()
          .single();

      // Use the response data (which includes the generated ID) for SQLite
      await DBHelper.insertBook(response);

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
        selectedFile = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
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
              decoration: const InputDecoration(labelText: "Judul"),
            ),
            TextField(
              controller: penulisController,
              decoration: const InputDecoration(labelText: "Penulis"),
            ),
            DropdownButtonFormField<String>(
              initialValue: selectedYear,
              items: years
                  .map(
                    (year) => DropdownMenuItem(value: year, child: Text(year)),
                  )
                  .toList(),
              onChanged: (val) => setState(() => selectedYear = val),
              decoration: const InputDecoration(labelText: "Tahun Terbit"),
            ),
            DropdownButtonFormField<String>(
              initialValue: selectedGenre,
              items: genres
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (val) => setState(() => selectedGenre = val),
              decoration: const InputDecoration(labelText: "Genre"),
            ),
            DropdownButtonFormField<String>(
              initialValue: selectedStatus,
              items: statuses
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => setState(() => selectedStatus = val),
              decoration: const InputDecoration(labelText: "Status"),
            ),
            TextField(
              controller: coverController,
              decoration: const InputDecoration(
                labelText: "Cover URL (opsional)",
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: pickFile,
                    icon: const Icon(Icons.file_upload),
                    label: const Text("Pilih File Cover"),
                  ),
                ),
              ],
            ),
            if (selectedFile != null) ...[
              const SizedBox(height: 10),
              Text("File dipilih: ${selectedFile!.name}"),
              Text(
                "Ukuran: ${(selectedFile!.size / 1024).toStringAsFixed(2)} KB",
              ),
            ],
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: isUploading ? null : tambahBuku,
              child: isUploading
                  ? const CircularProgressIndicator()
                  : const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }
}
