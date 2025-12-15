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

      final historyData = await supabase
          .from('peminjaman')
          .select('id, status, harga, books(judul, penulis)')
          .eq('user_id', user.id)
          .eq('status', 'History');

      setState(() {
        proses = List<Map<String, dynamic>>.from(prosesData);
        aktif = List<Map<String, dynamic>>.from(aktifData);
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

  // ✅ Fungsi untuk menyelesaikan peminjaman
  Future<void> _selesaikanPeminjaman(String peminjamanId, String judul) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Selesaikan Peminjaman"),
        content: Text('Apakah Anda yakin ingin menyelesaikan peminjaman buku "$judul"?\n\nBuku akan dipindahkan ke History.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("Ya, Selesaikan"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final supabase = Supabase.instance.client;
        
        await supabase
            .from('peminjaman')
            .update({'status': 'History'})
            .eq('id', peminjamanId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Peminjaman "$judul" telah diselesaikan'),
            backgroundColor: Colors.green,
          ),
        );

        _loadData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menyelesaikan peminjaman: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ✅ Hitung jumlah kolom berdasarkan lebar layar
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 4; // Desktop besar
    if (width >= 800) return 3;  // Tablet landscape
    if (width >= 600) return 2;  // Tablet portrait
    return 1;                     // Mobile
  }

  // ✅ Hitung aspect ratio berdasarkan lebar layar
  double _getChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 0.8;  // Desktop
    if (width >= 800) return 0.75;  // Tablet landscape
    if (width >= 600) return 0.7;   // Tablet portrait
    return 0.85;                     // Mobile (lebih tinggi)
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // ✅ Ubah jadi 3 tab
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
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.pending_actions), text: 'Proses'),
              Tab(icon: Icon(Icons.book), text: 'Aktif'),
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

    // ✅ Responsive padding
    final padding = MediaQuery.of(context).size.width >= 600 ? 16.0 : 12.0;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: GridView.builder(
        itemCount: data.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context), // ✅ Dinamis
          crossAxisSpacing: padding,
          mainAxisSpacing: padding,
          childAspectRatio: _getChildAspectRatio(context), // ✅ Dinamis
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
    final isMobile = MediaQuery.of(context).size.width < 600;

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
          // ✅ Header dengan tinggi responsif
          Container(
            height: isMobile ? 100 : 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Text(
                judul.split(' ').map((w) => w.isNotEmpty ? w[0] : '').join(),
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 8.0 : 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        judul,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 12 : 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        penulis,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: isMobile ? 11 : 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Harga: $hargaStr",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: isMobile ? 11 : 12,
                        ),
                      ),
                    ],
                  ),
                  // ✅ Footer responsif
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(statusIcon, color: statusColor, size: isMobile ? 16 : 18),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: isMobile ? 11 : 12,
                                color: statusColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // ✅ Tombol full width di mobile
                      if (status == 'Proses' || status == 'Aktif')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (status == 'Proses') {
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
                              } else if (status == 'Aktif') {
                                _selesaikanPeminjaman(peminjamanId, judul);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: status == 'Proses' ? Colors.green : Colors.blue,
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 8 : 12,
                                vertical: isMobile ? 6 : 8,
                              ),
                              textStyle: TextStyle(fontSize: isMobile ? 11 : 12),
                            ),
                            child: Text(status == 'Proses' ? "Bayar" : "Selesai"),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Responsive Bank Selection Page
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

  // ✅ Hitung crossAxisCount responsif
  int _getCrossAxisCount(double width) {
    if (width >= 1200) return 4;
    if (width >= 800) return 3;
    if (width >= 600) return 2;
    return 2; // Mobile tetap 2 kolom
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Bank", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Column(
        children: [
          // ✅ Card harga responsif
          Card(
            color: Colors.teal.shade50,
            elevation: 4,
            margin: EdgeInsets.all(isMobile ? 12 : 16),
            child: ListTile(
              leading: Icon(
                Icons.attach_money,
                color: Colors.teal,
                size: isMobile ? 28 : 32,
              ),
              title: Text(
                "Total Pembayaran",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 14 : 16,
                ),
              ),
              subtitle: Text(
                _formatHarga(harga),
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),
          
          // ✅ Grid bank responsif
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              child: GridView.builder(
                itemCount: banks.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _getCrossAxisCount(screenWidth),
                  mainAxisSpacing: isMobile ? 12 : 16,
                  crossAxisSpacing: isMobile ? 12 : 16,
                  childAspectRatio: isMobile ? 1.3 : 1.5,
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
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 18 : 22,
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