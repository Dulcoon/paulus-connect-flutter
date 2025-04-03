import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constans.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'profile_screen.dart';
import 'task_screen.dart';
import 'favorite_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Indeks halaman aktif

  // Daftar halaman
  final List<Widget> _pages = [
    HomeContent(),
    TaskScreen(),
    FavoriteScreen(),
    ProfileScreen(),
  ];

  final iconList = <IconData>[
    Icons.home,
    Icons.task,
    Icons.favorite,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCollor,
      body: _pages[_currentIndex],
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: _currentIndex,
        splashColor: oren,
        gapLocation: GapLocation.none,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        activeColor: oren,
        inactiveColor: Colors.grey,
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
                    Text(
                      'Lengkapi data diri anda',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
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
                        child: Row(
                          children: [
                            Text(
                              'Lengkapi Sekarang',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const Expanded(
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
              const SizedBox(width: 115),
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
                    const SizedBox(height: 10),
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

  @override
  void initState() {
    super.initState();
    _checkCompletionStatus();
  }

  Future<void> _checkCompletionStatus() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider
        .fetchUserData(); // Assuming you have a method to fetch user data

    if (!mounted)
      return; // Check if the widget is still mounted before calling setState

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isCompleted = authProvider.user?.isCompleted == 1;

    return _isLoading
        ? Center(
            child: CircularProgressIndicator(
            color: oren,
          ))
        : SafeArea(
            child: SingleChildScrollView(
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
                    if (isCompleted)
                      // Add the widget you want to display when isCompleted is true
                      UnCompletionPrompt(),
                    // Add other widgets here
                    const SizedBox(height: 40),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildIconButton(
                              imagePath:
                                  'assets/images/bookmark-dynamic-color.png',
                              label: 'Doa-doa',
                              onPressed: () {
                                Navigator.pushNamed(context, '/login');
                              },
                            ),
                            _buildIconButton(
                              imagePath: 'assets/images/pin-dynamic-color.png',
                              label: 'Intensi Misa',
                              onPressed: () {
                                Navigator.pushNamed(context, '/login');
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
                              imagePath:
                                  'assets/images/calender-dynamic-color.png',
                              label: 'Kalender Liturgi',
                              onPressed: () {
                                Navigator.pushNamed(context, '/login');
                              },
                            ),
                            _buildIconButton(
                              imagePath:
                                  'assets/images/bell-dynamic-gradient.png',
                              label: 'Jadwal Misa',
                              onPressed: () {
                                Navigator.pushNamed(context, '/login');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Berita Gereja',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildNewsButton(
                      title:
                          'Lorem ipsum dolor, sit amet consectetur adipisicing elit.',
                      onPressed: () {
                        Navigator.pushNamed(context, '/artikel');
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildNewsButton(
                      title:
                          'Lorem ipsum dolor, sit amet consectetur adipisicing elit.',
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildNewsButton(
                      title:
                          'Lorem ipsum dolor, sit amet consectetur adipisicing elit.',
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildIconButton({
    required String imagePath,
    required String label,
    double? imageWidth,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          child: Image.asset(
            imagePath,
            width: imageWidth ?? 70,
          ),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
    return ElevatedButton(
      onPressed: onPressed,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Baca Selangkapnya',
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
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}
