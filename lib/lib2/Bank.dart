import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BankPage extends StatefulWidget {
  final String bankName;
  final String peminjamanId; // UUID dari tabel peminjaman
  final String harga; // ✅ harga (text) dikirim dari PeminjamanScreen

  const BankPage({
    super.key,
    required this.bankName,
    required this.peminjamanId,
    required this.harga,
  });

  @override
  State<BankPage> createState() => _BankPageState();
}

class _BankPageState extends State<BankPage> {
  final List<String> steps = const [
    "Buka aplikasi mobile banking / ATM.",
    "Pilih menu Transfer.",
    "Masukkan nomor rekening tujuan.",
    "Masukkan nominal pembayaran.",
    "Konfirmasi detail transaksi.",
    "Simpan bukti transfer.",
  ];

  final String booklyAccountNumber = "010239281233"; // contoh rekening
  final String booklyAccountName = "Perpus Bookly";

  XFile? _selectedImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() => _isUploading = true);
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null || user.id.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "User belum login, tidak bisa upload bukti transfer.",
            ),
          ),
        );
        setState(() => _isUploading = false);
        return;
      }

      // Upload ke Storage
      final bytes = await _selectedImage!.readAsBytes();
      final bankPrefix = widget.bankName.replaceAll(" ", "");
      final fileName =
          "${bankPrefix}_${DateTime.now().millisecondsSinceEpoch}_${_selectedImage!.name}";
      await supabase.storage
          .from('Buktitransfer')
          .uploadBinary(fileName, bytes);
      final fileUrl = supabase.storage
          .from('Buktitransfer')
          .getPublicUrl(fileName);

      // Insert bukti transfer
      await supabase.from('bukti_transfer').insert({
        'file_url': fileUrl,
        'user_id': user.id,
        'peminjaman_id': widget.peminjamanId,
        'bank_name': widget.bankName,
        'jumlah': widget.harga,
      });

      // ✅ Update status peminjaman menjadi 'Aktif' setelah bukti transfer diupload
      await supabase
          .from('peminjaman')
          .update({'status': 'Aktif'})
          .eq('id', widget.peminjamanId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Bukti transfer berhasil diupload & status menjadi Aktif!",
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal upload bukti transfer: $e")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String hargaDisplay = (widget.harga.isEmpty) ? 'Rp -' : widget.harga;

    return Scaffold(
      appBar: AppBar(
        title: Text("Langkah Pembayaran - ${widget.bankName}"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Total pembayaran
          Card(
            color: Colors.teal.shade50,
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.attach_money, color: Colors.teal),
              title: const Text(
                "Total Pembayaran",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                hargaDisplay,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),

          // Rekening tujuan
          Card(
            color: Colors.teal.shade50,
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.account_balance, color: Colors.teal),
              title: const Text(
                "Rekening Tujuan",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "$booklyAccountName\nNo. Rekening: $booklyAccountNumber",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),

          // Langkah transfer
          ...steps.asMap().entries.map((entry) {
            final int index = entry.key;
            final String step = entry.value;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(step, style: const TextStyle(fontSize: 16)),
              ),
            );
          }),

          const SizedBox(height: 20),

          // Pilih bukti transfer
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.upload_file),
            label: const Text("Pilih Bukti Transfer"),
          ),
          const SizedBox(height: 12),

          // Preview + Upload
          if (_selectedImage != null)
            Column(
              children: [
                kIsWeb
                    ? FutureBuilder<Uint8List>(
                        future: _selectedImage!.readAsBytes(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.hasData) {
                            return Image.memory(
                              snapshot.data!,
                              height: 200,
                              fit: BoxFit.cover,
                            );
                          }
                          return const CircularProgressIndicator();
                        },
                      )
                    : Image.file(
                        File(_selectedImage!.path),
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _uploadImage,
                  icon: const Icon(Icons.cloud_upload),
                  label: Text(_isUploading ? "Mengupload..." : "Upload"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
