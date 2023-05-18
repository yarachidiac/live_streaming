import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class VoiceCard extends StatefulWidget {
  final snap;

  const VoiceCard({
    Key? key,
    required this.snap,

  }) : super(key: key);

  @override
  _VoiceCardState createState() => _VoiceCardState();
}



class _VoiceCardState extends State<VoiceCard> {
  bool isPlaying = false;
  AudioPlayer audioPlayer = AudioPlayer();
  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    print("hengeeeeee");
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            isPlaying = !isPlaying;
          });
          // Implement your logic to play/pause the audio here
          if (isPlaying) {
            print('Play voice: ${widget.snap['VoiceUrl']}');
          } else {
            print('Pause voice');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: widget.snap['image']!=""?
                NetworkImage(widget.snap['image'].toString())
                    : NetworkImage(
                    'https://www.vhv.rs/dpng/d/312-3120300_default-profile-hd-png-download.png'),
                radius: 24.0,
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.snap['username'],
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Stack(
                      children: [
                        Container(
                          height: 4.0,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                       /* Container(
                          height: 4.0,
                          width: isPlaying ? MediaQuery.of(context).size.width * 0.5 : 0,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),*/
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  setState(() {
                    isPlaying = !isPlaying;
                  });

                  if (isPlaying) {
                    late Source audioUrl;
                    audioUrl=UrlSource(widget.snap['VoiceUrl']);
                    audioPlayer.play(audioUrl);


                    //  await audioPlayer.play(url);

                    //widget.snap['url']
                  } else {
                    audioPlayer.pause();
                  }
                },
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 32.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}