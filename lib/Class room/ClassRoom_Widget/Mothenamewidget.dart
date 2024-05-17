import 'package:flutter/material.dart';

class MotherNameWidget extends StatelessWidget {
  final String mothername;

  MotherNameWidget({required this.mothername});
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.only(left: screenWidth * 0.01),
      child: Container(
        height: screenHeight * 0.07,
        width: screenWidth * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: Color.fromRGBO(245, 245, 245, 0.5),
            width: 1.0,
          ),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: screenWidth * 0.02),
              child: Icon(
                Icons.account_circle,
                size: screenWidth * 0.08,
                color: Color.fromRGBO(117, 94, 172, 1),
              ),
            ),
            SizedBox(width: screenWidth * 0.02),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mother Name',
                  style: TextStyle(
                    color: Color.fromRGBO(
                        0, 0, 0, 1), // Use your color variable here
                    fontFamily: 'Poppins',
                    fontSize: screenWidth * 0.04,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w500,
                    height: 1.1111, // This corresponds to line-height of 20px
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(
                  height: screenWidth * 0.01,
                ),
                Text(
                  mothername,
                  style: TextStyle(
                    color: Color.fromRGBO(
                        0, 0, 0, 1), // Use your color variable here
                    fontFamily: 'Poppins',
                    fontSize: screenWidth * 0.037,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w500,
                    height: 1.125, // This corresponds to line-height of 18px
                    letterSpacing: -0.078,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
