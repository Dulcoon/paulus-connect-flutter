import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'detail_doa_screen.dart'; // Import halaman detail doa
import '../utils/constans.dart';
import 'package:flutter/cupertino.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';

class ListDoaScreen extends StatefulWidget {
  @override
  _ListDoaScreenState createState() => _ListDoaScreenState();
}

class _ListDoaScreenState extends State<ListDoaScreen> {
  List<Map<String, String>> allDoa = [
    {
      "title": "Aku Percaya",
      "content":
          "Aku percaya akan Allah, Bapa yang Maha Kuasa, pencipta langit dan bumi..."
    },
    {
      "title": "Bapa Kami",
      "content": "Bapa kami yang ada di surga, dimuliakanlah nama-Mu..."
    },
    {
      "title": "Salam Maria",
      "content": "Salam Maria, penuh rahmat, Tuhan sertamu..."
    },
    {
      "title": "Kemuliaan",
      "content": "Kemuliaan kepada Bapa, dan Putra, dan Roh Kudus..."
    },
  ];

  List<String> personalDoa = []; // Doa pribadi yang ditambahkan user
  List<String> favoriteDoa = []; // Doa favorit
  Map<String, String> reminders = {}; // Pengingat untuk doa

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadFavorites();
    _loadPersonalDoa();
    _loadReminders();
  }

  void _initializeNotifications() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteDoa = prefs.getStringList('favoriteDoa') ?? [];
    });
  }

  Future<void> _loadPersonalDoa() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      personalDoa = prefs.getStringList('personalDoa') ?? [];
    });
  }

  Future<void> _loadReminders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      reminders = {};
      prefs.getKeys().forEach((key) {
        if (key.startsWith('reminder_')) {
          final title = key.replaceFirst('reminder_', '');
          reminders[title] = prefs.getString(key) ?? '';
        }
      });
    });
    print("Pengingat yang dimuat: $reminders");
  }

  Future<void> _addPersonalDoa(String title, String content) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      personalDoa
          .add("$title|$content"); // Gabungkan judul dan isi dengan pemisah "|"
      prefs.setStringList('personalDoa', personalDoa);
    });
  }

  Future<void> _toggleFavorite(String doa) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      final title = doa.contains('|') ? doa.split('|')[0] : doa;

      if (favoriteDoa.contains(title)) {
        favoriteDoa.remove(title);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title dihapus dari favorit')),
        );
      } else {
        favoriteDoa.add(title);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title ditambahkan ke favorit')),
        );
      }
      prefs.setStringList('favoriteDoa', favoriteDoa);
    });
  }

  Future<void> _addReminder(String title, TimeOfDay time) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String reminderKey = "reminder_$title";
    String reminderValue = "${time.hour}:${time.minute}";
    print(time);

    await prefs.setString(reminderKey, reminderValue);

    setState(() {
      reminders[title] = reminderValue;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Pengingat untuk $title berhasil ditambahkan")),
    );

    _scheduleNotification(title, time);
    print("Pengingat untuk $title disetel pada ${time.hour}:${time.minute}");
  }

  Future<void> _scheduleNotification(String title, TimeOfDay time) async {
    var androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Pengingat Doa',
      channelDescription: 'Pengingat untuk berdoa',
      importance: Importance.high,
      priority: Priority.high,
      onlyAlertOnce: true,
    );
    var platformDetails = NotificationDetails(android: androidDetails);

    var now = tz.TZDateTime.now(tz.local);
    var scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Jika waktu yang dijadwalkan sudah berlalu, jadwalkan untuk hari berikutnya
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      title.hashCode, // Unique ID
      'Pengingat Doa',
      'Saatnya berdoa: $title',
      scheduledTime,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _deleteReminder(String title) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      reminders.remove(title);
    });
    await prefs.remove('reminder_$title');
    print("Pengingat untuk $title dihapus.");
  }

  Widget _buildDoaList(List<Map<String, String>> doaList) {
    return ListView.builder(
      itemCount: doaList.length,
      itemBuilder: (context, index) {
        final doa = doaList[index];
        final title = doa['title']!;
        final isFavorite = favoriteDoa.contains(title);
        final hasReminder = reminders.containsKey(title);

        return ListTile(
          title: Row(
            children: [
              Text(title),
              if (hasReminder)
                Icon(Icons.notifications, color: Colors.blue, size: 16),
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: isFavorite ? oren : Colors.grey,
            ),
            onPressed: () => _toggleFavorite(title),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailDoaScreen(
                  title: title,
                  content: doa['content']!,
                ),
              ),
            );
          },
          onLongPress: () {
            _showActionMenu(context, title);
          },
        );
      },
    );
  }

  void _showActionMenu(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text("Hapus Pengingat"),
              onTap: () {
                Navigator.pop(context);
                _deleteReminder(title);
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications, color: Colors.blue),
              title: Text("Tambahkan Pengingat"),
              onTap: () {
                Navigator.pop(context);
                _showReminderDialog(title);
              },
            ),
          ],
        );
      },
    );
  }

  void _showReminderDialog(String title) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      _addReminder(title, selectedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: bgCollor,
        appBar: AppBar(
          title: Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text(
                'Kumpulan Doa',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          backgroundColor: bgCollor,
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsets.all(9),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: oren,
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: Icon(
                  CupertinoIcons.back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          bottom: TabBar(
            indicatorColor: oren,
            labelColor: oren,
            unselectedLabelColor: Colors.black54,
            automaticIndicatorColorAdjustment: true,
            tabs: [
              Tab(text: "Semua Doa"),
              Tab(text: "Doa Pribadi"),
              Tab(text: "Favorit"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDoaList(allDoa),
            personalDoa.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Anda belum memiliki doa pribadi"),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            final Map<String, String>? newDoa =
                                await _showAddDoaDialog();
                            if (newDoa != null &&
                                newDoa['title'] != null &&
                                newDoa['content'] != null) {
                              _addPersonalDoa(
                                  newDoa['title']!, newDoa['content']!);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "Judul atau isi doa tidak boleh kosong")),
                              );
                            }
                          },
                          child: Text("Buat pengingat doa pribadi"),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      _buildDoaList(
                        personalDoa.map((doa) {
                          final parts = doa.split('|');
                          return {
                            "title": parts[0],
                            "content": parts.length > 1
                                ? parts[1]
                                : "Isi doa belum tersedia",
                          };
                        }).toList(),
                      ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: FloatingActionButton(
                          onPressed: () async {
                            final Map<String, String>? newDoa =
                                await _showAddDoaDialog();
                            if (newDoa != null &&
                                newDoa['title'] != null &&
                                newDoa['content'] != null) {
                              _addPersonalDoa(
                                  newDoa['title']!, newDoa['content']!);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "Judul atau isi doa tidak boleh kosong")),
                              );
                            }
                          },
                          backgroundColor: oren,
                          child: Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
            favoriteDoa.isEmpty
                ? Center(child: Text("Belum ada doa favorit"))
                : _buildDoaList(
                    [
                      ...allDoa,
                      ...personalDoa.map((doa) {
                        final parts = doa.split('|');
                        return {
                          "title": parts[0],
                          "content": parts.length > 1
                              ? parts[1]
                              : "Isi doa belum tersedia",
                        };
                      }).toList(),
                    ]
                        .where((doa) => favoriteDoa.contains(doa['title']))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, String>?> _showAddDoaDialog() async {
    String title = "";
    String content = "";
    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Tambah Doa Pribadi"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => title = value,
                decoration: InputDecoration(hintText: "Masukkan judul doa"),
              ),
              SizedBox(height: 10),
              TextField(
                onChanged: (value) => content = value,
                decoration: InputDecoration(hintText: "Masukkan isi doa"),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, {"title": title, "content": content}),
              child: Text("Simpan"),
            ),
          ],
        );
      },
    );
  }
}
