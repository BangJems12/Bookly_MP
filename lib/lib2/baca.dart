// import 'package:flutter/material.dart';
// import 'package:pdfx/pdfx.dart';
// import 'package:http/http.dart' as http;
// import 'package:supabase_flutter/supabase_flutter.dart';

// class BacaPage extends StatefulWidget {
//   final String fileUrl;
//   final String? title;
//   const BacaPage({Key? key, required this.fileUrl, this.title})
//     : super(key: key);

//   @override
//   State<BacaPage> createState() => _BacaPageState();
// }

// /// Widget helper: ambil peminjaman aktif untuk user saat ini dan buka BacaPage
// class BacaFromPeminjaman extends StatefulWidget {
//   const BacaFromPeminjaman({Key? key}) : super(key: key);

//   @override
//   State<BacaFromPeminjaman> createState() => _BacaFromPeminjamanState();
// }

// class _BacaFromPeminjamanState extends State<BacaFromPeminjaman> {
//   bool _loading = true;
//   String? _error;
//   String? _fileUrl;
//   String? _title;
//   String? _coverUrl;
//   String? _penulis;

//   @override
//   void initState() {
//     super.initState();
//     _loadActive();
//   }

//   Future<void> _loadActive() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//     try {
//       final supabase = Supabase.instance.client;
//       final user = supabase.auth.currentUser;
//       if (user == null) {
//         setState(() => _error = 'Silakan login terlebih dahulu');
//         return;
//       }

//       // First get the active peminjaman and its book_id
//       final res = await supabase
//           .from('peminjaman')
//           .select('book_id')
//           .eq('user_id', user.id)
//           .eq('status', 'Aktif')
//           .limit(1);

//       final List? resList = res as List?;
//       if (resList == null || resList.isEmpty) {
//         setState(() => _error = 'Tidak ada peminjaman aktif');
//         return;
//       }

//       final bookId = resList[0]['book_id'];
//       if (bookId == null) {
//         setState(() => _error = 'Tidak ada book_id pada peminjaman');
//         return;
//       }

//       // Fetch the book row directly to avoid nested-select column name issues
//       final bookRowRaw = await supabase
//           .from('books')
//           .select('*')
//           .eq('id', bookId)
//           .maybeSingle();

//       final Map<String, dynamic>? bookRow = bookRowRaw as Map<String, dynamic>?;
//       if (bookRow == null) {
//         setState(() => _error = 'Data buku tidak ditemukan');
//         return;
//       }

//       // Try common field names for the PDF file URL
//       final candidates = [
//         'file_url',
//         'file',
//         'pdf_url',
//         'url',
//         'link',
//         'file_path',
//         'filePath',
//         'pdf',
//       ];

//       String? found;
//       for (final k in candidates) {
//         if (bookRow.containsKey(k) && bookRow[k] != null) {
//           found = bookRow[k].toString();
//           break;
//         }
//       }

//       if (found != null) {
//         setState(() {
//           _fileUrl = found;
//           _title = bookRow['judul'] as String?;
//           _penulis = bookRow['penulis'] as String?;
//           _coverUrl = bookRow['cover_url'] as String?;
//         });
//       } else {
//         final available = bookRow.keys.map((k) => k.toString()).join(', ');
//         setState(() => _error = 'Tidak ada file PDF terdaftar pada buku ini. Fields: $available');
//         return;
//       }
//     } catch (e) {
//       setState(() => _error = e.toString());
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading)
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     if (_error != null)
//       return Scaffold(body: Center(child: Text('Error: $_error')));
//     if (_fileUrl == null)
//       return const Scaffold(
//         body: Center(child: Text('Tidak ada file untuk dibaca')),
//       );

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Buku Aktif'),
//         backgroundColor: const Color(0xFF2E7D32),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               elevation: 4,
//               child: Row(
//                 children: [
//                   _coverUrl != null
//                       ? ClipRRect(
//                           borderRadius: const BorderRadius.horizontal(
//                             left: Radius.circular(12),
//                           ),
//                           child: Image.network(
//                             _coverUrl!,
//                             width: 120,
//                             height: 160,
//                             fit: BoxFit.cover,
//                             errorBuilder: (_, __, ___) => Container(
//                               width: 120,
//                               height: 160,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         )
//                       : Container(width: 120, height: 160, color: Colors.grey),
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.all(12.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             _title ?? '-',
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             _penulis ?? '',
//                             style: const TextStyle(color: Colors.grey),
//                           ),
//                           const Spacer(),
//                           Align(
//                             alignment: Alignment.bottomRight,
//                             child: ElevatedButton(
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) => BacaPage(
//                                       fileUrl: _fileUrl!,
//                                       title: _title,
//                                     ),
//                                   ),
//                                 );
//                               },
//                               child: const Text('Baca'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xFF2E7D32),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _BacaPageState extends State<BacaPage> {
//   PdfController? _pdfController;
//   bool isLoading = false;
//   String? error;

//   @override
//   void initState() {
//     super.initState();
//     _loadPdf();
//   }

//   Future<void> _loadPdf() async {
//     setState(() {
//       isLoading = true;
//       error = null;
//     });

//     try {
//       final uri = Uri.parse(widget.fileUrl);
//       final resp = await http.get(uri);
//       if (resp.statusCode == 403) {
//         // Try with Supabase auth token (useful for private buckets)
//         final token = Supabase.instance.client.auth.currentSession?.accessToken;
//         if (token != null) {
//           final retry = await http.get(
//             uri,
//             headers: {'Authorization': 'Bearer $token'},
//           );
//           if (retry.statusCode == 200) {
//             final bytes = retry.bodyBytes;
//             _pdfController = PdfController(
//               document: PdfDocument.openData(bytes),
//             );
//             setState(() {});
//             return;
//           }
//         }
//         throw Exception('Failed to fetch file (403 Forbidden)');
//       }
//       if (resp.statusCode != 200) {
//         throw Exception('Failed to fetch file: ${resp.statusCode}');
//       }

//       final bytes = resp.bodyBytes;
//       // openData returns a Future<PdfDocument>; pass the Future to PdfController
//       _pdfController = PdfController(document: PdfDocument.openData(bytes));
//       setState(() {});
//     } catch (e) {
//       setState(() => error = e.toString());
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   void dispose() {
//     _pdfController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title ?? 'Baca Buku'),
//         backgroundColor: const Color(0xFF2E7D32),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : error != null
//           ? Center(child: Text('Error: $error'))
//           : _pdfController == null
//           ? const Center(child: Text('Tidak ada dokumen'))
//           : PdfView(controller: _pdfController!),
//     );
//   }
// }
