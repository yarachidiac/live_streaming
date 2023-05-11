import 'package:flutter/material.dart';
import 'package:project_live_streaming/utils/colors.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({Key? key, required this.controller}) : super(key: key);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: buttonColor,
                width: 2,
            ),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: secondaryBackgroundColor,
          ),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }
}
