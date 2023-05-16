import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_live_streaming/screens/profile_screen.dart';
import 'package:project_live_streaming/utils/colors.dart';
import 'package:project_live_streaming/widgets/post_card.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/user_provider.dart';

class PostFeedScreen extends StatefulWidget {
  const PostFeedScreen({Key? key}) : super(key: key);

  @override
  State<PostFeedScreen> createState() => _PostFeedScreenState();
}

class _PostFeedScreenState extends State<PostFeedScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userP = Provider.of<UserProvider>(context).user;

    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Container(
          height: 40.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: Colors.black,
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              SizedBox(width: 10.0),
              Icon(Icons.search, color: Colors.grey),
              SizedBox(width: 10.0),
              Expanded(
                child: TextFormField(
                  controller: searchController,
                  style: TextStyle(fontSize: 16.0),
                  decoration: InputDecoration(
                    hintText: 'Search for a user...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.all(0),
                  ),
                  onFieldSubmitted: (String _) {
                    setState(() {
                      isShowUsers = true;
                    });
                    print(_);
                    print(searchController.text);
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      body: isShowUsers
          ? FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('users')
            .where(
          'username',
          isGreaterThanOrEqualTo: searchController.text,
        )
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final userList = (snapshot.data!as dynamic).docs
              .map((doc) => User.fromMap(doc.data()))
              .toList();
          return ListView.separated(
            itemCount: userList.length,
            separatorBuilder: (context, index) => Divider(thickness: 2),
            itemBuilder: (context, index) {
              final user = userList[index];

              return ListTile(
                onTap:
                    () =>
                    Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                    user.uid==userP.uid?
                        ProfileScreen(
                      broadcaster: user,
                      isBroadcaster: false,
                    ): ProfileScreen(
                      broadcaster: user,
                      isBroadcaster: true,
                    )
                  ),
                ),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.image),
                  radius: 20,
                ),
                title: Text(
                  user.username,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              );
            },
          );
        },
      )
          : StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('datePublished', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
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
          );

        },
      ),
    );
  }
}
