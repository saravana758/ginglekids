import 'package:flutter/material.dart';

import '../Class room/Message_Screen.dart';

class MsgCreateButton extends StatefulWidget {
  final String token;
  final String name;
  final String role;
  final List<String> selectedClassNames;
  MsgCreateButton(
      {required this.token, required this.name,
      required this.selectedClassNames,
       required this.role});

  @override
  State<MsgCreateButton> createState() => _MsgCreateButtonState();
}

class _MsgCreateButtonState extends State<MsgCreateButton> {
  @override
  void initState() {
    super.initState();

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
                builder: (context) => MessageSendScreen(
                  name: widget.name,
                  token: widget.token,
                  role: widget.role, selectedClassNames: [], selectedStudentNames: [],
                 
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
