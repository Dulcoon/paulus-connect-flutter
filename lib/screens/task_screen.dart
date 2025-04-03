import 'package:flutter/material.dart';

class TaskScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task'),
      ),
      body: Center(
        child: Text(
          'Halaman Task',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
