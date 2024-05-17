import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'Chat_Screen.dart';

class ChatClassroomList extends StatefulWidget {
  final String token;
  ChatClassroomList({required this.token});
  @override
  _ChatClassroomListState createState() => _ChatClassroomListState();
}

class _ChatClassroomListState extends State<ChatClassroomList> {
  late Future<List<String>> _classroomNamesFuture;

  @override
  void initState() {
    super.initState();
    print('Token: ${widget.token}');
    _classroomNamesFuture = fetchClassroomNames(widget.token);
  }

  Future<List<String>> fetchClassroomNames(String token) async {
    // Accept token as parameter
    final String apiUrl =
        'https://bob-magickids.trainingzone.in/api/ClassroomStudents/classrooms';

    var headers = {
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(Uri.parse(apiUrl), headers: headers);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var classrooms = data[1].cast<String>();
      return classrooms;
    } else {
      throw Exception('Failed to load classroom names');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Classroom',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontFamily: 'Poppins',
            fontSize: MediaQuery.of(context).size.width * 0.06,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            fontStyle: FontStyle.normal,
            height: 1,
          ),
        ),
        backgroundColor: Color(0xFF8779A6),
      ),
      body: FutureBuilder<List<String>>(
        future: _classroomNamesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator()); // or any loading indicator
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return buildClassroomList(snapshot.data!);
          }
        },
      ),
    );
  }

  Widget buildClassroomList(List<String> classroomNames) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: classroomNames.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen()), // Replace ChatScreen() with your ChatScreen widget
    );
  },
  child: Container(
    height: MediaQuery.of(context).size.height * 0.06,
    margin: EdgeInsets.only(top: index > 0 ? 10 : 0),
    decoration: BoxDecoration(
      color: Color.fromARGB(255, 235, 227, 227),
      borderRadius: BorderRadius.circular(10.0),
      border: Border.all(color: Color(0xFF8779A6)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.04,
          ),
          child: Text(
            classroomNames[index],
            style: TextStyle(
              color: Color(0xFF000000),
              fontFamily: 'Poppins',
              fontSize: MediaQuery.of(context).size.width * 0.05,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w500,
              height: 1.1,
              letterSpacing: 2.0,
            ),
          ),
        ),
      ],
    ),
  ),
),

            ],
          );
        },
      ),
    );
  }
}
