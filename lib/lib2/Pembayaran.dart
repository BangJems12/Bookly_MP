import 'package:flutter/material.dart';

class Pembayaran extends StatelessWidget {
  const Pembayaran({super.key});

  final List<Map<String, dynamic>> paymentMethods = const [
    {"name": "E-Wallet", "icon": Icons.account_balance_wallet, "color": Colors.blue},
    {"name": "Transfer Bank", "icon": Icons.account_balance, "color": Colors.green},
    {"name": "QR Payment", "icon": Icons.qr_code, "color": Colors.orange},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pembayaran Digital"),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: paymentMethods.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 opsi per baris
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            final method = paymentMethods[index];
            return InkWell(
              onTap: () {
                // Simulasi pembayaran
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Membayar lewat ${method['name']}")),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: method['color'],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(method['icon'], size: 50, color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      method['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
