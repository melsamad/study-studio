import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studystudio/branding.dart';
import 'package:studystudio/studybase/base_lesson.dart';
import 'package:studystudio/studybase/collection.dart';
import 'package:studystudio/studybase/comments.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:url_launcher/url_launcher.dart';

class StudyBase extends StatefulWidget {
  const StudyBase({super.key});

  @override
  State<StudyBase> createState() => _StudyBaseState();
}

class _StudyBaseState extends State<StudyBase> {
  Branding br = Branding();
  TextEditingController search = TextEditingController();
  CollectionReference studybase = FirebaseFirestore.instance.collection('studies in studio');

  List<DocumentSnapshot> allVideos = [];
  List<DocumentSnapshot> filteredVideos = [];

  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    search.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    String query = search.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredVideos = allVideos;
      } else {
        filteredVideos = allVideos.where((doc) {
          String explanation = doc['explanation']?.toString().toLowerCase() ?? '';
          String videoID = doc['video ID']?.toString().toLowerCase() ?? '';
          return explanation.contains(query) || videoID.contains(query);
        }).toList();
      }
    });
  }

  Future<Map<String, String>> getYoutubeInfo(String videoId) async {
    final yt = YoutubeExplode();

    try {
      final video = await yt.videos.get(VideoId(videoId));
      final title = video.title;
      final thumbnailUrl = video.thumbnails.highResUrl;

      yt.close();
      return {
        'title': title,
        'thumbnail': thumbnailUrl,
      };
    } catch (e) {
      yt.close();
      throw Exception('Failed to fetch video info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: br.white,
        appBar: AppBar(
          backgroundColor: br.white,
          leading: Image.asset('lib/animation/logo.png'),
          centerTitle: false,
          title: Text('STUDIES IN STUDIO',
              style: GoogleFonts.viga(color: br.black, fontSize: 18)),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                child: TextField(
                  cursorColor: Colors.amber,
                  controller: search,
                  decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: GoogleFonts.bricolageGrotesque(
                          color: Colors.grey[500]!, fontSize: 13),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey[400]!)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.amber))),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: TextButton.icon(
                        icon: Icon(Icons.bookmark_add_outlined,
                            size: 13, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => MyCollection()));
                        },
                        label: Text(
                          'View my collection',
                          style: GoogleFonts.bricolageGrotesque(
                              color: Colors.blue, fontSize: 12),
                        )),
                  )
                ],
              ),
              StreamBuilder(
                stream: studybase.orderBy('date', descending: false).snapshots(),
                builder: ((context, snapshot) {

                  
                  if (snapshot.hasData) {
                    allVideos = snapshot.data!.docs;
                    filteredVideos = search.text.isEmpty
                        ? allVideos
                        : allVideos.where((doc) {
                            String explanation = doc['explanation']?.toString().toLowerCase() ?? '';
                            String videoID = doc['video ID']?.toString().toLowerCase() ?? '';
                            return explanation.contains(search.text.toLowerCase()) ||
                                videoID.contains(search.text.toLowerCase());
                          }).toList();

                    return ListView.builder(
                      itemCount: filteredVideos.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: ((context, index) {
                        final videoDoc = filteredVideos[index];
                        String ytID = videoDoc['video ID'];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BaseLesson(doc: videoDoc)));
                          },
                          child: Container(
                            margin:
                                EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10)),
                            child: FutureBuilder(
                                future: getYoutubeInfo(ytID),
                                builder: ((context, ytShot) {
                                  if (ytShot.hasError) {
                                    return Text('Error: ${ytShot.error}');
                                  } else if (ytShot.hasData) {
                                    final data = ytShot.data!;
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10)),
                                            child: Image.network(
                                              data['thumbnail']!,
                                              height: 200,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            )),
                                        ListTile(
                                          title: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 7.0),
                                            child: Text(
                                              data['title']!,
                                              style: GoogleFonts.bricolageGrotesque(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 15),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                                child: StreamBuilder<QuerySnapshot>(
                                                    stream: studybase
                                                        .doc(videoDoc.id)
                                                        .collection('favorites')
                                                        .where('uid', isEqualTo: uid)
                                                        .snapshots(),
                                                    builder: (context, snapshot) {
                                                      if (snapshot.hasData) {
                                                        final isLiked =
                                                            snapshot.data!.docs;
                                                        return IconButton(
                                                            onPressed: () async {
                                                              if (isLiked.length == 1) {
                                                                studybase
                                                                    .doc(videoDoc.id)
                                                                    .collection('favorites')
                                                                    .doc(isLiked.first.id)
                                                                    .delete();
                                                              } else {
                                                                studybase
                                                                    .doc(videoDoc.id)
                                                                    .collection('favorites')
                                                                    .add({'uid': uid});
                                                              }
                                                            },
                                                            icon: Icon(
                                                              isLiked.length == 1
                                                                  ? Icons.favorite
                                                                  : Icons.favorite_border,
                                                              size: 20,
                                                              color: Colors.red,
                                                            ));
                                                      }
                                                      return IconButton(
                                                          onPressed: () {},
                                                          icon: Icon(Icons.favorite,
                                                              size: 20,
                                                              color: Colors.grey));
                                                    })),
                                            Expanded(
                                                child: StreamBuilder<QuerySnapshot>(
                                                    stream: studybase
                                                        .doc(videoDoc.id)
                                                        .collection('saves')
                                                        .where('uid', isEqualTo: uid)
                                                        .snapshots(),
                                                    builder: (context, snapshot) {
                                                      if (snapshot.hasData) {
                                                        final isSaved =
                                                            snapshot.data!.docs;

                                                        return IconButton(
                                                            onPressed: () async {
                                                              if (isSaved.length == 1) {
                                                                await studybase
                                                                    .doc(videoDoc.id)
                                                                    .collection('saves')
                                                                    .doc(isSaved.first.id)
                                                                    .delete();
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection('users')
                                                                    .doc(uid)
                                                                    .collection(
                                                                        'my collection')
                                                                    .doc(videoDoc.id)
                                                                    .delete();
                                                              } else {
                                                                QuerySnapshot
                                                                    flashcardsID =
                                                                    await studybase
                                                                        .doc(videoDoc.id)
                                                                        .collection(
                                                                            'flashcards')
                                                                        .get();

                                                                studybase
                                                                    .doc(videoDoc.id)
                                                                    .collection('saves')
                                                                    .add({'uid': uid});

                                                                FirebaseFirestore.instance
                                                                    .collection('users')
                                                                    .doc(uid)
                                                                    .collection(
                                                                        'my collection')
                                                                    .doc(videoDoc.id)
                                                                    .set({
                                                                  'creator': videoDoc['uid'],
                                                                  'video ID':
                                                                      videoDoc['video ID'],
                                                                  'explanation':
                                                                      videoDoc['explanation'],
                                                                  'date added': DateTime.now(),
                                                                  'date created':
                                                                      videoDoc['date']
                                                                });

                                                                if (flashcardsID
                                                                    .docs.isNotEmpty) {
                                                                  for (int i = 0;
                                                                      i <
                                                                          flashcardsID
                                                                              .docs.length;
                                                                      i++) {
                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection('users')
                                                                        .doc(uid)
                                                                        .collection(
                                                                            'my collection')
                                                                        .doc(videoDoc.id)
                                                                        .collection(
                                                                            'flashcards')
                                                                        .add({
                                                                      'answer': '',
                                                                      'question':
                                                                          flashcardsID
                                                                              .docs[i]['question']
                                                                    });
                                                                  }
                                                                }
                                                              }
                                                            },
                                                            icon: Icon(
                                                              isSaved.length == 1
                                                                  ? Icons.bookmark
                                                                  : Icons.bookmark_border,
                                                              size: 20,
                                                              color: Colors.grey[500],
                                                            ));
                                                      }

                                                      return IconButton(
                                                          onPressed: () {},
                                                          icon: Icon(Icons.bookmark,
                                                              size: 20,
                                                              color: Colors.grey[500]));
                                                    })),
                                            Expanded(
                                              child: IconButton(
                                                  onPressed: () {
                                                    showModalBottomSheet(
                                                        isScrollControlled: true,
                                                        context: context,
                                                        builder: ((context) {
                                                          return Comments(doc: videoDoc);
                                                        }));
                                                  },
                                                  icon: Icon(
                                                    Icons.comment_outlined,
                                                    size: 20,
                                                    color: Colors.grey[500],
                                                  )),
                                            ),
                                            Expanded(
                                              // https://www.youtube.com/watch?v=NIgrGqmoeHs
                                                child: IconButton(
                                                    onPressed: () async {

                                                      String youtubeUrl = "https://www.youtube.com/watch?v=${allVideos[index]['video ID']}";
                                                       final Uri url = Uri.parse(youtubeUrl);

      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $youtubeUrl';
      }
                                                    },
                                                    icon: Icon(Icons.play_arrow,
                                                        size: 20,
                                                        color: Colors.blue[800])))
                                          ],
                                        )
                                      ],
                                    );
                                  }
                                  return Container();
                                })),
                          ),
                        );
                      }),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator.adaptive();
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25.0),
                    child: Text(
                      'Something went wrong. \nCould not load database.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.bricolageGrotesque(fontSize: 11),
                    ),
                  );
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
