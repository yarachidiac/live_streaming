import 'dart:io';
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


  // Function to upload file to Firebase Storage
  Future<String> uploadFileToStorage(String filePath, String fileName) async {
    // Create a reference to the Firebase Storage bucket
    Reference storageRef = _storage.ref().child('files');

    // Upload the file to Firebase Storage
    UploadTask uploadTask = storageRef.child(fileName).putFile(File(filePath));

    // Await the completion of the upload task
    TaskSnapshot taskSnapshot = await uploadTask;

    // Get the download URL of the uploaded file
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    // Return the download URL
    return downloadUrl;
  }


}