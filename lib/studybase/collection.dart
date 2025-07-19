import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studystudio/branding.dart';
import 'package:studystudio/studybase/collection_lesson.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MyCollection extends StatefulWidget {
  const MyCollection({super.key});

  @override
  State<MyCollection> createState() => _MyCollectionState();
}

class _MyCollectionState extends State<MyCollection> {
  Branding br = Branding();
  TextEditingController search = TextEditingController();
  CollectionReference collection = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('my collection');

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
  void initState() {
    super.initState();
    search.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: br.white,
          leading: Icon(Icons.bookmark_add_outlined, color: Colors.blue, size: 20),
          centerTitle: false,
          title: Text(
            'MY COLLECTION',
            style: GoogleFonts.viga(color: Colors.blue, fontSize: 16),
          ),
        ),
        backgroundColor: br.white,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                child: TextField(
                  cursorColor: Colors.blue,
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
                        borderSide: BorderSide(color: Colors.blue)),
                  ),
                ),
              ),
              StreamBuilder(
  stream: collection.snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(
        child: Text('Searching...'),
      );
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0),
        child: Center(
          child: Text(
            'No videos found.',
            textAlign: TextAlign.center,
            style: GoogleFonts.bricolageGrotesque(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    List<DocumentSnapshot> arrdata = snapshot.data!.docs;

    return FutureBuilder(
      future: Future.wait(arrdata.map((doc) async {
        String ytID = doc['video ID'];
        try {
          Map<String, String> info = await getYoutubeInfo(ytID);
          return {'doc': doc, 'info': info};
        } catch (e) {
          return null; // skip failed fetches
        }
      })),
      builder: (context, ytSnapshot) {
        if (ytSnapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator.adaptive();
        }

        if (!ytSnapshot.hasData) return Container();

        final items = ytSnapshot.data!
            .where((item) => item != null)
            .cast<Map<String, dynamic>>()
            .where((item) {
              final query = search.text.trim().toLowerCase();
              if (query.isEmpty) return true;
              return item['info']['title']!.toLowerCase().contains(query);
            })
            .toList();

        return ListView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final doc = items[index]['doc'];
            final info = items[index]['info'];
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => CollectionLesson(doc: doc),
                ));
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                      child: Image.network(
                        info['thumbnail']!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    ListTile(
                      title: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7.0),
                        child: Text(
                          info['title']!,
                          style: GoogleFonts.bricolageGrotesque(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  },
)

            ],
          ),
        ),
      ),
    );
  }
}
