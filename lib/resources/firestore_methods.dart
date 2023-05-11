import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_live_streaming/providers/user_provider.dart';
import 'package:project_live_streaming/resources/storage_methods.dart';
import 'package:provider/provider.dart';

import '../models/livestream.dart';
import '../utils/utils.dart';



class FirestoreMethods{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageMehtods _storageMethods = StorageMehtods();


  Future<String> startLiveStream(BuildContext context, String title, Uint8List? image) async{
    final user = Provider.of<UserProvider>(context, listen: false);
    String channelId = '';
    try{
      if(title.isNotEmpty && image != null){
        if(!((await _firestore.collection('livestream').doc('${user.user.uid}${user.user.username}').get()).exists)){

          String thumbnailUrl = await _storageMethods.uploadImageStorage('livestream-thumbnails', image, user.user.uid);

          //channelId = uidusername
          channelId = '${user.user.uid}${user.user.username}';

          LiveStream liveStream = LiveStream(title: title, image: thumbnailUrl, uid: user.user.uid, username: user.user.username, startedAt: DateTime.now(), viewers: 0, channelId: channelId);

          _firestore.collection('livestream').doc(channelId).set(liveStream.toMap());
        }else{
          showSnackBar(context, 'Two Livestreams cannot start at the same time.');
        }
        //t
      }else{
        showSnackBar(context, 'Please enter all the fields');
      }
//p
    } on FirebaseException catch(e){
      showSnackBar(context, e.message!);
    }
    return channelId;
  }


  Future<void> endLiveStream(String channelId) async{
    try{
      QuerySnapshot snap =await _firestore
          .collection('livestream')
          .doc(channelId)
          .collection('comments')
          .get();
      for(int i = 0; i<snap.docs.length; i++){
        await _firestore
            .collection('livestream')
            .doc(channelId)
            .collection('comments')
            .doc(
          ((snap.docs[i].data()! as dynamic)['commentId']),
        )
            .delete();
      }
      await _firestore.collection('livestream').doc(channelId).delete();
    }catch(e){
      debugPrint(e.toString());
    }
    }

    //update viewers
  Future<void> updateViewCount(String channelId, bool isIncreased) async{
    try{
      await _firestore.collection('livestream').doc(channelId).update({
        'viewers': FieldValue.increment(isIncreased ? 1 : -1),
      });
    }catch(e){
      debugPrint(e.toString());
    }
  }




}