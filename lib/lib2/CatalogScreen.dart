import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Book.dart';
import 'BookDetailScreen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<Book> _books = [];
  bool _isLoading = false;
  String _selectedGenre = 'Semua';

  final List<String> genres = [
    'Semua',
    'Teknologi',
    'Fiksi',
    'Sejarah',
    'Bisnis',
    'Gaya Hidup',
    'Edukasi',
    'Sastra'
  ];

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      var queryBuilder = supabase.from('books').select();

      if (_selectedGenre != 'Semua') {
        queryBuilder = queryBuilder.eq('genre', _selectedGenre);
      }

      final List<dynamic> response = await queryBuilder;

      setState(() {
        _books =
            response.map((e) => Book.fromJson(e as Map<String, dynamic>)).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat data: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectGenre(String genre) {
    setState(() {
      _selectedGenre = genre;
    });
    _loadBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Katalog Bookly 📚",  style: TextStyle( color: Colors.white,),),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // 🎭 Horizontal Filter
          SizedBox(
            height: 60,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: genres.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final genre = genres[index];
                final isSelected = genre == _selectedGenre;
                return ChoiceChip(
                  label: Text(
                    genre,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF2E7D32),
                  backgroundColor: Colors.grey.shade200,
                  onSelected: (_) => _selectGenre(genre),
                );
              },
            ),
          ),

          const Divider(height: 20, thickness: 1),

          // 📚 Book List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _books.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.menu_book, size: 80, color: Colors.grey),
                          SizedBox(height: 12),
                          Text("Tidak ada buku yang ditemukan",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(12.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // ✅ tiga kolom
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: _books.length,
                        itemBuilder: (context, index) {
                          final book = _books[index];

                          return InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookDetailScreen(book: book),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // ✅ Cover dari Supabase
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(10)),
                                      child: book.coverUrl != null &&
                                              book.coverUrl!.isNotEmpty
                                          ? Image.network(
                                              book.coverUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  _fallbackCover(book),
                                            )
                                          : _fallbackCover(book),
                                    ),
                                  ),
                                  // Info
                                  Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          book.judul,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          book.penulis,
                                          style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // ✅ Fallback cover jika tidak ada gambar
  Widget _fallbackCover(Book book) {
    return Container(
      color: Colors.green.shade400,
      child: Center(
        child: Text(
          book.judul.isNotEmpty ? book.judul[0] : "?",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}