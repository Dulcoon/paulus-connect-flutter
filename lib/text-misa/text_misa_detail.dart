import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../utils/constans.dart';

class TextMisaDetail extends StatefulWidget {
  final String title;
  final String pdfPath;

  const TextMisaDetail({super.key, required this.title, required this.pdfPath});

  @override
  _TextMisaDetailState createState() => _TextMisaDetailState();
}

class _TextMisaDetailState extends State<TextMisaDetail> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;
  late PDFViewController _pdfViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: oren,
        foregroundColor: Colors.white,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 70),
            Icon(
              Icons.book,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 5),
            Text(
              "Text Misa",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        leading: Container(
          margin: const EdgeInsets.only(left: 10),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          if (_isReady)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Page $_currentPage of $_totalPages',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          if (_currentPage > 1) {
                            await _pdfViewController.setPage(_currentPage - 2);
                          }
                        },
                        icon: const Icon(Icons.arrow_back_ios),
                        color: oren,
                      ),
                      IconButton(
                        onPressed: () async {
                          if (_currentPage < _totalPages) {
                            await _pdfViewController.setPage(_currentPage);
                          }
                        },
                        icon: const Icon(Icons.arrow_forward_ios),
                        color: oren,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Expanded(
            child: Stack(
              children: [
                PDFView(
                  filePath: widget.pdfPath,
                  enableSwipe: true,
                  swipeHorizontal: true,
                  autoSpacing: false,
                  pageSnap: true,
                  pageFling: true,
                  onRender: (pages) {
                    setState(() {
                      _totalPages = pages!;
                      _isReady = true;
                    });
                  },
                  onViewCreated: (PDFViewController vc) {
                    _pdfViewController = vc;
                  },
                  onPageChanged: (int? page, int? total) {
                    setState(() {
                      _currentPage = page! + 1;
                    });
                  },
                  onError: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $error')),
                    );
                  },
                  onPageError: (page, error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Page error on page $page: $error')),
                    );
                  },
                ),
                if (!_isReady)
                  const Center(
                    child: CircularProgressIndicator(color: oren),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
