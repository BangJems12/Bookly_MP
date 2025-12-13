// API umum
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // untuk desktop
import 'package:path/path.dart';

class DBHelper {
  /// Inisialisasi database
  static Future<Database> initDB() async {
    // NOTE: SQLite via sqflite_common_ffi is only available on desktop (non-web).
    // Avoid calling `databaseFactory` on web where it is not initialized.
    if (kIsWeb) {
      throw UnsupportedError(
        'Local SQLite is not supported on web. Use Supabase as persistence on web.',
      );
    }

    // Pastikan databaseFactory sudah di-set di main.dart (sqfliteFfiInit/databaseFactoryFfi)
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
    // On web, we don't use local SQLite — skip and rely on Supabase
    if (kIsWeb) {
      print('⚠️ insertBook skipped on web (use Supabase for persistence).');
      return;
    }

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
    if (kIsWeb) {
      // On web, return empty list — recommend using Supabase to fetch books
      print('⚠️ getBooks on web: returning empty list. Use Supabase for data.');
      return <Map<String, dynamic>>[];
    }

    final db = await initDB();
    final result = await db.query('books', orderBy: 'created_at DESC');
    print('📚 Jumlah buku: ${result.length}');
    return result;
  }

  /// Update buku
  static Future<void> updateBook(Map<String, dynamic> data) async {
    if (kIsWeb) {
      print('⚠️ updateBook skipped on web. Use Supabase for updates.');
      return;
    }

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
    if (kIsWeb) {
      print('⚠️ deleteBook skipped on web. Use Supabase for deletions.');
      return;
    }

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
    if (kIsWeb) {
      print('⚠️ clearBooks skipped on web.');
      return;
    }

    final db = await initDB();
    final count = await db.delete('books');
    print('🗑️ Berhasil hapus semua buku ($count record)');
  }
}
