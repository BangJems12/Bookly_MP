import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookly - Beranda'),
        backgroundColor: const Color(0xFF2E7D32),
        automaticallyImplyLeading: false, // Hilangkan tombol back di home screen
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Selamat Datang di Bookly",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "Akses koleksi buku digital Anda.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Tombol utama ke Katalog
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigasi ke CatalogScreen
                    Navigator.pushNamed(context, "/catalog");
                  },
                  icon: const Icon(Icons.book, color: Colors.white),
                  label: const Text(
                    "Lihat Katalog Buku",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Tombol ke Profil
              TextButton.icon(
                onPressed: () {
                  // Navigasi ke ProfileScreen
                  Navigator.pushNamed(context, "/profile");
                },
                icon: const Icon(Icons.person),
                label: const Text("Pengaturan Profil"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}