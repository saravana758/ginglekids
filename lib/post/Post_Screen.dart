import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:gingle_kids/post/Pdfview.dart';
import 'dart:convert';

import 'package:gingle_kids/post/Post_Select_Screen.dart';
import 'package:gingle_kids/post/Video_Screen.dart';
import 'package:gingle_kids/post/comments.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../teacher_dashboard.dart';

class PostScreen extends StatefulWidget {
  final String token;
  final String name;
  final String role;
  final String classroomName;
  final String commentsurl;
  PostScreen({required this.token, required this.name, required this.role, required this.classroomName,required this.commentsurl});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  //List<Map<String, dynamic>> posts = [];
  List<dynamic> teacherIds = [];

  List<dynamic> posts = [];
  bool hasData = false;

  bool isLiked = false;
  Map<int, bool> postLikeStatus = {};
  int batchSize = 4; // Number of posts to load at a time
  int currentIndex = 0; // Index of the current batch of posts
  bool isLoading = false;

  late SharedPreferences prefs;
  late Future<List<String>> postsFuture;

  @override
  void initState() {
    super.initState();
    print('Token: ${widget.token}');
    print('in post screen');
        print('role');

    print(widget.role);
    FlutterDownloader.initialize();

    fetchData(widget.token); // Pass the token argument here
    fetchLikes(widget.token);
    fetchCommentsCount(widget.token);
    // initPrefs(); // Initialize SharedPreferences
    loadPosts();
  }

  Future<void> fetchData(String token) async {
    try {
      // Fetch data from API endpoint
      var response = await http.get(
        Uri.parse('https://bob-magickids.trainingzone.in/api/General/postview'),
        headers: {
          'Authorization': 'Bearer $token', // Use the passed token here
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        // If the API call is successful, parse the response
        var data = json.decode(response.body);
        print(data);
        if (data['post'].isEmpty) {
          // No posts available
          setState(() {
            hasData = false; // Update flag to indicate no data available
          });
        } else {
          // Posts available
          setState(() {
            hasData = true; // Update flag to indicate data available
            // Parse and update posts list as before
          });
        }

        print(data);
        List<int> postIds = [];
        for (var post in data['post']) {
          postIds.add(post['id']);
        }
        List<String> hashIds = []; // List to store hash ids
        for (var post in data['post']) {
          hashIds.add(post['hashid']); // Extract hash id and add to the list
        }
        List<String> teacherIds = [];
        for (var post in data['post']) {
          //var teacherHashId = post['created_by']['teacher']['hashid'];
          teacherIds.add(post['created_by']['teacher']['hashid']);
        }

        setState(() {
          // teacherHashIds = teacherIds;
        });

        var likesData = await fetchLikes(token);
        var commentsCountData = await fetchCommentsCount(token);

        for (var post in data['post']) {
          // Find likes data for this post
          var likesForPost = likesData.firstWhere(
            (like) => like['post_id'] == post['id'],
            orElse: () => {'total_likes': 0}, // Return empty likes data
          );
          var commentsCountForPost = commentsCountData.firstWhere(
            (comment) => comment['post_id'] == post['id'],
            orElse: () =>
                {'total_comments': 0}, // Return empty comments count data
          );

          // If likes data found, add it to the post
          if (likesForPost != null) {
            post['likes'] = likesForPost['total_likes'];
          }
          if (commentsCountForPost != null) {
            post['comments'] = commentsCountForPost['total_comments'];
          }
        }

        setState(() {
          posts = data['post'];
          // Now you have the IDs in postIds list

          print('Post IDs: $postIds');
          print('Hash IDs: $hashIds');
          print('Teacer IDs: $teacherIds');
        });
        initPrefs();
      } else {
        // Handle error scenario
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception during data fetching: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchLikes(String token) async {
    print(token);
    print('shaky');
    try {
      // Fetch data from API endpoint
      var response = await http.get(
        Uri.parse('https://bob-magickids.trainingzone.in/api/Students/likes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // If the API call is successful, parse the response
        var data = json.decode(response.body);
        print(data);
        // Return likes data
        return List<Map<String, dynamic>>.from(data['likes']);
      } else {
        // Handle error scenario
        print('Failed to load likes data: ${response.statusCode}');
        return []; // Return empty list
      }
    } catch (e) {
      // Handle exceptions
      print('Exception during likes data fetching: $e');
      return []; // Return empty list
    }
  }

  Future<void> addLike(
      String token, int postId, Map<String, dynamic> post) async {
    try {
      var body = json.encode({'post_id': postId});

      var response = await http.post(
        Uri.parse(
            'https://bob-magickids.trainingzone.in/api/Students/createlike'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        // Update the like status for the current post
        setState(() {
          postLikeStatus[postId] = true;
          // Update the like count in the post data
          post['likes'] = post['likes'] + 1;
        });
        await prefs.setBool('like_$postId', true);

        print('Like added successfully');
      } else {
        print('Failed to add like: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception while adding like: $e');
    }
  }

  Future<void> deleteLike(String token, int postId, post) async {
    try {
      // Prepare request body
      var body = json.encode({'post_id': postId});

      // Send DELETE request to API endpoint
      var response = await http.delete(
        Uri.parse(
            'https://bob-magickids.trainingzone.in/api/Students/deletelike'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        setState(() {
          postLikeStatus[postId] = false; // Set like status to false
          post['likes'] = post['likes'] - 1;
        });
        await prefs.setBool('like_$postId', false);
        print('Like deleted successfully');
        print('Like deleted successfully');
        // Handle success response here
      } else {
        // Handle error scenario
        print('Failed to delete like: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception while deleting like: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchCommentsCount(String token) async {
    try {
      var response = await http.get(
        Uri.parse(
            'https://bob-magickids.trainingzone.in/api/Students/commentscount'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print('comments count');
        print(data);
        return List<Map<String, dynamic>>.from(data['comments']);
      } else {
        print('Failed to fetch comments count: ${response.statusCode}');
        return []; // Return empty list
      }
    } catch (e) {
      print('Exception during comments count fetching: $e');
      return []; // Return empty list
    }
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    // Load like status from SharedPreferences and initialize postLikeStatus
    for (var post in posts) {
      var postId = post['id'];
      var likeStatus = prefs.getBool('like_$postId') ?? false;
      setState(() {
        postLikeStatus[postId] = likeStatus;
        // print('bannnuuu');
        // print(postLikeStatus[postId]);
      });
    }
  }

  Future<void> loadPosts() async {
    setState(() {
      isLoading = true;
    });

    // Simulated loading delay
    await Future.delayed(const Duration(seconds: 2));

    // Add the next batch of posts to the list
    List<Map<String, dynamic>> newPosts = await fetchNextBatchOfPosts();

    setState(() {
      posts.addAll(newPosts);
      currentIndex++;
      isLoading = false;
    });
  }

  // Function to fetch the next batch of posts
  Future<List<Map<String, dynamic>>> fetchNextBatchOfPosts() async {
    // Implement your logic to fetch the next batch of posts here
    // Example:
    // Replace this with your actual logic to fetch posts from an API or database
    List<Map<String, dynamic>> newPosts = [
      // Add your new posts here
    ];
    return newPosts;
  }

//  Future<void> loadMorePosts() async {
//     // Simulated loading delay
//     await Future.delayed(Duration(seconds: 2));
//     // Increment currentIndex to load the next batch of posts
//     setState(() {
//       currentIndex++;
//     });
//   }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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
              title: const Text(
                'Posts',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF8779A6),
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                if (widget.role != 'student')
                  IconButton(
                    icon:
                        const Icon(Icons.add_box_outlined, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostSelect(
                            token: widget.token,
                            name: widget.name,
                            role: widget.role, classroomName: widget.classroomName, commentsurl: widget.commentsurl,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
            body: posts.isEmpty
                ? Center(
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : hasData // Check if data is available
                            ? const Text(
                                'Loading Posts...') // Data is available, so don't show any message
                            : const Text(
                                'No posts available'), // No data available, show the message
                  )
                : NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (!isLoading &&
                          scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent) {
                        // Load more posts when the user reaches the end of the list
                        loadPosts();
                        return true;
                      }
                      return false;
                    },
                    child: Container(
                      color: const Color.fromARGB(255, 221, 208, 230),
                      child: ListView.builder(
                          itemCount: posts.length +
                              1, // Add 1 to account for the loading indicator
                          itemBuilder: (context, index) {
                            if (index == posts.length) {
                              // Placeholder for loading indicator
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (index < posts.length) {
                              var post = posts[index];

                              // Build your post UI here

                              return Column(children: [
                                Card(
                                  margin: const EdgeInsets.all(8.0),
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          SizedBox(
                                            width: screenWidth,
                                            height: screenHeight * 0.07,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Row(
                                              children: [
                                                // GestureDetector(
                                                //   onTap: () {
                                                //     // Handle the download action here
                                                //     // You can use a download manager or any method to save the file locally
                                                //     // For simplicity, you can display a message for now
                                                //     ScaffoldMessenger.of(context).showSnackBar(
                                                //       SnackBar(
                                                //         content: Text(
                                                //             'Downloading: ${contents[i]['documentName']}'),
                                                //       ),
                                                //     );
                                                //   },
                                                // child: Row(
                                                //   children: [
                                                //     Icon(Icons.download, color: Colors.blue),
                                                //     SizedBox(width: 8.0),
                                                //     Text('Download'),
                                                //   ],
                                                const SizedBox(
                                                  width: 8.0,
                                                ),
                                                Container(
                                                  width: screenHeight * 0.06,
                                                  height: screenHeight * 0.06,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.black,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: ClipOval(
                                                    child: Image.network(
                                                      //post['media'],
                                                      'https://bob-magickids.trainingzone.in/teacher/${post['created_by']['teacher']['hashid']}/teacher-images',
                                                      fit: BoxFit.cover,
                                                      width:
                                                          screenHeight * 0.06,
                                                      height:
                                                          screenHeight * 0.06,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 15,
                                                ),
                                                // SizedBox(width: 8.0),
                                                // Icon(Icons.description, color: Colors.blue),
                                                // SizedBox(width: 8.0),
                                                // Text(contents[i]['documentName'] ?? 'Document'),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: Text(
                                                    post['username'] ??
                                                        'Teacher',
                                                    style: TextStyle(
                                                      fontSize:
                                                          screenWidth * 0.05,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: screenWidth,
                                            height: screenHeight * 0.07,
                                            child: const Padding(
                                              padding: EdgeInsets.all(2.0),
                                            ),
                                          )
                                        ],
                                      ),
                                      Container(
                                        width: screenWidth,
                                        height: screenHeight * 0.31,
                                        child: post['media'] != null
                                            ? post['type'] == 'image'
                                                ? Image.network(
                                                    'https://bob-magickids.trainingzone.in/post/${post['hashid']}/post-images',
                                                    fit: BoxFit.contain,
                                                  )
                                                : post['type'] == 'video'
                                                    ?
                                                    // Image.network(
                                                    //   'https://bob-magickids.trainingzone.in/post/${post['hashid']}/post-images',
                                                    //       fit: BoxFit.contain,
                                                    //     )
                                                    VideoScreen(
                                                        videoUrl:
                                                            'https://bob-magickids.trainingzone.in/post/${post['hashid']}/post-images')
                                                    : post['type'] == 'document'
                                                        ? GestureDetector(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      PDFViewerPage(
                                                                          pdfUrl:
                                                                            'https://bob-magickids.trainingzone.in/post/${post['hashid']}/post-images',
                                                                 ) ),
                                                              );
                                                            },
                                                            // ? GestureDetector(
                                                            //     onTap: () {
                                                            //       ScaffoldMessenger
                                                            //               .of(context)
                                                            //           .showSnackBar(
                                                            //         const SnackBar(
                                                            //           content: Text(
                                                            //               'Downloading PDF...'),
                                                            //         ),
                                                            //       );
                                                            //       _downloadFile(
                                                            //           post[
                                                            //               'media']);
                                                            //     },
                                                            child:
                                                                Image.asset(
                                                        //  'https://bob-magickids.trainingzone.in/post/${post['hashid']}/post-images',

                                                              'assets/images/pdf_bgrm.png',
                                                              width:
                                                                  50, // Set the width of the image
                                                              height:
                                                                  50, // Set the height of the image
                                                            ),
                                                          )
                                                        : Container()
                                            : (post['type'] == 'video' &&
                                                    post['details'] != null &&
                                                    post['details']['link'] !=
                                                        null)
                                                ? GestureDetector(
                                                    onTap: () {
                                                      // Handle the tap on the YouTube link here
                                                      // For example, you can open the link in a web browser
                                                      print(post['details']
                                                          ['link']);

                                                      launchUrl(Uri.parse(
                                                          post['details']
                                                              ['link']));
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[
                                                            200], // Example background color
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: const Center(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .play_circle_fill_outlined, // Use the YouTube icon from the Icons class
                                                              size:
                                                                  35, // Adjust the size of the icon as needed
                                                              color: Colors
                                                                  .red, // Optionally, you can change the color of the icon
                                                            ),
                                                            SizedBox(
                                                                height:
                                                                    10), // Add some space between the icon and the text
                                                            Text(
                                                              'Click here to watch the video',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      16.0),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : post['content'] != null
                                                    ? SingleChildScrollView(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            post['content'],
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        16.0),
                                                          ),
                                                        ),
                                                      )
                                                    : const Center(
                                                        child: Text(
                                                          'No media or content available',
                                                          style: TextStyle(
                                                              fontSize: 16.0),
                                                        ),
                                                      ),
                                      ),
                                      const SizedBox(
                                        width: 8.0,
                                      ),
                                      Container(
                                        // width: screenWidth ,
                                        // height: screenHeight * 0.1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Text(
                                            post['caption'] ?? '',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: screenHeight * 0.047,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(width: screenWidth * 0.05),
                                                  if (post['like_enabled'] == true)

                                            GestureDetector(
                                              onTap: () {
                                                // Check if the post is liked, then call deleteLike, otherwise call addLike
                                                if (postLikeStatus[
                                                        post['id']] ==
                                                    true) {
                                                  // Call deleteLike function to remove the like
                                                  deleteLike(widget.token,
                                                      post['id'], post);
                                                } else {
                                                  // Call addLike function to add the like
                                                  addLike(widget.token,
                                                      post['id'], post);
                                                }
                                              },
                                              child: Row(
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .thumb_up_alt_outlined,
                                                      color: postLikeStatus[
                                                                  post['id']] ==
                                                              true
                                                          ? Colors.blue
                                                          : Colors.black),
                                                  SizedBox(
                                                      width:
                                                          screenWidth * 0.02),
                                                  Text(post['likes']
                                                          .toString() ??
                                                      ''),
                                                  SizedBox(
                                                      width:
                                                          screenWidth * 0.02),
                                                  Text(
                                                    "Likes",
                                                    style: TextStyle(
                                                        fontSize: screenWidth *
                                                            0.041),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                                width: screenWidth *
                                                    0.3), // Adjust the spacing between likes and comments
                                                if (post['comment_enabled'] == true)

                                            InkWell(
                                              onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CommentsPostingPage(
        token: widget.token,
        postId: post['id'],
        role: widget.role,
        refreshCommentsCount: () {
          fetchCommentsCount(post['id']);
        },
        name: widget.name,
        commentsUrl: 'https://bob-magickids.trainingzone.in/teacher/${post['created_by']['teacher']['hashid']}/teacher-images',
    ),
    ),
  );
},

                                              child: Row(
                                                children: [
//       const Icon(Icons.messenger_outline_sharp, color: Colors.grey),
//  SizedBox(width: screenWidth * 0.02),
                                                  Text(post['comments']
                                                          .toString() ??
                                                      ''),
                                                  SizedBox(
                                                      width:
                                                          screenWidth * 0.02),
                                                  Text(
                                                    "Comments",
                                                    style: TextStyle(
                                                        fontSize: screenWidth *
                                                            0.041),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          screenWidth * 0.02),
                                                  const Icon(
                                                      Icons
                                                          .messenger_outline_sharp,
                                                      color: Colors.black),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                              ]);
                            } else {
                              print('loading next batch');
                              return const SizedBox(); // Placeholder for loading indicator
                            }
                          }),
                    ))));
  }
}

void downloadCallback(String id, int status, int progress) {
  // Handle download status and progress
  if (status == DownloadTaskStatus.running.index) {
    // Download is in progress
    print('Download task $id is in progress. Progress: $progress%');
    // You can update UI to show download progress here
  } else if (status == DownloadTaskStatus.complete.index) {
    // Download is completed
    print('Download task $id is completed.');
    // You can perform any additional actions here, such as displaying a notification or updating UI
  } else if (status == DownloadTaskStatus.failed.index) {
    // Download has failed
    print('Download task $id has failed.');
    // You can handle failed downloads here, such as retrying or displaying an error message
  }
}

// Your _downloadFile function
void _downloadFile(String relativePath) async {
  // Define the base URL
  String baseUrl = "https://bob-magickids.trainingzone.in/";
  // String relativePath = "post-document/post_document1713771268.pdf";

  // Construct the complete URL
  String completeUrl = baseUrl + relativePath;
  print('completeUrl');

  print(completeUrl);

  final directory = await getExternalStorageDirectory();
  if (directory == null) {
    print('Error: Unable to get external storage directory.');
    return;
  }

  final taskId = await FlutterDownloader.enqueue(
    url: completeUrl, // Use the complete URL here
    savedDir: directory.path,
    fileName: 'document.pdf',
    showNotification: true,
    openFileFromNotification: true,
  );

  // Register the download callback
  FlutterDownloader.registerCallback(downloadCallback);
}




// void _downloadFile(String url) async {
//   final directory = await getExternalStorageDirectory();
//   final taskId = await FlutterDownloader.enqueue(
//     url: url,
//     savedDir: directory!.path,
//     fileName: 'document.pdf',
//     showNotification: true,
//     openFileFromNotification: true,
//   );

//   FlutterDownloader.registerCallback((id, status, progress) {
//     // Handle download status and progress
//     if (status == DownloadTaskStatus.running) {
//       // Download is in progress
//       print('Download task $id is in progress. Progress: $progress%');
//     } else if (status == DownloadTaskStatus.complete) {
//       // Download is completed
//       print('Download task $id is completed.');
//       // You can perform any additional actions here, such as displaying a notification or updating UI
//     } else if (status == DownloadTaskStatus.failed) {
//       // Download has failed
//       print('Download task $id has failed.');
//       // You can handle failed downloads here, such as retrying or displaying an error message
//     }
//   });
// }

 
