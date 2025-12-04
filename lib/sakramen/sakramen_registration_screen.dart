import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/custom_date_field.dart';
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

  final TextEditingController _namaLengkapController = TextEditingController();
  final TextEditingController _tempatLahirController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _namaAyahController = TextEditingController();
  final TextEditingController _namaIbuController = TextEditingController();
  final TextEditingController _kecamatanController = TextEditingController();
  final TextEditingController _kelurahanController = TextEditingController();
  final TextEditingController _alamatLengkapController =
      TextEditingController();
  final TextEditingController _lingkunganController = TextEditingController();

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

          _namaLengkapController.text = data['nama'] ?? '';
          _tempatLahirController.text = data['tempat_lahir'] ?? '';
          _tanggalLahirController.text = data['tanggal_lahir'] ?? '';
          _namaAyahController.text = data['nama_ayah'] ?? '';
          _namaIbuController.text = data['nama_ibu'] ?? '';
          _kecamatanController.text = data['kecamatan'] ?? '';
          _kelurahanController.text = data['kelurahan'] ?? '';
          _alamatLengkapController.text = data['alamat'] ?? '';
          _lingkunganController.text = data['lingkungan'] ?? '';
          _noHpController.text = data['no_hp'] ?? '';
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
        const SnackBar(
            content: Text('Token tidak valid. Silakan login ulang.')),
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
            'no_hp': _noHpController.text,
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
            const SnackBar(content: Text('Pendaftaran berhasil!')),
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/sakramen-list',
            (route) => false,
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mendaftarkan: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Token tidak valid. Silakan login ulang.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pendaftaran ${widget.event['jenis_sakramen']}',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: oren,
        foregroundColor: Colors.white,
      ),
      backgroundColor: bgCollor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                    _buildTextField(_noHpController, 'No HP'),
                    _buildTextField(_namaAyahController, 'Nama Ayah'),
                    _buildTextField(_namaIbuController, 'Nama Ibu'),
                    _buildTextField(_kecamatanController, 'Kecamatan'),
                    _buildTextField(_kelurahanController, 'Kelurahan'),
                    _buildTextField(_alamatLengkapController, 'Alamat Lengkap'),
                    _buildTextField(_lingkunganController, 'Lingkungan'),
                    const SizedBox(height: 20),
                    _buildFileUploader(
                      label: 'Upload Berkas KK',
                      file: _berkasKK,
                      onUpload: () => _pickFile('kk'),
                    ),
                    const SizedBox(height: 10),
                    _buildFileUploader(
                      label: 'Upload Akta Kelahiran',
                      file: _berkasAktaKelahiran,
                      onUpload: () => _pickFile('akta'),
                    ),
                    if (widget.event['jenis_sakramen'] == 'Komuni' ||
                        widget.event['jenis_sakramen'] == 'Krisma') ...[
                      const SizedBox(height: 10),
                      _buildFileUploader(
                        label: 'Upload Surat Baptis',
                        file: _berkasSuratBaptis,
                        onUpload: () => _pickFile('baptis'),
                      ),
                    ],
                    if (widget.event['jenis_sakramen'] == 'Krisma') ...[
                      const SizedBox(height: 10),
                      _buildFileUploader(
                        label: 'Upload Surat Komuni',
                        file: _berkasSuratKomuni,
                        onUpload: () => _pickFile('komuni'),
                      ),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitRegistration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: oren,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size.fromHeight(50),
                        elevation: 3,
                      ),
                      child: const Text(
                        'Daftar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildFileUploader({
    required String label,
    required File? file,
    required VoidCallback onUpload,
  }) {
    return GestureDetector(
      onTap: onUpload,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: file == null ? orenKalem : Colors.green,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
          color: file == null
              ? orenKalem.withOpacity(0.1)
              : Colors.green.withOpacity(0.1),
        ),
        child: Row(
          children: [
            Icon(
              file == null ? Icons.upload_file : Icons.check_circle,
              color: file == null ? orenKalem : Colors.green,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                file == null ? label : 'File berhasil diunggah',
                style: TextStyle(
                  color: file == null ? orenKalem : Colors.green,
                  fontSize: 16,
                ),
              ),
            ),
            if (file != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    if (label.contains('KK')) _berkasKK = null;
                    if (label.contains('Akta')) _berkasAktaKelahiran = null;
                    if (label.contains('Baptis')) _berkasSuratBaptis = null;
                    if (label.contains('Komuni')) _berkasSuratKomuni = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
