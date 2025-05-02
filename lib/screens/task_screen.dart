import 'package:flutter/material.dart';

class TaskScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task'),
      ),
      body: const Center(
        child: Text(
          'Halaman Task',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
