import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  final String text;

  TextWidget({required this.text});

  @override
  Widget build(BuildContext context) {
        double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Text(
      text,
      style: TextStyle(
        color: Color(0xFF000000), // You can replace this with your CSS variable or use a default color
        fontFamily: 'Poppins',
        fontSize: screenWidth * 0.06,
        fontWeight: FontWeight.w500,
        letterSpacing: 2,
      ),
    );
  }
}





