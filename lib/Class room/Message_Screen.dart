import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:gingle_kids/Message/MessageScreen.dart';

//import '../post/postButton.dart';
import 'SendButnWidget.dart';
import 'dot_line.dart';
class MessageSendScreen extends StatefulWidget {
  final String name;
  final String token;
  final String role;
  final List<String> selectedClassNames; // Include selectedClassNames here
    final List<String> selectedStudentNames; // Include selectedClassNames here


  MessageSendScreen({
    required this.name,
    required this.token,
    required this.role,
    required this.selectedClassNames, required this.selectedStudentNames, // Update constructor
  });


  @override
  State<MessageSendScreen> createState() => _MessageSendScreenState();
}

class _MessageSendScreenState extends State<MessageSendScreen> {

  final TextEditingController _messageController = TextEditingController();



Future<void> _submitForm(BuildContext context, String message) async {
  

    const String apiUrl = 'https://bob-magickids.trainingzone.in/api/Message/message';
    // Your authentication key

    // Request headers
    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.token}',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    // Request body
    Map<String, dynamic> body = {
      'content': _messageController.text,
      'class_name' : widget.selectedClassNames,
      'student_names': widget.selectedStudentNames,
    };

    try {
      // Send POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(body),
      );
      print(body);
print(response.statusCode);
      // Check response status code
      if (response.statusCode == 200) {
        print(response.body);

        // Show success dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Message Sent Successfully"),
              actions: [
                TextButton(
                  onPressed: () {
                    _messageController.text = '';
                    Navigator.of(context).pop();

                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        // Show error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Failed to send message. Please try again."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Show exception dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("An error occurred. Please try again later."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double dotSize = screenWidth * 0.008;

    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessageScreen(
              token: widget.token,
              name: widget.name,
              role: widget.role,
            ),
          ),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Message creation',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          backgroundColor: Color(0xFF8779A6),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: MediaQuery.of(context).size.width * 0.07,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MessageScreen(
                            token: widget.token,
                            name: widget.name,
                            role: widget.role,
                          )));
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.03),
                child: Text(
                  "Message",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: screenWidth * 0.06,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                    height: 1.1,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(
                //  screenWidth * 0.02,
                  screenWidth * 0.08,
                 // 0,
                 // 0,
                ),
                child: SizedBox(
                  height: screenHeight * 0.4,
                  width: screenWidth * 0.8,
                  child: CustomPaint(
                    size: Size(screenWidth, screenHeight),
                    painter: DashedBorderPainter(dotSize: dotSize),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Enter your message here...',
                            border: InputBorder.none,
                          ),
                          style: TextStyle(fontSize: screenWidth * 0.05),
                          maxLines: null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            //  SizedBox(height: 5), // Added space between text field and button
SendButton(
  "Send",
  onPressed: (message) {
    _submitForm(context, _messageController.text);
  },
),
               // Placed the button directly in the column
            ],
          ),
        ),
      ),
    );
  }
}
