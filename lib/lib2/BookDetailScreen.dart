import 'package:flutter/material.dart';
import 'CatalogScreen.dart'; // impor model Book dari CatalogScreen

class BookDetailScreen extends StatelessWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    // Dummy tambahan (karena di model Book belum ada field ini)
    final String imagePath = 'assets/books/default_cover.jpg'; // pastikan file ini ada
    const String price = 'Rp 89.000';
    const String rating = '4.8';
    const String description =
        'Buku ini membahas topik "${'"'}" dengan gaya yang mudah dipahami dan mendalam. '
        'Cocok untuk pembaca yang ingin memperluas wawasan di bidang terkait.';

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Gambar buku
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 250,
                  color: book.coverColor,
                  child: Center(
                    child: Text(
                      book.title.split(' ').map((w) => w[0]).join(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Judul & penulis
          Text(
            book.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'by ${book.author}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 10),

          // Harga dan rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                price,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 18),
                  const SizedBox(width: 4),
                  const Text(rating),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Deskripsi
          Text(
            description,
            textAlign: TextAlign.justify,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 30),

          // Tombol aksi
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Buku "${book.title}" ditambahkan ke keranjang!'),
                ),
              );
            },
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Tambahkan ke Keranjang'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Rekomendasi buku serupa
          const Text(
            'Rekomendasi Serupa',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 180,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildRecommendedCard('Ikigai', 'assets/books/ikigai.jpg'),
                _buildRecommendedCard(
                    'The Power of Now', 'assets/books/power_of_now.jpg'),
                _buildRecommendedCard(
                    'Start with Why', 'assets/books/start_with_why.jpg'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedCard(String title, String imagePath) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              height: 120,
              width: 90,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 120,
                width: 90,
                color: Colors.grey.shade300,
                child: const Icon(Icons.book, size: 40, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 90,
            child: Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
