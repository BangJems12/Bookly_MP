import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



// ✅ Import semua screen
import 'package:projekkuliahsemester5/lib2/kelolabuku.dart';
import 'package:projekkuliahsemester5/lib2/loginadmin.dart';
import 'package:projekkuliahsemester5/lib2/tambahbuku.dart';
import 'lib2/HomeScreen.dart';
import 'lib2/LoginScreen.dart';
import 'lib2/RegisterScreen.dart';
import 'lib2/LupaPasswordScreen.dart';
import 'lib2/ProfileScreen.dart';
import 'lib2/CatalogScreen.dart';
import 'lib2/PeminjamanScreen.dart';
import 'lib2/admin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Inisialisasi SQLite untuk desktop


  // ✅ Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://seyiwzagcxhlujayekru.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNleWl3emFnY3hobHVqYXlla3J1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMzODQxMTMsImV4cCI6MjA3ODk2MDExM30._LWPT8401HB4UlRJyz-CMpk6wjyJjT5WUA8UUHEhm6s',
  );

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
        useMaterial3: true,
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

        // ✅ Admin routes
        "/loginadmin": (context) => const LoginAdminScreen(),
        "/admin": (context) => const AdminScreen(),
        "/tambahbuku": (context) => const TambahBukuScreen(),
        "/kelolabuku": (context) => const KelolaBukuScreen(),
      },
    );
  }
}