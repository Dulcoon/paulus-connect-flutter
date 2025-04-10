import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'sakramen_registration_screen.dart';
import '../utils/constans.dart';
import '../services/api_service.dart';

class SakramenEventDetail extends StatefulWidget {
  final Map<String, dynamic> event;

  const SakramenEventDetail({Key? key, required this.event}) : super(key: key);

  @override
  _SakramenEventDetailState createState() => _SakramenEventDetailState();
}

class _SakramenEventDetailState extends State<SakramenEventDetail> {
  bool _isLoading = true;
  bool _isRegistered = false;
  String? _status;
  String? _alasan;
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _fetchRegistrationStatus(); // Periksa status pendaftaran
  }

  Future<void> _fetchUserProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.fetchUserProfile(); // Fetch user profile data
    setState(() {
      _userProfile = authProvider.userProfile;
      _isLoading = false;
    });
  }

  Future<void> _fetchRegistrationStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) return;

    try {
      final response = await ApiService.checkRegistration(
        token,
        widget.event['id'], // ID event sakramen
      );

      setState(() {
        _isRegistered = response['registered'];
        _status = response['status'];
        _alasan = response['alasan'];
      });
    } catch (e) {
      print('Error fetching registration status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          event['nama_event'],
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: oren,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header dengan background hijau
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: oren,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event['nama_event'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Jenis Sakramen: ${event['jenis_sakramen']}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Detail Event
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Deskripsi', event['deskripsi']),
                        _buildDetailRow('Tanggal Pelaksanaan',
                            event['tanggal_pelaksanaan']),
                        _buildDetailRow(
                            'Tempat Pelaksanaan', event['tempat_pelaksanaan']),
                        _buildDetailRow('Nama Romo', event['nama_romo']),
                        _buildDetailRow('Kuota Pendaftar',
                            event['kuota_pendaftar'].toString()),
                        _buildDetailRow('Status', event['status']),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Status Pendaftaran
                  if (_isRegistered)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Anda sudah mendaftar sakramen ini! \nStatus Pendaftaran: $_status',
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (_status == 'ditolak' && _alasan != null) ...[
                            SizedBox(height: 10),
                            Text(
                              'Alasan Penolakan:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            Text(
                              _alasan!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.red,
                              ),
                            ),
                            Text(
                                'Silahkan melakukan pendaftaran ulang melalui tombol dibawah ini')
                          ],
                        ],
                      ),
                    ),

                  // Tombol Daftar
                  if (!_isRegistered || _status == 'ditolak')
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigasi ke halaman pendaftaran
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SakramenRegistrationScreen(event: event),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: oren,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Daftar Sekarang',
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
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  // Widget untuk menampilkan detail dengan gaya baris
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
