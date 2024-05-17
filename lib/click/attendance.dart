import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gingle_kids/Attendance/Attendance.dart';

class AttendanceButton extends StatefulWidget {
  final String token;
  final String name;
  final String role;

  const AttendanceButton({
    Key? key,
    required this.token,
    required this.name,
    required this.role,
  }) : super(key: key);

  @override
  _AttendanceButtonState createState() => _AttendanceButtonState();
}

class _AttendanceButtonState extends State<AttendanceButton> {
  bool _isClicked = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          _isClicked = !_isClicked;
        });
        _navigateToAttendanceScreen();
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(0),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: _isClicked ? Colors.blue : Color.fromRGBO(135, 121, 166, 1),
          ),
        ),
        backgroundColor: _isClicked ? Colors.blue.withOpacity(0.2) : Colors.white,
      ),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        padding: EdgeInsets.all(_isClicked ? 12 : 8),
        width: screenWidth * 0.3,
        height: screenWidth * 0.3,
        decoration: BoxDecoration(
          border: Border.all(
            color: Color.fromRGBO(135, 121, 166, 1),
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        // child: SvgPicture.asset(
        //   "assets/icons/attendance-1.svg",
        //   width: _isClicked ? screenWidth * 0.50 : screenWidth * 0.2,
        //   height: _isClicked ? screenWidth * 0.50 : screenWidth * 0.2,
        //   color: Color.fromRGBO(135, 121, 166, 1),
        // ),

         child: Icon(
          Icons.storage,
          size: _isClicked ? screenWidth * 0.25 : screenWidth * 0.2,
          color: Color.fromRGBO(135, 121, 166, 1),
        ),
      ),
    );
  }

  void _navigateToAttendanceScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceScreen(
          token: widget.token,
          name: widget.name,
          role: widget.role,
        ),
      ),
    );
  }
}
