import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'detail_doa_screen.dart';
import '../utils/constans.dart';
import 'package:flutter/cupertino.dart';
import 'package:timezone/timezone.dart' as tz;
import '../main.dart';
import 'package:flutter/services.dart';
import '../services/notification_service.dart';

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
  Map<String, List<String>> reminders = {}; // title -> list of times

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
          // Check if it's a doa reminder notification
          final doa = allDoa.firstWhere(
            (doa) => doa['title'] == payload,
            orElse: () => {},
          );

          if (doa.isNotEmpty &&
              doa['title'] != null &&
              doa['content'] != null) {
            Navigator.push(
              navigatorKey.currentContext!,
              MaterialPageRoute(
                builder: (context) => DetailDoaScreen(
                  title: doa['title']!,
                  content: doa['content']!,
                ),
              ),
            );
          } else {
            print("Doa tidak ditemukan atau data tidak lengkap.");
            // Note: ScaffoldMessenger cannot be used here as context may not be available
            // when notification is tapped from background/terminated state
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
          final parts = key.replaceFirst('reminder_', '').split('_');
          if (parts.length >= 2) {
            final title = parts.sublist(0, parts.length - 1).join('_');
            final time = parts.last;
            if (!reminders.containsKey(title)) {
              reminders[title] = [];
            }
            reminders[title]!.add(time);
          }
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
        NotificationService().showInfo(
          context,
          '$title dihapus dari favorit',
        );
      } else {
        favoriteDoa.add(title);
        NotificationService().showSuccess(
          context,
          '$title ditambahkan ke favorit',
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
      if (!reminders.containsKey(title)) {
        reminders[title] = [];
      }
      reminders[title]!.add(reminderValue);
    });

    NotificationService().showSuccess(
      context,
      "Pengingat untuk $title pada pukul ${reminderValue} berhasil ditambahkan",
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
      androidScheduleMode: AndroidScheduleMode.exact,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: title,
    );
  }

  Future<void> _deleteReminder(String title) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get all reminder keys for this title
    final keysToRemove = prefs
        .getKeys()
        .where((key) => key.startsWith('reminder_$title'))
        .toList();

    // Remove all reminders for this title
    for (final key in keysToRemove) {
      await prefs.remove(key);
    }

    setState(() {
      reminders.remove(title);
    });

    NotificationService().showInfo(
      context,
      "Semua pengingat untuk $title dihapus.",
    );

    print("Semua pengingat untuk $title dihapus.");
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
      padding: const EdgeInsets.all(16),
      itemCount: doaList.length,
      itemBuilder: (context, index) {
        final doa = doaList[index];
        final title = doa['title']!;
        final isFavorite = favoriteDoa.contains(title);
        final hasReminder = reminders.containsKey(title);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
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
              HapticFeedback.heavyImpact();
              _showActionMenu(context, title);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        if (hasReminder) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text(
                                '🔔',
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Pengingat: ${reminders[title]!.join(', ')}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      color: isFavorite ? oren : Colors.grey,
                      size: 24,
                    ),
                    onPressed: () => _toggleFavorite(title),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showActionMenu(BuildContext context, String title) {
    final hasReminder = reminders.containsKey(title);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              if (hasReminder) ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time,
                          color: Colors.blue, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Pengingat: ${reminders[title]!.join(', ')}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
              ],
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Hapus Doa"),
                onTap: () {
                  Navigator.pop(context);
                  _deleteDoa(title);
                },
              ),
              if (hasReminder)
                ListTile(
                  leading:
                      const Icon(Icons.notifications_off, color: Colors.red),
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
          ),
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

    NotificationService().showSuccess(
      context,
      "$title berhasil dihapus.",
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
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.black,
          ),
          centerTitle: true,
          bottom: TabBar(
            indicator: BoxDecoration(
              color: oren,
              borderRadius: BorderRadius.circular(25),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[600],
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            tabs: const [
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
                          Icons.menu_book,
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
                          "Buat doa pribadi Anda sendiri untuk mengungkapkan harapan dan doa kepada Tuhan.",
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
                              NotificationService().showInfo(
                                context,
                                "Judul atau isi doa tidak boleh kosong",
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
                              NotificationService().showInfo(
                                context,
                                "Judul atau isi doa tidak boleh kosong",
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
                          NotificationService().showInfo(
                            context,
                            "Judul atau isi doa tidak boleh kosong",
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
