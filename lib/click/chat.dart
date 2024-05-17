import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gingle_kids/Chat/Chat_ClassroomList.dart'; // Import your chat screen

class ChatButton extends StatefulWidget {
  final String token;
  final String name;
  final String role;

  const ChatButton({
    Key? key,
    required this.token,required this.name,required this.role,
  }) : super(key: key);

  @override
  _ChatButtonState createState() => _ChatButtonState();
}

class _ChatButtonState extends State<ChatButton> {
  bool _isClicked = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          _isClicked = !_isClicked;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatClassroomList(
              token: widget.token,
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(0),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: _isClicked ? Color.fromRGBO(135, 121, 166, 1) : Color.fromRGBO(135, 121, 166, 1),
          ),
        ),
        backgroundColor: _isClicked ? Colors.blue.withOpacity(0.2) : Colors.white,
      ),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
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
        //   "assets/icons/bubble-chat-1.svg",
        //   color: Color.fromRGBO(135, 121, 166, 1),
        // ),
        child: Icon(
          Icons.sms,
          size: _isClicked ? screenWidth * 0.25 : screenWidth * 0.2,
          color: Color.fromRGBO(135, 121, 166, 1),
        ),
      ),
    );
  }
}
