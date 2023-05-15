import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/user_provider.dart';

class ChatCard extends StatelessWidget {
  final snap;
  final String image;
  const ChatCard({Key? key, required this.snap,required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).user;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              image ?? '',
            ),
            radius: 18,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [



                  Row(
                    children: [
                      Text( snap.data()['username'] ?? '',style:  const TextStyle(fontWeight: FontWeight.bold,),),
    Expanded(child: Text(' ${snap.data()['message']}' ?? ''),)
                    ],
                  ),

                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}