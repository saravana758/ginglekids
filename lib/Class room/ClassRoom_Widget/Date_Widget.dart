import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrentDateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the current date
    double screenWidth = MediaQuery.of(context).size.width;
   
    DateTime now = DateTime.now();

    // Format the date as Day/Month/Year
    String formattedDate = DateFormat('dd/MM/yyyy').format(now);

    return Container(
      
      child: Text(
        formattedDate,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: screenWidth * 0.04,
          color: Color(0xFF999999),
          fontWeight: FontWeight.w500, // Custom font weight
          letterSpacing: 2.0, // Custom letter spacing
         // height: 1.25, // Custom line height
        ),
      ),
    );
  }

  static getCurrentDate() {}
}
