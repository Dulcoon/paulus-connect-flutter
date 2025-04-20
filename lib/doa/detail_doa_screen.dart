import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/cupertino.dart';
import '../utils/constans.dart';
import '../main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class DetailDoaScreen extends StatefulWidget {
  final String title;
  final String content;

  const DetailDoaScreen({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  _DetailDoaScreenState createState() => _DetailDoaScreenState();
}

class _DetailDoaScreenState extends State<DetailDoaScreen> {
  final FlutterTts _flutterTts = FlutterTts();

  bool _isPlaying = false;
  bool _isPaused = false;
  bool _showAssistButtons = false;

  double _fontSize = 18.0;
  List<String> _lines = [];
  Set<int> _readLineIndexes = {};
  double _maxWidth = 0;
  List<dynamic> _voices = [];

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maxWidth = MediaQuery.of(context).size.width - 50;
    _splitContentIntoLines();
  }

  Future<void> _scheduleNotification(String title, TimeOfDay time) async {
    print(
        "Menjadwalkan notifikasi untuk $title pada ${time.hour}:${time.minute}");

    var androidDetails = AndroidNotificationDetails(
      'channelId',
      'channelName',
      importance: Importance.high,
      priority: Priority.high,
    );
    var platformDetails = NotificationDetails(android: androidDetails);

    var now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Konversi DateTime ke TZDateTime
    final tz.TZDateTime tzScheduledTime =
        tz.TZDateTime.from(scheduledTime, tz.local);

    print("Notifikasi dijadwalkan pada $tzScheduledTime");

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Pengingat Doa',
      'Saatnya berdoa: $title',
      tzScheduledTime,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    print("Notifikasi berhasil dijadwalkan.");
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("id-ID");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.4);

    _voices = await _flutterTts.getVoices;

    _flutterTts.setProgressHandler((text, start, end, word) {
      setState(() {
        int lineIndex = _findLineIndexByWord(word);
        if (lineIndex != -1) {
          _readLineIndexes.add(lineIndex);
        }
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isPlaying = false;
        _readLineIndexes.clear();
      });
    });

    // Set default voice
  }

  String _prepareTextForTts(String text) {
    return text.replaceAll("Allah", "Alah");
  }

  Future<void> _speak() async {
    String modifiedContent = _prepareTextForTts(widget.content);
    await _flutterTts.speak(modifiedContent);
    setState(() {
      _isPlaying = true;
      _isPaused = false;
    });
  }

  Future<void> _pause() async {
    await _flutterTts.pause();
    setState(() {
      _isPlaying = false;
      _isPaused = true;
    });
  }

  Future<void> _stop() async {
    await _flutterTts.stop();
    setState(() {
      _isPlaying = false;
      _isPaused = false;
      _readLineIndexes.clear();
    });
  }

  void _increaseFontSize() {
    setState(() {
      _fontSize += 2;
      _splitContentIntoLines();
    });
  }

  void _decreaseFontSize() {
    setState(() {
      if (_fontSize > 12) {
        _fontSize -= 2;
        _splitContentIntoLines();
      }
    });
  }

  void _splitContentIntoLines() {
    if (_maxWidth == 0) return;

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: widget.content,
        style: TextStyle(fontSize: _fontSize),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.start,
      maxLines: null,
    );

    textPainter.layout(maxWidth: _maxWidth);

    final lines = <String>[];
    final text = widget.content;
    int start = 0;

    for (var lineMetrics in textPainter.computeLineMetrics()) {
      int end = textPainter
          .getPositionForOffset(Offset(_maxWidth, lineMetrics.baseline))
          .offset;
      if (end <= start) end = text.length;
      lines.add(text.substring(start, end).trim());
      start = end;
    }

    setState(() {
      _lines = lines;
      _readLineIndexes.clear();
    });
  }

  int _findLineIndexByWord(String word) {
    String normalizedWord = word.toLowerCase();
    for (int i = 0; i < _lines.length; i++) {
      if (_lines[i].toLowerCase().contains(normalizedWord)) {
        return i;
      }
    }
    return -1;
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCollor,
      appBar: AppBar(
        backgroundColor: bgCollor,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Stack(
            children: [
              // Tombol Back
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: oren,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.center,
                      child: Icon(CupertinoIcons.back, color: Colors.white),
                    ),
                  ),
                ),
              ),
              // Judul
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _lines.asMap().entries.map((entry) {
                    final index = entry.key;
                    final line = entry.value;
                    final isRead = _readLineIndexes.contains(index);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Text(
                        line,
                        style: TextStyle(
                          fontSize: _fontSize,
                          color: isRead ? Colors.black : Colors.black54,
                          fontWeight:
                              isRead ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showAssistButtons = !_showAssistButtons;
                });
              },
              child: Text(
                _showAssistButtons ? "Sembunyikan Kontrol" : "Dengarkan",
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: oren,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
            if (_showAssistButtons) const SizedBox(height: 10),
            if (_showAssistButtons)
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 20,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isPlaying ? _pause : _speak,
                        icon: Icon(
                          _isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_fill,
                          color: Colors.white,
                        ),
                        label: Text(_isPlaying ? "Pause" : "Play"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _stop,
                        icon: Icon(Icons.stop_circle, color: Colors.white),
                        label: Text("Stop"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: _isPlaying ? null : _decreaseFontSize,
                            icon: Icon(Icons.text_decrease,
                                color: _isPlaying ? Colors.grey : Colors.black),
                          ),
                          Text("Ukuran Teks", style: TextStyle(fontSize: 16)),
                          IconButton(
                            onPressed: _isPlaying ? null : _increaseFontSize,
                            icon: Icon(Icons.text_increase,
                                color: _isPlaying ? Colors.grey : Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
