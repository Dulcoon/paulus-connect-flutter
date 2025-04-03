import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../utils/constans.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkCompletionStatus();
  }

  Future<void> _checkCompletionStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider
        .fetchUserData(); // Fetch user data to check isCompleted status

    if (!mounted) return;

    if (authProvider.user?.isCompleted == 1) {
      await authProvider
          .fetchUserProfile(); // Fetch user profile data if isCompleted is true
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProfile = authProvider.userProfile;
    final isCompleted = authProvider.user?.isCompleted == 1;

    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: oren,
            ))
          : isCompleted
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 280,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/Vector.png'),
                            fit: BoxFit.cover,
                          ),
                          color: oren,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              SizedBox(height: 30),
                              Row(
                                children: [
                                  Text(
                                    'User Profile',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Column(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundImage:
                                        AssetImage('assets/images/user.png'),
                                  ),
                                  SizedBox(width: 20),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${authProvider.user?.name}",
                                        style: const TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "${authProvider.user?.email}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Text(
                                  'Data Diri',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: oren,
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: oren,
                                    thickness: 1,
                                    height: 30,
                                    indent: 10,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            _buildProfileField(
                                'Nama Lengkap', userProfile?['nama_lengkap']),
                            SizedBox(height: 10),
                            _buildProfileField(
                                'Nomor HP', userProfile?['no_hp']),
                            SizedBox(height: 10),
                            _buildProfileField(
                                'Tempat Lahir', userProfile?['tempat_lahir']),
                            SizedBox(height: 10),
                            _buildProfileField(
                                'Tanggal Lahir', userProfile?['tanggal_lahir']),
                            SizedBox(height: 10),
                            _buildProfileField(
                                'Nama Ayah', userProfile?['nama_ayah']),
                            SizedBox(height: 10),
                            _buildProfileField(
                                'Nama Ibu', userProfile?['nama_ibu']),
                            SizedBox(height: 40),
                            Row(
                              children: [
                                Text(
                                  'Alamat',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: oren,
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: oren,
                                    thickness: 1,
                                    height: 30,
                                    indent: 10,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            _buildProfileField('Kecamatan',
                                userProfile?['kecamatan_tempat_tinggal']),
                            SizedBox(height: 10),
                            _buildProfileField(
                                'Kelurahan', userProfile?['nama_wilayah']),
                            SizedBox(height: 10),
                            _buildProfileField('Alamat Lengkap',
                                userProfile?['alamat_lengkap']),
                            SizedBox(height: 10),
                            _buildProfileField(
                                'Lingkungan', userProfile?['lingkungan']),
                            SizedBox(height: 40),
                            Row(
                              children: [
                                Text(
                                  'Data Sakramen',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: oren,
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: oren,
                                    thickness: 1,
                                    height: 30,
                                    indent: 10,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            _buildProfileField(
                                'Sudah Baptis', userProfile?['sudah_baptis']),
                            if (userProfile?['sudah_baptis'] == 'sudah') ...[
                              SizedBox(height: 10),
                              _buildProfileField('Tanggal Baptis',
                                  userProfile?['tanggal_baptis']),
                              SizedBox(height: 10),
                              _buildProfileField('Tempat Baptis',
                                  userProfile?['tempat_baptis']),
                            ],
                            SizedBox(height: 10),
                            _buildProfileField(
                                'Sudah Komuni', userProfile?['sudah_komuni']),
                            if (userProfile?['sudah_komuni'] == 'sudah') ...[
                              SizedBox(height: 10),
                              _buildProfileField('Tanggal Komuni',
                                  userProfile?['tanggal_komuni']),
                              SizedBox(height: 10),
                              _buildProfileField('Tempat Komuni',
                                  userProfile?['tempat_komuni']),
                            ],
                            SizedBox(height: 10),
                            _buildProfileField(
                                'Sudah Krisma', userProfile?['sudah_krisma']),
                            if (userProfile?['sudah_krisma'] == 'sudah') ...[
                              SizedBox(height: 10),
                              _buildProfileField('Tanggal Krisma',
                                  userProfile?['tanggal_krisma']),
                              SizedBox(height: 10),
                              _buildProfileField('Tempat Krisma',
                                  userProfile?['tempat_krisma']),
                            ],
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to edit profile screen
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: oren, // Background color
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'Edit Profile',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                final authProvider = Provider.of<AuthProvider>(
                                    context,
                                    listen: false);
                                authProvider.logout();
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red, // Background color
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'Logout',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            SizedBox(
                                height: 20), // Add some space at the bottom
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Anda belum mengisi profile-data anda, silahkan ke halaman home dan klik "lengkapi sekarang"',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false);
                            authProvider.logout();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // Background color
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildProfileField(String label, String? value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 3),
          Text(
            value ?? '',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
