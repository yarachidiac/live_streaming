import 'package:flutter/material.dart';

import 'add_post.dart';

class  ProfileScreen extends StatelessWidget {
  const ProfileScreen ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var w=MediaQuery.of(context).size.width;
    var h=MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body:
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: h * 0.5,),


          Container(
            width:  w* 0.5, // Half of the available width
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                onPrimary: Colors.white,
                padding: EdgeInsets.all(4.0),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddPostScreen()),
                );
              },
              child: Text(
                'Create Post',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
        ],
      ),

    );

  }
}
