import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommentCard extends StatelessWidget {
  final snap;
  const CommentCard({Key? key, required this.snap}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage:
            snap.data()['image']!=""?
            NetworkImage(snap.data()['image'])
                : NetworkImage(
                'https://www.vhv.rs/dpng/d/312-3120300_default-profile-hd-png-download.png'),

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
                      Text( snap.data()['name'],style:  const TextStyle(fontWeight: FontWeight.bold,),),
                      Expanded(child: Text(' ${snap.data()['text']}'))
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                    snap.data()['datePublished'] != null
                          ? DateFormat.yMMMd().format(snap.data()['datePublished'].toDate())
                          : 'N/A',

                      style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w400,),
                    ),
                  )
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}