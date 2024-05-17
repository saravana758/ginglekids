import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gingle_kids/Event/Event_Screen.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class EventCalendarScreen extends StatefulWidget {
  final String token;
  final String name;
  final String role;
  const EventCalendarScreen({
    Key? key,
    required this.token,
    required this.name,
    required this.role,
  }) : super(key: key);

  @override
  _EventCalendarScreenState createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<dynamic> events = [];
  List<dynamic> eventsForSelectedMonth = [];
  bool isDDFormat = true;

  @override
  void initState() {
    super.initState();
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
        events = jsonDecode(response.body)['events'];
        eventsForSelectedMonth =
            _filterEventsForSelectedMonth(_focusedDay.month);
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
      Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData.containsKey('events')) {
        setState(() {
          events = responseData['events'].values.toList();
          eventsForSelectedMonth = _filterEventsForSelectedMonth(_focusedDay.month);
        });
      } else {
        print('Events not found in response');
      }
    } else {
      print('Failed to fetch events: ${response.reasonPhrase}');
    }
  }

  List<dynamic> _filterEventsForSelectedMonth(int month) {
    return events.where((event) {
      var startTime = DateTime.parse(event['start_time']);
      return startTime.month == month;
    }).toList();
  }

  // Function to check if there are any events on a particular day
  List<dynamic> _getEventsOnDay(DateTime day) {
    return events.where((event) {
      var startTime = DateTime.parse(event['start_time']);
      return isSameDay(startTime, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => EventScreen(
              token: widget.token,
              name: widget.name,
              role: widget.role,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(-1.0, 0.0);
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
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Event',
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
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => EventScreen(
                    token: widget.token,
                    name: widget.name,
                    role: widget.role,
                  ),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(-1.0, 0.0);
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
          ),
        ),
        body: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 0) {
              // Swiped from left to right
              Navigator.pop(context);
            }
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      eventsForSelectedMonth =
                          _filterEventsForSelectedMonth(selectedDay.month);
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                      eventsForSelectedMonth =
                          _filterEventsForSelectedMonth(focusedDay.month);
                    });
                  },
                  // Remove eventLoader to remove small dots indicating events
                  calendarStyle: CalendarStyle(
                    markersMaxCount: 1,
                    outsideDaysVisible: false,
                    rangeHighlightColor: Color.fromARGB(
                        255, 3, 1, 12), // color for event markers
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, date, events) {
                      final eventCount = _getEventsOnDay(date).length;
                      return Container(
                        margin: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: eventCount > 0 ? Colors.red : null,
                        ),
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              color:
                                  eventCount > 0 ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextStyle: TextStyle(fontSize: screenWidth * 0.05),
                  ),
                ),
                SizedBox(height: screenWidth * 0.05),
                Center(
                  child: Text(
                    'Events for ${DateFormat.MMMM().format(_focusedDay)}',
                    style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: screenWidth * 0.05),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: eventsForSelectedMonth.map((event) {
                    var startTime = DateTime.parse(event['start_time']);
                    return Padding(
                      padding: EdgeInsets.only(left: screenWidth * 0.05),
                      child: Container(
                        height: screenWidth * 0.15,
                        width: screenWidth * 0.9,
                        margin: EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 4,
                              spreadRadius: 2,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: Color.fromRGBO(255, 83, 83, 1),
                                width: screenWidth * 0.01,
                              ),
                            ),
                          ),
                          padding: EdgeInsets.only(left: 8, top: 10),
                          child: Text(
                            '${startTime.day} - ${event['title']}',
                            style: TextStyle(
                              color: Color(0xFF000000),
                              fontFamily: 'Poppins',
                              fontSize: screenWidth * 0.06,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w400,
                              height: 1.1,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
