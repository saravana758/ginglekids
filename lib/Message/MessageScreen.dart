import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gingle_kids/Message/Message_lists.dart';
import 'package:http/http.dart' as http;

import '../Class room/Message_Screen.dart';
import '../teacher_dashboard.dart';
import 'StudentNames.dart';

class MessageScreen extends StatefulWidget {
  final String token;
  final String role;
  final String name;

  MessageScreen({required this.token, required this.name, required this.role});

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late Future<List<String>> _classroomNamesFuture;
  late List<bool> _isCheckedList;
  late List<String> _selectedClassNames;

  @override
  void initState() {
    super.initState();
    _classroomNamesFuture = fetchClassroomNames(widget.token);
    _isCheckedList = [];
    _selectedClassNames = []; // Initialize selected class names list
  }

  Future<List<String>> fetchClassroomNames(String token) async {
    final String apiUrl =
        'https://bob-magickids.trainingzone.in/api/ClassroomStudents/classrooms';

    var headers = {'Authorization': 'Bearer $token'};
    var response = await http.get(Uri.parse(apiUrl), headers: headers);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var classrooms = List<String>.from(data[1]);
      _isCheckedList = List.generate(classrooms.length, (index) => false);
      return classrooms;
    } else {
      throw Exception('Failed to load classroom names');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeacherDashboard(
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
            'Message',
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
                  builder: (context) => TeacherDashboard(
                    token: widget.token,
                    name: widget.name,
                    role: widget.role,
                  ),
                ),
              );
            },
          ),
          actions: <Widget>[
    IconButton(
      icon: Icon(
        Icons.mail,
        color: Colors.white,
      ),
          tooltip: 'View Messages', // Add tooltip text here

      onPressed: () {
        // Add your functionality here for the message button
        // For example, navigate to the MessageScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SentMessagesPage(
              token: widget.token,
              name: widget.name,
              role: widget.role, sentMessages: [],
            ),
          ),
        );
      },
    ),
  ],
        ),
        body: FutureBuilder<List<String>>(
          future: _classroomNamesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              return buildClassroomList(snapshot.data!);
            } else {
              return Container();
            }
          },
        ),
floatingActionButton: Padding(
  padding: const EdgeInsets.all(16.0),
  child: ElevatedButton(
    onPressed: () {
      if (_selectedClassNames.isNotEmpty) {
        print(_selectedClassNames);
        print("ok");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessageSendScreen(
              name: widget.name,
              token: widget.token,
              role: widget.role,
                  selectedClassNames: _selectedClassNames, selectedStudentNames: [], // Pass selected class names
            ),
          ),
        );
      } else {
        print("not ok");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("No Names Selected"),
              content: const Text("Please select Classname."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8779A6), 
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "OK",
                          style: TextStyle(
                            color: Colors.white, // Text color
                            fontSize: 16.0, // Font size
                          ),
                        ),
                       
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF8779A6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0), 
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Create',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.07, 
          ),
        ),
        SizedBox(width: screenWidth * 0.02),
        Icon(
          Icons.arrow_forward,
          color: Colors.white,
          size: screenWidth * 0.07, 
        ),
      ],
    ),
  ),
),


     ) );
  }

  Widget buildClassroomList(List<String> classroomNames) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: classroomNames.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentNameScreen(
                    token: widget.token,
                    className: classroomNames[index],
                    role: widget.role,
                    name: widget.name,
                  ),
                ),
              );
            },
            child: Container(
              height: MediaQuery.of(context).size.height * 0.06,
              margin: EdgeInsets.only(top: index > 0 ? 10 : 0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 235, 227, 227),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: const Color(0xFF8779A6)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.04,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isCheckedList[index] = !_isCheckedList[index];
                              if (_isCheckedList[index]) {
                                _selectedClassNames.add(classroomNames[index]);
                              } else {
                                _selectedClassNames
                                    .remove(classroomNames[index]);
                              }
                            });
                          },
                          child: Checkbox(
                            value: _isCheckedList[index],
                            onChanged: (bool? value) {
                              setState(() {
                                _isCheckedList[index] = value ?? false;
                                if (value ?? false) {
                                  _selectedClassNames
                                      .add(classroomNames[index]);
                                } else {
                                  _selectedClassNames
                                      .remove(classroomNames[index]);
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    classroomNames[index],
                    style: TextStyle(
                      color: const Color(0xFF000000),
                      fontFamily: 'Poppins',
                      fontSize: MediaQuery.of(context).size.width * 0.05,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
