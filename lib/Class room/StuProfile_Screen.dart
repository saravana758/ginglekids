import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'ClassRoom_Widget/EmailIDWidget.dart';
import 'ClassRoom_Widget/FatherNameWidget.dart';
import 'ClassRoom_Widget/Mothenamewidget.dart';

import 'ClassRoom_Widget/ProfileDetail.dart';
import 'ClassRoom_Widget/ProfileImgWidget.dart';
import 'StuCheck.dart';

class StuProfileScreen extends StatefulWidget {
  final String className;
  final String token;
  final String widgetname;
  final String name;
  final String role;

  const StuProfileScreen({
    Key? key,
    required this.name,
    required this.className,
    required this.token,
    required this.widgetname,
    required this.role,
  }) : super(key: key);

  @override
  _StuProfileScreenState createState() => _StuProfileScreenState();
}

class _StuProfileScreenState extends State<StuProfileScreen> {
  bool isLoading = false;
  String? studentDOB; // Declare studentDOB variable
  Map<String, dynamic>? responseData;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.token}'
    };
    var body = json.encode({
      "classroom_name": widget.className,
      "student_name": widget.widgetname
    });

    try {
      var response = await http.post(
        Uri.parse(
            'https://bob-magickids.trainingzone.in/api/ClassroomStudents/studentprofile'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        setState(() {
          responseData = json.decode(response.body); // Storing response data

          studentDOB = responseData?['student']['dob'];
          print(responseData);
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Extract father's name, mother's name, email, and father's mobile number from responseData
    final fatherName = responseData?['student']['parents']['father_name'] ?? "";
    final motherName = responseData?['student']['parents']['mother_name'] ?? "";
    final email = responseData?['student']['email'] ?? "";
    final fatherNum =
        responseData?['student']['parents']['fathers_mobile_no'] ?? "";
    final nationality = responseData?['student']['nationality'] ?? "";
    final gender = responseData?['student']['gender'] ?? "";

    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StuCheck(
              token: widget.token,
              className: widget.className,
              name: widget.name,
              role: widget.role,
            ),
          ),
        );
        return false;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            height: screenHeight * 1.2,
            width: screenWidth,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/profileback.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: screenWidth * 0.05, top: screenWidth * 0.1),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StuCheck(
                            token: widget.token,
                            className: widget.className,
                            name: widget.name,
                            role: widget.role,
                          ),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.arrow_back_sharp,
                      size: screenWidth * 0.07,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.014),
                Center( child: ProfileImage(hashid: responseData?['student']['hashid']),
),
                SizedBox(height: screenHeight * 0.02),
                NameWidget(text: widget.widgetname),
                SizedBox(height: screenHeight * 0.01),
                // Display student's class
                // Assuming you have a classwidget widget to display the class
                classwidget(text: "${widget.className}"),
                SizedBox(height: screenHeight * 0.1),
                Center(child: FatherNameWidget(fathername: fatherName)),
                SizedBox(height: screenHeight * 0.03),
                Center(child: MotherNameWidget(mothername: motherName)),
                SizedBox(height: screenHeight * 0.03),
                Center(child: EmailIDWidget(emailid: email)),
                SizedBox(height: screenHeight * 0.03),
                Row(
                  children: [
                    SizedBox(width: screenWidth * 0.02),
                    ProfiledetailWidget(
                      title: "Contact",
                      content: responseData?['student']['mobile'] ?? "",
                      icon: Icons.phone,
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    ProfiledetailWidget(
                      title: "Contact",
                      content: fatherNum,
                      icon: Icons.phone,
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),
                Row(
                  children: [
                    SizedBox(width: screenWidth * 0.02),
                    ProfiledetailWidget(
                      title: "Gender",
                      content: gender,
                      icon: Icons.transgender,
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    ProfiledetailWidget(
                      title: 'Date of Birth',
                      content: studentDOB ?? "",
                      icon: Icons.cake,
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),

                Row(
                  children: [
                    SizedBox(width: screenWidth * 0.02),
                    ProfiledetailWidget(
                      title: 'Blood Group',
                      content: 'O +ve',
                      icon: Icons.bloodtype,
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    ProfiledetailWidget(
                      title: 'Allergic',
                      content: 'Dust',
                      icon: Icons.medical_services,
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),
                Row(
                  children: [
                    SizedBox(width: screenWidth * 0.02),
                    ProfiledetailWidget(
                      title: 'Nationality',
                      content: nationality,
                      icon: Icons.flag,
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    ProfiledetailWidget(
                      title: 'Transport',
                      content: responseData?['transport'] == 'Y' ? "Yes" : "No",
                      icon: Icons.directions_bus,
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
