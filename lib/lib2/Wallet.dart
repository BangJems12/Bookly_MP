import 'package:flutter/material.dart';

class EWalletPage extends StatelessWidget {
  const EWalletPage({super.key});

  // Daftar e-wallet populer di Indonesia
  final List<Map<String, dynamic>> ewallets = const [
    {"name": "OVO", "color1": Colors.purple, "color2": Colors.deepPurple, "icon": Icons.account_balance_wallet},
    {"name": "GoPay", "color1": Colors.blue, "color2": Colors.lightBlue, "icon": Icons.account_balance_wallet},
    {"name": "DANA", "color1": Colors.lightBlue, "color2": Colors.blueAccent, "icon": Icons.account_balance_wallet},
    {"name": "ShopeePay", "color1": Colors.orange, "color2": Colors.deepOrange, "icon": Icons.account_balance_wallet},
    {"name": "LinkAja", "color1": Colors.red, "color2": Colors.pink, "icon": Icons.account_balance_wallet},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Pembayaran via E-Wallet"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 4,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ewallets.length,
        itemBuilder: (context, index) {
          final wallet = ewallets[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EWalletStepsPage(walletName: wallet['name']),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [wallet['color1'], wallet['color2']],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: wallet['color1'].withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(4, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(wallet['icon'], color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      wallet['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class EWalletStepsPage extends StatelessWidget {
  final String walletName;
  const EWalletStepsPage({super.key, required this.walletName});

  // Langkah pembayaran umum via e-wallet
  final List<String> steps = const [
    "Buka aplikasi e-wallet di smartphone.",
    "Pilih menu Bayar / Transfer.",
    "Scan QR Code atau masukkan nomor tujuan.",
    "Masukkan nominal pembayaran.",
    "Konfirmasi detail transaksi.",
    "Selesaikan pembayaran dan simpan bukti.",
  ];

  // Simulasi kode rekening tujuan Bookly
  final String booklyWalletCode = "Bookly_123492"; // contoh kode e-wallet
  final String booklyAccountName = "Bookly";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text("Langkah Pembayaran - $walletName"),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 4,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Card informasi rekening tujuan
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.teal, Colors.greenAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(4, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: Colors.white, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "$booklyAccountName\nKode E-Wallet: $booklyWalletCode",
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Daftar langkah pembayaran
          ...steps.asMap().entries.map((entry) {
            int index = entry.key;
            String step = entry.value;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Text("${index + 1}", style: const TextStyle(color: Colors.white)),
                ),
                title: Text(
                  step,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}