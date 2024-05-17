import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gingle_kids/Attendance/Attendance.dart';
import 'package:gingle_kids/Chat/Chat_ClassroomList.dart';
import 'package:gingle_kids/Class%20room/Classroom_list.dart';
import 'package:gingle_kids/Message/MessageScreen.dart';
import 'package:gingle_kids/Payment/Payment.dart';
import 'package:gingle_kids/click/attendance.dart';
import 'package:gingle_kids/click/chat.dart';
import 'package:gingle_kids/click/classroom.dart';
import 'package:gingle_kids/click/event.dart';
import 'package:gingle_kids/click/message.dart';
import 'package:gingle_kids/click/payment.dart';
import 'package:gingle_kids/click/post.dart';
import 'package:gingle_kids/post/Post_Screen.dart';
import 'package:http/http.dart' as http;
import 'package:gingle_kids/login/login_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'Batch/student_screen.dart';
import 'Event/Event_Screen.dart';


class TeacherDashboard extends StatefulWidget {
  final String token;
  final String name;
  final String role;

  const TeacherDashboard(
      {Key? key, required this.token, required this.name, required this.role})
      : super(key: key);

  @override
  _TeacherDashboardState createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int studentCount = 0;
  Object? get token => widget.token;
  String? _userInfoImageUrl;
   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  int _notificationId = 0;

  Timer? _timer;
  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    fetchClassroomNames(widget.token);
    print("Token: ok ${widget.token}");
    print(widget.name);
    print('role');
    print(widget.role);
// Print the token here
    fetchData();
    // _name = widget.name;
    _fetchUserData();
     _initializeNotifications();
    _scheduleDailyNotification();
    _startCurrentTimeUpdater();
  }
 @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
 Future<void> _initializeNotifications() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleDailyNotification() async {
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata')); // Indian time zone

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      10, // Hour
      13, // Minute
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      _notificationId++,
      'Notification Title',
      'This is a notification message',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id',
          'Channel Name',
          channelDescription: 'Channel Description',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    setState(() {
    });
  }

  void _startCurrentTimeUpdater() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      final now = tz.TZDateTime.now(tz.local);
      setState(() {
      });

      // Check if the current time is 10:25:00 AM
      if (now.hour == 6 && now.minute == 00 && now.second == 0) {
        _showImmediateNotification();
      }
    });
  }

  Future<void> _showImmediateNotification() async {
    const androidNotificationDetails = AndroidNotificationDetails(
      'channel_id',
      'Channel Name',
      channelDescription: 'Channel Description',
      importance: Importance.high,
      priority: Priority.high,
    );

    await flutterLocalNotificationsPlugin.show(
      _notificationId++,
      'Hi',
      'Good Morning',
      const NotificationDetails(
        android: androidNotificationDetails,
      ),
    );
  }

  Future<List<String>> fetchClassroomNames(String token) async {
    try {
      final String apiUrl =
          'https://bob-magickids.trainingzone.in/api/ClassroomStudents/classrooms';

      var headers = {
        'Authorization': 'Bearer $token',
      };

      var response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var classrooms = data[1].cast<String>();
        return classrooms;
      } else {
        throw Exception(
            'Failed to load classroom names. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching classroom names: $e');
      throw Exception('Failed to load classroom names. Error: $e');
    }
  }

  Future<void> fetchData() async {
    var headers = {
      'Authorization': 'Bearer ${widget.token}',
    };
    var uri = Uri.parse(
        'https://bob-magickids.trainingzone.in/api/ClassroomStudents/allstudentlist');
    var response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      // Parse JSON response
      List<dynamic> studentNames = json.decode(response.body);

      // Get the count of student names and set the value of studentCount
      studentCount = studentNames.length;
      print('Number of students: $studentCount');

      // Print each student name
      for (var name in studentNames) {
        print(name);
      }

      // After setting the value, trigger a rebuild of the widget tree
      setState(() {});
    } else {
      print('Failed to fetch data: ${response.reasonPhrase}');
    }
  }

  Future<void> _fetchUserData() async {
    final token = widget.token;
    final response = await http.get(
      Uri.parse('https://bob-magickids.trainingzone.in/api/userinfo'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final parsedResponse = json.decode(response.body);
      print(response.body);
      print(parsedResponse);
      setState(() {
        print(widget.name);
      });

      // Extract the hashid from the response
      final hashid = parsedResponse['user']['teacher']['hashid'];

      // Construct the image URL with the hashid
      final imageUrl =
          'https://bob-magickids.trainingzone.in/teacher/$hashid/teacher-images';

      // Now you can use this imageUrl wherever you want to display the image
      print(imageUrl);

      if (imageUrl.isNotEmpty) {
        print("ok");
        setState(() {
          _userInfoImageUrl = imageUrl;
        });
      } else {
        print("fail");
      }
    } else {
      print("Failed");
      print('Failed to load user data. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load user data');
    }
  }

  Widget circle(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final studentCount =
        10; // Sample student count, replace with your actual value

    return Positioned(
      left: screenWidth * 0.05, // 5% of the screen width
      top: screenHeight * 0.01, // 1% of the screen height
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          width: screenWidth * 0.1, // 10% of the screen width
          height: screenWidth * 0.1, // 10% of the screen width
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color.fromARGB(
                255, 2, 10, 17), // You can change the color as needed
          ),
          child: Center(
            child: Text(
              '$studentCount',
              style: TextStyle(
                // fontSize: screenWidth * 0.04,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        // Show dialog asking if the user wants to exit the app
        return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Exit App'),
                  content: const Text('Are you sure you want to exit the app?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('No'),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                    ),
                    TextButton(
                      child: const Text('Yes'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        SystemNavigator.pop();
                      },
                    ),
                  ],
                );
              },
            ) ??
            false; // If the dialog is dismissed, return false to prevent the back action
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(children: [
            Container(
              width: screenWidth,
              height: screenHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const Image(
                    image: AssetImage('assets/images/dashboard2.png'),
                    fit: BoxFit.fill,
                  ),
                  Positioned(
                    top: screenHeight * 0.03,
                    left: screenWidth * 0.02,
                    child: Row(
                      children: [
                        PopupMenuButton(
                          icon: Icon(Icons.menu,
                              color: Colors.white, size: screenWidth * 0.09),
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.home,
                                      color: Color(0xFF8779A6),
                                    ),
                                    SizedBox(width: screenWidth * 0.02),
                                    const Text('Home Screen'),
                                  ],
                                ),
                                value: 'item1',
                              ),
                              // PopupMenuItem(
                              //   child: Row(
                              //     children: [
                              //       const Icon(
                              //         Icons.info,
                              //         color: Color(0xFF8779A6),
                              //       ),
                              //       SizedBox(width: screenWidth * 0.02),
                              //       const Text('About Us'),
                              //     ],
                              //   ),
                              //   value: 'item2',
                              // ),
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.lock,
                                      color: Color(0xFF8779A6),
                                    ),
                                    SizedBox(width: screenWidth * 0.02),
                                    const Text('Change Password'),
                                  ],
                                ),
                                value: 'item3',
                              ),

                              // PopupMenuItem(
                              //   child: Row(
                              //     children: [
                              //       const Icon(
                              //         Icons.star,
                              //         color: Color(0xFF8779A6),
                              //       ),
                              //       SizedBox(width: screenWidth * 0.02),
                              //       const Text('Rate Us'),
                              //     ],
                              //   ),
                              //   value: 'item4',
                              // ),
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons
                                          .logout, // Assuming you have an appropriate logout icon
                                      color: Color(0xFF8779A6),
                                    ),
                                    SizedBox(width: screenWidth * 0.02),
                                    const Text('Log out'),
                                  ],
                                ),
                                value: 'item5',
                              ),
                              // Add more items as needed
                            ];
                          },
                          onSelected: (value) async {
                            // Handle menu item selection here
                            switch (value) {
                              case 'item1':
                                // Handle item 1 selection
                                break;
                              case 'item2':
                                // Handle item 2 selection
                                break;
                              case 'item3':
                                // Handle item 3 selection
                                break;
                              case 'item4':
                                // Handle item 4 selection
                                break;
                              case 'item5':
                              // Handle item 5 selection
                              // final storage = FlutterSecureStorage();
                              // await storage.delete(key: 'token');
                              // await storage.delete(key: 'name');
                              // Navigator.pushAndRemoveUntil(
                              //   context,
                              //   MaterialPageRoute(builder: (context) => LoginScreen()),
                              //   (route) => false, // This line will clear the navigation stack
                              // );
                              //  break;
                              case 'logout': // Assuming 'logout' is the value for the logout button
                                // Show dialog asking if the user wants to logout
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Logout Confirmation'),
                                      content: const Text(
                                          'Are you sure you want to logout?'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('No'),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          },
                                        ),
                                        TextButton(
                                          child: const Text('Yes'),
                                          onPressed: () {
                                            // Proceed with logout action
                                            final storage =
                                                const FlutterSecureStorage();
                                            storage.delete(key: 'token');
                                            storage.delete(key: 'name');
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      LoginScreen()),
                                              (route) =>
                                                  false, // This line will clear the navigation stack
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                                break;
                              // Add more cases as needed
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: screenHeight * 0.13,
                    left: screenWidth * 0.04,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: screenHeight * 0.04,
                          backgroundColor: Color.fromARGB(255, 252, 251, 251),
                          child: _userInfoImageUrl != null &&
                                  _userInfoImageUrl!.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    _userInfoImageUrl!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (BuildContext context,
                                        Object exception,
                                        StackTrace? stackTrace) {
                                      print('Error loading image: $exception');
                                      return Icon(
                                        Icons.person,
                                        size: screenHeight * 0.04,
                                        color: Color(0xFF8779A6),
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  size: screenHeight * 0.04,
                                  color: Color(0xFF8779A6),
                                ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenHeight * 0.025,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Text(
                            //   '${widget.email}',
                            //   style: TextStyle(
                            //     color: Colors.white,
                            //     fontSize: screenHeight * 0.018,
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: screenHeight * 0.04,
                    right: screenWidth * 0.1,
                    child: GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => ChatBox()),
                        // );
                      },
                      child: Container(
                        width: screenWidth * 0.07,
                        child: Icon(
                          Icons.mail,
                          color: Colors.white,
                          size: screenHeight * 0.05,
                        ),
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      Positioned(
                        width: 50,
                        height: 50,
                        left: screenWidth * 0.70,
                        top: screenHeight * 0.15,
                        child: Visibility(
                          visible: widget.role !=
                              'student', // Hide if role is 'student'
                          child: SvgPicture.asset(
                            "assets/icons/Boy.svg",
                            width: 90,
                            height: 20,
                            color: const Color.fromRGBO(135, 121, 166, 1),
                          ),
                        ),
                      ),
                      Positioned(
                        left: screenWidth * 0.6,
                        top: screenHeight * 0.23,
                        child: Visibility(
                          visible: widget.role != 'student',
                          child: Text(
                            "$studentCount - Students",
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              color: Colors.black,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                      if (widget.role == 'student')
                        Positioned(
                          left: screenWidth * 0.7,
                          top: screenHeight * 0.13,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Container(
                              width: screenWidth * 0.21,
                              height: screenWidth * 0.21,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Color.fromARGB(255, 249, 249, 250),
                                  width: 9,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      child: CircularProgressIndicator(
                                        value: 20 / 28,
                                        strokeWidth: 9,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Color(0xFF8779A6),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      '${(27 / 28 * 100).toStringAsFixed(2)}%',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.04,
                                        color: Color.fromARGB(255, 4, 0, 12),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (widget.role == 'student')
                    Positioned(
                      left: screenWidth * 0.66,
                      top: screenHeight * 0.24,
                      child: Text(
                        "Attendance",
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  Positioned(
                    left: screenWidth * 0.1,
                    top: screenHeight * 0.31,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: screenWidth * 0.8,
                        height: screenHeight * 0.9,
                        child: GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                          padding: const EdgeInsets.all(4.0),
                          children: [
                            if (widget.role == 'teacher' ||
                                widget.role == 'student')
                              Column(
                                children: [
                                  // ElevatedButton(
                                  //   onPressed: () {
                                  //     Navigator.push(
                                  //       context,
                                  //       MaterialPageRoute(
                                  //         builder: (context) => PostScreen(
                                  //           token: widget.token,
                                  //           name: widget.name,
                                  //           role: widget.role,
                                  //           classroomName: '',
                                  //           commentsurl: ''
                                  //         ),
                                  //       ),
                                  //     );
                                  //   },
                                  //   style: ElevatedButton.styleFrom(
                                  //     padding: const EdgeInsets.all(0),
                                  //     elevation: 6,
                                  //     shape: RoundedRectangleBorder(
                                  //       borderRadius: BorderRadius.circular(8),
                                  //       side: const BorderSide(
                                  //         color: Color.fromRGBO(135, 121, 166, 1),
                                  //       ),
                                  //     ),
                                  //   ),
                                  //   child: Container(
                                  //     padding: const EdgeInsets.all(8),
                                  //     width: screenWidth * 0.3,
                                  //     height: screenWidth * 0.3,
                                  //     decoration: BoxDecoration(
                                  //       border: Border.all(
                                  //         color: const Color.fromRGBO(135, 121, 166, 1),
                                  //       ),
                                  //       borderRadius: BorderRadius.circular(8),
                                  //       color: Colors.white,
                                  //     ),
                                  //     child: Icon(
                                  //       Icons.photo,
                                  //       size: screenWidth * 0.2,
                                  //       color: const Color.fromRGBO(135, 121, 166, 1),
                                  //     ),
                                  //   ),
                                  // ),
                                  ClickableButton(
                                    token: widget.token,
                                    name: widget.name,
                                    role: widget.role,
                                  ),
                                  Text(
                                    "Posts",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.06,
                                      color: Colors.black,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            // Add other widgets here
                            // Attendance widget
                            if (widget.role == 'teacher' ||
                                widget.role == 'student')
                              Column(
                                children: [
                                  // ElevatedButton(
                                  //   onPressed: () async {
                                  //     if (widget.role == 'student') {
                                  //       Navigator.push(
                                  //         context,
                                  //         MaterialPageRoute(
                                  //           builder: (context) => StudentScreen(
                                  //             token: widget.token,
                                  //             className: '',
                                  //             name: widget.name,
                                  //             role: widget.role,
                                  //             studentName: widget.name,
                                  //           ),
                                  //         ),
                                  //       );
                                  //     } else {
                                  //       Navigator.push(
                                  //         context,
                                  //         MaterialPageRoute(
                                  //           builder: (context) => AttendanceScreen(
                                  //             token: widget.token,
                                  //             name: widget.name,
                                  //             role: widget.role,
                                  //           ),
                                  //         ),
                                  //       );
                                  //     }
                                  //   },
                                  //   style: ElevatedButton.styleFrom(
                                  //     padding: const EdgeInsets.all(0),
                                  //     elevation: 6,
                                  //     shape: RoundedRectangleBorder(
                                  //       borderRadius: BorderRadius.circular(8),
                                  //       side: const BorderSide(
                                  //         color: Color.fromRGBO(135, 121, 166, 1),
                                  //       ),
                                  //     ),
                                  //   ),
                                  //  child: Container(
                                  //                               padding: const EdgeInsets.all(8),
                                  //                               width: screenWidth * 0.3,
                                  //                               height: screenWidth * 0.3,
                                  //                               decoration: BoxDecoration(
                                  //                                 border: Border.all(
                                  //                                     color: const Color.fromRGBO(
                                  //                                         135, 121, 166, 1)),
                                  //                                 borderRadius:
                                  //                                     BorderRadius.circular(8),
                                  //                                 color: Colors.white,
                                  //                               ),
                                  //                               child: SvgPicture.asset(
                                  //                                 "assets/icons/attendance-1.svg",
                                  //                                 color: const Color.fromRGBO(
                                  //                                     135, 121, 166, 1),
                                  //                               ),
                                  //                             ),
                                  //                           ),

                                  AttendanceButton(
                                    token: widget.token,
                                    name: widget.name,
                                    role: widget.role,
                                  ),

                                  Text(
                                    "Attendance",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.06,
                                      color: Colors.black,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            // Add other widgets here
                            // Chat widget
                            if (widget.role == 'teacher' ||
                                widget.role == 'student')
                              Column(
                                children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ChatClassroomList(
//                           token: widget.token,
//                         ),
//                       ),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.all(0),
//                     elevation: 6,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                       side: const BorderSide(
//                         color: Color.fromRGBO(135, 121, 166, 1),
//                       ),
//                     ),
//                   ),
// child: Container(
//                 padding: const EdgeInsets.all(8),
//                 width: screenWidth * 0.3,
//                 height: screenWidth * 0.3,
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                       color: const Color.fromRGBO(135, 121, 166, 1)),
//                   borderRadius: BorderRadius.circular(8),
//                   color: Colors.white,
//                 ),
//                 child: SvgPicture.asset(
//                   "assets/icons/bubble-chat-1.svg",
//                   color: const Color.fromRGBO(135, 121, 166, 1),
//                 ),
//               ),
//             ),

                                  ChatButton(
                                    token: widget.token,
                                    name: widget.name,
                                    role: widget.role,
                                  ),
                                  Text(
                                    "Chats",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.06,
                                      color: Colors.black,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            // Add other widgets here
                            // Classroom widget
                            if (widget.role == 'teacher')
                              Column(
                                children: [
                                  // ElevatedButton(
                                  //   onPressed: () {
                                  //     Navigator.push(
                                  //       context,
                                  //       MaterialPageRoute(
                                  //         builder: (context) => ClassroomList(
                                  //           token: widget.token,
                                  //           name: widget.name,
                                  //           role: widget.role,
                                  //         ),
                                  //       ),
                                  //     );
                                  //   },
                                  //   style: ElevatedButton.styleFrom(
                                  //     padding: const EdgeInsets.all(0),
                                  //     elevation: 6,
                                  //     shape: RoundedRectangleBorder(
                                  //       borderRadius: BorderRadius.circular(8),
                                  //       side: const BorderSide(
                                  //         color: Color.fromRGBO(135, 121, 166, 1),
                                  //       ),
                                  //     ),
                                  //   ),
                                  //   child: Container(
                                  //                             padding: const EdgeInsets.all(8),
                                  //                             width: screenWidth * 0.3,
                                  //                             height: screenWidth * 0.3,
                                  //                             decoration: BoxDecoration(
                                  //                               border: Border.all(
                                  //                                 color: const Color.fromRGBO(
                                  //                                     135, 121, 166, 1),
                                  //                               ),
                                  //                               borderRadius:
                                  //                                   BorderRadius.circular(8),
                                  //                               color: Colors
                                  //                                   .white, // Set the color to white
                                  //                             ),
                                  //                             child: SvgPicture.asset(
                                  //                               "assets/icons/classroom-1.svg",
                                  //                               width: 40,
                                  //                               height: 40,
                                  //                               color: const Color.fromRGBO(
                                  //                                   135, 121, 166, 1),
                                  //                             ),
                                  //                           ),
                                  //                         ),

                                  ClassroomButton(
                                    token: widget.token,
                                    name: widget.name,
                                    role: widget.role,
                                  ),

                                  Text(
                                    "Classroom",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.06,
                                      color: Colors.black,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            // Add other widgets here
                            // Event widget
                            if (widget.role == 'teacher' ||
                                widget.role == 'student')
                              Column(
                                children: [
                                  // ElevatedButton(
                                  //   onPressed: () {
                                  //     Navigator.push(
                                  //       context,
                                  //       MaterialPageRoute(
                                  //         builder: (context) => EventScreen(
                                  //           token: widget.token,
                                  //           name: widget.name,
                                  //           role: widget.role,
                                  //         ),
                                  //       ),
                                  //     );
                                  //   },
                                  //   style: ElevatedButton.styleFrom(
                                  //     padding: const EdgeInsets.all(0),
                                  //     elevation: 6,
                                  //     shape: RoundedRectangleBorder(
                                  //       borderRadius: BorderRadius.circular(8),
                                  //       side: const BorderSide(
                                  //         color: Color.fromRGBO(135, 121, 166, 1),
                                  //       ),
                                  //     ),
                                  //   ),
                                  //   child: Container(
                                  //     padding: const EdgeInsets.all(8),
                                  //     width: screenWidth * 0.3,
                                  //     height: screenWidth * 0.3,
                                  //     decoration: BoxDecoration(
                                  //       border: Border.all(
                                  //         color: Color.fromRGBO(135, 121, 166, 1),
                                  //       ),
                                  //       borderRadius: BorderRadius.circular(8),
                                  //       color: Colors.white,
                                  //     ),
                                  //     child: Icon(
                                  //       Icons.event,
                                  //       size: screenWidth * 0.2,
                                  //       color: Color.fromRGBO(135, 121, 166, 1),
                                  //     ),
                                  //   ),
                                  // ),

                                  EventButton(
                                    token: widget.token,
                                    name: widget.name,
                                    role: widget.role,
                                  ),
                                  Text(
                                    "Events",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.06,
                                      color: Colors.black,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            // Message widget
                            if (widget.role == 'teacher' ||
                                widget.role == 'student')
                              Column(
                                children: [
                                  // ElevatedButton(
                                  //   onPressed: () {
                                  //     Navigator.push(
                                  //       context,
                                  //       MaterialPageRoute(
                                  //         builder: (context) => MessageScreen(
                                  //           token: widget.token,
                                  //           name: widget.name,
                                  //           role: widget.role,
                                  //         ),
                                  //       ),
                                  //     );
                                  //   },
                                  //   style: ElevatedButton.styleFrom(
                                  //     padding: const EdgeInsets.all(0),
                                  //     elevation: 6,
                                  //     shape: RoundedRectangleBorder(
                                  //       borderRadius: BorderRadius.circular(8),
                                  //       side: const BorderSide(
                                  //         color: Color.fromRGBO(135, 121, 166, 1),
                                  //       ),
                                  //     ),
                                  //   ),
                                  //   child: Container(
                                  //     padding: const EdgeInsets.all(8),
                                  //     width: screenWidth * 0.3,
                                  //     height: screenWidth * 0.3,
                                  //     decoration: BoxDecoration(
                                  //       border: Border.all(
                                  //         color: Color.fromRGBO(135, 121, 166, 1),
                                  //       ),
                                  //       borderRadius: BorderRadius.circular(8),
                                  //       color: Colors.white,
                                  //     ),
                                  //     child: Icon(
                                  //       Icons.message,
                                  //       size: screenWidth * 0.2,
                                  //       color: Color.fromRGBO(135, 121, 166, 1),
                                  //     ),
                                  //   ),
                                  // ),
                                  MessageButton(
                                    token: widget.token,
                                    name: widget.name,
                                    role: widget.role,
                                  ),
                                  Text(
                                    "Message",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.06,
                                      color: Colors.black,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            if (widget.role == 'student')
                              Column(
                                children: [
//           ElevatedButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => PaymentPage(
//                     token: widget.token,
//                     name: widget.name,
//                     role: widget.role,
//                   ),
//                 ),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.all(0),
//               elevation: 6,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 side: const BorderSide(
//                   color: Color.fromRGBO(135, 121, 166, 1),
//                 ),
//               ),
//             ),
//             child: Container(
//               padding: const EdgeInsets.all(8),
//               width: screenWidth * 0.3,
//               height: screenWidth * 0.3,
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: Color.fromRGBO(135, 121, 166, 1),
//                 ),
//                 borderRadius: BorderRadius.circular(8),
//                 color: Colors.white,
//               ),
//               child:
//               Image.asset(
//   'assets/images/payment1.png', // Replace 'image_name.png' with the path to your image asset
//   width: screenWidth * 0.3, // Set the width of the image
//   height: screenWidth * 0.3, // Set the height of the image
//   color: Color.fromRGBO(135, 121, 166, 1), // Set the color of the image (if needed)
// ),
                                  // Icon(
                                  //   Icons.payment_outlined,
                                  //   size: screenWidth * 0.2,
                                  //   color: Color.fromRGBO(135, 121, 166, 1),
                                  // ),

                                  PaymentButton(
                                    token: widget.token,
                                    name: widget.name,
                                    role: widget.role,
                                  ),

                                  Text(
                                    "Payments",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.06,
                                      color: Colors.black,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add),
        ),
        //       bottomNavigationBar: BottomAppBar(
        //   color: Colors.black87,
        //   child: Row(
        //     children: [
        //       IconButton(
        //         onPressed: () {},
        //         icon: Icon(Icons.home),
        //         color: Colors.black,
        //       ),
        //       IconButton(
        //         onPressed: () {},
        //         icon: Icon(Icons.search),
        //         color: Colors.black,
        //       ),
        //     ],
        //   ),
        // ),
      ),
    );
  }
}
