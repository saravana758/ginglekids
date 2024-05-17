import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:gingle_kids/Message/MessageScreen.dart';

class SentMessagesPage extends StatefulWidget {
    final String token;
  final String role;
  final String name;
    final List<String> sentMessages; // List of sent messages


  SentMessagesPage({required this.token, required this.name, 
  required this.role, required this.sentMessages});


  @override
  State<SentMessagesPage> createState() => _SentMessagesPageState();
}

class _SentMessagesPageState extends State<SentMessagesPage> {

  late List<Map<String, dynamic>> messages;

@override
  void initState() {
    super.initState();
    print('Token: ${widget.token}');
    fetchMessages(widget.token);
  }

  Future<void> fetchMessages(String token) async {
    final String apiUrl = 'https://bob-magickids.trainingzone.in/api/Message/view';

    var headers = {
      'Authorization': 'Bearer $token',
    };

    try {
      var response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          messages = List<Map<String, dynamic>>.from(data['messages']);
        });
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      print('Exception while fetching messages: $e');
      setState(() {
        messages = []; // Return an empty list if an exception occurs
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
          title: Text(
            'Sent Messages',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: MediaQuery.of(context).size.width * 0.06,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          backgroundColor: const Color(0xFF8779A6),
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
                  ),
                ),
              );
            },
          ),
      ),
      body: ListView.builder(
        itemCount:messages.length,
        itemBuilder: (BuildContext context, int index) {
          String content = messages[index]['content'];
          return ListTile(
            title: Text(content),
            // Add additional details or actions for each message if needed
          );
        },
      ),
    );
  }
}
