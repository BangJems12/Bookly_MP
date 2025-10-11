import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 50),
                const Text(
                  "Selamat datang kembali",
                  style: TextStyle(fontSize: 17),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: "Masukan Username",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    labelText: "Masukan Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                  onTap: () {
                        Navigator.pushNamed(context, "/lupapassword");
                      },
                    child: const Text(
                      "Lupa kata sandi?",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/profile"); // contoh aja
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Masuk",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/register");
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Daftar",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
