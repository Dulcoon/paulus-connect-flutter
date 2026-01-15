import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'sakramen_registration_screen.dart';
import '../utils/constans.dart';
import '../services/api_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/notification_service.dart';
import '../utils/constans.dart';

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

    // ===== JIKA DARI NOTIFICATION (STATUS = 'loading') =====
    if (widget.event['status'] == 'loading') {
      print(
          "📥 Loading full event data from notification ID: ${widget.event['id']}");
      _loadFullEventData();
    } else {
      print("✅ Using event data from list");
      _fetchUserProfile();
      _fetchRegistrationStatus();
    }
  }

  Future<void> _loadFullEventData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        throw Exception('Token tidak tersedia');
      }

      // ===== GUNAKAN SAKRAMEN EVENT ID DARI NOTIFICATION =====
      final sakramenEventId = widget.event['sakramen_event_id'];

      print("🔄 Fetching full event data...");
      print("   - Sakramen Event ID: $sakramenEventId");
      print("   - Pendaftar ID: ${widget.event['pendaftar_id']}");

      final url = '${BASE_URL}/sakramen/events/$sakramenEventId';
      print("🔗 Request URL: $url");

      // ===== FETCH FULL EVENT DATA FROM API =====
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("📡 Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final eventData = data['data'] ?? data;

        print("✅ Full event data loaded successfully");
        print("📦 Event Data: $eventData");

        // ===== UPDATE WIDGET EVENT WITH FULL DATA =====
        widget.event.addAll(eventData);

        // ===== PRESERVE NOTIFICATION STATUS IF NOT IN API DATA =====
        if (widget.event['notification_status'] != null) {
          _status = widget.event['notification_status'];
          _alasan = widget.event['notification_body'];
        }
      } else {
        throw Exception('Failed to load event: ${response.statusCode}');
      }

      // ===== THEN LOAD USER PROFILE & REGISTRATION STATUS =====
      await _fetchUserProfile();
      await _fetchRegistrationStatus();
    } catch (e) {
      print('❌ Error loading full event data: $e');

      if (!mounted) return;

      NotificationService().showError(
        context,
        'Gagal memuat data event: $e',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.fetchUserProfile();
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
        widget.event['id'],
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
      final hasPermission = await _requestPermission();
      if (!hasPermission) {
        NotificationService().showError(
          context,
          'Izin penyimpanan ditolak. Tidak dapat mengunduh file.',
        );
        return;
      }

      final filePath = await _pathPdf(fileName);

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

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        await flutterLocalNotificationsPlugin.show(
          0,
          'Unduhan Selesai',
          'File berhasil diunduh',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'download_channel',
              'Download Progress',
              channelDescription: 'Menampilkan progres unduhan',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );

        OpenFile.open(filePath);
      } else {
        NotificationService().showError(
          context,
          'Gagal mengunduh file. Silakan coba lagi.',
        );
      }
    } catch (e) {
      NotificationService().showError(
        context,
        'Terjadi kesalahan saat mengunduh file: $e',
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
        final status = await Permission.manageExternalStorage.status;
        if (status.isDenied || status.isPermanentlyDenied) {
          final result = await Permission.manageExternalStorage.request();
          return result.isGranted;
        }
        return status.isGranted;
      } else {
        final status = await Permission.storage.status;
        if (status.isDenied || status.isPermanentlyDenied) {
          final result = await Permission.storage.request();
          return result.isGranted;
        }
        return status.isGranted;
      }
    }
    return false;
  }

  Future<bool> _isAndroid11OrHigher() async {
    return Platform.isAndroid && (await _getAndroidVersion() >= 30);
  }

  Future<int> _getAndroidVersion() async {
    final osVersion = Platform.operatingSystemVersion;

    final match = RegExp(r'Android (\d+)').firstMatch(osVersion);
    if (match != null) {
      final version = int.tryParse(match.group(1) ?? '0') ?? 0;
      return version;
    }

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
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: oren,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              oren.withOpacity(0.8),
                              oren.withOpacity(0.6)
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                event['status'].toUpperCase(),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              event['nama_event'],
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sakramen ${event['jenis_sakramen']}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Event Details Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Detail Acara',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildDetailItem(
                                  Icons.description_outlined,
                                  'Deskripsi',
                                  event['deskripsi'],
                                ),
                                const SizedBox(height: 16),
                                _buildDetailItem(
                                  Icons.calendar_today,
                                  'Tanggal Pelaksanaan',
                                  event['tanggal_pelaksanaan'],
                                ),
                                const SizedBox(height: 16),
                                _buildDetailItem(
                                  Icons.location_on_outlined,
                                  'Tempat Pelaksanaan',
                                  event['tempat_pelaksanaan'],
                                ),
                                const SizedBox(height: 16),
                                _buildDetailItem(
                                  Icons.person_outline,
                                  'Nama Romo',
                                  event['nama_romo'],
                                ),
                                const SizedBox(height: 16),
                                _buildDetailItem(
                                  Icons.group_outlined,
                                  'Kuota Pendaftar',
                                  '${event['kuota_pendaftar']} orang',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Registration Status Card
                      if (isSakramen(widget.event['jenis_sakramen']))
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            color: Colors.orange[50],
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.orange[700],
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Sakramen Sudah Diterima',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange[800],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Anda sudah menerima sakramen ini. Jika data tidak valid, silakan perbarui di menu profil.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.orange[700],
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else if (_isRegistered)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            color: _getStatusColor(_status),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _getStatusIcon(_status),
                                    color: Colors.white,
                                    size: 56,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Status Pendaftaran',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _status?.toUpperCase() ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (_alasan != null &&
                                      _alasan!.isNotEmpty) ...[
                                    const SizedBox(height: 20),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        _alasan!,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white,
                                          height: 1.6,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                  if (_status?.toLowerCase() == 'ditolak') ...[
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
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
                                          backgroundColor: Colors.white,
                                          foregroundColor: oren,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          elevation: 2,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.edit),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Daftar Ulang',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (_status?.toLowerCase() == 'selesai') ...[
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          final authProvider =
                                              Provider.of<AuthProvider>(context,
                                                  listen: false);
                                          final userId = authProvider.user?.id;
                                          final sakramenId = widget.event['id'];

                                          if (userId != null &&
                                              sakramenId != null) {
                                            final url =
                                                '$BASE_URL/pendaftars/$sakramenId/$userId/download-pdf';
                                            final fileName =
                                                'surat_bukti_sakramen_${widget.event['jenis_sakramen']}_$sakramenId.pdf';
                                            await _downloadPdf(url, fileName);
                                          } else {
                                            NotificationService().showError(
                                              context,
                                              'Gagal mengunduh file. Data pengguna tidak lengkap.',
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.green[700],
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          elevation: 2,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.download),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Unduh Surat',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 100), // Space for FAB
                    ],
                  ),
                ),

                // Floating Action Button
                if (!isSakramen(widget.event['jenis_sakramen']) &&
                    !_isRegistered)
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [oren, oren.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: oren.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SakramenRegistrationScreen(
                                event: widget.event,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Daftar Sekarang',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: oren.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: oren,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return oren;
    switch (status.toLowerCase()) {
      case 'menunggu':
        return Colors.blue[600]!;
      case 'disetujui':
        return Colors.green[600]!;
      case 'ditolak':
        return Colors.red[600]!;
      case 'selesai':
        return Colors.green[700]!;
      default:
        return oren;
    }
  }

  IconData _getStatusIcon(String? status) {
    if (status == null) return Icons.info;
    switch (status.toLowerCase()) {
      case 'menunggu':
        return Icons.hourglass_empty;
      case 'disetujui':
        return Icons.check_circle;
      case 'ditolak':
        return Icons.cancel;
      case 'selesai':
        return Icons.verified;
      default:
        return Icons.info;
    }
  }
}
