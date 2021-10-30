import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    required this.onpressed,
    required this.buttonname,
    this.textcolor,
    this.buttoncolor,
  });

  final String buttonname;
  final VoidCallback onpressed;
  final Color? textcolor;
  final Color? buttoncolor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(
        buttonname,
        style: TextStyle(
          color: textcolor,
          fontSize: 20.0,
        ),
      ),
      style: ElevatedButton.styleFrom(
        primary: buttoncolor,
        padding: const EdgeInsets.all(16),
        minimumSize: Size(280, 50),
      ),
      onPressed: onpressed,
    );
  }
}
