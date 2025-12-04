import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';
import 'text_misa_detail.dart';
import '../utils/constans.dart';
import '../services/api_service.dart';

class TextMisaList extends StatefulWidget {
  const TextMisaList({super.key});

  @override
  _TextMisaListState createState() => _TextMisaListState();
}

class _TextMisaListState extends State<TextMisaList> {
  late Future<List<dynamic>> _textMisa;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _textMisa = ApiService.fetchTextMisa();
  }

  Future<String> _downloadPdf(String fileName) async {
    final dio = Dio();
    int retryCount = 0;

    while (retryCount < 3) {
      try {
        final url = '${BASE_URL_NO_API}/misa-pdf/$fileName';
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/$fileName';

        await dio.download(
          url,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              print(
                  "Progress: ${(received / total * 100).toStringAsFixed(0)}%");
            }
          },
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            receiveTimeout: const Duration(minutes: 1),
            sendTimeout: const Duration(seconds: 30),
            receiveDataWhenStatusError: true,
          ),
        );

        return filePath;
      } catch (e) {
        retryCount++;
        if (retryCount >= 3) {
          throw Exception(
              'Gagal mengunduh file setelah beberapa kali percobaan: $e');
        }
      }
    }
    throw Exception('Gagal mengunduh file.');
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
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/jadwal-misa');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: oren,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.calendar_today, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Lihat Jadwal Misa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: _textMisa,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(color: oren));
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      itemCount: textMisaList.length,
                      itemBuilder: (context, index) {
                        final textMisa = textMisaList[index];
                        final filePath = textMisa['file_path'] as String;
                        final fileName = filePath.split('/').last;

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side:
                                BorderSide(color: Colors.grey[300]!, width: 1),
                          ),
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text(
                              textMisa['judul'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Tanggal: ${textMisa['tanggal']}'),
                            trailing: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: oren,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.arrow_forward,
                                  color: Colors.white),
                            ),
                            onTap: () async {
                              if (_isLoading) return;

                              setState(() {
                                _isLoading = true;
                              });

                              try {
                                final localPath = await _downloadPdf(fileName);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TextMisaDetail(
                                      title: textMisa['judul'],
                                      pdfPath: localPath,
                                    ),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Gagal membuka file: $e')),
                                );
                              } finally {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: oren),
                    SizedBox(height: 10),
                    Text('Mengunduh file, harap tunggu...',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
