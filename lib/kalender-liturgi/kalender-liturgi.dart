import 'package:flutter/material.dart';
import '../utils/constans.dart';
import '../services/api_service.dart';
import 'package:flutter/cupertino.dart';

class KalenderLiturgiScreen extends StatefulWidget {
  const KalenderLiturgiScreen({super.key});

  @override
  _KalenderLiturgiScreenState createState() => _KalenderLiturgiScreenState();
}

class _KalenderLiturgiScreenState extends State<KalenderLiturgiScreen> {
  String _selectedDate =
      "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
  Map<String, dynamic>? _liturgiData;
  bool _isLoading = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchLiturgiData(_selectedDate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  void _scrollToSelectedDate() {
    final DateTime startDate =
        DateTime.now().subtract(const Duration(days: 15));
    final DateTime selectedDate = DateTime.parse(_selectedDate);

    final int selectedIndex = selectedDate.difference(startDate).inDays;

    _scrollController.jumpTo(selectedIndex * 64.0);
  }

  Future<void> _fetchLiturgiData(String date) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await ApiService.fetchLiturgiByDate(date);

      setState(() {
        _liturgiData = data;
      });
    } catch (e) {
      setState(() {
        _liturgiData = null;
      });
      print("Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime startDate =
        DateTime.now().subtract(const Duration(days: 15));
    final DateTime endDate = DateTime.now().add(const Duration(days: 15));
    final List<DateTime> _datesInRange = List.generate(
      endDate.difference(startDate).inDays + 1,
      (index) => startDate.add(Duration(days: index)),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Kalender Liturgi",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Text(
                  _selectedDate.split('-')[2],
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${_getDayName(DateTime.parse(_selectedDate))}, ${_getMonthName(DateTime.parse(_selectedDate))} ${_selectedDate.split('-')[0]}",
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 80,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: _datesInRange.length,
              itemBuilder: (context, index) {
                final date = _datesInRange[index];
                final isSelected = _selectedDate ==
                    "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate =
                          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                    });
                    _fetchLiturgiData(_selectedDate);
                  },
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? oren : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? oren : Colors.grey,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getDayName(date, short: true),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildLiturgiDetail(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiturgiDetail() {
    if (_liturgiData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            const Text(
              "Tidak Ada Data Liturgi",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Silakan pilih tanggal lain untuk melihat data liturgi.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _liturgiData!['title'] ?? "Judul tidak tersedia",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLiturgiRow("Warna Liturgi",
                    _liturgiData!['warna_liturgi'] ?? "Tidak tersedia"),
                const Divider(color: Colors.grey, height: 24),
                _buildLiturgiRow(
                    "Bacaan I", _liturgiData!['bacaan1'] ?? "Tidak tersedia"),
                const Divider(color: Colors.grey, height: 24),
                _buildLiturgiRow(
                    "Mazmur", _liturgiData!['mazmur'] ?? "Tidak tersedia"),
                const Divider(color: Colors.grey, height: 24),
                _buildLiturgiRow(
                    "Bacaan II", _liturgiData!['bacaan2'] ?? "Tidak tersedia"),
                const Divider(color: Colors.grey, height: 24),
                _buildLiturgiRow("Bait Pengantar Injil",
                    _liturgiData!['bait_pengantar'] ?? "Tidak tersedia"),
                const Divider(color: Colors.grey, height: 24),
                _buildLiturgiRow("Bacaan Injil",
                    _liturgiData!['bacaan_injil'] ?? "Tidak tersedia"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiturgiRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label : ",
            style: const TextStyle(fontWeight: FontWeight.normal),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(DateTime date, {bool short = false}) {
    const days = [
      "Minggu",
      "Senin",
      "Selasa",
      "Rabu",
      "Kamis",
      "Jumat",
      "Sabtu"
    ];
    const shortDays = ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"];
    return short ? shortDays[date.weekday % 7] : days[date.weekday % 7];
  }

  String _getMonthName(DateTime date) {
    const months = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember"
    ];
    return months[date.month - 1];
  }
}
