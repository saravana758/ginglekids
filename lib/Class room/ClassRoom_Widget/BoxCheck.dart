import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../StuProfile_Screen.dart';
import 'Present_Detail_Widget.dart';

class BoxWidgetList extends StatefulWidget {
  final List<String> widgetNames;
  final String className;
  final String token;
  final List<String> presentStudents;
  final List<String> checkedOutStudents;
  final String name;
  final bool showPresentFirst;
  final VoidCallback refreshDataCallback;
  final String role;
  final List<String> hashid;
  final VoidCallback onConfirmPressed;
  const BoxWidgetList({
    Key? key,
    required this.widgetNames,
    required this.className,
    required this.name,
    required this.token,
    required this.role,
    required this.hashid,
    required this.presentStudents,
    required this.checkedOutStudents,
    required this.showPresentFirst,
    required this.refreshDataCallback,
    required this.onConfirmPressed,
  }) : super(key: key);

  @override
  _BoxWidgetListState createState() => _BoxWidgetListState();
}

class _BoxWidgetListState extends State<BoxWidgetList> {
  late Map<String, bool> _switchStates;
  late int totalStudentsCount;
  late int presentStudentsCount;
  late int absentStudentsCount;
  late List<String> presentStudents;
  late List<String> checkedOutStudents;

  @override
  void initState() {
    super.initState();
    _switchStates = {};
    totalStudentsCount = 0;
    presentStudentsCount = 0;
    absentStudentsCount = 0;

    presentStudents = [];
    checkedOutStudents = [];
    for (var studentName in widget.presentStudents) {
      _switchStates[studentName] = true;
    }
  }

  _refreshData() {
    setState(() {});
  }

  String getHashidForWidgetName(String widgetName) {
    // Assuming widgetNames and hashid are in the same order
    // and you want to find the index of widgetName in widgetNames
    // to get the corresponding hashid from hashid list
    int index = widget.widgetNames.indexOf(widgetName);
    if (index != -1) {
      // Return the hashid at the same index in the hashid list
      return widget.hashid[index];
    } else {
      // Handle the case where widgetName is not found in widgetNames
      // This could involve returning a default hashid or throwing an error
      return ''; // Return an empty string or a default hashid
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> presentStudents = widget.widgetNames
        .where((student) => widget.presentStudents.contains(student))
        .toList();
    List<String> absentStudents = widget.widgetNames
        .where((student) => !widget.presentStudents.contains(student))
        .toList();
    List<String> reorderedStudents = widget.showPresentFirst
        ? [...presentStudents, ...absentStudents]
        : [...absentStudents, ...presentStudents];

    List<Widget> rows = [];

    for (int i = 0; i < reorderedStudents.length; i += 2) {
      List<String> rowWidgets = [];

      if (i < reorderedStudents.length) rowWidgets.add(reorderedStudents[i]);
      if (i + 1 < reorderedStudents.length)
        rowWidgets.add(reorderedStudents[i + 1]);

      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: rowWidgets.map((widgetName) {
            String hashidForCurrentWidget = getHashidForWidgetName(widgetName);
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: BoxWidget(
                widgetName: widgetName,
                role: widget.role,
                className: widget.className,
                name: widget.name,
                token: widget.token,
                switchState: _switchStates[widgetName] ?? false,
                onSwitchStateChanged: (String widgetName, bool newValue) {
                  setState(() {
                    _switchStates[widgetName] = newValue;
                  });
                },
                checkedOutStudents: widget.checkedOutStudents,
                hashid: hashidForCurrentWidget,
              ),
            );
          }).toList(),
        ),
      );
    }

    return Column(
      children: [
        ...rows,
        ConfirmBtnWidget(
          switchStates: _switchStates,
          className: widget.className,
          token: widget.token,
          sendAttendance: sendAttendance,
          onPressed: _onConfirmPressed,
          refreshDataCallback: () => _refreshData(),
          refreshData: _refreshData,
          onConfirmPressed: widget.onConfirmPressed,
        ),
      ],
    );
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
        setState(() {
          totalStudentsCount = responseData['total_students'];
          presentStudentsCount = responseData['present_students_count'];
          absentStudentsCount = responseData['absent_students_count'];
          presentStudents = (responseData['present_students'] as List<dynamic>)
              .map((student) => student['name'] as String)
              .toList();
          checkedOutStudents =
              List<String>.from(responseData['check_out_students']);
        });
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
      setState(() {
        totalStudentsCount = responseData['total_students'];
        presentStudentsCount = responseData['present_students_count'];
        absentStudentsCount = responseData['absent_students_count'];
        presentStudents = (responseData['present_students'] as List<dynamic>)
            .map((student) => student['name'] as String)
            .toList();
        checkedOutStudents =
            List<String>.from(responseData['check_out_students']);
      });
      print('Checked Out Students: $checkedOutStudents');
    } else {
      throw Exception(
          'Failed to send attendance data: ${response.reasonPhrase}');
    }
  }

  void _onConfirmPressed() {
    for (var entry in _switchStates.entries) {
      sendAttendance(entry.key, widget.className, widget.token, entry.value);
    }
  }

  Future<void> sendAttendance(String studentName, String className,
      String token, bool switchState) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    var requestBody = {
      "classroom_name": className,
      "students": [
        {"name": studentName, "check_in": switchState}
      ]
    };

    var request = http.Request(
      'POST',
      Uri.parse(
          'https://bob-magickids.trainingzone.in/api/Attendance/attendance'),
    );
    request.headers.addAll(headers);
    request.body = json.encode(requestBody);

    try {
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        responseBody =
            responseBody.trim(); // Trim leading and trailing whitespace
        responseBody = responseBody.replaceAll('"', ''); // Remove double quotes

        print('Response: $responseBody');
        PresentWidget(
          totalStudents: totalStudentsCount,
          presentStudentsCount: presentStudentsCount,
          absentStudentsCount: absentStudentsCount,
        );
        if (responseBody.isNotEmpty && responseBody != '[]') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text(
                  responseBody,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text("Ok"),
                    onPressed: () {
                      widget.refreshDataCallback();

                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        print('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error sending request: $e');
    }
  }
}

class BoxWidget extends StatefulWidget {
  final String widgetName;
  final String className;
  final String token;
  final bool switchState;
  final Function(String, bool) onSwitchStateChanged;
  final List<String> checkedOutStudents;
  final String name;
  final String role;
  final String hashid; // Added hashid parameter
  const BoxWidget({
    Key? key,
    required this.widgetName,
    required this.className,
    required this.name,
    required this.token,
    required this.switchState,
    required this.onSwitchStateChanged,
    required this.checkedOutStudents,
    required this.role,
    required this.hashid, // Added hashid parameter
  }) : super(key: key);

  @override
  _BoxWidgetState createState() => _BoxWidgetState();
}

class _BoxWidgetState extends State<BoxWidget> {
  late bool _switchValue;

  @override
  void initState() {
    super.initState();
    _switchValue = widget.switchState;
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = 'https://bob-magickids.trainingzone.in/student/${widget.hashid}/student-images';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StuProfileScreen(
              className: widget.className,
              widgetname: widget.widgetName,
              role: widget.role,
              name: widget.name,
              token: widget.token,
            ),
          ),
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.25),
              blurRadius: 4.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.20,
          width: MediaQuery.of(context).size.width * 0.39,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.012,
                ),
                child: Container(
                  height: MediaQuery.of(context).size.width * 0.17,
                  width: MediaQuery.of(context).size.width * 0.17,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width * 0.100,
                        ),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              // Image is loaded successfully
                              return child;
                            } else {
                              // Image is still loading, you can show a placeholder or loading indicator here
                              return CircularProgressIndicator();
                            }
                          },
                          errorBuilder: (context, error, stackTrace) {
                            // Error occurred while loading image, you can show an error message or placeholder here
                            return Icon(
                              Icons.person,
                              size: MediaQuery.of(context).size.width * 0.17,
                              color: Color(0xFF8779A6),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.014,
                ),
                child: Text(
                  widget.widgetName,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    fontFamily: 'Poppins',
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.0,
                    height: 1.222,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.01,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!widget.checkedOutStudents.contains(widget.widgetName))
                    Theme(
                      data: ThemeData(
                        toggleableActiveColor: Colors.green,
                      ),
                      child: Switch(
                        value: _switchValue,
                        onChanged: (bool newValue) {
                          setState(() {
                            _switchValue = newValue;
                            widget.onSwitchStateChanged(
                              widget.widgetName,
                              newValue,
                            );
                          });
                        },
                      ),
                    )
                  else
                    Text(
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
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConfirmBtnWidget extends StatefulWidget {
  final Map<String, bool> switchStates;
  final String className;
  final String token;
  final Function(String, String, String, bool) sendAttendance;
  final VoidCallback onPressed;
  final VoidCallback refreshDataCallback;
  final VoidCallback refreshData;
  final VoidCallback onConfirmPressed;
  ConfirmBtnWidget({
    Key? key,
    required this.switchStates,
    required this.className,
    required this.token,
    required this.refreshData,
    required this.sendAttendance,
    required this.onPressed,
    required this.refreshDataCallback,
    required this.onConfirmPressed,
  }) : super(key: key);

  @override
  _ConfirmBtnWidgetState createState() => _ConfirmBtnWidgetState();
}

class _ConfirmBtnWidgetState extends State<ConfirmBtnWidget> {
  late int totalStudentsCount;
  late int presentStudentsCount;
  late int absentStudentsCount;
  late List<String> presentStudents;
  late List<String> checkedOutStudents;

  @override
  void initState() {
    super.initState();
    totalStudentsCount = 0;
    presentStudentsCount = 0;
    absentStudentsCount = 0;
    presentStudents = [];
    checkedOutStudents = [];
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
        setState(() {
          totalStudentsCount = responseData['total_students'];
          presentStudentsCount = responseData['present_students_count'];
          absentStudentsCount = responseData['absent_students_count'];
          presentStudents = (responseData['present_students'] as List<dynamic>)
              .map((student) => student['name'] as String)
              .toList();
          checkedOutStudents =
              List<String>.from(responseData['check_out_students']);
        });
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
      setState(() {
        totalStudentsCount = responseData['total_students'];
        presentStudentsCount = responseData['present_students_count'];
        absentStudentsCount = responseData['absent_students_count'];
        presentStudents = (responseData['present_students'] as List<dynamic>)
            .map((student) => student['name'] as String)
            .toList();
        checkedOutStudents =
            List<String>.from(responseData['check_out_students']);
      });
      print('Checked Out Students: $checkedOutStudents');
    } else {
      throw Exception(
          'Failed to send attendance data: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color(0xFF13C32F),
      ),
      child: ElevatedButton(
        onPressed: () {
          presentData();

          print("saro");

          print("saro");
          widget.refreshDataCallback();
          widget.refreshData();
          widget.onConfirmPressed();
          PresentWidget(
            totalStudents: totalStudentsCount,
            presentStudentsCount: presentStudentsCount,
            absentStudentsCount: absentStudentsCount,
          );
          widget.onPressed();
        },
        child: Text(
          'Confirm',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontFamily: 'Poppins',
            fontSize: screenWidth * 0.04,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w700,
            height: 1.47,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      ),
    );
  }
}
