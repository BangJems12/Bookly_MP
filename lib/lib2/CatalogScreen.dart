import 'package:flutter/material.dart';


//Raya Abiathar, 235150400111001 - Tugas Individu

// Dummy data buat katalog
class Book {
  final String title;
  final String author;
  final String genre;
  final Color coverColor;

  Book(this.title, this.author, this.genre, this.coverColor);
}

// Dummy list buat katalog
final List<Book> dummyBooks = [
  Book('Dart Programming', 'Google', 'Teknologi', Colors.blueGrey),
  Book('Flutter UI Design', 'Flutter Dev', 'Desain', Colors.green),
  Book('Sejarah Dunia', 'Herodotus', 'Sejarah', Colors.brown),
  Book('Fiksi Ilmiah Baru', 'A.I. Writer', 'Fiksi', Colors.deepPurple),
  Book('Resep Masakan', 'Chef Juna', 'Gaya Hidup', Colors.orange),
  Book('Ekonomi Modern', 'Keynes', 'Bisnis', Colors.teal),
  Book('Filosofi Hidup', 'Marcus Aurelius', 'Filsafat', Colors.indigo),
  Book('Puisi dan Kata', 'Chairil Anwar', 'Sastra', Colors.pink),
  Book('Web Development', 'Tim Berners-Lee', 'Teknologi', Colors.blue),
  Book('Manajemen Proyek', 'Agile Guru', 'Bisnis', Colors.amber),
  Book('Geometri Lanjut', 'Euclid', 'Edukasi', Colors.lightGreen),
  Book('Astrologi Modern', 'Zodiac Expert', 'Gaya Hidup', Colors.deepOrange),
];

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedGenre = 'Semua';
  List<Book> _filteredBooks = dummyBooks;
  final List<String> genres = ['Semua', 'Teknologi', 'Fiksi', 'Sejarah', 'Bisnis', 'Gaya Hidup', 'Edukasi', 'Sastra'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterBooks);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterBooks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBooks = dummyBooks.where((book) {
        final matchesGenre = _selectedGenre == 'Semua' || book.genre == _selectedGenre;
        final matchesQuery = book.title.toLowerCase().contains(query) ||
            book.author.toLowerCase().contains(query);
        return matchesGenre && matchesQuery;
      }).toList();
    });
  }

  void _selectGenre(String genre) {
    setState(() {
      _selectedGenre = genre;
      _filterBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Bookly 📚'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Cari Judul, Penulis, atau Jurnal...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
          
          // Horizontal Filter (ListView for Categories)
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: genres.length,
              itemBuilder: (context, index) {
                final genre = genres[index];
                final isSelected = genre == _selectedGenre;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    label: Text(genre, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
                    backgroundColor: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade200,
                    onPressed: () => _selectGenre(genre),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF2E7D32) : Colors.grey,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const Divider(height: 20, thickness: 1),

          // Book List (GridView)
          Expanded(
            child: _filteredBooks.isEmpty
                ? const Center(child: Text("Tidak ada buku yang ditemukan."))
                : GridView.builder(
                    padding: const EdgeInsets.all(12.0),
                    // Grid Layout Delegate: 2 columns with fixed size
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Tampilkan 2 buku per baris
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                      childAspectRatio: 0.7, // Rasio Lebar:Tinggi untuk kartu buku
                    ),
                    itemCount: _filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = _filteredBooks[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Book Cover Placeholder
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: book.coverColor,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                ),
                                child: Center(
                                  child: Text(
                                    book.title.split(' ').map((word) => word[0]).join(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Book Details
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    book.author,
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}