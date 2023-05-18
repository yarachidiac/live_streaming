
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/user_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../utils/utils.dart';

class ChatCard extends StatelessWidget {
  final snap;
  final String image;
  const ChatCard({Key? key, required this.snap,required this.image}) : super(key: key);

  Future<void> downloadAndOpenFile(String fileUrl, String fileName) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final saveDir = appDir.path + '/downloads';

      final dio = Dio();
      final response = await dio.download(fileUrl, '$saveDir/$fileName');

      if (response.statusCode == 200) {
        await OpenFile.open('$saveDir/$fileName');
      } else {
        print( 'Failed to download file');
      }
    } catch (e) {
      print('Error downloading or opening file: $e');
    }
  }


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
                  if (snap.data().containsKey('fileUrl'))
                    TextButton(
                      onPressed: () async{
                        if (snap.data().containsKey('fileUrl')) {
                          String fileUrl = snap.data()['fileUrl'];
                          String fileNameWithExtension = snap.data()['fileName'];
                          downloadAndOpenFile(fileUrl, fileNameWithExtension);

                        }
                      },

                      child: Row(
                        children: [
                          Icon(Icons.attach_file),
                          Text('Download File'),
                        ],
                      ),
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