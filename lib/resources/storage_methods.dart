import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageMehtods{
  FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String>  uploadImageStorage(String childName, Uint8List file, String uid) async {
    Reference ref = _storage.ref().child(childName).child(uid);
    UploadTask uploadTask = ref.putData(
        file,
        SettableMetadata(
      //contentType: 'image/jpg'
    ));
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> uploadImageToStorage(String childName, Uint8List file, bool isPost, String uid) async {
    // creating location to our firebase storage
    String id = const Uuid().v1();
    Reference ref =
    _storage.ref().child(childName).child(uid);


    ref = ref.child(id);


    // putting in uint8list format -> Upload task like a future but not future
    UploadTask uploadTask = ref.putData(
        file
    );

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }




}