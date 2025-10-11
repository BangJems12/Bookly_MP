import 'package:flutter/material.dart';
import 'lib2/HomeScreen.dart';
import 'lib2/LoginScreen.dart';
import 'lib2/RegisterScreen.dart';
import 'lib2/LupaPasswordScreen.dart';
import 'lib2/ProfileScreen.dart'; 
import 'lib2/CatalogScreen.dart';
import 'lib2/Pembayaran.dart'; // <-- import Pembayaran
import 'lib2/PeminjamanScreen.dart';

void main() {
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
        "/login": (context) => const LoginScreen(),
        "/register": (context) => const RegisterScreen(),
        "/lupapassword": (context) => const LupaPasswordScreen(),
        "/profile": (context) => const ProfileScreen(),
        "/home": (context) => const HomeScreen(),
        "/catalog": (context) => const CatalogScreen(),
        "/pembayaran": (context) => const Pembayaran(), // <-- route pembayaran
        "/peminjaman": (context) => const PeminjamanScreen(),
      },
    );
  }
}
