import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gingle_kids/Batch/student_screen.dart';
import 'package:http/http.dart' as http;
import '../Class room/Message_Screen.dart';
import 'MessageScreen.dart';

class StudentNameScreen extends StatefulWidget {
  final String token;
  final String className;
  final String name;
  final String role;

  StudentNameScreen({
    required this.token,
    required this.className,
    required this.name,
    required this.role,
  });

  @override
  _StudentNameScreenState createState() => _StudentNameScreenState();
}

class _StudentNameScreenState extends State<StudentNameScreen> {
  List<dynamic> classroomStudents = [];
  List<String> selectedStudents = [];

  @override
  void initState() {
    super.initState();
    fetchData(widget.token, widget.className);
  }

  Future<void> fetchData(String token, String className) async {
    try {
      var response = await http.post(
        Uri.parse('https://bob-magickids.trainingzone.in/api/ClassroomStudents/studentlist'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'classroom_name': className,
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          classroomStudents = data['students'];
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception during data fetching: $e');
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
            widget.className,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          backgroundColor: const Color(0xFF8779A6),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: screenWidth * 0.07,
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
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: screenWidth * 0.03),
                  Column(
                    children: classroomStudents.map((student) {
                      String name = student['name'];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentScreen(
                                studentName: name,
                                token: widget.token,
                                className: widget.className,
                                name: widget.name,
                                role: widget.role,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            _buildNameBox(name, isSelected(name)),
                            SizedBox(height: screenWidth * 0.03),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              if (selectedStudents.isNotEmpty) {
    print("Selected Students: $selectedStudents"); // Print selected students
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MessageSendScreen(
                      name: widget.name,
                      token: widget.token,
                      role: widget.role, selectedClassNames: [],
                                selectedStudentNames: selectedStudents, // Pass selected student names

                    ),
                  ),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("No Names Selected"),
                      content: const Text("Please select students."),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8779A6), // Button background color
                              borderRadius: BorderRadius.circular(8.0), // Button border radius
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
              backgroundColor: const Color(0xFF8779A6), // Button background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // Button border radius
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Create',
                  style: TextStyle(
                    color: Colors.white, // Text color
                    fontSize: screenWidth * 0.07, // Font size
                  ),
                ),
                SizedBox(width: screenWidth * 0.02), // Add space between text and icon
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white, // Icon color
                  size: screenWidth * 0.07, // Icon size
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool isSelected(String name) {
    return selectedStudents.contains(name);
  }

  Widget _buildNameBox(String name, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          Expanded(
            child: _buildElevatedRectangleBox(
              const Color.fromRGBO(135, 121, 166, 1),
              name,
              isSelected,
              () {
                setState(() {
                  if (isSelected) {
                    selectedStudents.remove(name);
                  } else {
                    selectedStudents.add(name);
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElevatedRectangleBox(
      Color borderColor, String name, bool isSelected, Function()? onTap) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 2),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Icon(
                Icons.account_circle,
                color: const Color(0xFF8779A6),
                size: MediaQuery.of(context).size.width * 0.08,
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.06,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Checkbox(
                value: isSelected,
                onChanged: (value) {
                  if (onTap != null) onTap();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
