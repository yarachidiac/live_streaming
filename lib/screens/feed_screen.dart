import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_live_streaming/models/livestream.dart';
import 'package:project_live_streaming/screens/broadcast_screen.dart';

import '../resources/firestore_methods.dart';
import '../widgets/loading_indicator.dart';
import 'package:timeago/timeago.dart' as timeago;

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0).copyWith(
          top: 10
      ),
      child: Column(
        children: [
          const Text('Live Users', style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22
          ),
          ),
          SizedBox(height: size.height*0.03,),

          StreamBuilder<dynamic>(
            stream: FirebaseFirestore.instance
                .collection('livestream')
                .snapshots(),
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting){
                return const LoadingIndicator();
              }
              return
                snapshot.hasData && snapshot.data!.docs.isNotEmpty?

                Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    LiveStream post = LiveStream.fromMap(snapshot.data.docs[index].data());

                    return InkWell(
                      onTap: () async {
                        await FirestoreMethods().updateViewCount(post.channelId, true);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BroadcastScreen(
                              isBroadcaster: false,
                              channelId: post.channelId,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: size.height * 0.1,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(
                                post.image,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    post.username,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    post.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    '${post.viewers} watching',
                                  ),
                                  Text(
                                    'Started ${timeago.format(post.startedAt.toDate())}',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ):  Center(child: Text("NO Current Live Streaming",  style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              ),),);

            },)
        ],

      ),
    ));
  }
}