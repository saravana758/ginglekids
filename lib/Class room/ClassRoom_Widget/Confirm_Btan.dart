import 'package:flutter/material.dart';

class ConfirmBtnWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color(0xFF13C32F), // Using hexadecimal color code
      ),
      child: ElevatedButton(
        onPressed: () {
          // Add your confirmation logic here
          print('Confirmed');
        },
        child: Text(
          'Confirm',
          style: TextStyle(
            color: Color(0xFFFFFFFF), // Using hexadecimal color code for white
            fontFamily: 'Poppins',
            fontSize: 15,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w700,
            height: 1.47, // Corresponds to line-height: 22px (22/15 = 1.47)
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors
              .transparent, // Set to transparent to see the container's background
          elevation: 0, // No shadow
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      ),
    );
  }
}
