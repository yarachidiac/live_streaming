import 'dart:convert';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project_live_streaming/config/appId.dart';
import 'package:project_live_streaming/providers/user_provider.dart';
import 'package:project_live_streaming/resources/firestore_methods.dart';
import 'package:project_live_streaming/screens/home_screen.dart';
import 'package:project_live_streaming/screens/profile_screen.dart';
import 'package:project_live_streaming/widgets/chat.dart';
import 'package:provider/provider.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:uuid/uuid.dart';




import '../models/post.dart';
import '../models/user.dart';

class BroadcastScreen extends StatefulWidget {
  final bool isBroadcaster;
  final String channelId;
  const BroadcastScreen({Key? key, required this.isBroadcaster, required this.channelId}) : super(key: key);


  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  late final RtcEngine _engine;
  List<int> remoteUid = [];
  bool switchCamera = true;
  bool isMuted = false;
  late User _broadcaster = User(uid: '', username: '', email: '', image: '', followers: [], following: []);
  bool _isRecording = false;
  late String _recordingFilePath;
  late String _recordingPath;
  final firebase_storage.FirebaseStorage _storage = firebase_storage.FirebaseStorage.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initEngine();

    getBroadcasterDetail();
  }
  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
    await Permission.storage.request();
  }



  Future<void> _toggleRecording() async {
    setState(() {
      _isRecording = !_isRecording;
      print(_isRecording);
      print("mmmmmmmmmmmmmmmmmmmmmmmmm");
    });

    if (_isRecording) {
      // Start recording
      await _requestPermissions();

      final appDocDir = await path_provider.getApplicationDocumentsDirectory();
      _recordingFilePath = '${appDocDir.path}/recording.aac';
      await _engine.startAudioRecording(
        _recordingFilePath,
        AudioSampleRateType.Type32000,
        AudioRecordingQuality.Low,
      );
      print("heyyyyyyyyyyyyyy balshhhhh");
    } else {
      // Stop recording
      await _engine.stopAudioRecording();

      // Upload the recorded file to Firebase Storage
      final file = File(_recordingFilePath);
      final reference =
      _storage.ref().child('recordings/${DateTime.now().millisecondsSinceEpoch}.aac');

      try {
        await reference.putFile(file);
        final downloadURL = await reference.getDownloadURL();

        // Save the download URL to Firestore or perform any necessary operations
      /*  String recordingId = const Uuid().v1();
        await FirebaseFirestore.instance
            .collection('recordings').doc(recordingId)
            .set({'url': downloadURL,
                'uid':_broadcaster.uid,
                'username': _broadcaster.username,
                'likes': [],
                'image': _broadcaster.image,
                'createdAt': DateTime.now(),
                });*/
        print("helooodddddddddddddd");

        /*String res = await FirestoreMethods().uploadPost(
          "",
          "" as Uint8List,
          _broadcaster.uid,
          _broadcaster.username,
          _broadcaster.image,
          true,
          downloadURL,

        );*/
        String postId = const Uuid().v1();

        Post post = Post(
            description: "",
            uid: _broadcaster.uid,
            username: _broadcaster.username,
            likes: [],
            postId: postId,
            datePublished: DateTime.now(),
            postUrl: "",
            image: _broadcaster.image,
            isVoice:true,
            VoiceUrl:downloadURL
        );
        await FirebaseFirestore.instance.collection('posts').doc(postId).set({
          'description': "",
          'uid': _broadcaster.uid,
          'username': _broadcaster.username,
          'likes': [],
          'postId': postId,
          'datePublished': DateTime.now(),
          'postUrl': "",
          'image': _broadcaster.image,
          'isVoice':true,
          'VoiceUrl':downloadURL});
        print("heyyyyyyyyyyyyyyyyyyy" + downloadURL);


      } catch (e) {
        // Handle the upload error
        print('Error uploading recording: $e');
      }
    }
  }




  void _initEngine() async {
    _engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
    _addListeners();

    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.enableAudio();

    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);

    if (widget.isBroadcaster) {
      await _engine.setClientRole(ClientRole.Broadcaster);
    } else {
      await _engine.setClientRole(ClientRole.Audience);
    }

    _joinChannel();
  }

  getBroadcasterDetail() async{
    FirestoreMethods _firestoreMethods = FirestoreMethods();
    _broadcaster = await _firestoreMethods.getBroadcasterDetail(widget.channelId);
    setState(() {});
  }

  String baseUrl = "https://agora-server-zc6n.onrender.com";

  String? token;

  Future<void> getToken() async {
    final res = await http.get(
      Uri.parse(baseUrl +
          '/rtc/' +
          widget.channelId +
          '/publisher/userAccount/' +
          Provider
              .of<UserProvider>(context, listen: false)
              .user
              .uid +
          '/'),
    );

    if (res.statusCode == 200) {
      setState(() {
        token = res.body;
        token = jsonDecode(token!)['rtcToken'];
      });
    } else {
      debugPrint('Failed to fetch the token');
    }
  }

  void _addListeners() {
    _engine.setEventHandler(RtcEngineEventHandler(
        joinChannelSuccess: (channel, uid, elapsed) {
          debugPrint('joinChannelSuccess $channel $uid $elapsed');
        },
        userJoined: (uid, elapsed) {
          debugPrint('userJoined $uid $elapsed');
          setState(() {
            remoteUid.add(uid);
          });
        },
        userOffline: (uid, reason) {
          debugPrint('userOffline $uid $reason');
          setState(() {
            remoteUid.removeWhere((element) => element == uid);
          });
        },
        leaveChannel: (stats) {
          debugPrint('leaveChannel $stats');
          setState(() {
            remoteUid.clear();
          });
        },
        tokenPrivilegeWillExpire: (token) async {
          await getToken();
          await _engine.renewToken(token);
        }
    ));
  }


  void _joinChannel() async {
    await getToken();
    if (defaultTargetPlatform == TargetPlatform.android) {
      await [Permission.microphone, Permission.camera].request();
      await _engine.joinChannelWithUserAccount(
          token,
          widget.channelId,
          Provider
              .of<UserProvider>(context, listen: false)
              .user
              .uid
      );
    }
  }

  _leaveChannel() async {
    await _engine.leaveChannel();
    if ('${Provider
        .of<UserProvider>(context, listen: false)
        .user
        .uid}${Provider
        .of<UserProvider>(context, listen: false)
        .user
        .username}' == widget.channelId) {
      await FirestoreMethods().endLiveStream(widget.channelId);
    } else {
      await FirestoreMethods().updateViewCount(widget.channelId, false);
    }
    Navigator.pushReplacementNamed(context, HomeScreen.routeName);
  }

  void _switchCamera() {
    _engine.switchCamera().then((value) {
      setState(() {
        switchCamera = !switchCamera;
      });
    }).catchError((err) {
      debugPrint('switchCamera $err');
    });
  }

  void onToggleMute() async {
    setState(() {
      isMuted = !isMuted;
    });
    await _engine.muteLocalAudioStream(isMuted);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;


    return WillPopScope(
      onWillPop: () async {
        await _leaveChannel();
        return Future.value(true);
      },
      child: Scaffold(

        body: Column(
          children: [
            Container(
              height: (MediaQuery.of(context).size.height * 0.7)-keyboardHeight,
              child: Stack(
                children: [
                  _renderVideo(user),
                  Positioned(
                    top: 16.0,
                    left: 16.0,
                    child: GestureDetector(
                      onTap: () {
                        if (!widget.isBroadcaster) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                              broadcaster: _broadcaster,
                              isBroadcaster: true,
                            ),
                          ));
                        }
                      },
                      child: CircleAvatar(
                        backgroundImage: _broadcaster.image != ''
                            ? NetworkImage(_broadcaster.image)
                            : NetworkImage(
                            'https://www.vhv.rs/dpng/d/312-3120300_default-profile-hd-png-download.png'),
                        radius: 24.0,
                        child: _broadcaster.image == ''
                            ? CircularProgressIndicator()
                            : null,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 24.0,
                    left: 80.0,
                    child: Text(
                      _broadcaster.username ?? '',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if ("${user.uid}${user.username}" == widget.channelId)
                    Positioned(
                      bottom: 16.0,
                      left: 0.0,
                      right: 0.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: _switchCamera,
                            child: Icon(
                              Icons.switch_camera_outlined,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 16.0),
                          InkWell(
                            onTap: onToggleMute,
                            child: Icon(
                              isMuted ? Icons.mic_off : Icons.mic,
                              color: isMuted ? Colors.red : Colors.white,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Positioned(
                    top: 16.0,
                    right: 16.0,
                        child:InkWell(
                          onTap: _toggleRecording,
                          child: Icon(_isRecording ? Icons.stop : Icons.mic),
                        ),

                  ),

                ],
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Chat(channelId: widget.channelId),
              ),
            ),
          ],
        ),

      ),

    );
  }

  _renderVideo(user) {
    return '${user.uid}${user.username}' == widget.channelId
        ? const RtcLocalView.SurfaceView(
        zOrderMediaOverlay: true,
      zOrderOnTop: true,
    )
        : remoteUid.isNotEmpty
        ? kIsWeb
        ? RtcRemoteView.SurfaceView(
      uid: remoteUid[0],
      channelId: widget.channelId,
    )
        : RtcRemoteView.TextureView(
      uid: remoteUid[0],
      channelId: widget.channelId,
    )
        : Container();
  }

  Widget _renderLocalPreview() {
    return Container(
      child: RtcLocalView.SurfaceView(),
    );
  }

  Widget _renderRemoteVideo() {
    if (remoteUid != null) {
      return Container(
        child: RtcRemoteView.SurfaceView(uid: remoteUid[0],
          channelId: widget.channelId,),
      );
    } else {
      return SizedBox.shrink();
    }
  }

}