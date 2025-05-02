import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../utils/constans.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavbar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconList = <IconData>[
      Icons.task,
      Icons.home,
      Icons.person,
    ];

    return CurvedNavigationBar(
      backgroundColor: bgCollor, // Warna latar belakang di atas navbar
      color: oren, // Warna aksen navbar
      buttonBackgroundColor: Colors.white, // Warna tombol tengah
      height: 60, // Tinggi navbar
      animationDuration: const Duration(milliseconds: 300),
      animationCurve: Curves.easeInOut,
      index: currentIndex,
      items: iconList.asMap().entries.map((entry) {
        final index = entry.key;
        final icon = entry.value;

        // Periksa apakah item sedang terseleksi
        final isSelected = currentIndex == index;

        return Icon(
          icon,
          size: 30,
          color: isSelected ? oren : Colors.white, // Warna berbeda
        );
      }).toList(),
      onTap: onTap,
    );
  }
}
