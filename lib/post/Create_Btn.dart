import 'package:flutter/material.dart';
import 'package:gingle_kids/login/login_screen.dart';
import 'package:gingle_kids/post/Post_create.dart';
import 'package:gingle_kids/teacher_dashboard.dart';

class CreateButton extends StatefulWidget {
  final String token;
  final String name;
  final String role;
  final String commentsurl;
  final String classroomName;

  CreateButton({required this.token,required this.name,required this.classroomName,required this.commentsurl,
  required this.role,required List<String> selectedClassrooms, required void Function() onPressed});

  @override
  State<CreateButton> createState() => _CreateButtonState();
}

class _CreateButtonState extends State<CreateButton> {
  @override
  void initState() {
    super.initState();
    print('shakilaaa in create ');
    print(widget.role);
    print(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.50,
      height: screenHeight * 0.07,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Color.fromRGBO(
            135, 121, 166, 1), // Using RGB values for violet color
      ),
      child: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostCreate(
                  token: widget.token,
                  name: widget.name, role: widget.role, classroomName: widget.classroomName, commentsurl: widget.commentsurl, profileUrl: '',
                ),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Create",
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
              SizedBox(width: 9),
              Icon(Icons.arrow_forward,
                  color: Colors.white, size: screenWidth * 0.08),
            ],
          ),
        ),
      ),
    );
  }
}
