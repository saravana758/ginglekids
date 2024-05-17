import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gingle_kids/Batch/morning_batch.dart';
import 'package:gingle_kids/search/search_student.dart';
import 'package:http/http.dart' as http;

import '../teacher_dashboard.dart';

class AttendanceScreen extends StatefulWidget {
  final String token;
  final String name;
  final String role;
  AttendanceScreen({required this.token, required this.name,required this.role});
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  TextEditingController _searchController = TextEditingController();
  List<String> _allNames = [];
  List<String> _filteredNames = [];
  List<String> _studentNames = [];
  List<String> _studentList = [];

  @override
  void initState() {
    super.initState();
    print('Token: ${widget.token}');
    fetchAllStudentsList().then((studentNames) {
      setState(() {
        _studentNames = studentNames;
        _studentList = studentNames; // Update the state with the fetched list
      });
    });
    fetchClassroomNames();
    fetchAllNames().then((classroomNames) {
      setState(() {
        _allNames = classroomNames;
        _filteredNames = _allNames;
      });
    });

    // Call printStudentList to define studentList
    printStudentList();
  }

  // Search condition

  void _searchStudents(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredNames = _allNames;
      });
      return;
    }

    String lowerCaseQuery = query.toLowerCase();

    List<String> results = _allNames
        .where((name) => name.toLowerCase().contains(lowerCaseQuery))
        .toList();

    List<String> studentsFromClassroom = fetchStudentsByClassroom(query)
        .where((name) => name.toLowerCase().contains(lowerCaseQuery))
        .toList();
    results.addAll(studentsFromClassroom);

    setState(() {
      _filteredNames = results.toSet().toList();
    });
  }

  Future<List<String>> fetchAllNames() async {
    try {
      List<String> classroomNames = await fetchClassroomNames();
      return classroomNames;
    } catch (e) {
      print('Error fetching classroom names: $e');

      return [];
    }
  }

  List<String> fetchStudentsByClassroom(String classroomName) {
    return _studentNames
        .where(
            (name) => name.toLowerCase().contains(classroomName.toLowerCase()))
        .toList();
  }

  //Classroom list URL connect

  Future<List<String>> fetchClassroomNames() async {
    final String apiUrl =
        'https://bob-magickids.trainingzone.in/api/ClassroomStudents/classrooms';

    var headers = {
      'Authorization': 'Bearer ${widget.token}',
    };

    var response = await http.get(Uri.parse(apiUrl), headers: headers);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var classrooms = data[1].cast<String>();
      print(await response.body);

      for (var classroom in classrooms) {
        print('Classroom Name: $classroom');
      }
      return classrooms;
    } else {
      throw Exception('Failed to load classroom names');
    }
  }

  // All Student list URL

  Future<List<String>> fetchAllStudentsList() async {
    var headers = {
      'Authorization': 'Bearer ${widget.token}',
    };

    var request = http.Request(
        'GET',
        Uri.parse(
            'https://bob-magickids.trainingzone.in/api/ClassroomStudents/allstudentlist'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      var data = json.decode(responseBody);
      print(responseBody);

      // Assuming the data is a list of student names
      List<String> studentNames = List<String>.from(data);
      return studentNames;
    } else {
      throw Exception('Failed to load student list');
    }
  }

  void printStudentList() async {
    try {
      List<String> studentList = await fetchAllStudentsList();
      setState(() {
        _studentList = studentList;
      });
      print("Student List: $_studentList");
    } catch (e) {
      print("Error fetching student list: $e");
    }
  }

  // Container Widget

  Widget _buildNameBox(String name) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Material(
            elevation: 1,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.06,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 235, 227, 227),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Color(0xFF8779A6)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.06,
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
                          name,
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
            ),
          ),
        ),
        SizedBox(height: screenWidth * 0.04), // Add a SizedBox with height 5
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return WillPopScope(
        onWillPop: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeacherDashboard(
                token: widget.token,
                name: widget.name,role: widget.role,
              ),
            ),
          );
          return false;
        },
        child: Scaffold(
          // AppBar

          appBar: AppBar(
            title: Text(
              'Attendance',
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontFamily: 'Poppins',
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                fontStyle: FontStyle.normal,
                height: 1,
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
                        builder: (context) => TeacherDashboard(
                              token: widget.token,
                              name: widget.name,role: widget.role,
                            )));
              },
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Search Box container Textfiled

                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              vertical: screenWidth * 0.03),
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey[300],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_search,
                                color: Colors.grey,
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.05,
                                    color: Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Search for a student...",
                                    hintStyle: TextStyle(
                                      fontSize: screenWidth * 0.05,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    _searchStudents(value);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenWidth * 0.04),

                // Navigator conditions

                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredNames.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          String selectedName = _filteredNames[index];
                          bool isClassroom = _allNames.contains(
                              selectedName); // Check if the selected name is a classroom

                          if (isClassroom) {
                            // Navigate to BlueHouseScreen for classroom
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlueHouseScreen(
                                    token: widget.token,
                                    classroomName: selectedName,
                                    className: selectedName,role:widget.role,
                                    name: widget.name),
                              ),
                            );
                          } else {
                            // Navigate to SearchStudentScreen for student
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchStudentScreen(
                                    token: widget.token,
                                    studentName: selectedName,
                                    classroomNames: _allNames,
                                    studentList: _studentList,role:widget.role,
                                    name: widget.name),
                              ),
                            );
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildNameBox(_filteredNames[index]),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
