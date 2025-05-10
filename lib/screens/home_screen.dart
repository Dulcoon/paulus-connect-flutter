import 'package:flutter/material.dart';
import 'package:paulus_connect/alkitab/alkitab.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constans.dart';
import 'profile_screen.dart';
import '../services/api_service.dart';
import 'pengumuman_detail_screen.dart';
import 'bottom_navbar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1;

  final List<Widget> _pages = [
    const AlkitabScreen(),
    const HomeContent(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCollor,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class CompletionPrompt extends StatelessWidget {
  final VoidCallback onPressed;

  const CompletionPrompt({required this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: oren,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                spreadRadius: 2,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 115),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lengkapi data diri anda',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Dan nikmati semua fitur Paulus Connect',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 30,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: onPressed,
                        child: const Row(
                          children: [
                            Text(
                              'Lengkapi Sekarang',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Expanded(
                              child: Icon(
                                Icons.arrow_forward,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -20,
          left: 0,
          child: Image.asset(
            "assets/images/copy-dynamic-gradient.png",
            width: 140,
          ),
        ),
      ],
    );
  }
}

class UnCompletionPrompt extends StatelessWidget {
  const UnCompletionPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: oren,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                spreadRadius: 2,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: const Row(
            children: [
              SizedBox(width: 115),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paulus Connect',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Iman, Komunitas, Pelayanan dalam genggaman!',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -30,
          left: 0,
          child: Image.asset(
            "assets/images/mobile-dynamic-color@2x.png",
            width: 140,
          ),
        ),
      ],
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _isLoading = true;
  List<dynamic> _pengumuman = [];
  final List<String> imagePaths = [
    'assets/images/carousel item1.jpg',
    'assets/images/carousel item2.jpg',
    'assets/images/carousel item3.jpg',
    'assets/images/carousel item4.jpg',
  ];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkCompletionStatus();
    _fetchPengumuman();
    requestPermissions(context);
  }

  Future<void> _fetchPengumuman() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token != null) {
      try {
        final data = await ApiService.fetchPengumuman(token);
        if (!mounted) return;
        setState(() {
          _pengumuman = data;
          _isLoading = false;
        });
      } catch (e) {
        print('Error fetching pengumuman: $e');
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkCompletionStatus() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.fetchUserData();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isCompleted = authProvider.user?.isCompleted == 1;

    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(
            color: oren,
          ))
        : SafeArea(
            child: RefreshIndicator(
              color: oren,
              onRefresh: _fetchPengumuman,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Salam Sejahtera,",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                "${authProvider.user?.name}",
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.symmetric(
                                vertical: BorderSide(
                                  color: Colors.black26,
                                  width: 2,
                                ),
                                horizontal: BorderSide(
                                  color: Colors.black26,
                                  width: 2,
                                ),
                              ),
                            ),
                            width: 55,
                            height: 55,
                            child: Image.asset(
                              'assets/images/notif.png',
                              width: 0,
                              height: 0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (!isCompleted)
                        CompletionPrompt(
                          onPressed: () {
                            Navigator.pushNamed(context, '/userData');
                          },
                        ),
                      if (isCompleted) const UnCompletionPrompt(),
                      const SizedBox(height: 20),
                      Divider(
                        color: Colors.black.withOpacity(0.2),
                        thickness: 1,
                        height: 20,
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          Column(
                            children: [
                              CarouselSlider(
                                options: CarouselOptions(
                                  height: 120,
                                  aspectRatio: 21 / 9,
                                  viewportFraction: 0.9,
                                  enableInfiniteScroll: true,
                                  autoPlay: true,
                                  autoPlayInterval: const Duration(seconds: 3),
                                  autoPlayAnimationDuration:
                                      const Duration(milliseconds: 800),
                                  enlargeCenterPage: true,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _currentIndex = index;
                                    });
                                  },
                                ),
                                items: imagePaths.map((imagePath) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.asset(
                                          imagePath,
                                          fit: BoxFit.cover,
                                          width:
                                              MediaQuery.of(context).size.width,
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:
                                    imagePaths.asMap().entries.map((entry) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width:
                                        _currentIndex == entry.key ? 12.0 : 8.0,
                                    height: 8.0,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4.0, vertical: 10.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentIndex == entry.key
                                          ? oren
                                          : Colors.grey,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildIconButton(
                                width: 160,
                                height: 90,
                                imagePath:
                                    'assets/images/bookmark-dynamic-color.png',
                                label: 'Doa-doa',
                                onPressed: () {
                                  Navigator.pushNamed(context, '/doa');
                                },
                              ),
                              _buildIconButton(
                                width: 160,
                                height: 90,
                                imagePath:
                                    'assets/images/pin-dynamic-color.png',
                                label: 'Text Misa',
                                onPressed: () {
                                  Navigator.pushNamed(context, '/text-misa');
                                },
                                imageWidth: 56,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildIconButton(
                                width: 160,
                                height: 90,
                                imagePath:
                                    'assets/images/calender-dynamic-color.png',
                                label: 'Kalender Liturgi',
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/kalender-liturgi');
                                },
                              ),
                              _buildIconButton(
                                width: 160,
                                height: 90,
                                imagePath:
                                    'assets/images/bell-dynamic-gradient.png',
                                label: 'Sakramen',
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/sakramen-list');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Divider(
                        color: Colors.black.withOpacity(0.2),
                        thickness: 1,
                        height: 40,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildIconButton(
                            width: 80,
                            height: 80,
                            icon: CupertinoIcons.calendar_today,
                            label: 'Event',
                            onPressed: () {
                              Navigator.pushNamed(context, '/sakramen-list');
                            },
                          ),
                          _buildIconButton(
                            width: 80,
                            height: 80,
                            icon: CupertinoIcons.envelope_open,
                            label: 'Persembahan',
                            onPressed: () {
                              Navigator.pushNamed(context, '/sakramen-list');
                            },
                          ),
                          _buildIconButton(
                            width: 80,
                            height: 80,
                            icon: CupertinoIcons.heart_circle_fill,
                            label: 'Donasi',
                            onPressed: () {
                              Navigator.pushNamed(context, '/sakramen-list');
                            },
                          ),
                        ],
                      ),
                      Divider(
                        color: Colors.black.withOpacity(0.2),
                        thickness: 1,
                        height: 40,
                      ),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              SizedBox(width: 10),
                              Text(
                                'Pengumuman',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (_isLoading)
                            const Center(
                                child: CircularProgressIndicator(color: oren))
                          else if (_pengumuman.isEmpty)
                            const Text('Tidak ada pengumuman saat ini.')
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _pengumuman.length,
                              itemBuilder: (context, index) {
                                final pengumuman = _pengumuman[index];
                                return _buildNewsButton(
                                  title: pengumuman['judul'],
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PengumumanDetailScreen(
                                                pengumuman: pengumuman),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Versi 1.0.0',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: Colors.black54,
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

  Widget _buildIconButton({
    String? imagePath,
    IconData? icon,
    required String label,
    double? imageWidth,
    double? width, // Tambahkan parameter untuk width
    double? height, // Tambahkan parameter untuk height
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: EdgeInsets.zero, // Hilangkan padding default
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            fixedSize: width != null && height != null
                ? Size(width, height) // Gunakan ukuran fix jika diberikan
                : null, // Jika tidak diberikan, gunakan ukuran default
          ),
          child: imagePath != null
              ? Image.asset(
                  imagePath,
                  width: imageWidth ?? 70,
                  height: height != null
                      ? height - 20
                      : null, // Sesuaikan tinggi gambar
                  fit: BoxFit.contain,
                )
              : Icon(
                  icon,
                  size: imageWidth ?? 45,
                  color: Colors.black,
                ),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }

  Widget _buildNewsButton({
    required String title,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Baca Selengkapnya',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
