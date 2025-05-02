import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../services/api_service.dart';
import 'text_misa_detail.dart';
import '../utils/constans.dart';

class TextMisaList extends StatefulWidget {
  const TextMisaList({super.key});

  @override
  _TextMisaListState createState() => _TextMisaListState();
}

class _TextMisaListState extends State<TextMisaList> {
  late Future<List<dynamic>> _textMisa;

  @override
  void initState() {
    super.initState();
    _textMisa = ApiService.fetchTextMisa();
  }

  Future<String> _downloadPdf(String filePath) async {
    const baseUrl = "$BASE_URL_NO_API/storage/";
    final url = "$baseUrl$filePath";
    final response = await ApiService.downloadFile(url);
    final directory = await getTemporaryDirectory();
    final localFilePath = '${directory.path}/${filePath.split('/').last}';
    final file = File(localFilePath);
    await file.writeAsBytes(response);
    return localFilePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCollor,
      appBar: AppBar(
        title: const Text(
          "Teks Misa",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: bgCollor,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _textMisa,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: oren));
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red)),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('Tidak ada teks misa yang tersedia.'));
          }

          final textMisaList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            itemCount: textMisaList.length,
            itemBuilder: (context, index) {
              final textMisa = textMisaList[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(
                    textMisa['judul'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Tanggal: ${textMisa['tanggal']}'),
                  trailing: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: oren, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                  onTap: () async {
                    try {
                      final filePath =
                          await _downloadPdf(textMisa['file_path']);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TextMisaDetail(
                            title: textMisa['judul'],
                            pdfPath: filePath,
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal membuka file: $e')),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
