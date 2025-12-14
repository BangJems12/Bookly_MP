class Book {
  final String id; // ✅ tambahkan id
  final String judul;
  final String penulis;
  final String? tahun;
  final String? genre;
  final String? status;
  final String? coverUrl;
  final double? harga;

  Book({
    required this.id,
    required this.judul,
    required this.penulis,
    this.tahun,
    this.genre,
    this.status,
    this.coverUrl,
    this.harga,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'].toString(), // ✅ id bisa UUID, jadi aman pakai toString()
      judul: json['judul'] ?? '-',
      penulis: json['penulis'] ?? '-',
      tahun: json['tahun']?.toString(),
      genre: json['genre'],
      status: json['status'],
      coverUrl: json['cover_url'], // ✅ ambil dari kolom cover_url di Supabase
      harga: json['harga'] != null
          ? double.tryParse(json['harga'].toString())
          : (json['price'] != null
                ? double.tryParse(json['price'].toString())
                : null),
    );
  }
}
