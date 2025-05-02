import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constans.dart';
import 'package:xml/xml.dart' as xml;

class AlkitabScreen extends StatefulWidget {
  const AlkitabScreen({super.key});

  @override
  _AlkitabScreenState createState() => _AlkitabScreenState();
}

class _AlkitabScreenState extends State<AlkitabScreen> {
  Map<String, dynamic>? _bibleData;
  bool _isLoading = false;
  String _searchQuery = '';

  Future<void> _fetchBibleData(String passage) async {
    setState(() {
      _isLoading = true;
    });

    final url = 'https://alkitab.sabda.org/api/passage.php?passage=$passage';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.body);

        // Ambil judul dari elemen <title> pada ayat pertama
        final firstVerseTitle = document
                .findAllElements('verse')
                .first
                .findElements('title')
                .isNotEmpty
            ? document
                .findAllElements('verse')
                .first
                .findElements('title')
                .first
                .text
            : 'Judul tidak tersedia';

        // Ambil daftar ayat
        final verses = document.findAllElements('verse').map((verseElement) {
          return {
            'number': verseElement.findElements('number').first.text,
            'title': verseElement.findElements('title').isNotEmpty
                ? verseElement.findElements('title').first.text
                : null,
            'text': verseElement.findElements('text').first.text,
          };
        }).toList();

        setState(() {
          _bibleData = {
            'title': firstVerseTitle, // Gunakan judul dari ayat pertama
            'verses': verses,
          };
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat data Alkitab')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchBibleData('Yohanes+1:1-10'); // Default passage
  }

  Widget _buildVerseList() {
    if (_bibleData == null) {
      return const Center(
        child: Text(
          'Tidak ada data Alkitab',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    final title = _bibleData?['title'] ?? 'Judul tidak tersedia';
    final verses = _bibleData?['verses'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul di tengah atas
          Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Daftar ayat
          ...verses.map((verse) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nomor ayat di dalam tanda kurung
                Text(
                  '[${verse['number']}]',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),

                // Isi ayat
                Text(
                  verse['text'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5, // Menambahkan jarak antar baris
                  ),
                ),
                const SizedBox(height: 16), // Jarak antar ayat
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCollor,
      appBar: AppBar(
        title: const Text(
          'Alkitab',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: bgCollor,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: oren),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form pencarian
                  Row(
                    children: [
                      // Input pencarian
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Contoh: Yohanes 1:1-10',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: oren),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Tombol pencarian
                      ElevatedButton(
                        onPressed: () {
                          if (_searchQuery.isNotEmpty) {
                            _fetchBibleData(_searchQuery);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Masukkan referensi ayat terlebih dahulu'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: oren,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.only(
                            top: 10,
                            bottom: 10,
                            left: 16,
                            right: 16,
                          ),
                        ),
                        child: const Icon(Icons.search,
                            color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Input yang dimasukkan pengguna dan ikon favorit
                  if (_searchQuery.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Input pengguna
                        Text(
                          _searchQuery,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        // Ikon bintang untuk favorit
                        IconButton(
                          icon: const Icon(
                            Icons.star_border,
                            color: oren,
                          ),
                          onPressed: () {
                            // Tambahkan logika untuk menambahkan ke favorit
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '$_searchQuery ditambahkan ke favorit'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Konten Alkitab
                  Expanded(child: _buildVerseList()),
                ],
              ),
            ),
    );
  }

  Future<String?> _showPassageInputDialog() async {
    String passage = '';
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Cari Ayat Alkitab',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            onChanged: (value) => passage = value,
            decoration: InputDecoration(
              hintText: 'Contoh: Yohanes 1:1-10',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: oren),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.black54),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, passage),
              style: ElevatedButton.styleFrom(
                backgroundColor: oren,
              ),
              child: const Text('Cari'),
            ),
          ],
        );
      },
    );
  }
}
