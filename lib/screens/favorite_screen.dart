import 'package:flutter/material.dart';

class FavoriteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite'),
      ),
      body: Center(
        child: Text(
          'Halaman Favorite',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
