// 
import 'package:flutter/material.dart';

class ProductGalleryApp extends StatelessWidget {
  final List<String> categories = ['Terbaru', 'Populer', 'Diskon', 'Pakaian', 'Elektronik', 'Rumah'];
  final int totalProducts = 15;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Toko Sederhana'),
        backgroundColor: Colors.deepOrange,
      ),
      // Widget 'ListView' dan 'GridView' yang sederhana (tanpa CustomScrollView)
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. ListView (Horizontal Scroll) untuk Kategori
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Jelajahi Kategori', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 50, // Tinggi tetap untuk ListView horizontal
              child: ListView.builder(
                // Mengubah arah gulir menjadi horizontal
                scrollDirection: Axis.horizontal, 
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Chip(
                      label: Text(categories[index]),
                      backgroundColor: Colors.deepOrange.shade100,
                    ),
                  );
                },
              ),
            ),

            // Garis pemisah
            Divider(height: 20, thickness: 1),

            // 2. GridView (Nested Scroll) untuk Produk
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Produk Pilihan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            // Menggunakan GridView di dalam SingleChildScrollView memerlukan:
            // 1. physics: NeverScrollableScrollPhysics() agar GridView tidak mencoba scroll
            // 2. shrinkWrap: true agar GridView mengambil tinggi sesuai isinya
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(), // Scroll dikendalikan oleh SingleChildScrollView
              padding: EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 kolom
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.75, // Rasio lebar/tinggi item
              ),
              itemCount: totalProducts,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.grey.shade200, // Placeholder Image
                          child: Center(child: Icon(Icons.shopping_bag, size: 40, color: Colors.deepOrange)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Produk Keren ${index + 1}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                        child: Text(
                          'Rp ${((index + 1) * 100000).toString()}',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Untuk menjalankan, panggil: runApp(MaterialApp(home: ProductGalleryApp()));
