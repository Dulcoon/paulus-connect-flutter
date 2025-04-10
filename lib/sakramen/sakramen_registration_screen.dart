import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/custom_date_field.dart'; // Import CustomDateField
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../utils/constans.dart';

class SakramenRegistrationScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const SakramenRegistrationScreen({Key? key, required this.event})
      : super(key: key);

  @override
  _SakramenRegistrationScreenState createState() =>
      _SakramenRegistrationScreenState();
}

class _SakramenRegistrationScreenState
    extends State<SakramenRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? _defaultData;
  bool _isLoading = true;

  String? _selectedJenisKelamin;

  // Controllers untuk form field
  final TextEditingController _namaLengkapController = TextEditingController();
  final TextEditingController _tempatLahirController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _namaAyahController = TextEditingController();
  final TextEditingController _namaIbuController = TextEditingController();
  final TextEditingController _kecamatanController = TextEditingController();
  final TextEditingController _kelurahanController = TextEditingController();
  final TextEditingController _alamatLengkapController =
      TextEditingController();
  final TextEditingController _lingkunganController = TextEditingController();

  // File uploader
  File? _berkasKK;
  File? _berkasAktaKelahiran;
  File? _berkasSuratBaptis;
  File? _berkasSuratKomuni;

  @override
  void initState() {
    super.initState();
    _loadDefaultData();
  }

  Future<void> _loadDefaultData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token != null) {
      try {
        final data = await ApiService.fetchDefaultData(token);
        setState(() {
          _defaultData = data;
          _isLoading = false;
          _selectedJenisKelamin = data['kelamin'];

          // Isi nilai default ke dalam controller
          _namaLengkapController.text = data['nama'] ?? '';
          _tempatLahirController.text = data['tempat_lahir'] ?? '';
          _tanggalLahirController.text = data['tanggal_lahir'] ?? '';
          _namaAyahController.text = data['nama_ayah'] ?? '';
          _namaIbuController.text = data['nama_ibu'] ?? '';
          _kecamatanController.text = data['kecamatan'] ?? '';
          _kelurahanController.text = data['kelurahan'] ?? '';
          _alamatLengkapController.text = data['alamat'] ?? '';
          _lingkunganController.text = data['lingkungan'] ?? '';
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data default: $e')),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token tidak valid. Silakan login ulang.')),
      );
    }
  }

  Future<void> _pickFile(String fileType) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        switch (fileType) {
          case 'kk':
            _berkasKK = File(result.files.single.path!);
            break;
          case 'akta':
            _berkasAktaKelahiran = File(result.files.single.path!);
            break;
          case 'baptis':
            _berkasSuratBaptis = File(result.files.single.path!);
            break;
          case 'komuni':
            _berkasSuratKomuni = File(result.files.single.path!);
            break;
        }
      });
    }
  }

  Future<void> _submitRegistration() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token != null) {
        try {
          final data = {
            'sakramen_event_id': widget.event['id'],
            'nama_lengkap': _namaLengkapController.text,
            'tempat_lahir': _tempatLahirController.text,
            'tanggal_lahir': _tanggalLahirController.text,
            'jenis_kelamin': _selectedJenisKelamin,
            'nama_ayah': _namaAyahController.text,
            'nama_ibu': _namaIbuController.text,
            'kecamatan': _kecamatanController.text,
            'kelurahan': _kelurahanController.text,
            'alamat_lengkap': _alamatLengkapController.text,
            'lingkungan': _lingkunganController.text,
          };

          final files = {
            'berkas_kk': _berkasKK,
            'berkas_akta_kelahiran': _berkasAktaKelahiran,
            'berkas_surat_baptis': _berkasSuratBaptis,
            'berkas_surat_komuni': _berkasSuratKomuni,
          };

          await ApiService.submitRegistrationWithFiles(token, data, files);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pendaftaran berhasil!')),
          );
          Navigator.pushNamed(
              context, '/sakramen-list'); // Kembali ke halaman sebelumnya
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mendaftarkan: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Token tidak valid. Silakan login ulang.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pendaftaran ${widget.event['jenis_sakramen']}',
            style: TextStyle(color: Colors.white)),
        backgroundColor: oren,
        foregroundColor: Colors.white,
      ),
      backgroundColor: bgCollor,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(_namaLengkapController, 'Nama Lengkap'),
                    _buildTextField(_tempatLahirController, 'Tempat Lahir'),
                    CustomDateField(
                      controller: _tanggalLahirController,
                      label: 'Tanggal Lahir',
                      onDateSelected: (date) {
                        _tanggalLahirController.text =
                            "${date.toLocal()}".split(' ')[0];
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: DropdownButtonFormField<String>(
                        value: _selectedJenisKelamin,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.green),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          labelText: 'Jenis Kelamin',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)),
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
                    ),
                    _buildTextField(_namaAyahController, 'Nama Ayah'),
                    _buildTextField(_namaIbuController, 'Nama Ibu'),
                    _buildTextField(_kecamatanController, 'Kecamatan'),
                    _buildTextField(_kelurahanController, 'Kelurahan'),
                    _buildTextField(_alamatLengkapController, 'Alamat Lengkap'),
                    _buildTextField(_lingkunganController, 'Lingkungan'),
                    SizedBox(height: 20),

                    // File Uploaders
                    ElevatedButton(
                      onPressed: () => _pickFile('kk'),
                      child: Text(_berkasKK == null
                          ? 'Upload Berkas KK'
                          : 'Berkas KK Terpilih'),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _pickFile('akta'),
                      child: Text(_berkasAktaKelahiran == null
                          ? 'Upload Akta Kelahiran'
                          : 'Akta Kelahiran Terpilih'),
                    ),
                    if (widget.event['jenis_sakramen'] == 'komuni' ||
                        widget.event['jenis_sakramen'] == 'krisma') ...[
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _pickFile('baptis'),
                        child: Text(_berkasSuratBaptis == null
                            ? 'Upload Surat Baptis'
                            : 'Surat Baptis Terpilih'),
                      ),
                    ],
                    if (widget.event['jenis_sakramen'] == 'krisma') ...[
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _pickFile('komuni'),
                        child: Text(_berkasSuratKomuni == null
                            ? 'Upload Surat Komuni'
                            : 'Surat Komuni Terpilih'),
                      ),
                    ],
                    SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _submitRegistration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: oren,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Daftar',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
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
            borderSide: const BorderSide(color: Colors.green),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
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
}
