import 'package:flutter/material.dart';

class PresentWidget extends StatelessWidget {
  final int totalStudents;
  final int presentStudentsCount;
  final int absentStudentsCount;

  const PresentWidget({
    Key? key,
    required this.totalStudents,
    required this.presentStudentsCount,
    required this.absentStudentsCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.9,
      height: screenHeight * 0.09,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            blurRadius: 4,
            spreadRadius: 2,
          ),
        ],
      ),
      alignment: Alignment.topCenter,
      child: Padding(
        padding:
            EdgeInsets.only(top: screenHeight * 0.001, left: screenWidth * 0.02),
        child: Row(
          children: [
            Expanded(
              child: TotalStu(totalStudents: totalStudents.toString()),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Present(totalPresent: presentStudentsCount.toString()),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Absent(totalAbsent: absentStudentsCount.toString()),
            ),
          ],
        ),
      ),
    );
  }
}

class TotalStu extends StatelessWidget {
  final String totalStudents;

  const TotalStu({Key? key, required this.totalStudents}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return FittedBox(
      fit: BoxFit.contain,
      child: Column(
        children: [
          Text(
            "Student",
            style: TextStyle(
              color: Color(0xFF8779A6),
              fontFamily: "Poppins",
              fontWeight: FontWeight.w700,
              fontSize: screenWidth * 0.03,
              letterSpacing: 0.5,
              height: 1.46667,
            ),
          ),
          SizedBox(height: screenWidth * 0.01), // Adjust spacing as needed
          Text(
            totalStudents,
            style: TextStyle(
              color: Color(0xFF8779A6),
              fontFamily: "Poppins",
              fontWeight: FontWeight.w500,
              fontSize: screenWidth * 0.03,
              letterSpacing: 0.5,
              height: 1.22,
            ),
          ),
        ],
      ),
    );
  }
}

class Present extends StatelessWidget {
  final String totalPresent;

  const Present({Key? key, required this.totalPresent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return FittedBox(
      fit: BoxFit.contain,
      child: Column(
        children: [
          Text(
            "Present",
            style: TextStyle(
              color: Color(0xFF8779A6),
              fontFamily: "Poppins",
              fontSize: screenWidth * 0.03,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              height: 1.46667,
            ),
          ),
         SizedBox(height: screenWidth * 0.01),
          Text(
            totalPresent,
            style: TextStyle(
              color: Color(0xFFff5353),
              fontFamily: "Poppins",
              fontSize: screenWidth * 0.03,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              height: 1.22,
            ),
          ),
        ],
      ),
    );
  }
}

class Absent extends StatelessWidget {
  final String totalAbsent;

  const Absent({Key? key, required this.totalAbsent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return FittedBox(
      fit: BoxFit.contain,
      child: Column(
        children: [
          Text(
            "Absent",
            style: TextStyle(
              color: Color(0xFF8779A6),
              fontFamily: "Poppins",
              fontSize: screenWidth * 0.03,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              height: 1.46667,
            ),
          ),
         SizedBox(height: screenWidth * 0.01),
          Text(
            totalAbsent,
            style: TextStyle(
              color: Color(0xFFff5353),
              fontFamily: "Poppins",
              fontWeight: FontWeight.w500,
              fontSize: screenWidth * 0.03,
              letterSpacing: 0.5,
              height: 1.22,
            ),
          ),
        ],
      ),
    );
  }
}
