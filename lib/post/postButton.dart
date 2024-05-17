import 'package:flutter/material.dart';

class PostButton extends StatelessWidget {
  final String buttonText;

  PostButton(this.buttonText);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.40,
      height: screenHeight * 0.06,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Color.fromRGBO(135, 121, 166, 1), // Using RGB values for violet color
      ),
      child: Center(
        child: Text(
          buttonText,
          style: TextStyle(
            color: Colors.white, // Using white color
            fontFamily: "Inter",
            fontSize: screenWidth * 0.08,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.28,
            height: 22 / 28, // Calculating line height based on font size
          ),
        ),
      ),
    );
  }
}
