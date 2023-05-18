import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:project_live_streaming/providers/user_provider.dart';
import 'package:project_live_streaming/resources/firestore_methods.dart';
import 'package:project_live_streaming/widgets/chat_card.dart';
import 'package:project_live_streaming/widgets/custom_textfield.dart';
import 'package:project_live_streaming/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

class Chat extends StatefulWidget {
  final String channelId;
  const Chat({Key? key, required this.channelId}) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _chatController = TextEditingController();
  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      String? filePath = file.path;
      String? mimeType = lookupMimeType(filePath!);

      // Extract the file name and extension
      String fileNameWithExtension = file.name;
      String fileName = fileNameWithExtension.split('.').first;
      String fileExtension = fileNameWithExtension.split('.').last;

      return {
        'path': filePath,
        'mimeType': mimeType,
        'fileName': fileName,
        'fileExtension': fileExtension,
      };
    }

    return null;
  }




  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: StreamBuilder<dynamic>(
              stream: FirebaseFirestore.instance
                  .collection('livestream')
                  .doc(widget.channelId)
                  .collection('comments')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting){
                  return const LoadingIndicator();
                }
                if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
                  return const SizedBox(); // Return an empty widget if there is no data
                }
                return ListView.separated(
                    itemCount: snapshot.data.docs.length,
                    separatorBuilder: (context, index) => Row(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: 1,
                            color: Colors.grey.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    itemBuilder: (context, index) =>ChatCard(snap: snapshot.data!.docs[index], image:userProvider.user.image)

                );
              },)
            ,),
          Row(
            children: [
              Flexible(child: CustomTextField(controller: _chatController,)),
              IconButton(
                onPressed: () {
                  if(_chatController.text != '') {
                    FirestoreMethods().chat(
                        _chatController.text, widget.channelId, '', '', context);
                    setState(() {
                      _chatController.text = '';
                    });
                  }
                },
                icon: Transform.rotate(
                  angle: -30 * 3.14159 / 180, // Rotate by 30 degrees in radians (-30 degrees)
                  child: Icon(Icons.send),


                ),
              ),

              IconButton(
                icon: Icon(Icons.attach_file),
                onPressed: () async {
                  Map<String, dynamic>? fileData = await pickFile();

                  if (fileData != null) {
                    String filePath = fileData['path'];
                    String fileName = fileData['fileName'];
                    String fileExtension = fileData['fileExtension'];
                    String uniqueFileName = '${fileName}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

                    FirestoreMethods().chat('', widget.channelId, filePath, uniqueFileName, context);
                  }
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}