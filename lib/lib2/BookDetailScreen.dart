import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Book.dart';
import 'PeminjamanScreen.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  Future<void> _pinjamBuku(BuildContext context) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Silakan login terlebih dahulu")),
        );
        return;
      }

      final bool isFree = (book.harga == null || (book.harga ?? 0) <= 0);
      final status = isFree ? 'Aktif' : 'Proses';

      await supabase.from('peminjaman').insert({
        'user_id': user.id,
        'book_id': book.id,
        'status': status,
        'harga': book.harga,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFree
                ? 'Berhasil meminjam "${book.judul}" — gratis!'
                : 'Buku "${book.judul}" masuk ke proses pembayaran!',
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PeminjamanScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memproses peminjaman: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isFree = (book.harga == null || (book.harga ?? 0) <= 0);
    final String price = book.harga != null
        ? _formatPrice(book.harga)
        : 'Gratis';
    const String rating = '4.8';
    final String description =
        'Buku "${book.judul}" membahas topik dengan gaya yang mudah dipahami dan mendalam. '
        'Cocok untuk pembaca yang ingin memperluas wawasan di bidang terkait.';

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(book.judul),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cover
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: book.coverUrl != null
                  ? Image.network(
                      book.coverUrl!,
                      height: 300,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholderCover(),
                    )
                  : _buildPlaceholderCover(),
            ),
          ),
          const SizedBox(height: 20),

          // Info Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.judul,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'by ${book.penulis}',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        price,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Row(
                        children: const [
                          Icon(Icons.star, color: Colors.orange, size: 22),
                          SizedBox(width: 4),
                          Text(
                            rating,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Deskripsi
          Text(
            description,
            textAlign: TextAlign.justify,
            style: const TextStyle(fontSize: 16, height: 1.6),
          ),
          const SizedBox(height: 40),

          // ✅ Tombol pembayaran besar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _pinjamBuku(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                backgroundColor: Colors.transparent,
                shadowColor: Colors.black45,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  height: 60, // ✅ tombol lebih besar
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payment, color: Colors.white, size: 26),
                      const SizedBox(width: 10),
                      Text(
                        isFree ? 'Pinjam Sekarang' : 'Proses Pembayaran',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCover() {
    return Container(
      height: 300,
      color: Colors.green,
      child: const Center(
        child: Icon(Icons.book, size: 64, color: Colors.white),
      ),
    );
  }
}

String _formatPrice(double? p) {
  if (p == null) return '';
  final intPart = p.truncate();
  final frac = ((p - intPart).abs() * 100).round();
  String intStr = intPart.toString();
  intStr = intStr.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
  if (frac == 0) return 'Rp $intStr';
  final fracStr = frac.toString().padLeft(2, '0');
  return 'Rp $intStr,$fracStr';
}
