import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:project_live_streaming/providers/user_provider.dart';
import 'package:project_live_streaming/resources/storage_methods.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/livestream.dart';
import '../models/post.dart';
import '../models/user.dart';
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

  Future<void> chat(String text, String channelId, String filePath, String fileName, BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      String commentId = Uuid().v1();

      if(filePath != ''){
        // Upload the file to Firebase Storage and get the download URL
        String downloadUrl = await _storageMethods.uploadFileToStorage(filePath, fileName);
        await _firestore.collection('livestream').doc(channelId).collection('comments')
            .doc(commentId).set({
          'username': userProvider.user.username,
          'message': text,
          'uid': userProvider.user.uid,
          'createdAt': DateTime.now(),
          'commentId': commentId,
          'fileUrl': downloadUrl, // Add the file URL field
          'fileName': fileName, // Add the fileName field
        });

      }else{
        await _firestore.collection('livestream').doc(channelId).collection('comments')
            .doc(commentId).set({
          'username': userProvider.user.username,
          'message': text,
          'uid': userProvider.user.uid,
          'createdAt': DateTime.now(),
          'commentId': commentId,
        });
      }

    } on FirebaseException catch (e) {
      showSnackBar(context, e.message!);
    }
  }


  Future<String> updateUserImage(BuildContext context, Uint8List? image) async{
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      String imageUrl = await _storageMethods.uploadImageStorage(
          'user-image', image!, userProvider.user.uid);
      await _firestore.collection('users').doc(userProvider.user.uid).update(
          {'image': imageUrl});
      return imageUrl;

    }catch(e){
      e.toString();
      return '';
    }
  }

  Future<User> getBroadcasterDetail(String channelId) async {
    DocumentSnapshot liveStreamSnapshot = await _firestore
        .collection('livestream')
        .doc(channelId)
        .get();

    String broadcasterUid = liveStreamSnapshot['uid'];

    DocumentSnapshot userSnapshot = await _firestore
        .collection('users')
        .doc(broadcasterUid)
        .get();

    User user = User.fromMap(userSnapshot.data()! as Map<String, dynamic>);
    return user;
  }

  Future<void> followBroadcaster(
      String broadcasterUid,
      UserProvider userProvider
      ) async {
    try {
      DocumentSnapshot snap = await _firestore.collection('users').doc(userProvider.user.uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if(following.contains(broadcasterUid)) {
        await _firestore.collection('users').doc(broadcasterUid).update({
          'followers': FieldValue.arrayRemove([userProvider.user.uid])
        });

        await _firestore.collection('users').doc(userProvider.user.uid).update({
          'following': FieldValue.arrayRemove([broadcasterUid])
        });
      } else {
        await _firestore.collection('users').doc(broadcasterUid).update({
          'followers': FieldValue.arrayUnion([userProvider.user.uid])
        });

        await _firestore.collection('users').doc(userProvider.user.uid).update({
          'following': FieldValue.arrayUnion([broadcasterUid])
        });
      }

    } catch(e) {
      print(e.toString());
    }
  }

  Future<String> uploadPost(String description, Uint8List file, String uid,
      String username, String profImage) async {
    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
    String res = "Some error occurred";
    try {
      String photoUrl =
      await StorageMehtods().uploadImageToStorage('posts', file, true,uid);
      String postId = const Uuid().v1(); // creates unique id based on time
      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        likes: [],
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        image: profImage,
      );
      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }


  Future<String> likePost(String postId, String uid, List likes/*we will get the list likes men l streambuilder */) async {
    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) { //eza l user li eendo l uid li kabasa aa kabsit l like mawjud l uid tabaoo already bi alb likes list tabaa l post mnaamol dislike w menshilo mn l likes list else men zido w mnaamol like
        //mawjud mnshilo
        await _firestore.collection('posts').doc(postId).update({ //aamnfut aa collection l post wel doc postid aamna2e l post li aamyaamol action eele w update query lanzabit l list
          'likes': FieldValue.arrayRemove([uid])             //eemlna .update laan eza bedna naamol .set bedna nsir nmari2 kel l values
        });                                                  //aamn2ul la firebase ru7 aal likes field khod kel l list w shil bas l current uid mena
      } else {
        // else mezido aal likes
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> postComment(String postId, String text, String uid,
      String name, String profilePic) async {

    //baatna l uid hek eza bedna bas nekbs aa esem l user men l comments nekhdo aa safhit profile tabaa l user li aamil l comment
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        // if the likes list contains the user uid, we need to remove it
        String commentId = const Uuid().v1();
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'image': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
        res = 'success';
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deletePost(String postId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('posts').doc(postId).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }


}