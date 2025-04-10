import 'package:flutter/material.dart';

class RegistrationStatusScreen extends StatelessWidget {
  final String? status;
  final String? alasan;

  const RegistrationStatusScreen({Key? key, this.status, this.alasan})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Status Pendaftaran'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status Pendaftaran: $status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (status == 'ditolak' && alasan != null) ...[
              SizedBox(height: 10),
              Text(
                'Alasan Penolakan:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                alasan!,
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
