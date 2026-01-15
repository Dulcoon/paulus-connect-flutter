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
import 'dart:async';
import 'pengumuman_list_screen.dart';

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

// ===== PERTAHANKAN COMPLETION PROMPT (TANPA PERUBAHAN) =====
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

// ===== PERTAHANKAN UNCOMPLETION PROMPT (TANPA PERUBAHAN) =====
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
  String _currentTime = '';
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTime();
    });
    _checkCompletionStatus();
    _fetchPengumuman();
    requestPermissions(context);
  }

  void _updateTime() {
    setState(() {
      final now = DateTime.now();
      _currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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
    final userName = authProvider.user?.name ?? 'Guest';

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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      // ===== HEADER SECTION (PROPORSIONAL) =====
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Salam Sejahtera",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // ===== LIVE CLOCK SECTION (MENGGANTI LONCENG) =====
                          Container(
                            width: 75,
                            height: 75,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 15,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentTime,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: oren,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'WIB',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ===== COMPLETION PROMPT (PERTAHANKAN ASSET 3D) =====
                      if (!isCompleted)
                        CompletionPrompt(
                          onPressed: () {
                            Navigator.pushNamed(context, '/userData');
                          },
                        ),
                      if (isCompleted) const UnCompletionPrompt(),

                      const SizedBox(height: 28),

                      // ===== CAROUSEL SECTION =====
                      Column(
                        children: [
                          CarouselSlider(
                            options: CarouselOptions(
                              height: 140,
                              aspectRatio: 21 / 9,
                              viewportFraction: 0.95,
                              enableInfiniteScroll: true,
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 4),
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
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.asset(
                                      imagePath,
                                      fit: BoxFit.cover,
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: imagePaths.asMap().entries.map((entry) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: _currentIndex == entry.key ? 24.0 : 6.0,
                                height: 6.0,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 4.0, vertical: 10.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: _currentIndex == entry.key
                                      ? oren
                                      : Colors.grey[300],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // ===== SECTION HEADER: FITUR UTAMA =====
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              color: oren,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Fitur Utama',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ===== MENU GRID (PERTAHANKAN ASSET 3D) - EXPANDED =====
                      Row(
                        children: [
                          _buildIconButton(
                            imagePath:
                                'assets/images/bookmark-dynamic-color.png',
                            label: 'Doa-doa',
                            accentColor: oren,
                            onPressed: () {
                              Navigator.pushNamed(context, '/doa');
                            },
                          ),
                          const SizedBox(width: 14),
                          _buildIconButton(
                            imagePath: 'assets/images/pin-dynamic-color.png',
                            label: 'Text Misa',
                            accentColor: const Color(0xFF6366F1),
                            onPressed: () {
                              Navigator.pushNamed(context, '/text-misa');
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      Row(
                        children: [
                          _buildIconButton(
                            imagePath:
                                'assets/images/calender-dynamic-color.png',
                            label: 'Kalender Liturgi',
                            accentColor: const Color(0xFF10B981),
                            onPressed: () {
                              Navigator.pushNamed(context, '/kalender-liturgi');
                            },
                          ),
                          const SizedBox(width: 14),
                          _buildIconButton(
                            imagePath:
                                'assets/images/bell-dynamic-gradient.png',
                            label: 'Sakramen',
                            accentColor: const Color(0xFFF59E0B),
                            onPressed: () {
                              Navigator.pushNamed(context, '/sakramen-list');
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // ===== SECTION HEADER: AKSI CEPAT =====
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              color: oren,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Aksi Cepat',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ===== MODERN ACTION CARDS (PERSEMBAHAN & DONASI) =====
                      Row(
                        children: [
                          Expanded(
                            child: _buildModernActionCard(
                              icon: Icons.volunteer_activism_outlined,
                              title: 'Persembahan',
                              subtitle: 'Riwayat persembahan',
                              color: const Color(0xFF10B981),
                              onPressed: () {
                                Navigator.pushNamed(context, '/persembahan');
                              },
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildModernActionCard(
                              icon: Icons.favorite,
                              title: 'Donasi',
                              subtitle: 'Berikan dukungan',
                              color: oren,
                              onPressed: () {
                                Navigator.pushNamed(context, '/donasi');
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // ===== PENGUMUMAN SECTION (MODERN DESIGN) =====
                      // ...existing code...

                      // ===== PENGUMUMAN SECTION (MODERN DESIGN) =====
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: oren,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Pengumuman Terbaru',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              if (_pengumuman.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: oren.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_pengumuman.length}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: oren,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_isLoading)
                            const Center(
                              child: CircularProgressIndicator(color: oren),
                            )
                          else if (_pengumuman.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.grey[400],
                                    size: 28,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Belum ada pengumuman',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Column(
                              children: [
                                // Display max 3 pengumuman
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _pengumuman.length > 3
                                      ? 3
                                      : _pengumuman.length,
                                  itemBuilder: (context, index) {
                                    final pengumuman = _pengumuman[index];
                                    return _buildModernNewsCard(
                                      title: pengumuman['judul'],
                                      index: index + 1,
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
                                // Show "Lihat Lainnya" button jika pengumuman > 3
                                if (_pengumuman.length > 3) ...[
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: oren,
                                        side: const BorderSide(
                                          color: oren,
                                          width: 2,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const PengumumanListScreen(),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Lihat Pengumuman Lainnya',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                        ],
                      ),

// ...existing code...

                      const SizedBox(height: 24),

                      Text(
                        'v1.0.0',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[500],
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
    required String imagePath,
    required String label,
    required VoidCallback onPressed,
    required Color accentColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ===== 3D ICON (HERO) =====
              Image.asset(
                imagePath,
                width: 56,
                height: 56,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 14),

              // ===== LABEL =====
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== MODERN ACTION CARD (PERSEMBAHAN & DONASI) =====
  Widget _buildModernActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget sectionDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300)),
          const SizedBox(width: 8),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: oren,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }

  // ===== MODERN NEWS CARD (PENGUMUMAN) =====
  Widget _buildModernNewsCard({
    required String title,
    required int index,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: oren.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '$index',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: oren,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tap untuk baca selengkapnya',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: oren.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: oren,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
