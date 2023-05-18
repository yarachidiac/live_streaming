import 'package:delta_to_html/delta_to_html.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

//import 'package:image_picker/image_picker.dart';
//import 'package:instagram_clone_flutter/providers/user_provider.dart';
//import 'package:instagram_clone_flutter/resources/firestore_methods.dart';
//import 'package:instagram_clone_flutter/utils/colors.dart';
//import 'package:instagram_clone_flutter/utils/utils.dart';
import 'package:project_live_streaming/utils/colors.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import 'package:image_picker/image_picker.dart';

import '../resources/firestore_methods.dart';
import '../utils/utils.dart';
import 'package:text_editor/text_editor.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);
  static String routeName = '/addPost';

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  bool isLoading = false;
  //final TextEditingController _descriptionController = TextEditingController();
  quill.QuillController _descriptionController = quill.QuillController.basic();


// for picking up image from gallery
  pickImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();
    XFile? _file = await _imagePicker.pickImage(source: source);
    if (_file != null) {
      return await _file.readAsBytes();
    }
    print('No Image Selected');
  }

//
  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Create a Post'),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.pop(context);
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
//
  void postImage(String uid, String username, String profImage) async {
    setState(() {
      isLoading = true;
    });
    // start the loading
    try {
      // Retrieve the Quill Delta from the controller
      List<dynamic> deltaJson = _descriptionController.document.toDelta().toJson();

// Convert the Delta to HTML
      var html = DeltaToHTML.encodeJson(deltaJson);
      print("laaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
      print(html);

      // upload to storage and db
      String res = await FirestoreMethods().uploadPost(
        html,
        _file!,
        uid,
        username,
        profImage,
        false,
        ""
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        showSnackBar(
          context,
          'Posted!',
        );
        clearImage();
      } else {
        showSnackBar(context, res);
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);


    return _file == null ?
    Scaffold(

        appBar: AppBar(
          backgroundColor: buttonColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'Post to',
          ),
          centerTitle: false,
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  postImage(
                    userProvider.user.uid,
                    userProvider.user.username,
                    userProvider.user.image,
                  ),
              child: const Text(
                "Post",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
              ),
            )
          ],
        ),

        body: Center(
          child: IconButton(icon: const Icon(Icons.upload),
            onPressed: () => _selectImage(context)
            ,),
        )) :
    Scaffold(
      appBar: AppBar(
        backgroundColor: buttonColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Post to',
        ),
        centerTitle: false,
        actions: <Widget>[
          TextButton(
            onPressed: () =>
                postImage(
                  userProvider.user.uid,
                  userProvider.user.username,
                  userProvider.user.image,
                ),
            child: const Text(
              "Post",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (isLoading) const LinearProgressIndicator(),
              const SizedBox(height: 16.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white, // Change the background color here
                    backgroundImage: userProvider.user.image != ""
                        ? NetworkImage(userProvider.user.image)
                        : NetworkImage(
                        'https://www.vhv.rs/dpng/d/312-3120300_default-profile-hd-png-download.png'),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: quill.QuillEditor(
                      controller: _descriptionController,
                      scrollController: ScrollController(),
                      scrollable: true,
                      focusNode: FocusNode(),
                      autoFocus: true,
                      readOnly: false,
                      placeholder: 'Enter text...',
                      expands: false,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Container(
                height: 60,
                child: quill.QuillToolbar.basic(
                  controller: _descriptionController!,
                  showItalicButton: true,
                  showBoldButton: true,
                ),
              ),
              const SizedBox(height: 16.0),
              AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: MemoryImage(_file!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }
}