import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:file_picker/file_picker.dart'; // package untuk pilih file

class QRPage extends StatelessWidget {
  const QRPage({super.key});

  @override
  Widget build(BuildContext context) {
    const String transactionData = "PAYMENT:1234567890";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("QR Payment"),
        backgroundColor: Colors.orange,
        centerTitle: true,
        elevation: 4,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Scan QR untuk melakukan pembayaran",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // QR code besar di tengah
            QrImageView(
              data: transactionData,
              version: QrVersions.auto,
              size: 320.0,
              backgroundColor: Colors.white,
            ),

            const SizedBox(height: 40),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
              ),
              onPressed: () async {
                // buka file picker
                FilePickerResult? result = await FilePicker.platform.pickFiles();

                if (result != null) {
                  String fileName = result.files.single.name;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("File '$fileName' berhasil diupload sebagai konfirmasi")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Upload dibatalkan")),
                  );
                }
              },
              icon: const Icon(Icons.upload_file, color: Colors.white),
              label: const Text(
                "Upload Konfirmasi",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}