import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'ClassRoom_Widget/BoxCheck.dart';
import 'ClassRoom_Widget/Date_Widget.dart';
import 'ClassRoom_Widget/Present_Detail_Widget.dart';
import 'ClassRoom_Widget/Text.dart';
import 'Classroom_list.dart';

class StuCheck extends StatefulWidget {
  final String className;
  final String token;
  final String name;
  final String role;
  const StuCheck(
      {Key? key,
      required this.className,
      required this.name,
      required this.token,
      required this.role})
      : super(key: key);

  @override
  _StuCheckState createState() => _StuCheckState();
}

class _StuCheckState extends State<StuCheck> {
  late List<Map<String, dynamic>> students = [];
  bool isLoading = true;

  int totalStudentsCount = 0;
  int presentStudentsCount = 0;
  int absentStudentsCount = 0;
  List<String> presentStudents = [];
  List<String> checkedOutStudents = [];

  bool _showPresentFirst = true;

  @override
  void initState() {
    _refreshData();
    super.initState();
    fetchData();
    presentData();
  }

  Future<void> fetchData() async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.token}'
    };
    var body = json.encode({
      "classroom_name": widget.className,
    });

    try {
      var response = await http.post(
          Uri.parse(
              'https://bob-magickids.trainingzone.in/api/ClassroomStudents/studentlist'),
          headers: headers,
          body: body);

      if (response.statusCode == 200) {
        print('API Response: ${response.body}');
        setState(() {
          students = List<Map<String, dynamic>>.from(
              json.decode(response.body)['students']);
          // Iterate through the list of students
          for (var student in students) {
            // Extract the hashid for the current student
            String hashid = student['hashid'];
            // Add the hashid to the student's details
            student['details']['hashid'] = hashid;
            // Print the hashid for this student
            print('Hashid for ${student['name']}: $hashid');
            String hash = student['details']['hashid'];
            print(hash);
          }
          isLoading = false;
        });
      } else {
        print('Failed to load data: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> presentData() async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.token}'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://bob-magickids.trainingzone.in/api/Attendance/present'));
    request.headers.addAll(headers);

    var currentDate = DateTime.now();
    var formattedDate =
        "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";

    request.body = json.encode({
      "classroom_name": widget.className,
      "date": formattedDate,
    });

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 302) {
      String newLocation = response.headers['location']!;
      print('Redirected to: $newLocation');
      var redirectedResponse = await http.get(Uri.parse(newLocation));
      if (redirectedResponse.statusCode == 200) {
        String responseBody = redirectedResponse.body;
        print(responseBody);
        // Extract counts from the response
        Map<String, dynamic> responseData = json.decode(responseBody);
        totalStudentsCount = responseData['total_students'];
        presentStudentsCount = responseData['present_students_count'];
        absentStudentsCount = responseData['absent_students_count'];
        presentStudents = (responseData['present_students'] as List<dynamic>)
            .map((student) => student['name'] as String)
            .toList();
        checkedOutStudents =
            List<String>.from(responseData['check_out_students']);
        print(
            'Checked Out Students: $checkedOutStudents'); // Debug: Print the updated list
      } else {
        throw Exception(
            'Failed to send attendance data: ${redirectedResponse.reasonPhrase}');
      }
    } else if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      print(responseBody);

      // Extract counts from the response
      Map<String, dynamic> responseData = json.decode(responseBody);
      totalStudentsCount = responseData['total_students'];
      presentStudentsCount = responseData['present_students_count'];
      absentStudentsCount = responseData['absent_students_count'];
      presentStudents = (responseData['present_students'] as List<dynamic>)
          .map((student) => student['name'] as String)
          .toList();
      checkedOutStudents =
          List<String>.from(responseData['check_out_students']);
      print('Checked Out Students: $checkedOutStudents');
    } else {
      throw Exception(
          'Failed to send attendance data: ${response.reasonPhrase}');
    }
  }

  Future<void> checkOutStudents(List<String> students) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.token}'
    };

    var body = json.encode({
      "classroom_name": widget.className,
      "students": students,
    });

    try {
      var response = await http.post(
          Uri.parse(
              'https://bob-magickids.trainingzone.in/api/Attendance/checkout'),
          headers: headers,
          body: body);

      // Debug: Print the raw response body
      print('Raw API Response: ${response.body}');

      if (response.statusCode == 200) {
        print('Checked out students: ${json.decode(response.body)}');
        // Ensure the response is correctly parsed and the state is updated
        setState(() {
          checkedOutStudents = List<String>.from(
              json.decode(response.body)['check_out_students']);
        });
        print(
            'Updated checkedOutStudents: $checkedOutStudents'); // Debug: Print the updated list
      } else {
        print('Failed to check out students: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error checking out students: $e');
    }
  }

  Future<void> _refreshData() async {
    print("saro");
    await fetchData();
    await presentData();
  }

  void _toggleSortOrder() {
    setState(() {
      print("Sort Order Saro");
      _showPresentFirst = !_showPresentFirst;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClassroomList(
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
                  builder: (context) => ClassroomList(
                    token: widget.token,
                    name: widget.name,
                    role: widget.role,
                  ),
                ),
              );
            },
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.vertical,
                onDismissed: (_) => _refreshData(),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        TextWidget(text: "Attendance"),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),
                        Row(
                          children: [
                            CurrentDateWidget(), // Assuming this is a widget showing the current date
                            SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4),
                            GestureDetector(
                              onTap: _toggleSortOrder,
                              child: Row(
                                children: [
                                  Icon(Icons.swap_vert),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.01),
                                  Text(
                                    "Sort",
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.05,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                        PresentWidget(
                          totalStudents: totalStudentsCount,
                          presentStudentsCount: presentStudentsCount,
                          absentStudentsCount: absentStudentsCount,
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.04),
                        BoxWidgetList(
                          className: widget.className,
                          onConfirmPressed: _refreshData,
                          token: widget.token,
                          widgetNames: students
                              .map((student) => student['name'] as String)
                              .toList(),
                          presentStudents: presentStudents,
                          checkedOutStudents: checkedOutStudents,
                          name: widget.name,
                          showPresentFirst: _showPresentFirst,
                          refreshDataCallback: () => _refreshData(),
                          role: widget.role,
                          // Assuming you have a list of hashids for each student
                          hashid: students
                              .map((student) => student['hashid'] as String)
                              .toList(),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.04),
                        SizedBox(
                            height: MediaQuery.of(context).size.width * 0.03),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
