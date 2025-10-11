import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    "Register",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "Daftar Pengguna",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: "Username",
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
                  const SizedBox(height: 8),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: !_confirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Konfirmasi Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _confirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _confirmPasswordVisible = !_confirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: aksi daftar
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Daftar",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Sudah punya akun? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "/login");
                        },
                        child: const Text(
                          "Masuk",
                          style: TextStyle(color: Color(0xFF2E7D32)),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
