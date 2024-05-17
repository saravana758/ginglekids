import 'package:flutter/material.dart';

class SendButton extends StatelessWidget {
  final String buttonText;
  final Function(String) onPressed;

  SendButton(this.buttonText, {required this.onPressed});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GestureDetector(
        onTap: () {
          // Trigger the onPressed callback with an empty message initially
          onPressed('');
        },
        child: Container(
          height: screenHeight * 0.06,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Color.fromRGBO(128, 164, 114, 1), // Using RGB values for violet color
          ),
          child: Center(
            child: Text(
              buttonText,
              style: TextStyle(
                color: Colors.white, // Using white color
                fontFamily: "Inter",
                fontSize: screenWidth * 0.07,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.28,
                height: 22 / 28, // Calculating line height based on font size
              ),
            ),
          ),
        ),
      ),
    );
  }
}
