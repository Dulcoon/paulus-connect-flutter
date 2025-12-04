import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Tambahkan import ini

class DonationHistoryScreen extends StatefulWidget {
  const DonationHistoryScreen({Key? key}) : super(key: key);

  @override
  State<DonationHistoryScreen> createState() => _DonationHistoryScreenState();
}

class _DonationHistoryScreenState extends State<DonationHistoryScreen> {
  List<Map<String, dynamic>> _donations = [];
  bool _isLoading = true;
  NumberFormat? _currencyFormat; // Ubah jadi nullable
  DateFormat? _dateFormat; // Ubah jadi nullable

  @override
  void initState() {
    super.initState();
    _initializeFormats();
  }

  Future<void> _initializeFormats() async {
    // Inisialisasi locale Indonesia
    await initializeDateFormatting('id_ID', null);

    // Set format setelah locale diinisialisasi
    setState(() {
      _currencyFormat = NumberFormat.currency(
          locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
      _dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    });

    // Load data setelah format siap
    _loadDonationHistory();
  }

  Future<void> _loadDonationHistory() async {
    print('=== LOAD DONATION HISTORY DEBUG ===');

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      print('Auth token available: ${authProvider.token != null}');

      if (authProvider.token == null) {
        print('ERROR: No auth token for donation history');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print('Calling ApiService.getDonationHistory...');
      final response = await ApiService.getDonationHistory(
        token: authProvider.token!,
      );

      print('Donation history response: $response');

      if (response['success'] == true) {
        final donations = List<Map<String, dynamic>>.from(response['data']);
        print('Number of donations received: ${donations.length}');

        setState(() {
          _donations = donations;
          _isLoading = false;
        });
      } else {
        final errorMessage =
            response['message'] ?? 'Failed to load donation history';
        print('Donation history load failed: $errorMessage');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('EXCEPTION in _loadDonationHistory: $e');
      print('Exception Type: ${e.runtimeType}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Riwayat Donasi'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading || _currencyFormat == null || _dateFormat == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Memuat riwayat donasi...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : _donations.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadDonationHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _donations.length,
                    itemBuilder: (context, index) {
                      return _buildDonationCard(_donations[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.volunteer_activism,
                size: 64, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum ada riwayat donasi',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            'Donasi pertama Anda akan muncul di sini',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.volunteer_activism),
            label: const Text('Mulai Berdonasi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[900],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(Map<String, dynamic> donation) {
    final status = donation['status'].toString().toLowerCase();
    final amount = double.parse(donation['amount'].toString());
    final createdAt = DateTime.parse(donation['created_at']);

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'success':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Berhasil';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        statusText = 'Menunggu';
        break;
      default:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Gagal';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: status == 'success'
              ? LinearGradient(
                  colors: [Colors.green[50]!, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _currencyFormat!.format(amount),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    _dateFormat!.format(createdAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (donation['note'] != null &&
                  donation['note'].toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.message, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          donation['note'].toString(),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (status == 'success' && donation['paid_at'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 16, color: Colors.green[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Dibayar: ${_dateFormat!.format(DateTime.parse(donation['paid_at']))}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
