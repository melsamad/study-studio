import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:studystudio/ai%20agents/card.dart';
import 'package:studystudio/ai%20agents/yt.dart';
import 'package:studystudio/branding.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MyAiAgent extends StatefulWidget {
  const MyAiAgent({super.key});

  @override
  State<MyAiAgent> createState() => _MyAiAgentState();
}

class _MyAiAgentState extends State<MyAiAgent> {

  Branding br = Branding();
  String uid = FirebaseAuth.instance.currentUser!.uid;

  Future<Map<String, String>> getYoutubeInfo(String videoId) async {
  final yt = YoutubeExplode();

  try {
    final video = await yt.videos.get(VideoId(videoId));
    final title = video.title;
    final thumbnailUrl = video.thumbnails.highResUrl;

    yt.close(); // always close when done
    return {
      'title': title,
      'thumbnail': thumbnailUrl,
    };
  } catch (e) {
    yt.close();
    throw Exception('Failed to fetch video info: $e');
  }
}

  Widget team(String lottie, String text) {
    return Expanded(
      child: Container(
        //height: 150,
        margin: EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 5
        ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey[500]!,
                        width: 1.2
                      )
                    ),
                    
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            
                          Lottie.asset(lottie, height: 90),
                            
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                              child: Text(text,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.bricolageGrotesque(
                                fontSize: 12
                              ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
    );
  }

  bool isUserPro = false;
  Future<void> ThreeFreeLeft() async {
    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
                              CustomerInfo customerInfo = await Purchases.getCustomerInfo();
                              EntitlementInfo? entitlement = customerInfo.entitlements.all['Study Turbo'];
                              if (entitlement != null && entitlement.isActive) {
                                  setState(() {
                       isUserPro = true;
                      });
                              } else {
                                
                            
                                print('not subscribed');
                              }
                      }
                      );
  }

  int newCount = 0;


  Future<void> checkCount() async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(uid).collection('Ai Knowbies Amount').doc('amount');

  await FirebaseFirestore.instance.runTransaction((transaction) async {
    final snapshot = await transaction.get(docRef);

    int currentCount = 0;
    if (snapshot.exists && snapshot.data()?['count'] != null) {
      currentCount = snapshot['count'] as int;
    }

    newCount = currentCount;

    transaction.set(docRef, {'count': newCount});

    print(newCount);

  });
  }



  @override
  void initState() {
    super.initState();
    ThreeFreeLeft();
    checkCount();
  }

  Future<void> progressIndicator() async {
    showDialog(
      context: context, 
      builder: ((context) {
        return AlertDialog(
          backgroundColor: br.white,
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Center(
              child: Lottie.asset('lib/animation/robot_human.json', height: 100),
            ),
          ),
        );
      })
    );
  }

  



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add, size: 20,),
        backgroundColor: br.white,
        elevation: 2,
        onPressed: () async {

          if (isUserPro == true || newCount < 3) {
            progressIndicator();

                      final docRef = FirebaseFirestore.instance.collection('users').doc(uid).collection('Ai Knowbies Amount').doc('amount');

  await FirebaseFirestore.instance.runTransaction((transaction) async {
    final snapshot = await transaction.get(docRef);

    int currentCount = 0;
    if (snapshot.exists && snapshot.data()?['count'] != null) {
      currentCount = snapshot['count'] as int;
    }

    newCount = currentCount + 1;

    transaction.set(docRef, {'count': newCount});

    print(newCount);

  });



  Navigator.pop(context);
  setState(() {
    newCount;
  });

          
          Navigator.push(context, MaterialPageRoute(builder: (context) => StudyAi()));
          } else {
             final paywalResult = await RevenueCatUI.presentPaywallIfNeeded('Study Turbo');
            log('Paywall results: $paywalResult');
            paywalResult;
          }

           


          
        }, 
        label: Text('new lesson',
        style: GoogleFonts.bricolageGrotesque(
          fontWeight: FontWeight.w600
        ),
        )
      ),
      backgroundColor: br.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [], 
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [

              ListTile(
                title: Text('KNOWBIES - Ai STUDY AGENTS',
                style: GoogleFonts.viga(
                  color: br.black
                ),
              ),
              subtitle: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Text('MEET THE TEAM!',
                  style: GoogleFonts.bricolageGrotesque(
                    color: br.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w700
                  ),
                  ),
                ),
            ),



            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7),
              child: Column(
                children: [
                  Row(
                    children: [
                      team('lib/animation/youtube.json', "Bob will get the YouTube subtitles."),
                      team('lib/animation/pdf.json', "Mia will turn them into a lesson."),
                    ],
                  ),
                  
                  Row(
                    children: [
                      team('lib/animation/flashcards.json', "Luke will create flashcards."),
                      team('lib/animation/robot.json', "Naya will answer your questions."),
                    ],
                  ),
                ],
              ),
            ),


            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: ListTile(
                  title: Text('YOUR LESSONS \n& FLASHCARDS',
                  style: GoogleFonts.viga(
                    color: br.black
                  ),
                ),


                subtitle: isUserPro == false ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text('${3 - newCount} FREE USES LEFT',
                  style: GoogleFonts.bricolageGrotesque(
                    fontWeight: FontWeight.w700,
                    color: Colors.green
                  ),
                  ),
                ) : null,
                
              ),
            ),


            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('Ai Knowbies Lesson').orderBy('date', descending: true).snapshots(), 
              builder: ((context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Lottie.asset('lib/animation/robot_human.json', height: 90),
                );
                }

                if (snapshot.hasData) {

                  List<DocumentSnapshot> arrdata = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: arrdata.length,
                    itemBuilder: ((context, index)  {

                      String ytID = arrdata[index]['video ID'];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => MyLesson(doc: arrdata[index])));
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10)
                          ),
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
                        
                                      ListTile(
                                        title: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 7.0),
                                          child: Text(data['title']!, 
                                          style: GoogleFonts.bricolageGrotesque(
                                             fontWeight: FontWeight.w500,
                                            fontSize: 15
                                          )
                                  ),
                                        ),
                                      ),
                                      ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10)
                                        ),
                                        child: Image.network(data['thumbnail']!, height: 200, width: double.infinity, fit: BoxFit.cover,)),
                                      
                                    ],
                                  );
                                }
                        
                                return Container();
                              
                            })
                          ),
                        ),
                      );
                    })
                  );
                
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Text('No lessons found.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.bricolageGrotesque(
                    color: Colors.red,
                    fontSize: 13,
                  ),
                  ),
                );


                
              })
            ),


            ],
          ),
        )
      ),
    );
  }
}