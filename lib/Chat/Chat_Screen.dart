import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _textController = TextEditingController();
  List<Map<String, String>> _messages = []; // List of maps to store both message and timestamp
  bool showTodayIndicator = false;
  DateTime _lastMessageDateTime = DateTime.now(); // Track the date of last message

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat Screen',
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
      ),
      body: Column(
        children: [
          if (showTodayIndicator)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TodayIndicator(),
            ), // Display "Today" indicator if flag is true
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length + (showTodayIndicator ? 1 : 0), // Add 1 for TodayIndicator
              itemBuilder: (context, index) {
                if (showTodayIndicator && index == 0) {
                  return SizedBox(); // Return empty container for TodayIndicator, as it's already displayed separately
                }
                return Message(
                  text: _messages[showTodayIndicator ? index - 1 : index]['text']!,
                  time: _messages[showTodayIndicator ? index - 1 : index]['time']!,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      contentPadding: EdgeInsets.all(16), // Padding inside the TextField
                      border: OutlineInputBorder(
                        // Border style
                        borderRadius: BorderRadius.circular(20),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200], // Background color
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    String message = _textController.text.trim();
                    if (message.isNotEmpty) {
                      setState(() {
                        DateTime now = DateTime.now();
                        String formattedTime = DateFormat.Hm().format(now);

                        // Check if the message is sent on a different day
                        if (!_isSameDay(now, _lastMessageDateTime)) {
                          showTodayIndicator = true;
                        }

                        _messages.add({'text': message, 'time': formattedTime});
                        _textController.clear();
                        _lastMessageDateTime = now; // Update last message date
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

class Message extends StatelessWidget {
  final String text;
  final String time;

  const Message({
    Key? key,
    required this.text,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .scaffoldBackgroundColor, 
          border: Border.all(color: Colors.white, width: 1), 
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
            topLeft: Radius.circular(0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class TodayIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey[300], // Background color for "Today" indicator
      child: Text(
        'Today',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
