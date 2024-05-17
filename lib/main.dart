// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:gingle_kids/teacher_dashboard.dart';
// import 'login/login_screen.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
// void main() {
//   runApp(MyApp());
  
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: SplashScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({Key? key}) : super(key: key);

//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     checkLoginStatus();
//     _initAnimation();

//     _animationController.forward();

//     Timer(Duration(seconds: 5), () {
//       Navigator.pushReplacement(
//         context,
//         customPageRoute(LoginScreen()),
//       );
//     });
//   }

//   void _initAnimation() {
//     _animationController = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 7),
//     );

//     _animation =
//         Tween<double>(begin: 1.0, end: 0.0).animate(_animationController);
//   }

//   Future<void> checkLoginStatus() async {
//     final storage = FlutterSecureStorage();
//     final token = await storage.read(key: 'token');
//     final name = await storage.read(key: 'name');
//         final role = await storage.read(key: 'role');

//     Timer(const Duration(seconds: 5), () {
//       if (token != null) {
//         print('Navigate to HomePage');
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(
//             builder: (_) => TeacherDashboard(
//               token: token,
//              name: name ?? '', role: role ?? '',
//             ),
//           ),
//         );
//       } else {
//         print('Navigate to LoginScreen');
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(
//             builder: (_) => LoginScreen(),
//           ),
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: AnimatedBuilder(
//         animation: _animationController,
//         builder: (context, child) {
//           return Stack(
//             alignment: Alignment.center,
//             children: [
//               Container(
//                 width: 430,
//                 height: 932,
//                 color: Colors.white,
//               ),
//               ClipOval(
//                 clipper: CircularClipper(_animation.value),
//                 child: Container(
//                   width: 430,
//                   height: 932,
//                   decoration: BoxDecoration(
//                     gradient: RadialGradient(
//                       radius: _animation.value,
//                       stops: [0, 1],
//                       colors: [
//                         Color(0xFF8779A6).withOpacity(1.0 - _animation.value),
//                         Colors.white,
//                       ],
//                     ),
//                   ),
//                   child: Center(
//                     child: Opacity(
//                       opacity: 1.0 - _animation.value,
//                       child: Image.asset(
//                         'assets/images/log.png',
//                         width: 200,
//                         height: 200,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
// }

// class CircularClipper extends CustomClipper<Rect> {
//   final double animationValue;

//   CircularClipper(this.animationValue);

//   @override
//   Rect getClip(Size size) {
//     double radius = size.width * (1 - animationValue);
//     return Rect.fromCircle(center: size.center(Offset.zero), radius: radius);
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
//     return true;
//   }
// }

// PageRouteBuilder customPageRoute(Widget page) {
//   return PageRouteBuilder(
//     pageBuilder: (context, animation, secondaryAnimation) => page,
//     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//       const begin = 0.0;
//       const end = 1.0;
//       const curve = Curves.easeInOut;

//       var curveTween = CurveTween(curve: curve);
//       var tween = Tween(begin: begin, end: end).chain(curveTween);

//       var fadeAnimation = animation.drive(tween);

//       return FadeTransition(
//         opacity: fadeAnimation,
//         child: child,
//       );
//     },
//   );
// }










// void main() {
//   tz.initializeTimeZones();
//   runApp(MyApp());
// }

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   int _notificationId = 0;
//   String _nextNotificationTime = '';
//   String _currentTime = '';

//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _initializeNotifications();
//     _scheduleDailyNotification();
//     _startCurrentTimeUpdater();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   Future<void> _initializeNotifications() async {
//     var initializationSettingsAndroid =
//         AndroidInitializationSettings('app_icon');

//     var initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//     );

//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }

//   Future<void> _scheduleDailyNotification() async {
//     tz.setLocalLocation(tz.getLocation('Asia/Kolkata')); // Indian time zone

//     final now = tz.TZDateTime.now(tz.local);
//     var scheduledDate = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       10, // Hour
//       13, // Minute
//     );

//     if (scheduledDate.isBefore(now)) {
//       scheduledDate = scheduledDate.add(Duration(days: 1));
//     }

//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       _notificationId++,
//       'Notification Title',
//       'This is a notification message',
//       scheduledDate,
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'channel_id',
//           'Channel Name',
//           channelDescription: 'Channel Description',
//           importance: Importance.high,
//           priority: Priority.high,
//         ),
//       ),
//       androidAllowWhileIdle: true,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );

//     setState(() {
//       _nextNotificationTime =
//           '${scheduledDate.hour.toString().padLeft(2, '0')}:${scheduledDate.minute.toString().padLeft(2, '0')}:${scheduledDate.second.toString().padLeft(2, '0')} AM (IST)';
//     });
//   }

//   void _startCurrentTimeUpdater() {
//     _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
//       final now = tz.TZDateTime.now(tz.local);
//       setState(() {
//         _currentTime =
//             '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
//       });

//       // Check if the current time is 10:25:00 AM
//       if (now.hour == 14 && now.minute == 27 && now.second == 0) {
//         _showImmediateNotification();
//       }
//     });
//   }

//   Future<void> _showImmediateNotification() async {
//     const androidNotificationDetails = AndroidNotificationDetails(
//       'channel_id',
//       'Channel Name',
//       channelDescription: 'Channel Description',
//       importance: Importance.high,
//       priority: Priority.high,
//     );

//     await flutterLocalNotificationsPlugin.show(
//       _notificationId++,
//       'Immediate Notification',
//       'This is an immediate notification triggered at 10:25 AM',
//       const NotificationDetails(
//         android: androidNotificationDetails,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
        
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               Text('Current time: $_currentTime AM (IST)'),
//               SizedBox(height: 20),
//               Text('Next notification scheduled at $_nextNotificationTime'),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:async';

void main() {
  tz.initializeTimeZones();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  int _notificationId = 0;
  String _nextNotificationTime = '';
  String _currentTime = '';

  Timer? _timer;

  @override
  void initState() {
    super.initState();
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
        AndroidInitializationSettings('ic_launcher');

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
          ticker: 'ticker',
          icon: 'ic_launcher',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    setState(() {
      _nextNotificationTime =
          '${scheduledDate.hour.toString().padLeft(2, '0')}:${scheduledDate.minute.toString().padLeft(2, '0')}:${scheduledDate.second.toString().padLeft(2, '0')} AM (IST)';
    });
  }

  void _startCurrentTimeUpdater() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      final now = tz.TZDateTime.now(tz.local);
      setState(() {
        _currentTime =
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
      });

      // Check if the current time is 10:25:00 AM
      if (now.hour == 10 && now.minute == 25 && now.second == 0) {
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
      ticker: 'ticker',
      icon: 'ic_launcher',
    );

    await flutterLocalNotificationsPlugin.show(
      _notificationId++,
      'Immediate Notification',
      'This is an immediate notification triggered at 10:25 AM',
      const NotificationDetails(
        android: androidNotificationDetails,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Current time: $_currentTime AM (IST)'),
              SizedBox(height: 20),
              Text('Next notification scheduled at $_nextNotificationTime'),
            ],
          ),
        ),
      ),
    );
  }
}

