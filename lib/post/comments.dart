import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gingle_kids/post/Post_Screen.dart';
import 'package:http/http.dart' as http;

class CommentsPostingPage extends StatefulWidget {
  final String token;
  final int postId;
  final String role;
  final String name;
  final VoidCallback refreshCommentsCount;
  final String commentsUrl; // New parameter for comments URL

  CommentsPostingPage({
    required this.token,
    required this.postId,
    required this.name,
    required this.refreshCommentsCount,
    required this.role,
    required this.commentsUrl,
  });

  @override
  _CommentsPostingPageState createState() => _CommentsPostingPageState();
}

class _CommentsPostingPageState extends State<CommentsPostingPage> {
  TextEditingController _commentController = TextEditingController();
  List<String> comments = []; // List to store comments

  Future<void> addComment(String token, int postId, String commentText) async {
    try {
      var body = json.encode({
        'post_id': postId.toString(),
        'details': commentText,
      });
      var response = await http.post(
        Uri.parse('https://bob-magickids.trainingzone.in/api/Students/createcomments'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        print('Comment added successfully');
        setState(() {
          comments.insert(0, commentText);
        });
        // Call the method to refresh comments count
        widget.refreshCommentsCount();
      } else {
        print('Failed to add comment: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception while adding comment: $e');
    }
  }

  Future<void> fetchCommentsForPost(String token) async {
    try {
      var response = await http.get(
        Uri.parse('https://bob-magickids.trainingzone.in/api/Students/comments'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body)['comments'];
        List<Map<String, dynamic>> postComments = [];

        for (var comment in data) {
          if (comment['post_id'] == widget.postId) {
            String commentDetails = comment['details'].replaceAll('"', '');

            Map<String, dynamic> commentMap = {
              'post_id': comment['post_id'],
              'details': commentDetails,
            };

            postComments.add(commentMap);
          }
        }

        setState(() {
          comments = postComments.map((comment) => comment['details']).toList().cast<String>();
        });
      } else {
        print('Failed to fetch comments: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception while fetching comments: $e');
    }
  }

  Future<void> fetchDataForComments(String token) async {
    try {
      var response = await http.get(
        Uri.parse('https://bob-magickids.trainingzone.in/api/General/postview'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<int> postIds = [];
        for (var post in data['post']) {
          postIds.add(post['id']);
        }
        List<String> hashIds = [];
        for (var post in data['post']) {
          hashIds.add(post['hashid']);
        }
        List<String> teacherIds = [];
        for (var post in data['post']) {
          teacherIds.add(post['created_by']['teacher']['hashid']);
        }

        setState(() {
          // Update the state as needed
        });

        print('Post IDs: $postIds');
        print('Hash IDs: $hashIds');
        print('Teacher IDs: $teacherIds');
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception during data fetching: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCommentsForPost(widget.token);
    fetchDataForComments(widget.token); // Fetch additional data for comments page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 223, 213, 238),
              Color.fromARGB(255, 220, 210, 231),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: kToolbarHeight),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_double_arrow_down_outlined),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostScreen(
                            token: widget.token,
                            name: widget.name,
                            role: widget.role,
                            classroomName: '', commentsurl: widget.commentsUrl,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Comments',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: comments.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Container(
                            //   width: MediaQuery.of(context).size.height * 0.06,
                            //   height: MediaQuery.of(context).size.height * 0.06,
                            //   decoration: BoxDecoration(
                            //     color: Colors.black,
                            //     shape: BoxShape.circle,
                            //   ),
                            //   child: ClipOval(
                            //     child: Image.network(
                            //       widget.commentsUrl, // Use commentsUrl here
                            //       fit: BoxFit.cover,
                            //       width: MediaQuery.of(context).size.height * 0.06,
                            //       height: MediaQuery.of(context).size.height * 0.06,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      );
                    } else {
                      final commentIndex = index - 1;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListTile(
                            leading: ClipOval(
                              child: Image.network(
                                widget.commentsUrl, // Use commentsUrl here
                                fit: BoxFit.cover,
                                width: 50,
                                height: 50,
                              ),
                            ),
                            title: Text(comments[commentIndex]),
                          ),
                          const Divider(),
                        ],
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  ClipOval(
                    child: Image.network(
                      widget.commentsUrl, // Use commentsUrl here
                      width: 50,
                      height: 50,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment',
                        hintStyle: TextStyle(fontWeight: FontWeight.w300),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      String comment = _commentController.text;
                      await addComment(widget.token, widget.postId, comment.toString());
                      _commentController.clear();
                    },
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
