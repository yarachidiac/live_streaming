import 'package:cloud_firestore/cloud_firestore.dart';

class User{
  final String uid;
  final String username;
  final String email;
  late String image;
  final List<String> followers;
  final List<String> following;

  User({required this.uid, required this.username, required this.email, required this.image, required this.followers, required this.following});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'image': image,
      'followers': followers,
      'following': following,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      image: map['image'] ?? '',
      followers: List<String>.from(map['followers'] ?? []),
      following: List<String>.from(map['following'] ?? []),
    );
  }

  /*factory User.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return User(
      uid: snapshot.id,
      username: data['username'],
      email: data['email'] ?? '',
      image: data['image'],
      followers: List<String>.from(data['followers'] ?? []),
      following: List<String>.from(data['following'] ?? []),

    );
  }*/
}