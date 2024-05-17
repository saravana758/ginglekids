import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Attendance/Attendance.dart';
import '../Class room/ClassRoom_Widget/Present_Detail_Widget.dart';

class SearchStudentScreen extends StatefulWidget {
  final String token;
  final String studentName;
  final List<String> classroomNames;
  final List<String> studentList;
  final String name;
  final String role;

  SearchStudentScreen({
    required this.token,
    required this.studentName,
    required this.classroomNames,
    required this.studentList,
    required this.name,
    required this.role,
  });

  @override
  _SearchStudentScreenState createState() => _SearchStudentScreenState();
}

class _SearchStudentScreenState extends State<SearchStudentScreen> {
  bool _isChecked = false;
  int totalStudents = 0;
  int presentStudentsCount = 0;
  int absentStudentsCount = 0;
  String? _className;
  Map<String, dynamic>? _attendanceResponse;
  TextEditingController _searchController = TextEditingController();
  List<String> filteredStudentList = [];
  bool _showSpecificStudent = true;
  @override
  void initState() {
    super.initState();
    filteredStudentList = widget.studentList;
    // Iterate over each classroom name and fetch data
    for (String className in widget.classroomNames) {
      fetchClassroomNames(className);
    }
  }

  void _showDialog(String message) {
  if (message.isNotEmpty && message != '[]') {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message,style: TextStyle(fontWeight: FontWeight.bold),),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                // Update the state to refresh the UI
                setState(() {
                  // Reset filteredStudentList
                  filteredStudentList = widget.studentList;
                  // Fetch data again for each classroom name
                  for (String className in widget.classroomNames) {
                    fetchClassroomNames(className);
                  }
                });
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}


  void filterStudents(String query) {
    if (query.isEmpty) {
      setState(() {
        _showSpecificStudent = true;
        filteredStudentList = widget.studentList;
      });
    } else {
      setState(() {
        _showSpecificStudent = false;
        filteredStudentList = widget.studentList
            .where((studentName) =>
                studentName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  Future<void> fetchClassroomNames(String className) async {
    // Prepare headers
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.token}',
    };

    var requestBody = {
      "classroom_name": className,
    };

    var request = http.Request(
      'POST',
      Uri.parse(
          'https://bob-magickids.trainingzone.in/api/ClassroomStudents/studentlist'),
    );
    request.headers.addAll(headers);
    request.body = json.encode(requestBody);

    // Send the request
    http.StreamedResponse response = await request.send();

    // Handle response
    if (response.statusCode == 200) {
      // Decode the response body
      String responseBody = await response.stream.bytesToString();
      print("Response: $responseBody");

      // Parse the response body to get student lists and update the UI accordingly
      var jsonResponse = json.decode(responseBody);
      if (jsonResponse != null &&
          jsonResponse is Map &&
          jsonResponse.containsKey('students')) {
        // Assuming the response contains a 'students' key with a list of students
        List students = jsonResponse['students'];
        if (students.isNotEmpty) {
          // Here you can update your UI with the student list received from the response
          print("Students found: ${students.length}");

          // Check if the studentName exists in the response
          if (students
              .any((student) => student['name'] == widget.studentName)) {
            print("Student ${widget.studentName} found in $className");

            // Store the className when the student is found
            setState(() {
              _className = className;
              // Call todayPresent only after _className is set
              todayPresent(widget.studentName).then((isPresent) {
                setState(() {
                  _isChecked = isPresent;
                });
              });
            });
          } else {
            print("Student ${widget.studentName} not found in $className");
          }
        } else {
          print('No students found in the response.');
        }
      } else {
        print('Invalid response format or no students found.');
      }
    } else {
      print("Error: ${response.reasonPhrase}");
      // Handle the error, e.g., show a message to the user
    }
  }

  Widget _buildSlideButton(
    Color borderColor,
    String name,
    bool isChecked,
    bool isCheckOut,
    bool showSwitch,
  ) {
    // Determine if the student has checked out
    bool isStudentCheckedOut = false;
    if (_attendanceResponse != null &&
        _attendanceResponse!.containsKey('check_out_students')) {
      isStudentCheckedOut =
          _attendanceResponse!['check_out_students'].contains(name);
    }

    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.02,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 2),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.13,
                  child: Image.asset(
                    "assets/images/Male User.png",
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.02,
                ),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.06,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            if (showSwitch)
              isCheckOut
                  ? Text(
                      'Checkout') // Render checkout text for checkout students
                  : !isStudentCheckedOut
                      ? Switch(
                          value: isChecked,
                          onChanged: (value) {
                            setState(() {
                              _isChecked = value;
                              updateAttendance(value);
                            });
                          },
                          activeTrackColor: Colors.green,
                          activeColor: Colors.white,
                        )
                      : Text(
                          'Check Out',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                            fontFamily: 'Poppins',
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1.0,
                            height: 1.222,
                          ),
                        ), // Render text if already checked out
          ],
        ),
      ),
    );
  }

 Future<void> updateAttendance(bool isChecked) async {
  if (_className != null) {
    // Prepare headers
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.token}',
    };

    // Prepare request body
    var requestBody = {
      "classroom_name": _className, // Use the stored className
      "students": [
        {
          "name": widget.studentName,
          "check_in": isChecked,
        }
      ]
    };

    // Create the POST request
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://bob-magickids.trainingzone.in/api/Attendance/attendance'));
    request.headers.addAll(headers);
    request.body = json.encode(requestBody);

    // Send the request
    http.StreamedResponse response = await request.send();

    // Handle response
    if (response.statusCode == 200) {
      // Read response body
      String responseBody = await response.stream.bytesToString();
      responseBody = responseBody.trim(); // Trim leading and trailing whitespace
      responseBody = responseBody.replaceAll('"', ''); 

      print("Response: $responseBody");
      _showDialog(responseBody);
      // Update the UI based on the response if necessary
      // For example, you might want to update the total students, present students count, or absent students count
    } else {
      print("Error: ${response.reasonPhrase}");
      // Handle the error, e.g., show a message to the user
    }
  } else {
    print("Error: _className is null");
    // Handle the case where className is not found
  }
}

  Future<bool> todayPresent(String name) async {
    // Prepare headers
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.token}',
    };
    var currentDate = DateTime.now();
    var formattedDate =
        "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";

    // Prepare request body
    var requestBody = {
      "classroom_name": _className, // Assuming _className is accessible here
      "date": formattedDate,
    };

    // Create the POST request
    var request = http.Request(
      'POST',
      Uri.parse('https://bob-magickids.trainingzone.in/api/Attendance/present'),
    );
    request.headers.addAll(headers);
    request.body = json.encode(requestBody);

    // Send the request
    http.StreamedResponse response = await request.send();

    // Handle response
    if (response.statusCode == 200) {
      // Parse response
      var responseBody = await response.stream.bytesToString();
      var decodedResponse = json.decode(responseBody);
      print(responseBody);

      // Check if 'present_students' is present in the response
      if (decodedResponse.containsKey('present_students')) {
        // Extract 'present_students' list
        var presentStudents = decodedResponse['present_students'];

        // Check if the student is present
        bool isPresent =
            presentStudents.any((student) => student['name'] == name);

        // Update state variables
        setState(() {
          totalStudents = decodedResponse['total_students'];
          presentStudentsCount = decodedResponse['present_students_count'];
          absentStudentsCount = decodedResponse['absent_students_count'];
        });

        // Store the decoded response data
        _attendanceResponse = decodedResponse;

        // Return the presence status
        return isPresent;
      } else {
        // Handle case when 'present_students' key is missing in the response
        print("Error: 'present_students' key is missing in the response.");
        return false; // Default to false if not found
      }
    } else {
      // Handle other status codes
      print(response.reasonPhrase);
      return false; // Default to false if not found
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
              builder: (context) => AttendanceScreen(
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
              'Search Student',
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
                        builder: (context) => AttendanceScreen(
                              token: widget.token,
                              name: widget.name,
                              role: widget.role,
                            )));
              },
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Results',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.08,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.width * 0.04),
                        PresentWidget(
                          totalStudents: totalStudents,
                          presentStudentsCount: presentStudentsCount,
                          absentStudentsCount: absentStudentsCount,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.width * 0.08,
                        ),
                        if (!_showSpecificStudent &&
                            filteredStudentList
                                .isNotEmpty) // Only display filtered list when search is performed and list is not empty
                          ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: filteredStudentList.length,
                            separatorBuilder: (context, index) => SizedBox(
                              height: MediaQuery.of(context).size.width * 0.08,
                            ),
                            itemBuilder: (context, index) {
                              String studentName = filteredStudentList[index];
                              if (_attendanceResponse != null &&
                                  _attendanceResponse!
                                      .containsKey('check_out_students')) {
                                bool isCheckOut =
                                    _attendanceResponse!['check_out_students']
                                        .contains(studentName);

                                return GestureDetector(
                                  onTap: () {
                                    // Handle the selection of student name here
                                    print('Selected student: $studentName');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SearchStudentScreen(
                                          token: widget.token,
                                          studentName: studentName,
                                          classroomNames: widget.classroomNames,
                                          studentList: widget.studentList,
                                          name: widget.name,
                                          role: widget.role,
                                        ),
                                      ),
                                    );
                                  },
                                  child: _buildSlideButton(
                                    Color.fromRGBO(135, 121, 166, 1),
                                    studentName,
                                    _isChecked,
                                    isCheckOut,
                                    false, // Don't show the switch
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                        if (_showSpecificStudent) // Display specific student initially
                          _buildSlideButton(
                            Color.fromRGBO(135, 121, 166, 1),
                            widget.studentName,
                            _isChecked,
                            false,
                            true, // Show the switch
                          ),
                        if (!_showSpecificStudent &&
                            filteredStudentList
                                .isEmpty) // Display message if filtered list is empty
                          Text(
                            'No matching student',
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.06,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Search Box container Textfiled

                    Expanded(
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: screenWidth * 0.03),
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
                                //  onChanged: filterStudents,
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
                                onChanged: filterStudents,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
