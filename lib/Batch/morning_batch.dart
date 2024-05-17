import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gingle_kids/Attendance/Attendance.dart';
import 'package:gingle_kids/Batch/student_screen.dart';
import 'package:http/http.dart' as http;

class BlueHouseScreen extends StatefulWidget {
  final String token;
  final String classroomName;
  final String className;
  final String name;
  final String role;

  BlueHouseScreen({
    required this.token,
    required this.classroomName,
    required this.className,
    required this.name,
    required this.role,
  });

  @override
  _BlueHouseScreenState createState() => _BlueHouseScreenState();
}

class _BlueHouseScreenState extends State<BlueHouseScreen> {
  List<dynamic> classroomStudents = [];
  Map<String, int> absentDaysMap = {};

  @override
  void initState() {
    super.initState();
    fetchData(widget.token, widget.className); 
    fetchAttendanceData();
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
        // Fetch attendance data for each student
        await fetchAttendanceData();
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception during data fetching: $e');
    }
  }

 Future<void> fetchAttendanceData() async {
  final apiUrl = 'https://bob-magickids.trainingzone.in/api/Attendance/monthlypresent';
  final token = widget.token;

  try {
    final responses = await Future.wait(classroomStudents.map((student) =>
      http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, String>{
           
         'classroom_name': widget.className,
          'month': DateTime.now().month.toString().padLeft(2, '0'),
          'student_name': student['name'],
        }),
      ),
    ));

    for (var i = 0; i < responses.length; i++) {
      final response = responses[i];
      final student = classroomStudents[i];

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<String> absentDays;
        if (data['Absent Days'] is Map<String, dynamic>) {
          absentDays = (data['Absent Days'] as Map<String, dynamic>)
              .values
              .map((value) => value.toString())
              .toList();
        } else if (data['Absent Days'] is List<dynamic>) {
          absentDays = List<String>.from(data['Absent Days']);
        } else {
          throw Exception('Unexpected data type for Absent Days');
        }

        print('${student['name']} - Absent Days: ${absentDays.length}');
        absentDaysMap[student['name']] = absentDays.length;
      } else {
        throw Exception('Failed to fetch attendance data: ${response.statusCode}');
      }
    }
    setState(() {});
  } catch (error) {
    print('Error fetching attendance data: $error');
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
            widget.className,
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
                  builder: (context) => AttendanceScreen(
                    token: widget.token,
                    name: widget.name,
                    role: widget.role,
                  ),
                ),
              );
            },
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: screenWidth * 0.05),
                Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.56),
                  child: _buildTotalAbsentDays(),
                ),
                SizedBox(height: screenWidth * 0.03),
                Column(
                  children: classroomStudents.map((student) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentScreen(
                              studentName: student['name'],
                              token: widget.token,
                              className: widget.classroomName,
                              name: widget.name,
                              role: widget.role,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          _buildNameBox(student['name'] ?? '', absentDaysMap[student['name']] ),

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
    );
  }

Widget _buildNameBox(String name, int? absentDaysCount) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Row(
      children: [
        SizedBox(width: MediaQuery.of(context).size.width * 0.02),
        Expanded(
          child: _buildElevatedRectangleBox(
            Color.fromRGBO(135, 121, 166, 1),
            name,
            absentDaysCount ?? 0, // Ensure absentDaysCount is not null
          ),
        ),
      ],
    ),
  );
}



  Widget _buildElevatedRectangleBox(Color borderColor, String name, int absentDaysCount) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 2),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              Icons.account_circle,
              color: Color(0xFF8779A6),
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
            Text(
              "$absentDaysCount", // Show absent days count here
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.04,
                color: Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalAbsentDays() {
    return Row(
      children: [
        Icon(
          Icons.circle,
          size: MediaQuery.of(context).size.width * 0.03,
          color: Colors.green,
        ),
        SizedBox(width: 10),
        Text(
          "Total absent days",
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.04,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
