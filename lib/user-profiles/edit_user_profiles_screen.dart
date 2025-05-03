import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../utils/constans.dart';
import '../screens/profile_screen.dart';

class EditUserProfileScreen extends StatefulWidget {
  const EditUserProfileScreen({super.key});

  @override
  State<EditUserProfileScreen> createState() => _EditUserProfileScreenState();
}

class _EditUserProfileScreenState extends State<EditUserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaLengkapController = TextEditingController();
  final _noHpController = TextEditingController();
  final _namaAyahController = TextEditingController();
  final _namaIbuController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _kecamatanController = TextEditingController();
  final _alamatLengkapController = TextEditingController();
  final _baptisController = TextEditingController();
  final _tanggalBaptisController = TextEditingController();
  final _tempatBaptisController = TextEditingController();
  final _komuniController = TextEditingController();
  final _tanggalKomuniController = TextEditingController();
  final _tempatKomuniController = TextEditingController();
  final _krismaController = TextEditingController();
  final _tanggalKrismaController = TextEditingController();
  final _tempatKrismaController = TextEditingController();

  String? _selectedJenisKelamin;
  String? _selectedKelurahanId;
  List<Map<String, dynamic>> _wilayahList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadWilayah();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProfile = authProvider.userProfile;

    if (userProfile != null) {
      setState(() {
        _namaLengkapController.text = userProfile['nama_lengkap'] ?? '';
        _noHpController.text = userProfile['no_hp'] ?? '';
        _namaAyahController.text = userProfile['nama_ayah'] ?? '';
        _namaIbuController.text = userProfile['nama_ibu'] ?? '';
        _tempatLahirController.text = userProfile['tempat_lahir'] ?? '';
        _tanggalLahirController.text = userProfile['tanggal_lahir'] ?? '';
        _kecamatanController.text =
            userProfile['kecamatan_tempat_tinggal'] ?? '';
        _alamatLengkapController.text = userProfile['alamat_lengkap'] ?? '';
        _selectedJenisKelamin = userProfile['kelamin'];
        _selectedKelurahanId = userProfile['kelurahan_id']?.toString();
        _baptisController.text = userProfile['sudah_baptis'] ?? 'belum';
        _tanggalBaptisController.text = userProfile['tanggal_baptis'] ?? '';
        _tempatBaptisController.text = userProfile['tempat_baptis'] ?? '';
        _komuniController.text = userProfile['sudah_komuni'] ?? 'belum';
        _tanggalKomuniController.text = userProfile['tanggal_komuni'] ?? '';
        _tempatKomuniController.text = userProfile['tempat_komuni'] ?? '';
        _krismaController.text = userProfile['sudah_krisma'] ?? 'belum';
        _tanggalKrismaController.text = userProfile['tanggal_krisma'] ?? '';
        _tempatKrismaController.text = userProfile['tempat_krisma'] ?? '';
      });
    }
  }

  Future<void> _loadWilayah() async {
    try {
      final wilayah = await ApiService.getWilayah();
      setState(() {
        _wilayahList = wilayah;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data wilayah: $e')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token tidak valid')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final data = {
        "nama_lengkap": _namaLengkapController.text,
        "no_hp": _noHpController.text,
        "nama_ayah": _namaAyahController.text,
        "nama_ibu": _namaIbuController.text,
        "tempat_lahir": _tempatLahirController.text,
        "tanggal_lahir": _tanggalLahirController.text,
        "kelamin": _selectedJenisKelamin,
        "kecamatan_tempat_tinggal": _kecamatanController.text,
        "kelurahan_id": _selectedKelurahanId,
        "alamat_lengkap": _alamatLengkapController.text,
        "sudah_baptis": _baptisController.text,
        "tanggal_baptis": _tanggalBaptisController.text.isEmpty
            ? null
            : _tanggalBaptisController.text,
        "tempat_baptis": _tempatBaptisController.text.isEmpty
            ? null
            : _tempatBaptisController.text,
        "sudah_komuni": _komuniController.text,
        "tanggal_komuni": _tanggalKomuniController.text.isEmpty
            ? null
            : _tanggalKomuniController.text,
        "tempat_komuni": _tempatKomuniController.text.isEmpty
            ? null
            : _tempatKomuniController.text,
        "sudah_krisma": _krismaController.text,
        "tanggal_krisma": _tanggalKrismaController.text.isEmpty
            ? null
            : _tanggalKrismaController.text,
        "tempat_krisma": _tempatKrismaController.text.isEmpty
            ? null
            : _tempatKrismaController.text,
      };

      try {
        await ApiService.updateUserProfile(token, data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui profil: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCollor,
      appBar: AppBar(
        backgroundColor: oren,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 19,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            ); // Kembali ke halaman sebelumnya
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Bagian Data Diri
                      const Text(
                        'Data Diri',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: oren,
                        ),
                      ),
                      const Divider(color: oren, thickness: 1),
                      const SizedBox(
                        height: 10,
                      ),
                      _buildTextField(_namaLengkapController, 'Nama Lengkap'),
                      _buildTextField(_noHpController, 'Nomor HP'),
                      _buildDropdownJenisKelamin(),
                      _buildTextField(_namaAyahController, 'Nama Ayah'),
                      _buildTextField(_namaIbuController, 'Nama Ibu'),
                      _buildTextField(_tempatLahirController, 'Tempat Lahir'),
                      _buildDateField(_tanggalLahirController, 'Tanggal Lahir'),

                      const SizedBox(height: 20),

                      // Bagian Alamat
                      const Text(
                        'Alamat',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: oren,
                        ),
                      ),
                      const Divider(color: oren, thickness: 1),
                      const SizedBox(
                        height: 10,
                      ),
                      _buildTextField(
                          _kecamatanController, 'Kecamatan Tempat Tinggal'),
                      _buildDropdownWilayah(),
                      _buildTextField(
                          _alamatLengkapController, 'Alamat Lengkap'),

                      const SizedBox(height: 20),

                      // Bagian Sakramen
                      const Text(
                        'Data Sakramen',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: oren,
                        ),
                      ),
                      const Divider(color: oren, thickness: 1),
                      const SizedBox(
                        height: 10,
                      ),
                      _buildDropdownField(_baptisController, 'Sudah Baptis',
                          ['sudah', 'belum']),
                      if (_baptisController.text == 'sudah') ...[
                        _buildDateField(
                            _tanggalBaptisController, 'Tanggal Baptis'),
                        _buildTextField(
                            _tempatBaptisController, 'Tempat Baptis'),
                      ],
                      _buildDropdownField(_komuniController, 'Sudah Komuni',
                          ['sudah', 'belum']),
                      if (_komuniController.text == 'sudah') ...[
                        _buildDateField(
                            _tanggalKomuniController, 'Tanggal Komuni'),
                        _buildTextField(
                            _tempatKomuniController, 'Tempat Komuni'),
                      ],
                      _buildDropdownField(_krismaController, 'Sudah Krisma',
                          ['sudah', 'belum']),
                      if (_krismaController.text == 'sudah') ...[
                        _buildDateField(
                            _tanggalKrismaController, 'Tanggal Krisma'),
                        _buildTextField(
                            _tempatKrismaController, 'Tempat Krisma'),
                      ],

                      const SizedBox(height: 30),

                      // Tombol Simpan
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: oren,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5, // Efek bayangan
                          shadowColor: Colors.black,
                        ),
                        onPressed: _submitForm,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'Simpan',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: oren),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: bgCollor),
          ),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownJenisKelamin() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: _selectedJenisKelamin,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: oren),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: bgCollor),
          ),
          labelText: 'Jenis Kelamin',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
        items: ['Laki-Laki', 'Perempuan'].map((jenisKelamin) {
          return DropdownMenuItem(
            value: jenisKelamin,
            child: Text(jenisKelamin),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedJenisKelamin = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select Jenis Kelamin';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownWilayah() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: _selectedKelurahanId,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: oren),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: bgCollor),
          ),
          labelText: 'Wilayah',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
        items: _wilayahList.map((wilayah) {
          return DropdownMenuItem(
            value: wilayah['id'].toString(),
            child: Text(wilayah['nama_wilayah']),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedKelurahanId = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select Wilayah';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            setState(() {
              controller.text = "${picked.toLocal()}".split(' ')[0];
            });
          }
        },
        child: IgnorePointer(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: oren),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: bgCollor),
              ),
              labelText: label,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
      TextEditingController controller, String label, List<String> options) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: controller.text.isNotEmpty ? controller.text : null,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: oren),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: bgCollor),
          ),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            controller.text = value ?? '';
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select $label';
          }
          return null;
        },
      ),
    );
  }
}
