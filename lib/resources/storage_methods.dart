import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

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

  Future<String>  uploadUserImage(String childName, Uint8List file, String uid) async {
    Reference ref = _storage.ref().child(childName).child(uid);
    UploadTask uploadTask = ref.putData(
        file,
        SettableMetadata(
          //contentType: 'image/jpg'
        ));
    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();
    return imageUrl;
  }


}