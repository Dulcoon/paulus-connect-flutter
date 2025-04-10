import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'sakramen_event_detail.dart';
import '../utils/constans.dart';

class SakramenEventList extends StatefulWidget {
  @override
  _SakramenEventListState createState() => _SakramenEventListState();
}

class _SakramenEventListState extends State<SakramenEventList> {
  late Future<List<dynamic>> _events;
  bool _isLoading = true;
  bool _isProfileCompleted = true; // Tambahkan flag untuk validasi profil

  @override
  void initState() {
    super.initState();
    _checkCompletionStatus(); // Tambahkan validasi isCompleted
  }

  Future<void> _checkCompletionStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider
        .fetchUserData(); // Fetch user data untuk memeriksa isCompleted

    if (!mounted) return;

    if (authProvider.user?.isCompleted == 1) {
      await authProvider
          .fetchUserProfile(); // Fetch user profile jika isCompleted true
      final token = authProvider.token;

      if (token != null) {
        _events = ApiService.getActiveSakramenEvents(token);
      } else {
        _events = Future.error('Token tidak valid. Silakan login ulang.');
      }
    } else {
      // Set flag isProfileCompleted ke false jika profil belum lengkap
      _isProfileCompleted = false;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Event Sakramen Aktif'),
        backgroundColor: oren,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _isProfileCompleted
              ? FutureBuilder<List<dynamic>>(
                  future: _events,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('Tidak ada event aktif.'));
                    }

                    final events = snapshot.data!;
                    return ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return Card(
                          margin: EdgeInsets.all(10),
                          child: ListTile(
                            title: Text(
                              event['nama_event'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                                'Jenis Sakramen: ${event['jenis_sakramen']}'),
                            trailing: Icon(Icons.arrow_forward),
                            onTap: () {
                              // Navigasi ke halaman detail sakramen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SakramenEventDetail(event: event),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Silakan lengkapi user-profile Anda terlebih dahulu.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }
}
