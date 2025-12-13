import 'package:sqflite_common/sqlite_api.dart';       // API umum
import 'package:sqflite_common_ffi/sqflite_ffi.dart';  // untuk desktop
import 'package:path/path.dart';

class DBHelper {
  /// Inisialisasi database
  static Future<Database> initDB() async {
    // Pastikan databaseFactory sudah di-set di main.dart
    final dbPath = await databaseFactory.getDatabasesPath();
    return await databaseFactory.openDatabase(
      join(dbPath, 'books.db'),
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS books(
              id TEXT PRIMARY KEY,          -- uuid disimpan sebagai TEXT
              judul TEXT NOT NULL,
              penulis TEXT,
              tahun INTEGER,
              genre TEXT,
              status TEXT,
              cover_url TEXT,
              created_at TEXT,
              updated_at TEXT
            )
          ''');
        },
      ),
    );
  }

  /// Insert buku baru
  static Future<void> insertBook(Map<String, dynamic> data) async {
    final db = await initDB();

    // Validasi id
    if (data['id'] == null || (data['id'] as String).isEmpty) {
      throw ArgumentError('Field id wajib diisi (UUID)');
    }

    // Tambahkan created_at jika belum ada
    data['created_at'] ??= DateTime.now().toIso8601String();
    data['updated_at'] ??= DateTime.now().toIso8601String();

    await db.insert(
      'books',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('✅ Berhasil insert buku dengan id: ${data['id']}');
  }

  /// Ambil semua buku
  static Future<List<Map<String, dynamic>>> getBooks() async {
    final db = await initDB();
    final result = await db.query('books', orderBy: 'created_at DESC');
    print('📚 Jumlah buku: ${result.length}');
    return result;
  }

  /// Update buku
  static Future<void> updateBook(Map<String, dynamic> data) async {
    final db = await initDB();

    // Update timestamp otomatis
    data['updated_at'] = DateTime.now().toIso8601String();

    final count = await db.update(
      'books',
      data,
      where: 'id = ?',
      whereArgs: [data['id']],
    );

    if (count == 0) {
      print('⚠️ Tidak ada record dengan id ${data['id']} untuk diupdate');
    } else {
      print('✅ Berhasil update $count record dengan id ${data['id']}');
    }
  }

  /// Hapus buku
  static Future<void> deleteBook(String id) async {
    final db = await initDB();
    final count = await db.delete('books', where: 'id = ?', whereArgs: [id]);

    if (count == 0) {
      print('⚠️ Tidak ada record dengan id $id untuk dihapus');
    } else {
      print('🗑️ Berhasil hapus $count record dengan id $id');
    }
  }

  /// Opsional: hapus semua buku
  static Future<void> clearBooks() async {
    final db = await initDB();
    final count = await db.delete('books');
    print('🗑️ Berhasil hapus semua buku ($count record)');
  }
}