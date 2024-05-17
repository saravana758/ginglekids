import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gingle_kids/Batch/morning_batch.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../teacher_dashboard.dart';

class StudentScreen extends StatefulWidget {
  final String token;
  final String studentName;
  final String className;
  final String name;
  final String role;
  const StudentScreen(
      {required this.token,
      required this.studentName,
      required this.name,
      required this.role,
      required this.className});

  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  // Map<String, dynamic> monthlyPresentDays = {};
   late List<String> classroomsData; 
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List<dynamic>> _eventsMap;
  int totalworkingdays = 0;
 
  late int monthlyAbsentDays = 0;
  int monthlyPresentDays = 0;
   final List<DateTime> highlightedDates = [
    // DateTime(2024, 4, 16),
    // DateTime(2024, 4, 24),
    // DateTime(2024, 4, 23),
    // Add more dates as needed
  ];

  // late List<dynamic> _selectedEvents;
  //late int totalworkingdays;
  late String _selectedMonth;
  // late String _classroomName;
  // late String _month;
  // late int monthlyPresentDays;

    @override
  void initState() {
    super.initState();
  fetchClassroomNames(widget.token).then((classrooms) {
    classroomsData = classrooms; // Assigning the fetched classrooms to classroomsData
    if (widget.role == 'teacher') {
      fetchAttendanceData();
    } else if (widget.role == 'student') {
      studentAttendanceData(classrooms);
    }
  });

    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _eventsMap = {};
    _selectedMonth = DateFormat('MM').format(DateTime.now());
  }

  void _onMonthChanged(DateTime selectedDay, List<String> classroomsData) {
    setState(() {
      _selectedMonth = DateFormat('MM').format(selectedDay);
    });
    fetchAttendanceData();
     studentAttendanceData(classroomsData);
  }

  void _onLeftChevronTapped( List<String> classroomsData) {
    var selectedDateTime = DateTime.parse('2024-$_selectedMonth-01');
    var previousMonth = DateTime(selectedDateTime.year,
        selectedDateTime.month - 1, selectedDateTime.day);
    setState(() {
      _selectedMonth = DateFormat('MM').format(previousMonth);
      _focusedDay = previousMonth;
    });
    fetchAttendanceData();
     studentAttendanceData(classroomsData);
  }

  void _onrightChevronTapped( List<String> classroomsData) {
    // Increment the selected month
    var selectedDateTime = DateTime.parse('2024-$_selectedMonth-01');
    var nextMonth = DateTime(selectedDateTime.year, selectedDateTime.month + 1,
        selectedDateTime.day);
    setState(() {
      _selectedMonth = DateFormat('MM').format(nextMonth);
      _focusedDay = nextMonth;
    });
    fetchAttendanceData(); // Call fetchAttendanceData() after updating the month

     studentAttendanceData(classroomsData);
  }

  Future<List<String>> fetchClassroomNames(String token) async {
    final String apiUrl =
        'https://bob-magickids.trainingzone.in/api/ClassroomStudents/classrooms';

    var headers = {
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(Uri.parse(apiUrl), headers: headers);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(response.body);
      // Assuming the classroom names are in the second element of the list
      var classroomsData = data[1];
      print(classroomsData);
      // Check if classroomsData is a list and not empty
      if (classroomsData is List && classroomsData.isNotEmpty) {
        // Assuming each classroom name is a string
        List<String> classrooms = classroomsData.cast<String>();
        return classrooms;
      } else {
        throw Exception('No classroom names found');
      }
    } else {
      throw Exception('Failed to load classroom names');
    }
  }

  Future<void> fetchAttendanceData() async {
    // Convert _selectedMonth to a DateTime object representing the first day of the selected month in the current year
    final selectedMonthDateTime =
        DateTime(DateTime.now().year, int.parse(_selectedMonth), 1);
    final currentMonth = DateTime.now().month;
    final selectedMonth = selectedMonthDateTime.month;

    // Check if selected month is not in the future
    if (selectedMonth <= currentMonth) {
      final apiUrl =
          'https://bob-magickids.trainingzone.in/api/Attendance/monthlypresent';
      final token = widget.token;

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(<String, String>{
            'classroom_name': widget.className,
            'month':
                _selectedMonth, // This line might need adjustment based on your API's expected format
            'student_name': widget.studentName,
          }),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print(response.body);

          // Determine if 'Absent Days' is a map or a list
          List<String> absentDays;
          if (data['Absent Days'] is Map<String, dynamic>) {
            // Handle 'Absent Days' as a map
            final Map<String, dynamic> absentDaysMap =
                data['Absent Days'] as Map<String, dynamic>;
            absentDays =
                absentDaysMap.values.map((value) => value.toString()).toList();
          } else if (data['Absent Days'] is List<dynamic>) {
            // Handle 'Absent Days' as a list
            absentDays = List<String>.from(data['Absent Days']);
          } else {
            throw Exception('Unexpected data type for Absent Days');
          }

          // Convert the list of date strings to DateTime objects
          final List<DateTime> parsedAbsentDates = absentDays.map((dateString) {
            final parts = dateString.split('-');
            return DateTime(
                int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          }).toList();

          // Update your state or UI with the parsed data
          setState(() {
            monthlyPresentDays = data['Monthly Present Days'] as int;
            monthlyAbsentDays = absentDays.length;
            totalworkingdays = monthlyPresentDays + monthlyAbsentDays;

            highlightedDates.clear();
            highlightedDates.addAll(parsedAbsentDates);
          });

          print('Monthly Present Days: $monthlyPresentDays');
          print('Monthly Absent Days: $monthlyAbsentDays');
          print('Total Working Days: $totalworkingdays');
        } else {
          throw Exception(
              'Failed to fetch attendance data: ${response.statusCode}');
        }
      } catch (error) {
        print('Error fetching attendance data: $error');
      }
    } else {
      monthlyAbsentDays = 0;
      totalworkingdays = 0;
      monthlyPresentDays = 0;
      print('Selected month is in the future. No request sent.');
    }
  }

 void studentAttendanceData(List<String> classroomsData) async{
    // Convert _selectedMonth to a DateTime object representing the first day of the selected month in the current year
    final selectedMonthDateTime =
        DateTime(DateTime.now().year, int.parse(_selectedMonth), 1);
    final currentMonth = DateTime.now().month;
    final selectedMonth = selectedMonthDateTime.month;

    // Check if selected month is not in the future
    if (selectedMonth <= currentMonth) {
      final apiUrl =
          'https://bob-magickids.trainingzone.in/api/Attendance/monthlypresent';
      final token = widget.token;

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(<String, String>{
            'classroom_name':  classroomsData[0],
            'month':
                _selectedMonth, // This line might need adjustment based on your API's expected format
            'student_name': widget.studentName,
          }),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print(response.body);

          // Determine if 'Absent Days' is a map or a list
          List<String> absentDays;
          if (data['Absent Days'] is Map<String, dynamic>) {
            // Handle 'Absent Days' as a map
            final Map<String, dynamic> absentDaysMap =
                data['Absent Days'] as Map<String, dynamic>;
            absentDays =
                absentDaysMap.values.map((value) => value.toString()).toList();
          } else if (data['Absent Days'] is List<dynamic>) {
            // Handle 'Absent Days' as a list
            absentDays = List<String>.from(data['Absent Days']);
          } else {
            throw Exception('Unexpected data type for Absent Days');
          }

          // Convert the list of date strings to DateTime objects
          final List<DateTime> parsedAbsentDates = absentDays.map((dateString) {
            final parts = dateString.split('-');
            return DateTime(
                int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          }).toList();

          // Update your state or UI with the parsed data
          setState(() {
            monthlyPresentDays = data['Monthly Present Days'] as int;
            monthlyAbsentDays = absentDays.length;
            totalworkingdays = monthlyPresentDays + monthlyAbsentDays;

            highlightedDates.clear();
            highlightedDates.addAll(parsedAbsentDates);
          });

          print('Monthly Present Days: $monthlyPresentDays');
          print('Monthly Absent Days: $monthlyAbsentDays');
          print('Total Working Days: $totalworkingdays');
        } else {
          throw Exception(
              'Failed to fetch attendance data: ${response.statusCode}');
        }
      } catch (error) {
        print('Error fetching attendance data: $error');
      }
    } else {
      monthlyAbsentDays = 0;
      totalworkingdays = 0;
      monthlyPresentDays = 0;
      print('Selected month is in the future. No request sent.');
    }
  }
  // Widget buildAbsentDaysList(List<DateTime> absentDays, double screenWidth) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: List.generate(
  //       absentDays.length,
  //       (index) => Container(
  //         height: screenWidth * 0.15,
  //         width: screenWidth * 0.9,
  //         margin: EdgeInsets.only(bottom: 8),
  //         padding: EdgeInsets.all(8),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(10),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.black.withOpacity(0.25),
  //               blurRadius: 4,
  //               spreadRadius: 2,
  //               offset: Offset(0, 0),
  //             ),
  //           ],
  //         ),
  //         child: Container(
  //           decoration: BoxDecoration(
  //             border: Border(
  //               left: BorderSide(
  //                 color: Color.fromRGBO(255, 83, 83, 1),
  //                 width: screenWidth * 0.01,
  //               ),
  //             ),
  //           ),
  //           padding: EdgeInsets.only(left: 8, top: 10),
  //           child: Text(
  //            "${absentDays[index].day.toString()}  -",
  //             style: TextStyle(
  //               color: Color(0xFF000000),
  //               fontFamily: 'Poppins',
  //               fontSize: screenWidth * 0.06,
  //               fontStyle: FontStyle.normal,
  //               fontWeight: FontWeight.w400,
  //               height: 1.1,
  //               letterSpacing: 0.5,
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
        onWillPop: () async {
          if (widget.role == 'student') {
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
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlueHouseScreen(
                  token: widget.token,
                  name: widget.name,
                  classroomName: widget.studentName,
                  className: widget.className,
                  role: widget.role,
                ),
              ),
            );
            return true;
          }
        },
        child: Scaffold(
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
                  if (widget.role == 'student') {
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
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlueHouseScreen(
                          token: widget.token,
                          name: widget.name,
                          classroomName: widget.studentName,
                          className: widget.className,
                          role: widget.role,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            body: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.account_circle,
                                color: Color(0xFF8779A6),
                                size: screenWidth * 0.08,
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              Text(
                                '${widget.studentName}',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.06,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenWidth * 0.04),
                          Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: screenWidth * 0.93,
                              height: screenHeight * 0.16,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: screenWidth * 0.93,
                                    height: screenHeight * 0.07,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      ),
                                      color: Color(0xff8679a5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        " ${DateFormat('MMMM').format(DateTime.parse('2024-$_selectedMonth-01'))} 2024",
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.06,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: ListView(
                                            shrinkWrap: true,
                                            children: [
                                              Text(
                                                'Working Days',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: screenWidth * 0.037,
                                                  fontWeight: FontWeight.w700,
                                                  fontStyle: FontStyle.normal,
                                                  letterSpacing: 0.5,
                                                  color: Color.fromRGBO(
                                                      135, 121, 166, 1),
                                                  height: 1.47,
                                                ),
                                              ),

                                              SizedBox(
                                                  height: screenWidth * 0.02),

                                              Text(
                                                totalworkingdays > 0
                                                    ? '$totalworkingdays'
                                                    : '-',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: screenWidth * 0.05,
                                                  fontWeight: FontWeight.w700,
                                                  fontStyle: FontStyle.normal,
                                                  letterSpacing: 0.5,
                                                  color: Colors.black,
                                                  height:
                                                      1.22, // Equivalent to line height 22px
                                                ),
                                              )
                                              // This ensures that the ListView has at least one child
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: ListView(
                                            shrinkWrap: true,
                                            children: [
                                              Text(
                                                'Present Days',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: screenWidth * 0.037,
                                                  fontWeight: FontWeight.w700,
                                                  fontStyle: FontStyle.normal,
                                                  letterSpacing: 0.5,
                                                  color: Color.fromRGBO(
                                                      135, 121, 166, 1),
                                                  height: 1.47,
                                                ),
                                              ),

                                              SizedBox(
                                                  height: screenWidth * 0.02),
                                              // _selectedEvents.length > 0
                                              //     ?
                                              Text(
                                                monthlyPresentDays > 0
                                                    ? '$monthlyPresentDays'
                                                    : '-',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: screenWidth * 0.05,
                                                  fontWeight: FontWeight.w700,
                                                  fontStyle: FontStyle.normal,
                                                  letterSpacing: 0.5,
                                                  color: Color.fromARGB(
                                                      255, 23, 247, 3),
                                                  height:
                                                      1.22, // Equivalent to line height 22px
                                                ),
                                              )
                                              // This ensures that the ListView has at least one child
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: ListView(
                                            shrinkWrap: true,
                                            children: [
                                              Text(
                                                'Absent Days',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: screenWidth * 0.037,
                                                  fontWeight: FontWeight.w700,
                                                  fontStyle: FontStyle.normal,
                                                  letterSpacing: 0.5,
                                                  color: Color.fromRGBO(
                                                      135, 121, 166, 1),
                                                  height: 1.47,
                                                ),
                                              ),

                                              SizedBox(
                                                  height: screenWidth * 0.02),
                                              // _selectedEvents.length > 0
                                              //     ?
                                              Text(
                                                monthlyAbsentDays > 0
                                                    ? '$monthlyAbsentDays'
                                                    : '-',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: screenWidth * 0.05,
                                                  fontWeight: FontWeight.w700,
                                                  fontStyle: FontStyle.normal,
                                                  letterSpacing: 0.5,
                                                  color: const Color.fromARGB(
                                                      255, 226, 64, 64),
                                                  height:
                                                      1.22, // Equivalent to line height 22px
                                                ),
                                              )
                                              // This ensures that the ListView has at least one child
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: screenWidth * 0.01),
                          Center(
                              child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onHorizontalDragEnd: (DragEndDetails details) {
                              print("Swipe detected");
                              if (details.primaryVelocity! > 0) {
                                print("Swipe left");
                                _onLeftChevronTapped(classroomsData);
                              } else if (details.primaryVelocity! < 0) {
                                print("Swipe right");
                               _onrightChevronTapped(classroomsData);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(4),
                              child: TableCalendar(
                                availableGestures: AvailableGestures.none,
                                firstDay: DateTime.utc(2020, 1, 1),
                                lastDay: DateTime.utc(2030, 12, 31),
                                focusedDay: _focusedDay,
                                calendarFormat: _calendarFormat,
                                selectedDayPredicate: (day) {
                                  return isSameDay(_selectedDay, day) &&
                                      _selectedDay.day == day.day &&
                                      _selectedDay.month == day.month &&
                                      _selectedDay.year == day.year;
                                },
                                onDaySelected: (selectedDay, focusedDay) async {
                                  if (!isSameDay(_selectedDay, selectedDay)) {
                                    setState(() {
                                      _selectedDay = selectedDay;
                                      _focusedDay = focusedDay;
                                    });
                                    _onMonthChanged(selectedDay,classroomsData);
                                    await fetchActivityData(selectedDay);
                                  }
                                },
                                eventLoader: (day) {
                                  return _eventsMap[day] ?? [];
                                },
                                calendarStyle: CalendarStyle(
                                  markersMaxCount: 1,
                                  outsideDaysVisible: false,
                                  defaultTextStyle:
                                      TextStyle(color: Colors.black),
                                  todayDecoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.green),
                                  selectedDecoration: BoxDecoration(
                                    color: Color.fromARGB(255, 209, 11, 133),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.green),
                                  ),
                                ),
                                headerStyle: HeaderStyle(
                                  titleCentered: true,
                                  formatButtonVisible: false,
                                  titleTextStyle: TextStyle(
                                    fontSize: 22,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  leftChevronIcon: GestureDetector(
                                   onTap: () => _onLeftChevronTapped(classroomsData),
                                    child: Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      size: 40,
                                      color: Color.fromRGBO(135, 121, 166, 1),
                                    ),
                                  ),
                                  rightChevronIcon: GestureDetector(
                                     onTap: () => _onrightChevronTapped(classroomsData),
                                    child: Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 40,
                                      color: Color.fromRGBO(135, 121, 166, 1),
                                    ),
                                  ),
                                ),
                                daysOfWeekStyle: DaysOfWeekStyle(
                                  weekdayStyle: TextStyle(color: Colors.black),
                                  weekendStyle: TextStyle(color: Colors.black),
                                ),
                                calendarBuilders: CalendarBuilders(
                                  // Modify the defaultBuilder in your CalendarBuilders
                                  defaultBuilder: (context, date, _) {
                                    final isWeekend =
                                        date.weekday == 6 || date.weekday == 7;
                                    final isSelectedDay =
                                        isSameDay(_selectedDay, date);
                                    final isPresentDay =
                                        isSameDay(date, DateTime.now());
                                    final isHighlightedDate = highlightedDates
                                        .any((highlightedDate) =>
                                            isSameDay(date, highlightedDate));

                                    Widget dayWidget;

                                    if (isPresentDay) {
                                      dayWidget = GestureDetector(
                                        // onTap: () {
                                        //   // Do nothing if present day is tapped
                                        // },
                                        child: Container(
                                          margin: const EdgeInsets.all(2.0),
                                          width: screenWidth * 0.085,
                                          height: screenWidth * 0.085,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color.fromRGBO(
                                                135, 121, 166, 1),
                                          ),
                                          child: Center(
                                            child: Text(
                                              date.day.toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    } else if (isWeekend) {
                                      // Highlight weekends differently
                                      dayWidget = GestureDetector(
                                        onTap: () {
                                          if (!isSelectedDay) {
                                            setState(() {
                                              _selectedDay = date;
                                              _focusedDay = date;
                                            });
                                            fetchActivityData(date);
                                          }
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.all(2.0),
                                          width: screenWidth * 0.085,
                                          height: screenWidth * 0.085,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color.fromRGBO(
                                                135, 121, 166, 1),
                                          ),
                                          child: Center(
                                            child: Text(
                                              date.day.toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      // Default style for other days
                                      dayWidget = GestureDetector(
                                        onTap: () {
                                          if (!isSelectedDay) {
                                            setState(() {
                                              _selectedDay = date;
                                              _focusedDay = date;
                                            });
                                            fetchActivityData(date);
                                          }
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.all(4.0),
                                          width: screenWidth * 0.085,
                                          height: screenWidth * 0.085,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isHighlightedDate
                                                ? Colors.red
                                                : (isSelectedDay
                                                    ? Colors.green
                                                    : const Color.fromARGB(
                                                        0, 250, 246, 246)),
                                          ),
                                          child: Center(
                                            child: Text(
                                              date.day.toString(),
                                              style: TextStyle(
                                                color: isHighlightedDate
                                                    ? Colors.white
                                                    : isSelectedDay
                                                        ? Colors.white
                                                        : Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return dayWidget;
                                  },
                                ),
                              ),
                            ),
                          )),
                          SizedBox(height: screenWidth * 0.05),
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     // Other widgets...

                          //     SizedBox(height: screenWidth * 0.01),

                          //     // Display the absent days
                          //     buildAbsentDaysList(highlightedDates, screenWidth),

                          //     SizedBox(height: screenWidth * 0.01),
                          //   ],
                          // ),
                        ])))));
  }

  fetchActivityData(DateTime selectedDay) {}
}
