import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String snapToken;
  final int donationId;

  const PaymentWebViewScreen({
    Key? key,
    required this.snapToken,
    required this.donationId,
  }) : super(key: key);

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pembayaran Donasi'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitConfirmation(),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(
                  'https://app.sandbox.midtrans.com/snap/v2/vtweb/${widget.snapToken}'),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              databaseEnabled: true,
              allowsInlineMediaPlayback: true,
              mediaPlaybackRequiresUserGesture: false,
              useWideViewPort: true,
              supportZoom: false,
              clearCache: false,
              userAgent:
                  "Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36",
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onLoadStart: (controller, url) {
              print('Page started loading: $url');
            },
            onLoadStop: (controller, url) async {
              print('Page finished loading: $url');
              setState(() {
                _isLoading = false;
              });

              // Check if payment completed based on URL
              if (url.toString().contains('finish') ||
                  url.toString().contains('success')) {
                _handlePaymentResult('success');
              } else if (url.toString().contains('pending')) {
                _handlePaymentResult('pending');
              } else if (url.toString().contains('error') ||
                  url.toString().contains('cancel')) {
                _handlePaymentResult('failed');
              }
            },
            onProgressChanged: (controller, progress) {
              setState(() {
                _progress = progress / 100;
              });
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url.toString();
              print('Navigation intercepted: $url');

              // Handle specific payment result URLs
              if (url.contains('finish') ||
                  url.contains('success') ||
                  url.contains('pending') ||
                  url.contains('error') ||
                  url.contains('cancel')) {
                String status = 'failed';
                if (url.contains('finish') || url.contains('success')) {
                  status = 'success';
                } else if (url.contains('pending')) {
                  status = 'pending';
                }

                _handlePaymentResult(status);
                return NavigationActionPolicy.CANCEL;
              }

              return NavigationActionPolicy.ALLOW;
            },
            onConsoleMessage: (controller, consoleMessage) {
              print('Console message: ${consoleMessage.message}');

              // Handle JavaScript callbacks from Midtrans
              if (consoleMessage.message.contains('payment')) {
                print('Payment callback detected: ${consoleMessage.message}');
              }
            },
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Memuat halaman pembayaran...',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

          // Progress bar
          if (_progress < 1.0 && !_isLoading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[900]!),
              ),
            ),
        ],
      ),
    );
  }

  void _handlePaymentResult(String status) {
    print('Handling payment result: $status');

    // Add delay to ensure transaction is processed
    Future.delayed(const Duration(seconds: 2), () {
      _checkPaymentStatus();
    });
  }

  Future<void> _checkPaymentStatus() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await ApiService.checkPaymentStatus(
        donationId: widget.donationId,
        token: authProvider.token!,
      );

      if (response['success'] == true) {
        final status = response['data']['status'];
        _showPaymentResult(
          success: status == 'success',
          isPending: status == 'pending',
          message: response['message'] ?? 'Pembayaran berhasil diproses',
        );
      } else {
        _showPaymentResult(
          success: false,
          isPending: false,
          message: response['message'] ?? 'Gagal memeriksa status pembayaran',
        );
      }
    } catch (e) {
      print('Error checking payment status: $e');
      _showPaymentResult(
        success: false,
        isPending: false,
        message: 'Gagal memeriksa status pembayaran',
      );
    }
  }

  void _showPaymentResult(
      {required bool success,
      required bool isPending,
      required String message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(
              success
                  ? Icons.check_circle
                  : isPending
                      ? Icons.access_time
                      : Icons.error,
              color: success
                  ? Colors.green
                  : isPending
                      ? Colors.orange
                      : Colors.red,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              success
                  ? 'Berhasil!'
                  : isPending
                      ? 'Menunggu'
                      : 'Gagal',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            if (success) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Terima kasih atas donasi Anda untuk kemajuan gereja!',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close webview
              if (success) {
                Navigator.of(context).pop(); // Close donation screen
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: success
                  ? Colors.green[700]
                  : isPending
                      ? Colors.orange[700]
                      : Colors.red[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              success ? 'Selesai' : 'OK',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange[700]),
            const SizedBox(width: 8),
            const Text('Batalkan Pembayaran?'),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan proses pembayaran? Transaksi yang sedang berlangsung akan dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Lanjutkan',
              style: TextStyle(color: Colors.blue[700]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close webview
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red[700],
            ),
            child: const Text(
              'Ya, Batalkan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
