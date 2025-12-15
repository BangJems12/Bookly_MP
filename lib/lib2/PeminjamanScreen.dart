import 'package:flutter/material.dart';
import 'package:Bookly_MP/lib2/HomeScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Bank.dart';

class PeminjamanScreen extends StatefulWidget {
  const PeminjamanScreen({super.key});

  @override
  State<PeminjamanScreen> createState() => _PeminjamanScreenState();
}

class _PeminjamanScreenState extends State<PeminjamanScreen> {
  List<Map<String, dynamic>> proses = [];
  List<Map<String, dynamic>> aktif = [];
  List<Map<String, dynamic>> berlangganan = [];
  List<Map<String, dynamic>> history = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Silakan login terlebih dahulu")),
        );
        return;
      }

      final prosesData = await supabase
          .from('peminjaman')
          .select('id, status, harga, books(judul, penulis)')
          .eq('user_id', user.id)
          .eq('status', 'Proses');

      final aktifData = await supabase
          .from('peminjaman')
          .select('id, status, harga, books(judul, penulis)')
          .eq('user_id', user.id)
          .eq('status', 'Aktif');

      final berlanggananData = await supabase
          .from('peminjaman')
          .select('id, status, harga, books(judul, penulis)')
          .eq('user_id', user.id)
          .eq('status', 'Berlangganan');

      final historyData = await supabase
          .from('peminjaman')
          .select('id, status, harga, books(judul, penulis)')
          .eq('user_id', user.id)
          .eq('status', 'History');

      setState(() {
        proses = List<Map<String, dynamic>>.from(prosesData);
        aktif = List<Map<String, dynamic>>.from(aktifData);
        berlangganan = List<Map<String, dynamic>>.from(berlanggananData);
        history = List<Map<String, dynamic>>.from(historyData);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memuat data: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F5),
        appBar: AppBar(
          title: const Text(
            'Peminjaman Digital 📚',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF2E7D32),
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
              tooltip: 'Refresh Data',
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.pending_actions), text: 'Proses'),
              Tab(icon: Icon(Icons.book), text: 'Aktif'),
              Tab(icon: Icon(Icons.subscriptions), text: 'Berlangganan'),
              Tab(icon: Icon(Icons.history), text: 'History'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildGrid(proses, status: 'Proses'),
                  _buildGrid(aktif, status: 'Aktif'),
                  _buildGrid(berlangganan, status: 'Berlangganan'),
                  _buildGrid(history, status: 'History'),
                ],
              ),
      ),
    );
  }

  Widget _buildGrid(List<Map<String, dynamic>> data, {required String status}) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'Belum ada data $status',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        itemCount: data.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (context, index) {
          final item = data[index];
          final book = item['books'];
          return _buildBookCard(
            book['judul'],
            book['penulis'],
            status,
            item['id'],
            item['harga'],
          );
        },
      ),
    );
  }

  Widget _buildBookCard(
    String judul,
    String penulis,
    String status,
    String peminjamanId,
    dynamic harga,
  ) {
    String hargaStr;
    if (harga == null || (harga is String && harga.isEmpty)) {
      hargaStr = 'Rp -';
    } else if (harga is num) {
      final double p = harga.toDouble();
      final int intPart = p.truncate();
      final int frac = ((p - intPart).abs() * 100).round();
      String intStr = intPart.toString();
      intStr = intStr.replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (m) => '.',
      );
      if (frac == 0) {
        hargaStr = 'Rp $intStr';
      } else {
        final String fracStr = frac.toString().padLeft(2, '0');
        hargaStr = 'Rp $intStr,$fracStr';
      }
    } else {
      hargaStr = harga.toString();
    }

    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'Proses':
        statusColor = Colors.orange;
        statusIcon = Icons.pending_actions;
        break;
      case 'Aktif':
        statusColor = Colors.green;
        statusIcon = Icons.book;
        break;
      case 'Berlangganan':
        statusColor = Colors.blue;
        statusIcon = Icons.subscriptions;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.history;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Text(
                judul.split(' ').map((w) => w[0]).join(),
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  penulis,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  "Harga: $hargaStr",
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          style: TextStyle(fontSize: 12, color: statusColor),
                        ),
                      ],
                    ),
                    if (status == 'Proses')
                      ElevatedButton(
                        onPressed: () async {
                          num? hargaNum;
                          if (harga is String) {
                            hargaNum = num.tryParse(harga);
                          } else if (harga is num) {
                            hargaNum = harga;
                          }
                          
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => _BankSelectionPage(
                                peminjamanId: peminjamanId,
                                harga: hargaNum,
                              ),
                            ),
                          );
                          
                          if (result == true) {
                            _loadData();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        child: const Text("Bayar"),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Class BankSelectionPage dengan underscore prefix (private)
class _BankSelectionPage extends StatelessWidget {
  final String peminjamanId;
  final num? harga;

  const _BankSelectionPage({
    required this.peminjamanId,
    required this.harga,
  });

  final List<Map<String, dynamic>> banks = const [
    {"name": "BCA", "color": Colors.blue},
    {"name": "BNI", "color": Colors.orange},
    {"name": "Mandiri", "color": Colors.yellow},
    {"name": "BRI", "color": Colors.indigo},
  ];

  String _formatHarga(num? p) {
    if (p == null) return 'Rp -';
    final double val = p.toDouble();
    final int intPart = val.truncate();
    final int frac = ((val - intPart).abs() * 100).round();
    String intStr = intPart.toString();
    intStr = intStr.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => '.',
    );
    if (frac == 0) return 'Rp $intStr';
    final String fracStr = frac.toString().padLeft(2, '0');
    return 'Rp $intStr,$fracStr';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Bank", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Column(
        children: [
          Card(
            color: Colors.teal.shade50,
            elevation: 4,
            margin: const EdgeInsets.all(16),
            child: ListTile(
              leading: const Icon(Icons.attach_money, color: Colors.teal, size: 32),
              title: const Text(
                "Total Pembayaran",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                _formatHarga(harga),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: banks.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemBuilder: (context, index) {
                  final bank = banks[index];
                  return InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BankPage(
                            bankName: bank['name'],
                            peminjamanId: peminjamanId,
                            harga: harga,
                          ),
                        ),
                      );
                      if (result == true) {
                        Navigator.pop(context, true);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: bank['color'],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          bank['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}