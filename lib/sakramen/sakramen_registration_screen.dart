import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/custom_date_field.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../utils/constans.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/notification_service.dart';

class SakramenRegistrationScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const SakramenRegistrationScreen({Key? key, required this.event})
      : super(key: key);

  @override
  _SakramenRegistrationScreenState createState() =>
      _SakramenRegistrationScreenState();
}

class _SakramenRegistrationScreenState extends State<SakramenRegistrationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? _defaultData;
  bool _isLoading = true;
  bool _isDarkMode = false;
  bool _isSubmitting = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
    _loadDefaultData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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
        NotificationService().showError(
          context,
          'Gagal memuat data. Silakan coba lagi.',
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      NotificationService().showError(
        context,
        'Token tidak valid. Silakan login ulang.',
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
      setState(() {
        _isSubmitting = true;
      });

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

          NotificationService().showSuccess(
            context,
            'Pendaftaran berhasil dikirim.',
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/sakramen-list',
            (route) => false,
          );
        } catch (e) {
          NotificationService().showError(
            context,
            'Gagal mengirim pendaftaran. Silakan coba lagi.',
          );
        } finally {
          setState(() {
            _isSubmitting = false;
          });
        }
      } else {
        setState(() {
          _isSubmitting = false;
        });
        NotificationService().showError(
          context,
          'Token tidak valid. Silakan login ulang.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pendaftaran ${widget.event['jenis_sakramen']}',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: oren,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
          ),
        ],
      ),
      backgroundColor: _isDarkMode ? Colors.grey[900] : bgCollor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personal Information Card
                      _buildSectionCard(
                        title: 'Informasi Pribadi',
                        icon: Icons.person,
                        children: [
                          _buildTextField(_namaLengkapController,
                              'Nama Lengkap', Icons.person_outline),
                          _buildTextField(_tempatLahirController,
                              'Tempat Lahir', Icons.location_on_outlined),
                          CustomDateField(
                            controller: _tanggalLahirController,
                            label: 'Tanggal Lahir',
                            onDateSelected: (date) {
                              _tanggalLahirController.text =
                                  "${date.toLocal()}".split(' ')[0];
                            },
                          ),
                          _buildDropdownField(),
                          _buildTextField(
                              _noHpController, 'No HP', Icons.phone_outlined),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Family Information Card
                      _buildSectionCard(
                        title: 'Informasi Keluarga',
                        icon: Icons.family_restroom,
                        children: [
                          _buildTextField(_namaAyahController, 'Nama Ayah',
                              Icons.person_2_outlined),
                          _buildTextField(_namaIbuController, 'Nama Ibu',
                              Icons.person_3_outlined),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Address Information Card
                      _buildSectionCard(
                        title: 'Informasi Alamat',
                        icon: Icons.location_city,
                        children: [
                          _buildTextField(_kecamatanController, 'Kecamatan',
                              Icons.location_city_outlined),
                          _buildTextField(_kelurahanController, 'Kelurahan',
                              Icons.home_work_outlined),
                          _buildTextField(_alamatLengkapController,
                              'Alamat Lengkap', Icons.home_outlined),
                          _buildTextField(_lingkunganController, 'Lingkungan',
                              Icons.near_me_outlined),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Documents Card
                      _buildSectionCard(
                        title: 'Dokumen',
                        icon: Icons.folder,
                        children: [
                          _buildFileUploader(
                            label: 'Upload Berkas KK',
                            file: _berkasKK,
                            onUpload: () => _pickFile('kk'),
                            icon: Icons.family_restroom,
                          ),
                          const SizedBox(height: 12),
                          _buildFileUploader(
                            label: 'Upload Akta Kelahiran',
                            file: _berkasAktaKelahiran,
                            onUpload: () => _pickFile('akta'),
                            icon: Icons.document_scanner,
                          ),
                          if (widget.event['jenis_sakramen'] == 'Komuni' ||
                              widget.event['jenis_sakramen'] == 'Krisma') ...[
                            const SizedBox(height: 12),
                            _buildFileUploader(
                              label: 'Upload Surat Baptis',
                              file: _berkasSuratBaptis,
                              onUpload: () => _pickFile('baptis'),
                              icon: Icons.church,
                            ),
                          ],
                          if (widget.event['jenis_sakramen'] == 'Krisma') ...[
                            const SizedBox(height: 12),
                            _buildFileUploader(
                              label: 'Upload Surat Komuni',
                              file: _berkasSuratKomuni,
                              onUpload: () => _pickFile('komuni'),
                              icon: Icons.church_outlined,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Submit Button
                      Container(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitRegistration,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: oren,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            shadowColor: oren.withOpacity(0.3),
                          ),
                          child: _isSubmitting
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  'Daftar',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData? icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: _isDarkMode ? Colors.grey[800] : Colors.white,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.green),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          labelText: label,
          prefixIcon: icon != null
              ? Icon(icon, color: _isDarkMode ? Colors.white70 : Colors.grey)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: _selectedJenisKelamin,
        decoration: InputDecoration(
          filled: true,
          fillColor: _isDarkMode ? Colors.grey[800] : Colors.white,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.green),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          labelText: 'Jenis Kelamin',
          prefixIcon:
              Icon(Icons.wc, color: _isDarkMode ? Colors.white70 : Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
        dropdownColor: _isDarkMode ? Colors.grey[800] : Colors.white,
        style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: _isDarkMode ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: oren, size: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildFileUploader({
    required String label,
    required File? file,
    required VoidCallback onUpload,
    IconData? icon,
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
              file == null ? (icon ?? Icons.upload_file) : Icons.check_circle,
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
