import 'package:flutter/material.dart';

import 'add_post.dart';

class  ProfileScreen extends StatelessWidget {
  const ProfileScreen ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Button Page'),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.blue,
            onPrimary: Colors.white,
            padding: EdgeInsets.all(16.0),
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AddPostScreen.routeName);

          },
          child: Text(
            'Click Me',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
        ),
      ),
    );

  }
}
