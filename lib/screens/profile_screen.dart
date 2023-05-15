import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_live_streaming/resources/firestore_methods.dart';
import 'package:project_live_streaming/utils/colors.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/user_provider.dart';
import '../utils/utils.dart';
import '../widgets/post_card.dart';
import 'add_post.dart';

class ProfileScreen extends StatefulWidget {
  final User broadcaster;
  final bool isBroadcaster;
  ProfileScreen({Key? key, required this.broadcaster, required this.isBroadcaster}) : super(key: key);

  @override
  _ProfileScreen createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  var broadcastData = {};
  int followers = 0;
  int following = 0;
  bool isLoading = false;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var broadcastSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.broadcaster.uid)
          .get();


      broadcastData = broadcastSnap.data()!;
      followers = broadcastSnap.data()!['followers'].length;
      following = broadcastSnap.data()!['following'].length;
      isFollowing = broadcastSnap
          .data()!['followers']
          .contains(Provider.of<UserProvider>(context, listen: false).user.uid);
      setState(() {});
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final size=MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Profile', style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22
        ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Column(
            children: [
              widget.isBroadcaster
                  ?  CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white, // Change the background color here
                backgroundImage: widget.broadcaster.image != ""
                    ? NetworkImage(widget.broadcaster.image)
                    : NetworkImage(
                    'https://www.vhv.rs/dpng/d/312-3120300_default-profile-hd-png-download.png'),
              )

                  : GestureDetector(
                onTap: () async {
                  setState(() {
                    isLoading = true; // set isLoading to true when image starts loading
                  });
                  Uint8List? pickedImage = await pickImage();
                  if (pickedImage != null) {
                    String imageUrl =
                    await FirestoreMethods().updateUserImage(context, pickedImage);
                    setState(() {
                      user.image = imageUrl;
                      isLoading = false; // set isLoading to false when image is loaded
                    });
                  }
                },
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white, // Change the background color here
                      backgroundImage: user.image != ""
                          ? NetworkImage(user.image)
                          : NetworkImage(
                          'https://www.vhv.rs/dpng/d/312-3120300_default-profile-hd-png-download.png'),
                    ),
                    if (isLoading)
                      Positioned.fill(
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              widget.isBroadcaster
                  ? Text(
                widget.broadcaster.username,
                style: Theme.of(context).textTheme.headline6,
              )
                  :  Text(
                user.username,
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 8),

               Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                         '$followers' ,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Followers',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '$following',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Following',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ],
              )

            ],
          ),
          const SizedBox(height: 16),

          widget.isBroadcaster
              ? Center(
              child: isFollowing
                  ? ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                      return buttonColor;
                    },
                  ),
                ),
                onPressed: () async{
                  await FirestoreMethods().followBroadcaster(widget.broadcaster.uid, Provider.of<UserProvider>(context, listen: false));
                  setState(() {
                    isFollowing = false;
                    followers--;
                  });
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_add),
                    SizedBox(width: 8),
                    Text("Unfollow",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
              )
                  :ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                      return buttonColor;
                    },
                  ),
                ),
                onPressed:  () async{
                  await FirestoreMethods().followBroadcaster(widget.broadcaster.uid, Provider.of<UserProvider>(context, listen: false));
                  setState(() {
                    isFollowing = true;
                    followers++;
                  });
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_add),
                    SizedBox(width: 8),
                    Text('Follow',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
              )
          )
              : Container(),


          widget.isBroadcaster
              ? Container()
              : Center(
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    return buttonColor;
                  },
                ),
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
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .where('uid', isEqualTo:user.uid)
                  .orderBy('datePublished', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return
                  snapshot.hasData?
                  ListView.builder(
                    itemCount: snapshot.data!.docs.length,

                    itemBuilder: (ctx, index) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.9),
                              blurRadius: 2.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: PostCard(
                          snap: snapshot.data!.docs[index].data(),
                        ),
                      ),
                    ),
                  ):
                  Center(child:Text(""));

              },
            ),
          ),
        ],
      ),
    );
  }

}
