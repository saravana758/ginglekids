import 'dart:convert';
import 'dart:io';
// import 'package:file_picker/file_picker.dart';
import 'package:gingle_kids/post/DotLineWidget.dart';
import 'package:gingle_kids/post/PostBtnWidget.dart';
import 'package:gingle_kids/post/Video_Screen.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:gingle_kids/post/Post_Select_Screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'CaptionWidget.dart';
import 'LikeBtnWidget.dart';
import 'ProfileName.dart'; // Assuming DotLine.dart contains DottedOutlinePainter

class PostCreate extends StatefulWidget {
  
  final String token;
  final String name;
    final String role;
    final String classroomName;
    final String commentsurl;
    final String profileUrl;


  final XFile? selectedImage; // Add this line

  PostCreate(
      {required this.token,
      this.selectedImage,
      required this.name,
      required this.classroomName,
       required this.role,required this.commentsurl,required this.profileUrl}); // Modify the constructor
  @override
  _PostCreateState createState() => _PostCreateState();
  
}

class _PostCreateState extends State<PostCreate> {
  

  XFile? _selectedvideo;
  // late File? _selectedvideo;
  late VideoPlayerController _videoController;
  late Future<void> _initializeVideoPlayerFuture;
   bool hasData = false;

  String? media;
  String? type;
  String? youtubeLink;

  String selectedText = '';
  String caption = '';
  String content = '';
  XFile? _selectedImage;
  File? galleryFile;
  final picker = ImagePicker();
  String? _selectedDocumentPath;

  TextEditingController youtubeLinkController = TextEditingController();

  TextEditingController textEditingController = TextEditingController();
  String? videoOption; // Corrected the declaration
  String selectedOption = '';

    bool likeSwitchStatus = false;
  bool commentSwitchStatus = false;
  

  @override
  void initState() {
    super.initState();
    print('shakila in post create');
    print(widget.token);
    fetchData(widget.token);
  }

  void updateCaption(String text) {
    setState(() {
      caption = text;
    });
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
  Future<void> createPost() async {
    var url =
        Uri.parse('https://bob-magickids.trainingzone.in/api/teacher/post');
    var headers = {
      'Authorization': 'Bearer ${widget.token}',
      'Accept': 'application/json',
    };

    var request = http.MultipartRequest('POST', url);
    request.headers.addAll(headers);
    if (_selectedImage != null) {
      type = 'image';
      //media = _selectedDocumentPath;
    } else if (_selectedvideo != null) {
      // media = _selectedvideo!

      type = 'video';
    } else if (_selectedDocumentPath != null) {
      // media = _selectedDocumentPath;
      type = 'document';
    } else if (textEditingController.text.isNotEmpty) {
      type = 'content';
    } else if (youtubeLinkController.text.isNotEmpty) {
      // Handle the selected document (file path or other relevant data)
      //  media = youtubeLinkController.text;
      type = 'video';
    }

    // Add other fields
    request.fields['type'] = type!;
    request.fields['title'] = 'New post';
    request.fields['caption'] = caption;
    request.fields['content'] = textEditingController.text;
      request.fields['likes'] = likeSwitchStatus.toString();
  request.fields['comments'] = commentSwitchStatus.toString();

    // request.fields['media'] = media!;
    if (type == 'video' && youtubeLinkController.text.isNotEmpty)
      request.fields['link'] = youtubeLinkController.text;

    // Add more fields as needed

    // Add image file
    if (_selectedImage != null) {
      var file = await http.MultipartFile.fromPath(
        'media',
        _selectedImage!.path,

        // contentType: MediaType('image', 'jpeg'), // Adjust the content type as needed
      );
      request.files.add(file);
    }
    if (_selectedDocumentPath != null) {
      var documentFile = File(_selectedDocumentPath!);
      if (documentFile.existsSync()) {
        // print(documentFile);
        // print('shakila banu');
        var documentMultipartFile = await http.MultipartFile.fromPath(
          'media',
          documentFile.path,
        );
        // print(documentFile.path);
        // print(documentMultipartFile);
        request.files.add(documentMultipartFile);
      } else {
        print('Selected document file does not exist.');
        // Handle the error or inform the user accordingly
      }
    }

// Add video file
    if (_selectedvideo != null) {
      var videoFile = await http.MultipartFile.fromPath(
        'media', // Change 'video' to the appropriate field name for videos
        _selectedvideo!.path,
        // contentType: MediaType('video', 'mp4'), // Adjust the content type as needed
      );
      request.files.add(videoFile);
      print(videoFile);
    }
    showDialog(
      context: context,
      barrierDismissible: false, // prevent user from dismissing dialog
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Creating post...'),
              ],
            ),
          ),
        );
      },
    );
          print('request.fields');

      print(request.fields);
    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        Navigator.pop(context);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Post created successfully'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
 Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostCreate(
                  token: widget.token,
                  name: widget.name, role: widget.role, classroomName: widget.classroomName, commentsurl: widget.commentsurl, profileUrl: '',
                ),
              ),
            );                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
       
        setState(() {
          _selectedImage = null;
          _selectedvideo = null;
          _selectedDocumentPath = null;
          youtubeLinkController.clear();
          caption = '';
          content = '';
          textEditingController.text ='';
          // Reset any variables or states here if needed
        });
      } else {
        // Error handling
        print('Failed to create post');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
        onWillPop: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostSelect(
                token: widget.token,
                name: widget.name, role: widget.role, classroomName: widget.classroomName, commentsurl: widget.commentsurl,
              ),
            ),
          );
          return false;
        },
        child: Scaffold(
            backgroundColor: Colors.white, // Setting background color to white

            body: SingleChildScrollView(
                child: Stack(children: [
              Container(
                height: screenHeight * 1.5,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch, // Add this line

                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(screenWidth * 0.04,
                          screenHeight * 0.2, screenWidth * 0.04, 0),
                      child: Container(
                        height: screenHeight * 0.4,
                        width: screenWidth * 0.9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [],
                        ),
                        child:CustomPaint(
  painter: DottedOutlinePainter(
    showOutline: selectedText != 'Video',
    isVideoSelected: selectedText == 'Video',
  ),
  child: selectedText == 'Video'
      ? Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            RadioListTile<String>(
              title: const Text('Video'),
              value: 'Video',
              groupValue: selectedOption,
              onChanged: (value) {
                setState(() {
                  selectedOption = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('YouTube'),
              value: 'YouTube',
              groupValue: selectedOption,
              onChanged: (value) {
                setState(() {
                  selectedOption = value!;
                });
              },
            ),
            // Display the image based on the selected option
            if (selectedOption == 'Video')
             Container(
  width: screenWidth * 0.85,
  height: screenHeight * 0.2,
  color: Colors.amber,
  child: Stack(
    fit: StackFit.expand,
    children: [
      if (_selectedvideo != null)
        _buildSelectedVideo(_selectedvideo)
      else
        Image.asset(
          'assets/images/videodot.png',
          fit: BoxFit.fill,
        ),
              if (_selectedvideo == null)

      Positioned.fill(
        child: GestureDetector(
          onTap: () async {
            _showVideoPicker(context);
            setState(() {}); // Trigger UI rebuild after recording
          },
          child: const Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.video_library,
                  size: 50,
                  color: Color.fromRGBO(9, 9, 9, 1),
                ),
                SizedBox(height: 10),

                Text(
                  'Click here to upload video',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  ),
)

            else if (selectedOption == 'YouTube')
              Container(
                width: screenWidth * 0.85,
                height: screenHeight * 0.1,
                color: Colors.amber,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/youtubedot.png',
                      fit: BoxFit.fill,
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: TextField(
                            controller: youtubeLinkController,
                            decoration: const InputDecoration(
                              hintText: 'Paste URL',
                              hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 16.0,
                              
                                fontWeight: FontWeight.w300,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                          
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        )
      : selectedText != 'Content'
          ? PlaceholderWidget(
              selectedText: selectedText,
              onImageSelected: (XFile? selectedImage) {
                setState(() {
                  _selectedImage = selectedImage;
                });
                print('Selected image path: $_selectedImage');
                // Handle the selected image here
              },
              onDocumentSelected: (String? selectedDocument) {
                setState(() {
                  _selectedDocumentPath = selectedDocument;
                });
                print('Selected doc path: $_selectedDocumentPath');
              },
            )
          : ContentInput(
              textEditingController: textEditingController,
            ),
)

                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: screenHeight * 0.9,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SelectionBar(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    selectedText: selectedText,
                    onSelect: (String text) {
                      setState(() {
                        selectedText = text;
                        _selectedImage = null;
                        _selectedvideo = null;
                        _selectedDocumentPath = null;
                        youtubeLinkController.text = '';
                        textEditingController.text = '';
                        caption = '';
                        content = '';
                      });
                    },
                    onToggleOutline: (bool) {},
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.81,
                left: screenWidth * 0.30,
                child: CustomButton(
                  text: 'Post', // Add the text parameter here

                  onPressed: () {
                    
      print(widget.token);
      print('in post button');
      
     
      createPost(); // Call createPost method when the button is pressed
    },
                ),
              ),
              Positioned(
                  top: screenHeight * 0.62,
                  left: screenWidth * 0.05,
                  child: CaptionWidget(
                    onCaptionChanged: updateCaption,
                  )),
            Positioned(
  top: screenHeight * 0.70,
  left: screenWidth * 0.1,
  child:  LikeButtonWidget(
        // Define the callback function to handle the status change
        onStatusChanged: (bool likeStatus, bool commentStatus) {
          setState(() {
            // Update the status variables
            likeSwitchStatus = likeStatus;
            commentSwitchStatus = commentStatus;
          });
          // Print the status in the console\
          print('in p[ost create page]');
          print('Like Switch clicked: $likeStatus');
          print('Comment Switch clicked: $commentStatus');
        },
      ),

),

              Positioned(
                  top: screenHeight * 0.1,
                  left: screenWidth * 0.04,
                  child: GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileNameWidget(token: widget.token,name: widget.name,)),
      );
    },
    child: ProfileNameWidget(token: widget.token,name: widget.name),
  ),
),
              Positioned(
                top: screenHeight * 0.05,
                left: screenWidth * 0.04,
                child: GestureDetector(
                  onTap: () {
                    print('shakila');
                    print(widget.token);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PostSelect(
                              token: widget.token, name: widget.name, role: widget.role, classroomName: widget.classroomName, commentsurl: widget.commentsurl, )),
                    );
                  },
                  child: Icon(
                    Icons.arrow_back,
                    size: screenWidth * 0.1,
                    color: const Color.fromARGB(255, 104, 87, 87),
                  ),
                ),
              ),
            ]))));
  }

  Future<void> _showVideoPicker(BuildContext context) async {
    final picker = ImagePicker();
    final imageSource = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Video Source'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Gallery'),
          ),
          // Remove the option to pick from the camera
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Camera'),
          ),
        ],
      ),
    );

    if (imageSource != null) {
      print(imageSource);
      final pickedVideo = await picker.pickVideo(
        source: imageSource,
        // maxHeight: 400,
        // maxWidth: 400,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (pickedVideo != null) {
        print('Picked video path: ${pickedVideo.path}');
        setState(() {
          _selectedvideo = XFile(pickedVideo.path);
          print(_selectedvideo);
          print('Selected video path: ${_selectedvideo!.path}');
        });
      }
    }
  }

  Widget _buildSelectedVideo(XFile? video) {
    double iconSize = MediaQuery.of(context).size.width * 0.2;

    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              if (video != null)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: AspectRatio(
                    aspectRatio:
                        16 / 9, // You can adjust the aspect ratio as needed
                    child: VideoScreen(
                      videoUrl: video.path,
                    ),
                    // child: Container(color: Colors.black), // Black color box container
                  ),
                )
              else
                const Placeholder(), // Placeholder UI until a video is selected
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedvideo = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  color: Colors.black.withOpacity(0.3),
                  child: const Icon(
                    Icons.close,
                    color: Colors.grey,
                    size: 24,
                  ),
                ),
              ),
                         ],
          ),
        ],
      ),
    );
  }
}
