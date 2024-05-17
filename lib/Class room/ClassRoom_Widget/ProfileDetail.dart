import 'package:flutter/material.dart';

class ProfiledetailWidget extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  ProfiledetailWidget(
      {Key? key,
      required this.title,
      required this.content,
      required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.only(left: screenWidth * 0.03),
      child: Container(
        height: screenHeight * 0.07,
        width: screenWidth * 0.4,
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
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: screenWidth * 0.02),
              child: Icon(icon,
                  size: screenWidth * 0.08,
                  color: Color.fromRGBO(117, 94, 172, 1)),
            ),
            SizedBox(width: screenWidth * 0.02),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 1),
                    fontFamily: 'Poppins',
                    fontSize: screenWidth * 0.04,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w500,
                    height: 1.1111,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(
                  height: screenWidth * 0.01,
                ),
                Text(
                  content, // Display the phone number passed as parameter
                  style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 1),
                    fontFamily: 'Poppins',
                    fontSize: screenWidth * 0.037,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w500,
                    height: 1.125,
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
