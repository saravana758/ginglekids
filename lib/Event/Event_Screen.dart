import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gingle_kids/Event/Event_Calandar_Screen.dart';
import 'package:gingle_kids/teacher_dashboard.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'Event_detail_screen.dart';

class EventScreen extends StatefulWidget {
  final String token;
  final String name;
  final String role;

  const EventScreen({
    Key? key,
    required this.token,
    required this.name,
    required this.role,
  }) : super(key: key);

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  List<dynamic> events = [];
  Map<String, List<dynamic>> eventsByMonth = {};

  @override
  void initState() {
    super.initState();
    // Check the user's role and call the appropriate method to fetch events
    if (widget.role == 'teacher') {
      fetchEventData();
    } else if (widget.role == 'student') {
      studentFetchEventData();
    }
  }

  Future<void> fetchEventData() async {
    var headers = {
      'Authorization': 'Bearer ${widget.token}',
    };
    var response = await http.get(
      Uri.parse('https://bob-magickids.trainingzone.in/api/General/eventview'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      print(response.body);
      setState(() {
        var responseData = jsonDecode(response.body)['events'];
        // Parse start_time and end_time to DateTime objects
        responseData.forEach((event) {
          event['start_time'] = DateTime.parse(event['start_time']);
          event['end_time'] = DateTime.parse(event['end_time']);
        });
        events =
            responseData; // Assign the list of events to the events variable
        groupEventsByMonth();
      });
    } else {
      print('Failed to fetch events: ${response.reasonPhrase}');
    }
  }

  Future<void> studentFetchEventData() async {
    var headers = {
      'Authorization': 'Bearer ${widget.token}',
    };
    var response = await http.get(
      Uri.parse('https://bob-magickids.trainingzone.in/api/General/eventview'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      print(response.body);
      setState(() {
        var responseData = jsonDecode(response.body)['events'];
        for (var key in responseData.keys) {
          var event = responseData[key];
          event['start_time'] = DateTime.parse(event['start_time']);
          event['end_time'] = DateTime.parse(event['end_time']);
        }
        events = responseData.values.toList();
        groupEventsByMonth();
      });
    } else {
      print('Failed to fetch events: ${response.reasonPhrase}');
    }
  }

  void groupEventsByMonth() {
    eventsByMonth.clear();
    DateTime currentDate = DateTime.now();

    for (var event in events) {
      DateTime startTime = event['start_time'];

      // Check if the event's start time is on or after the current date
      if (startTime.isAfter(currentDate) ||
          startTime.isAtSameMomentAs(currentDate)) {
        String month = '${startTime.month}';

        if (!eventsByMonth.containsKey(month)) {
          eventsByMonth[month] = [];
        }
        eventsByMonth[month]!.add(event);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
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
            'Events',
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
                  builder: (context) => TeacherDashboard(
                    token: widget.token,
                    name: widget.name,
                    role: widget.role,
                  ),
                ),
              );
            },
          ),
        ),
       body: eventsByMonth.isEmpty
    ? Center(
        child: Text(
          'No upcoming events',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
    : ListView.builder(
        itemCount: eventsByMonth.length,
        itemBuilder: (context, index) {
          String month = eventsByMonth.keys.toList()[index];
          List<dynamic> eventsInMonth = eventsByMonth[month]!;
          return Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                margin: EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.01,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: screenWidth * 0.01),
                      child: Text(
                        _getMonthName(int.parse(month)),
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF999999),
                          fontFamily: 'Poppins',
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.6),
                    GestureDetector(
                      // Wrap the Icon with GestureDetector
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => EventCalendarScreen(
                              token: widget.token,
                              name: widget.name,
                              role: widget.role,
                            ),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0); // Adjusted to start from the right
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;
                              var tween = Tween(begin: begin, end: end).chain(
                                CurveTween(curve: curve),
                              );
                              var offsetAnimation = animation.drive(tween);

                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: screenWidth * 0.05),
                        child: Icon(
                          Icons.calendar_today,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Color(0xFF999999),
                thickness: 1,
                indent: 10,
                endIndent: 10,
              ),
              SizedBox(
                height: screenWidth * 0.03,
              ),
              Column(
                children: eventsInMonth.map((event) {
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => EventDetailsScreen(
                                eventName: event['title'] ?? "",
                                evenendDate: DateFormat('dd/MM/yyyy').format(event['end_time']),
                                eventDate: DateFormat('dd/MM/yyyy').format(event['start_time']),
                                eventDescription: event['description'] ?? '',
                                name: widget.name,
                                token: widget.token,
                                role: widget.role,
                              ),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0); // Adjusted to start from the right
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;
                                var tween = Tween(begin: begin, end: end).chain(
                                  CurveTween(curve: curve),
                                );
                                var offsetAnimation = animation.drive(tween);

                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18),
                          child: Container(
                            height: screenHeight * 0.07,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(0, 85, 255, 0.10),
                              borderRadius: BorderRadius.circular(22.5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    event['title'] ?? "",
                                    style: TextStyle(
                                      color: const Color(0xFF8779A6),
                                      fontSize: screenWidth * 0.06,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    DateFormat('dd/MM/yy').format(event['start_time']),
                                    style: TextStyle(
                                      color: Color.fromRGBO(153, 153, 153, 1),
                                      fontSize: screenWidth * 0.04,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.03),
                    ],
                  );
                }).toList(),
              ),
              SizedBox(
                height: screenWidth * 0.03,
              )
            ],
          );
        },
      ),

      ),
    );
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }
}
