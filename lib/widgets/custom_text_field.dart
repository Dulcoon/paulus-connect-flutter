import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>?
      validator; // Tambahkan validator sebagai atribut opsional

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.validator, // Inisialisasi validator
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Theme(
        data: ThemeData(
          primaryColor: Colors.orange, // Replace with your `oren` color
          colorScheme: ColorScheme.light(primary: Colors.orange),
        ),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.orange),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                  color: Colors.grey), // Replace with `bgCollor`
            ),
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          ),
          validator: validator, // Gunakan validator yang diberikan
        ),
      ),
    );
  }
}
