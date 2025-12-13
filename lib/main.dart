import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
// Initialize sqflite ffi when running on desktop (Windows/macOS/Linux)
// to ensure `databaseFactory` is set before using DB helpers.
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// ✅ Import semua screen
import 'package:Bookly_MP/lib2/kelolabuku.dart';
import 'package:Bookly_MP/lib2/kelola_user.dart';
import 'package:Bookly_MP/lib2/loginadmin.dart';
import 'package:Bookly_MP/lib2/tambahbuku.dart';
import 'package:Bookly_MP/lib2/HomeScreen.dart';
import 'package:Bookly_MP/lib2/LoginScreen.dart';
import 'package:Bookly_MP/lib2/RegisterScreen.dart';
import 'package:Bookly_MP/lib2/LupaPasswordScreen.dart';
import 'package:Bookly_MP/lib2/ProfileScreen.dart';
import 'package:Bookly_MP/lib2/CatalogScreen.dart';
import 'package:Bookly_MP/lib2/PeminjamanScreen.dart';
import 'package:Bookly_MP/lib2/admin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Jika bukan web, inisialisasi sqflite ffi dan set databaseFactory
  if (!kIsWeb) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Inisialisasi Supabase
  try {
    await Supabase.initialize(
      url: 'https://seyiwzagcxhlujayekru.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNleWl3emFnY3hobHVqYXlla3J1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMzODQxMTMsImV4cCI6MjA3ODk2MDExM30._LWPT8401HB4UlRJyz-CMpk6wjyJjT5WUA8UUHEhm6s',
    );
  } catch (e) {
    print('Supabase initialization failed: $e');
    // Continue without Supabase for now
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Projek Perpustakaan',
      theme: ThemeData(
        useMaterial3: false,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
      ),
      initialRoute: "/login",
      routes: {
        // ✅ User routes
        "/login": (context) => const LoginScreen(),
        "/register": (context) => const RegisterScreen(),
        "/lupapassword": (context) => const LupaPasswordScreen(),
        "/profile": (context) => const ProfileScreen(),
        "/home": (context) => const HomeScreen(),
        "/catalog": (context) => const CatalogScreen(),
        "/peminjaman": (context) => const PeminjamanScreen(),
        "/kelola_user": (context) => const KelolaUserScreen(),

        // ✅ Admin routes
        "/loginadmin": (context) => const LoginAdminScreen(),
        "/admin": (context) => const AdminScreen(),
        "/tambahbuku": (context) => const TambahBukuScreen(),
        "/kelolabuku": (context) => const KelolaBukuScreen(),
      },
    );
  }
}
