import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:project_live_streaming/resources/firestore_methods.dart';
import 'package:project_live_streaming/utils/utils.dart';
import 'package:project_live_streaming/widgets/custom_button.dart';
import 'package:project_live_streaming/widgets/custom_textfield.dart';

import '../utils/colors.dart';
import 'broadcast_screen.dart';

class GoLiveScreen extends StatefulWidget {
  const GoLiveScreen({Key? key}) : super(key: key);

  @override
  State<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends State<GoLiveScreen> {
  TextEditingController _titleController = TextEditingController();
  FirestoreMethods _firestoreMethods = FirestoreMethods();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Uint8List? image;

  goLiveStream() async{
    String channelId = await _firestoreMethods.startLiveStream(context, _titleController.text, image);
    if(channelId.isNotEmpty){
      showSnackBar(context, 'Livestream has started successfully');
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => BroadcastScreen(
          isBroadcaster: true,
          channelId: channelId,
        ),
      ),);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0,),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      Uint8List? pickedImage = await pickImage();
                      if(pickedImage != null){
                        setState((){
                          image = pickedImage;

                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22.0,
                        vertical:20,),
                      child: image != null ?
                      SizedBox(
                        height: 200,
                        child: Image.memory(image!)
                        ,) :
                      DottedBorder(
                        borderType: BorderType.Rect,
                        radius: const Radius.circular(10),
                        dashPattern: const [10.4],
                        strokeCap: StrokeCap.round,
                        color: buttonColor,
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                              color: buttonColor.withOpacity(.05),
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_open,
                                color: buttonColor,
                                size: 40,
                              ),
                              SizedBox(height: 15,),
                              Text('Select your thumbnail',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Title', style: TextStyle(
                          fontWeight: FontWeight.bold
                      ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: CustomTextField(controller: _titleController),
                      )
                    ],
                  )
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: CustomButton(onTap: goLiveStream, text: 'Go live'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
