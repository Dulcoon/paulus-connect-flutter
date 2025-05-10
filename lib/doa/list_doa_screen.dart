import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'detail_doa_screen.dart';
import '../utils/constans.dart';
import 'package:flutter/cupertino.dart';
import 'package:timezone/timezone.dart' as tz;

class ListDoaScreen extends StatefulWidget {
  const ListDoaScreen({super.key});

  @override
  _ListDoaScreenState createState() => _ListDoaScreenState();
}

class _ListDoaScreenState extends State<ListDoaScreen> {
  List<Map<String, String>> allDoa = [
    {
      "title": "Aku Percaya",
      "content":
          "Aku percaya akan Allah, Bapa yang Maha Kuasa, pencipta langit dan bumi dan akan Yesus Kristus, Putra-Nya yang tunggal Tuhan kita, yang dikandung dari Roh Kudus, dilahirkan oleh perawan Maria, yang menderita sengsara dalam pemerintahan Pontius Pilatus, disalibkan wafat dan dimakamkan, yang turun ke tempat penantian, pada hari ketiga bangkit dari antara orang mati, yang naik ke surga, duduk di sebelah kanan Allah Bapa yang Maha Kuasa, dari situ Ia akan datang mengadili orang yang hidup dan yang mati. Aku percaya akan Roh Kudus, gereja yang kudus dan am, persekutuan para kudus, pengampunan dosa, kebangkitan tubuh dan hidup kekal. Amin."
    },
    {
      "title": "Bapa Kami",
      "content":
          "Bapa kami yang ada di surga, dimuliakanlah nama-Mu, datanglah kerajaan-Mu, jadilah kehendak-Mu di atas bumi seperti di dalam surga. Berilah kami rezeki pada hari ini, dan ampunilah kesalahan kami, seperti kami pun mengampuni yang bersalah kepada kami. Dan janganlah masukkan kami ke dalam pencobaan, tetapi lepaskanlah kami dari yang jahat. Amin."
    },
    {
      "title": "Salam Maria",
      "content":
          "Salam Maria, penuh rahmat, Tuhan sertamu, terpujilah engkau di antara wanita dan terpujilah buah tubuhmu, Yesus. Santa Maria, Bunda Allah, doakanlah kami yang berdosa ini, sekarang dan pada waktu kami mati. Amin."
    },
    {
      "title": "Kemuliaan",
      "content":
          "Kemuliaan kepada Bapa, dan Putra, dan Roh Kudus, seperti pada permulaan, sekarang, selalu, dan sepanjang segala abad. Amin."
    },
    {
      "title": "Terpujhilah",
      "content":
          "Terpujilah engkau, ya Tuhan, Raja semesta alam, sebab dari kemurahan-Mu kami menerima roti yang kami siapkan ini. Kami persembahkan kepada-Mu, sebagai hasil dari bumi dan usaha manusia. Semoga menjadi bagi kami roti kehidupan."
    },
    {
      "title": "Ya Yesus Yang Baik",
      "content":
          "Ya Yesus yang baik, ampunilah dosa-dosa kami, selamatkanlah kami dari Api neraka, dan bawalah jiwa-jiwa ke dalam surga, terutama mereka yang sangat membutuhkan Kerahimanmu-Mu. Amin."
    },
    {
      "title": "Angelus",
      "content":
          "Maria diberi kabar oleh malaikat Tuhan, bahwa ia akan mengandung dari Roh Kudus, \nSalam Maria, penuh rahmat, Tuhan sertamu, terpujilah engkau di antara wanita dan terpujilah buah tubuhmu, Yesus. Santa Maria, Bunda Allah, doakanlah kami yang berdosa ini, sekarang dan pada waktu kami mati. Amin. \n Aku ini hamba Tuhan, Terjadilah padaku menurut perkataanmu, \nSalam Maria, penuh rahmat, Tuhan sertamu, terpujilah engkau di antara wanita dan terpujilah buah tubuhmu, Yesus. Santa Maria, Bunda Allah, doakanlah kami yang berdosa ini, sekarang dan pada waktu kami mati. Amin.\nSabda sudah menjadi daging, dan tinggal diantara kita,\nSalam Maria, penuh rahmat, Tuhan sertamu, terpujilah engkau di antara wanita dan terpujilah buah tubuhmu, Yesus. Santa Maria, Bunda Allah, doakanlah kami yang berdosa ini, sekarang dan pada waktu kami mati. Amin.\nDoakanlah kami Ya Santa Bunda Allah, supaya kami dapat menikmati janji kristus.\nYa Allah karna kabar Malaikat, kami mengetahui bahwa Yesus Kristus Putra-Mu menjadi manusia, curahkanlah rahmat-Mu kepada kami, supaya karena sengsara dan salib-Nya kami dibawa kepada kebangkitan yang Mulia, sebab Dia lah Tuhan dan Pengatara kami, Amin."
    },
  ];

  List<String> personalDoa = [];
  List<String> favoriteDoa = [];
  Map<String, String> reminders = {};

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadFavorites();
    _loadPersonalDoa();
    _loadReminders();

    _setDefaultAngelusReminders();
  }

  void _initializeNotifications() {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final payload = response.payload;
        print("Payload: $payload");
        if (payload != null) {
          final doa = allDoa.firstWhere(
            (doa) => doa['title'] == payload,
            orElse: () => {},
          );

          if (doa != null && doa['title'] != null && doa['content'] != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailDoaScreen(
                  title: doa['title']!,
                  content: doa['content']!,
                ),
              ),
            );
          } else {
            print("Doa tidak ditemukan atau data tidak lengkap.");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Doa tidak ditemukan atau data tidak lengkap")),
            );
          }
        }
      },
    );
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
      personalDoa.add("$title|$content");
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
    String reminderKey =
        "reminder_${title}_${time.hour}:${time.minute.toString().padLeft(2, '0')}";
    String reminderValue =
        "${time.hour}:${time.minute.toString().padLeft(2, '0')}";

    await prefs.setString(reminderKey, reminderValue);

    setState(() {
      reminders[reminderKey] = reminderValue;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              "Pengingat untuk $title berhasil ditambahkan pada ${time.hour}:${time.minute.toString().padLeft(2, '0')}")),
    );

    await _scheduleNotification(title, time);
  }

  Future<void> _scheduleNotification(String title, TimeOfDay time) async {
    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Pengingat Doa',
      channelDescription: 'Pengingat untuk berdoa',
      importance: Importance.high,
      priority: Priority.high,
      onlyAlertOnce: true,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(Duration(days: 1));
    }

    print(
        "Sekarang: ${now.hour}:${now.minute}, Dijadwalkan: ${scheduledTime.hour}:${scheduledTime.minute}");

    await flutterLocalNotificationsPlugin.zonedSchedule(
      title.hashCode,
      'Pengingat Doa',
      'Saatnya berdoa: $title',
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: title,
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

  Future<void> _setDefaultAngelusReminders() async {
    const angelusTitle = "Angelus";

    final times = [
      const TimeOfDay(hour: 6, minute: 0),
      const TimeOfDay(hour: 12, minute: 0),
      const TimeOfDay(hour: 18, minute: 0),
    ];

    for (final time in times) {
      final reminderKey =
          "reminder_${angelusTitle}_${time.hour}:${time.minute.toString().padLeft(2, '0')}";
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey(reminderKey)) {
        await _addReminder(angelusTitle, time);
      }
    }
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
                const Icon(Icons.notifications, color: Colors.blue, size: 16),
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
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Hapus Doa"),
              onTap: () {
                Navigator.pop(context);
                _deleteDoa(title);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off, color: Colors.red),
              title: const Text("Hapus Pengingat"),
              onTap: () {
                Navigator.pop(context);
                _deleteReminder(title);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.blue),
              title: const Text("Tambahkan Pengingat"),
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

  Future<void> _deleteDoa(String title) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      personalDoa.removeWhere((doa) => doa.split('|')[0] == title);
      prefs.setStringList('personalDoa', personalDoa);

      favoriteDoa.remove(title);
      prefs.setStringList('favoriteDoa', favoriteDoa);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Doa \"$title\" berhasil dihapus")),
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
          title: const Text(
            'Kumpulan Doa',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: bgCollor,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.black,
          ),
          centerTitle: true,
          bottom: const TabBar(
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
                        Icon(
                          Icons.bookmark_border,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Belum ada doa pribadi",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Tambahkan doa pribadi Anda untuk memulai.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black45,
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
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
                                const SnackBar(
                                  content: Text(
                                      "Judul atau isi doa tidak boleh kosong"),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            "Buat Doa Pribadi",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: oren,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
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
                                const SnackBar(
                                    content: Text(
                                        "Judul atau isi doa tidak boleh kosong")),
                              );
                            }
                          },
                          backgroundColor: oren,
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
            favoriteDoa.isEmpty
                ? const Center(child: Text("Belum ada doa favorit"))
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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.add, color: oren, size: 24),
                    const SizedBox(width: 10),
                    const Text(
                      "Tambah Doa Pribadi",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Judul Doa",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (value) => title = value,
                  decoration: InputDecoration(
                    hintText: "Masukkan judul doa",
                    hintStyle: const TextStyle(color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: oren),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Isi Doa",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (value) => content = value,
                  decoration: InputDecoration(
                    hintText: "Masukkan isi doa",
                    hintStyle: const TextStyle(color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: oren),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black54,
                      ),
                      child: const Text(
                        "Batal",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (title.isEmpty || content.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Judul atau isi doa tidak boleh kosong",
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          Navigator.pop(context, {
                            "title": title,
                            "content": content,
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: oren,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Simpan",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
