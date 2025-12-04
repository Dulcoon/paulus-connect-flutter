import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constans.dart';
import '../services/api_service.dart';
import '../screens/home_screen.dart';

class UserDataScreen extends StatefulWidget {
  const UserDataScreen({super.key});

  @override
  State<UserDataScreen> createState() => _UserDataScreenState();
}

class _UserDataScreenState extends State<UserDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaLengkapController = TextEditingController();
  final _noHpController = TextEditingController();
  final _namaAyahController = TextEditingController();
  final _namaIbuController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _kecamatanController = TextEditingController();
  final _alamatLengkapController = TextEditingController();
  final _tempatBaptisController = TextEditingController();
  final _tempatKomuniController = TextEditingController();
  final _tempatKrismaController = TextEditingController();
  final _tanggalBaptisController = TextEditingController();
  final _tanggalKomuniController = TextEditingController();
  final _tanggalKrismaController = TextEditingController();

  String? _selectedKelurahanId;
  String? _selectedJenisKelamin;
  String? _selectedBaptis;
  String? _selectedKomuni;
  String? _selectedKrisma;
  DateTime? _tanggalBaptis;
  DateTime? _tanggalKomuni;
  DateTime? _tanggalKrisma;

  List<Map<String, dynamic>> _wilayahList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWilayah();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadWilayah();
  }

  Future<void> _loadWilayah() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Token tidak valid')),
          );
        });
        return;
      }

      final wilayah = await ApiService.getWilayah();
      setState(() {
        _wilayahList = wilayah;
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data wilayah: $e')),
        );
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final confirm = await _showConfirmationDialog();
      if (!confirm) return;

      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;
      final token = authProvider.token;

      if (userId == null || token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User atau token tidak valid')),
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
        "sudah_baptis": _selectedBaptis,
        "tanggal_baptis":
            _selectedBaptis == 'sudah' ? _tanggalBaptisController.text : null,
        "tempat_baptis":
            _selectedBaptis == 'sudah' ? _tempatBaptisController.text : null,
        "sudah_komuni": _selectedKomuni,
        "tanggal_komuni":
            _selectedKomuni == 'sudah' ? _tanggalKomuniController.text : null,
        "tempat_komuni":
            _selectedKomuni == 'sudah' ? _tempatKomuniController.text : null,
        "sudah_krisma": _selectedKrisma,
        "tanggal_krisma":
            _selectedKrisma == 'sudah' ? _tanggalKrismaController.text : null,
        "tempat_krisma":
            _selectedKrisma == 'sudah' ? _tempatKrismaController.text : null,
      };

      try {
        await ApiService.saveUserData(token, userId, data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil disimpan')),
        );
        _clearFormFields();
        await _showSuccessDialog();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan data: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(
      BuildContext context, Function(DateTime) onSelected) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Konfirmasi'),
              content: Text('Apakah yakin ingin menyimpan data?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('Tidak'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('Ya'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sukses'),
          content: const Text('Data berhasil disimpan'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _clearFormFields() {
    _namaLengkapController.clear();
    _noHpController.clear();
    _namaAyahController.clear();
    _namaIbuController.clear();
    _tempatLahirController.clear();
    _tanggalLahirController.clear();
    _kecamatanController.clear();
    _alamatLengkapController.clear();
    _tempatBaptisController.clear();
    _tempatKomuniController.clear();
    _tempatKrismaController.clear();
    _tanggalBaptisController.clear();
    _tanggalKomuniController.clear();
    _tanggalKrismaController.clear();
    setState(() {
      _selectedJenisKelamin = null;
      _selectedBaptis = null;
      _selectedKomuni = null;
      _selectedKrisma = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCollor,
      appBar: AppBar(
        backgroundColor: oren,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          },
        ),
        title: const Text(
          'User Data',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 19, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Silahkan Lengkapi Data ',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: ' \nAnda',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: oren,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(_namaLengkapController, 'Nama Lengkap'),
                      _buildTextField(_noHpController, 'Nomor HP'),
                      _buildDropdownJenisKelamin(),
                      _buildTextField(_namaAyahController, 'Nama Ayah'),
                      _buildTextField(_namaIbuController, 'Nama Ibu'),
                      _buildTextField(_tempatLahirController, 'Tempat Lahir'),
                      _buildDateField(_tanggalLahirController, 'Tanggal Lahir'),
                      _buildTextField(
                          _kecamatanController, 'Kecamatan Tempat Tinggal'),
                      _buildDropdownWilayah(),
                      _buildTextField(
                          _alamatLengkapController, 'Alamat Lengkap'),
                      _buildSakramenDropdown('Baptis', _selectedBaptis,
                          (value) {
                        setState(() {
                          _selectedBaptis = value;
                        });
                      }),
                      if (_selectedBaptis == 'sudah') ...[
                        _buildDateField(
                            _tanggalBaptisController, 'Tanggal Baptis'),
                        _buildTextField(
                            _tempatBaptisController, 'Tempat Baptis'),
                      ],
                      _buildSakramenDropdown('Komuni', _selectedKomuni,
                          (value) {
                        setState(() {
                          _selectedKomuni = value;
                        });
                      }),
                      if (_selectedKomuni == 'sudah') ...[
                        _buildDateField(
                            _tanggalKomuniController, 'Tanggal Komuni'),
                        _buildTextField(
                            _tempatKomuniController, 'Tempat Komuni'),
                      ],
                      _buildSakramenDropdown('Krisma', _selectedKrisma,
                          (value) {
                        setState(() {
                          _selectedKrisma = value;
                        });
                      }),
                      if (_selectedKrisma == 'sudah') ...[
                        _buildDateField(
                            _tanggalKrismaController, 'Tanggal Krisma'),
                        _buildTextField(
                            _tempatKrismaController, 'Tempat Krisma'),
                      ],
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: oren,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: _submitForm,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 21,
                                  width: 21,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : const Text("Submit",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 40)
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDropdownJenisKelamin() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Theme(
        data: ThemeData(
          primaryColor: oren,
          colorScheme: const ColorScheme.light(primary: oren),
        ),
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
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Theme(
        data: ThemeData(
          primaryColor: oren,
          colorScheme: const ColorScheme.light(primary: oren),
        ),
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
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () => _selectDate(context, (date) {
          setState(() {
            controller.text = "${date.toLocal()}".split(' ')[0];
          });
        }),
        child: IgnorePointer(
          child: Theme(
            data: ThemeData(
              primaryColor: oren,
              colorScheme: const ColorScheme.light(primary: oren),
            ),
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
      ),
    );
  }

  Widget _buildDropdownWilayah() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Theme(
        data: ThemeData(
          primaryColor: oren,
          colorScheme: const ColorScheme.light(primary: oren),
        ),
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
      ),
    );
  }

  Widget _buildSakramenDropdown(
      String label, String? value, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Theme(
        data: ThemeData(
          primaryColor: oren,
          colorScheme: const ColorScheme.light(primary: oren),
        ),
        child: DropdownButtonFormField<String>(
          value: value,
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
          items: ['sudah', 'belum'].map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(status),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select $label';
            }
            return null;
          },
        ),
      ),
    );
  }
}
