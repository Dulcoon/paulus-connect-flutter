import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'sakramen_registration_screen.dart';
import '../utils/constans.dart';
import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constans.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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
  bool isSakramen(String jenisSakramen) {
    if (_userProfile == null) return false;

    // Periksa jenis sakramen dan status penerimaan
    if (jenisSakramen.toLowerCase() == 'baptis' &&
        _userProfile!['sudah_baptis'] == 'sudah') {
      return true;
    } else if (jenisSakramen.toLowerCase() == 'komuni' &&
        _userProfile!['sudah_komuni'] == 'sudah') {
      return true;
    } else if (jenisSakramen.toLowerCase() == 'krisma' &&
        _userProfile!['sudah_krisma'] == 'sudah') {
      return true;
    }

    return false;
  }

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

  Future<void> _downloadPdf(String url, String fileName) async {
    try {
      // Meminta izin akses penyimpanan
      final hasPermission = await _requestPermission();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Izin penyimpanan ditolak')),
        );
        return;
      }

      // Menentukan lokasi penyimpanan file
      final filePath = await _pathPdf(fileName);

      // Menampilkan notifikasi progress
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'download_channel',
        'Download Progress',
        channelDescription: 'Menampilkan progres unduhan',
        importance: Importance.low,
        priority: Priority.low,
        onlyAlertOnce: true,
        showProgress: true,
        maxProgress: 100,
        progress: 0,
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.show(
        0,
        'Mengunduh File',
        'Proses unduhan dimulai...',
        platformChannelSpecifics,
      );

      // Mengunduh file dari URL
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Perbarui notifikasi setelah unduhan selesai
        await flutterLocalNotificationsPlugin.show(
          0,
          'Unduhan Selesai',
          'File berhasil diunduh',
          NotificationDetails(
            android: AndroidNotificationDetails(
              'download_channel',
              'Download Progress',
              channelDescription: 'Menampilkan progres unduhan',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );

        // Buka file setelah selesai
        OpenFile.open(filePath);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Gagal mengunduh file. Status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  Future<String> _pathPdf(String fileName) async {
    final directory = Directory('/storage/emulated/0/Download');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    String filePath = '${directory.path}/$fileName';
    int counter = 1;

    // Periksa apakah file sudah ada, jika ya tambahkan angka ke nama file
    while (await File(filePath).exists()) {
      final fileNameWithoutExtension = fileName.split('.').first;
      final fileExtension = fileName.split('.').last;
      filePath =
          '${directory.path}/${fileNameWithoutExtension}_($counter).$fileExtension';
      counter++;
    }

    return filePath;
  }

  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      if (await _isAndroid11OrHigher()) {
        // Untuk Android 11+ gunakan MANAGE_EXTERNAL_STORAGE
        final status = await Permission.manageExternalStorage.status;
        if (status.isDenied || status.isPermanentlyDenied) {
          final result = await Permission.manageExternalStorage.request();
          return result.isGranted;
        }
        return status.isGranted;
      } else {
        // Untuk Android 10 atau lebih rendah gunakan READ/WRITE_EXTERNAL_STORAGE
        final status = await Permission.storage.status;
        if (status.isDenied || status.isPermanentlyDenied) {
          final result = await Permission.storage.request();
          return result.isGranted;
        }
        return status.isGranted;
      }
    }
    return false; // Untuk platform selain Android
  }

  Future<bool> _isAndroid11OrHigher() async {
    return Platform.isAndroid && (await _getAndroidVersion() >= 30);
  }

  Future<int> _getAndroidVersion() async {
    print('disini oy');
    final osVersion = Platform.operatingSystemVersion;
    print('Operating System Version: $osVersion');

    // Gunakan regex untuk mengekstrak versi Android
    final match = RegExp(r'Android (\d+)').firstMatch(osVersion);
    if (match != null) {
      final version = int.tryParse(match.group(1) ?? '0') ?? 0;
      print('Parsed Android Version: $version');
      return version;
    }

    // Jika tidak dapat diparsing, kembalikan 0 sebagai default
    print('Failed to parse Android version');
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Scaffold(
      backgroundColor: bgCollor,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          'Sakramen ${event['jenis_sakramen']}',
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
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      event['nama_event']
                          .toUpperCase(), // Ubah teks menjadi uppercase
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Header dengan background hijau

                  SizedBox(height: 16),

                  // Detail Event
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
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

                  // Tombol atau Pesan
                  if (isSakramen(widget.event['jenis_sakramen']))
                    // Pesan jika sudah menerima sakramen
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Anda sudah menerima sakramen ini. Apabila data ini tidak valid, silahkan melakukan perubahan data ke bagian menu profile.',
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  else if (_isRegistered)
                    // Pesan jika sudah mendaftar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'Anda sudah mendaftar sakramen ini! \nStatus Pendaftaran: $_status',
                                style: TextStyle(
                                  color: Colors.orange[800],
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (_alasan != null && _alasan!.isNotEmpty) ...[
                              SizedBox(height: 8),
                              Center(
                                child: Text(
                                  'Pesan: $_alasan',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                            if (_status?.toLowerCase() == 'ditolak') ...[
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  // Navigasi ke halaman pendaftaran ulang
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SakramenRegistrationScreen(
                                        event: widget.event,
                                      ),
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
                                      'Daftar Ulang',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (_status?.toLowerCase() == 'selesai') ...[
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () async {
                                  print(widget.event['id']);
                                  final url =
                                      '$BASE_URL/pendaftars/${widget.event['id']}/download-pdf';
                                  print(url);
                                  final fileName =
                                      'surat_bukti_sakramen_${event['jenis_sakramen']}_${widget.event['id']}.pdf';
                                  print(fileName);
                                  await _downloadPdf(
                                      url, fileName); // Mengunduh PDF
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.download, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Unduh Surat Bukti Sakramen',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  else
                    // Tombol Daftar jika belum mendaftar dan belum menerima sakramen
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigasi ke halaman pendaftaran
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SakramenRegistrationScreen(
                                  event: widget.event),
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
          Expanded(
            flex: 2, // Bagian kiri (label)
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3, // Bagian kanan (value)
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
