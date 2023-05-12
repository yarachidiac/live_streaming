import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project_live_streaming/config/appId.dart';
import 'package:project_live_streaming/providers/user_provider.dart';
import 'package:project_live_streaming/resources/firestore_methods.dart';
import 'package:project_live_streaming/screens/home_screen.dart';
import 'package:project_live_streaming/widgets/chat.dart';
import 'package:provider/provider.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initEngine();
  }

  void _initEngine() async{
    _engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
    _addListeners();

    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);

    if(widget.isBroadcaster){
      await _engine.setClientRole(ClientRole.Broadcaster);
    }else{
      await _engine.setClientRole(ClientRole.Audience);
    }

    _joinChannel();
  }

  void _addListeners(){
    _engine.setEventHandler(RtcEngineEventHandler(
      joinChannelSuccess: (channel, uid, elapsed) {
        debugPrint('joinChannelSuccess $channel $uid $elapsed');
      },
      userJoined: (uid, elapsed){
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

    ));
  }

  void _joinChannel() async{
    if(defaultTargetPlatform == TargetPlatform.android){
      await [Permission.microphone, Permission.camera].request();
      await _engine.joinChannelWithUserAccount(
          tempToken,
          widget.channelId,
          Provider.of<UserProvider>(context, listen: false).user.uid
      );
    }
  }

  _leaveChannel() async{
    await _engine.leaveChannel();
    if('${Provider.of<UserProvider>(context, listen: false).user.uid}${Provider.of<UserProvider>(context, listen: false).user.username}' == widget.channelId){
      await FirestoreMethods().endLiveStream(widget.channelId);
    }else{
      await FirestoreMethods().updateViewCount(widget.channelId, false);
    }
    Navigator.pushReplacementNamed(context, HomeScreen.routeName);
  }

  void _switchCamera(){
    _engine.switchCamera().then((value) {
      setState(() {
        switchCamera  = !switchCamera;
      });
    }).catchError((err){
      debugPrint('switchCamera $err');
    });
  }

  void onToggleMute() async{
    setState(() {
      isMuted = !isMuted;
    });
    await _engine.muteLocalAudioStream(isMuted);

  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return WillPopScope(
      onWillPop: () async {
        await _leaveChannel();
        return Future.value(true);
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _renderVideo(user),
              if("${user.uid}${user.username}" == widget.channelId)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: _switchCamera,
                        child: Icon(Icons.switch_camera_outlined, size: 32,),
                      ),
                      SizedBox(width: 16.0),
                      InkWell(
                        onTap: onToggleMute,
                        child: Icon(
                          isMuted ? Icons.mic_off : Icons.mic,
                          color: isMuted ? Colors.red : null,
                          size: 32,
                        ),
                      )
                    ],
                  ),
                ),
              Flexible(child: Chat(channelId: widget.channelId,))
            ],
          ),
        ),
      ),
    );
  }

  _renderVideo(user){
    return AspectRatio(aspectRatio: 16/8,
      child: '${user.uid}${user.username}' == widget.channelId ? const RtcLocalView.SurfaceView(
        zOrderMediaOverlay: true,
        zOrderOnTop: true,)
          : remoteUid.isNotEmpty ?
      kIsWeb ?
      RtcRemoteView.SurfaceView(uid: remoteUid[0], channelId: widget.channelId,)
          : RtcRemoteView.TextureView(uid: remoteUid[0], channelId: widget.channelId,)

          :Container()
      ,);
  }
}