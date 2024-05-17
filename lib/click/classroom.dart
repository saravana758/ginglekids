import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gingle_kids/Class%20room/Classroom_list.dart';
// import 'package:gingle_kids/Class room/Classroom_List.dart';

class ClassroomButton extends StatefulWidget {
  final String token;
  final String name;
  final String role;

  const ClassroomButton({
    Key? key,
    required this.token,
    required this.name,
    required this.role,
  }) : super(key: key);

  @override
  _ClassroomButtonState createState() => _ClassroomButtonState();
}

class _ClassroomButtonState extends State<ClassroomButton> {
  bool _isClicked = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          _isClicked = !_isClicked;
        });
        _navigateToClassroomScreen();
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
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
            //   "assets/icons/google-classroom.svg",
            //   width: 40,
            //   height: 40,
            //   color: Color.fromRGBO(135, 121, 166, 1),
            // ),
             child: Icon(
          Icons.local_library_rounded,
          size: _isClicked ? screenWidth * 0.25 : screenWidth * 0.2,
          color: Color.fromRGBO(135, 121, 166, 1),
        ),
          ),
        ],
      ),
    );
  }

  void _navigateToClassroomScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClassroomList(
          token: widget.token,
          name: widget.name,
          role: widget.role,
        ),
      ),
    );
  }
}
