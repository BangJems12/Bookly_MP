import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:flutter/services.dart';

class EditBukuScreen extends StatefulWidget {
  final Map<String, dynamic> buku;

  const EditBukuScreen({super.key, required this.buku});

  @override
  State<EditBukuScreen> createState() => _EditBukuScreenState();
}

class _EditBukuScreenState extends State<EditBukuScreen> {
  late final TextEditingController judulController;
  late final TextEditingController penulisController;
  late final TextEditingController coverController;
  late final TextEditingController hargaController;

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
    'Teknologi',
    'Fiksi',
    'Sejarah',
    'Bisnis',
    'Gaya Hidup',
    'Edukasi',
    'Sastra',
    'Biografi',
  ];
  final List<String> statuses = ['Tersedia', 'Tidak Tersedia'];

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing book data
    judulController = TextEditingController(text: widget.buku['judul'] ?? '');
    penulisController = TextEditingController(
      text: widget.buku['penulis'] ?? '',
    );
    coverController = TextEditingController(
      text: widget.buku['cover_url'] ?? '',
    );

    // Handle harga - convert to string
    final hargaValue = widget.buku['harga'];
    if (hargaValue != null) {
      if (hargaValue is num) {
        hargaController = TextEditingController(text: hargaValue.toString());
      } else {
        hargaController = TextEditingController(text: hargaValue.toString());
      }
    } else {
      hargaController = TextEditingController(text: '0');
    }

    // Set dropdown values - validate they exist in the lists
    final tahunValue = widget.buku['tahun'];
    final tahunStr = tahunValue != null ? tahunValue.toString() : null;
    selectedYear = (tahunStr != null && years.contains(tahunStr))
        ? tahunStr
        : null;

    final genreValue = widget.buku['genre'];
    selectedGenre = (genreValue != null && genres.contains(genreValue))
        ? genreValue
        : null;

    final statusValue = widget.buku['status'];
    selectedStatus = (statusValue != null && statuses.contains(statusValue))
        ? statusValue
        : null;
  }

  @override
  void dispose() {
    judulController.dispose();
    penulisController.dispose();
    coverController.dispose();
    hargaController.dispose();
    super.dispose();
  }

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

    // Ensure the user is authenticated
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
            .from('covers')
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

  /// Update data buku ke Supabase
  Future<void> updateBuku() async {
    if (judulController.text.trim().isEmpty ||
        penulisController.text.trim().isEmpty ||
        hargaController.text.trim().isEmpty ||
        selectedYear == null ||
        selectedGenre == null ||
        selectedStatus == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua field wajib diisi")));
      return;
    }

    // parse harga (allow comma as decimal separator)
    final hargaText = hargaController.text.trim().replaceAll(',', '.');
    final hargaVal = double.tryParse(hargaText);
    if (hargaVal == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Harga tidak valid')));
      return;
    }
    if (hargaVal < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga harus bernilai 0 atau lebih')),
      );
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
      // Use manual URL or keep existing
      coverUrl = coverController.text.trim().isEmpty
          ? null
          : coverController.text.trim();
    }

    final data = {
      'judul': judulController.text.trim(),
      'penulis': penulisController.text.trim(),
      'tahun': int.tryParse(selectedYear!),
      'genre': selectedGenre,
      'status': selectedStatus,
      'cover_url': coverUrl,
      'harga': hargaVal,
    };

    try {
      // Update to Supabase
      await Supabase.instance.client
          .from('books')
          .update(data)
          .eq('id', widget.buku['id']);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Buku berhasil diperbarui")));

      // Go back to previous screen
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Buku")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Edit Buku',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: judulController,
                      decoration: const InputDecoration(
                        labelText: 'Judul',
                        prefixIcon: Icon(Icons.book_outlined),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: penulisController,
                      decoration: const InputDecoration(
                        labelText: 'Penulis',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedYear,
                            items: years
                                .map(
                                  (y) => DropdownMenuItem(
                                    value: y,
                                    child: Text(y),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => selectedYear = v),
                            decoration: const InputDecoration(
                              labelText: 'Tahun',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedGenre,
                            items: genres
                                .map(
                                  (g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(g),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => selectedGenre = v),
                            decoration: const InputDecoration(
                              labelText: 'Genre',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      items: statuses
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedStatus = v),
                      decoration: const InputDecoration(labelText: 'Status'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: coverController,
                      decoration: const InputDecoration(
                        labelText: 'Cover URL (opsional)',
                        prefixIcon: Icon(Icons.image_outlined),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: hargaController,
                      decoration: const InputDecoration(
                        labelText: 'Harga (mis. 25000)',
                        prefixIcon: Icon(Icons.attach_money_outlined),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9\,\.]')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: pickFile,
                          icon: const Icon(Icons.file_upload),
                          label: const Text('Pilih Cover'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: isUploading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: updateBuku,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text('Update Buku'),
                                ),
                        ),
                      ],
                    ),
                    if (selectedFile != null) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: Column(
                          children: [
                            Image.memory(
                              selectedFile!.bytes ?? Uint8List(0),
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              selectedFile!.name,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ] else if (coverController.text.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: Column(
                          children: [
                            Image.network(
                              coverController.text.trim(),
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 120,
                                width: 80,
                                color: Colors.green.shade400,
                                child: const Icon(
                                  Icons.book,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Current Cover',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
