import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:studystudio/branding.dart';
import 'package:studystudio/home_page.dart';

class Elaboration extends StatefulWidget {
  const Elaboration({super.key});

  @override
  State<Elaboration> createState() => _ElaborationState();
}

class _ElaborationState extends State<Elaboration> {

  Branding br = Branding();
  String uid = FirebaseAuth.instance.currentUser!.uid;
  // Initially selected random color
  Color? containerColor;

  // Function to get a random color from the list
  Color? getRandomColor() {
    final random = Random();
    return br.colors[random.nextInt(br.colors.length)];
  }

  @override
  void initState() {
    super.initState();
    // Set an initial random color
    containerColor = getRandomColor();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: br.white,
      floatingActionButton: FloatingActionButton.extended(
        elevation: 2,
        backgroundColor: Colors.grey[200],
        icon: Icon(Icons.add, color: br.black, size: 20,),
        onPressed: () async {
           br.progress(context);

           QuerySnapshot col = await FirebaseFirestore.instance.collection('users').doc(uid).collection('elaboration').get();

          if (isPro == true || col.docs.length < 2) {
                                  

          await FirebaseFirestore.instance.collection('users').doc(uid).collection('elaboration').add({
            'date':DateTime.now(),
            'topic':'',
            'subject':'Other',
            'summary':'',
            'feel':'Not sure'
          });

          Navigator.pop(context);


          Navigator.push(context, MaterialPageRoute(builder: (context) => CreateElaboration()));
                              } else {

                                Navigator.pop(context);
                                
                                 await RevenueCatUI.presentPaywallIfNeeded('Study Turbo');
                                
                              }

         
         
        }, 
        label: Text('study session',
        style: GoogleFonts.bricolageGrotesque(
          color: br.black
        ),
        )
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            
            ListTile(
              title: Text('ELABORATION',
              style: GoogleFonts.viga(
                color: br.black,
              ),
              ),

              subtitle: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text('Select a topic, summarize it, then elaborate on key points by adding additional information to complete your understanding.',
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.grey[700],
                  fontSize: 13
                ),
                ),
              ),
            ),



            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('elaboration').snapshots(), 
              builder:( (context, snapshot) {

                if (snapshot.hasData) {
                  List<DocumentSnapshot> arrdata = snapshot.data!.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: arrdata.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: ((context, index) {
                      containerColor = getRandomColor();

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => InsideElaboration(
                              doc: arrdata[index],
                            )));
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              width: 1.5,
                              color: containerColor!
                            )
                          ),
                          title: Text(arrdata[index]['topic'].toString().toUpperCase(),
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 15
                          ),
                          ),
                          subtitle: Text(arrdata[index]['subject'].toString().toLowerCase(),
                          style: GoogleFonts.bricolageGrotesque(
                            color: Colors.grey[700]
                          ),
                          ),
                          //tileColor: Colors.grey[300],
                        ),
                      );
                    })
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator.adaptive();
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text('Unable to load study sessions.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.bricolageGrotesque(
                    color: Colors.grey[700],
                    fontSize: 12
                  ),
                  ),
                );
              })
            )

          ],
        ),
      ),
    );
  }
}


class InsideElaboration extends StatefulWidget {
  final DocumentSnapshot doc;
  const InsideElaboration({super.key,
  required this.doc
  });

  @override
  State<InsideElaboration> createState() => _InsideElaborationState();
}

class _InsideElaborationState extends State<InsideElaboration> {

  Branding br = Branding();
  String choose = 'SUMMARY';
  String uid = FirebaseAuth.instance.currentUser!.uid;

  GlobalKey<FormState> key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: br.white,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context, 
                builder: ((context) {
                  return DeleteSession(name: 'elaboration', doc: widget.doc);
                })
              );
            }, 
            icon: Icon(Icons.more_horiz, color: Colors.grey, size: 15,)
          )
        ],
              backgroundColor: br.white,
              iconTheme: IconThemeData(
                size: 20,
                color: Colors.grey
              ),
            )
          ], 
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Form(
              key: key,
              child: Column(
                children: [
              
                  ListTile(
                    title: Text(widget.doc['topic'].toString().toUpperCase(),
                    style: GoogleFonts.viga(
                      color: br.black
                    ),
                    ),
              
                    subtitle: Text(widget.doc['subject'].toString().toLowerCase(),
                    style: GoogleFonts.bricolageGrotesque(
                      color: Colors.grey[700],
                      fontSize: 14
                    ),
                    ),
                  ),
              
                  Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                  child: Row(
                    children: [
                  
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(choose == 'SUMMARY' ? Colors.blueAccent : br.white),
                              side: WidgetStatePropertyAll(BorderSide(
                                color: Colors.blueAccent,
                                width: 2
                              ))
                            ),
                            onPressed: () {
                              setState(() {
                                choose = 'SUMMARY';
                              });
                            }, 
                            child: Text('SUMMARY',
                            style: GoogleFonts.viga(
                              color: choose == 'SUMMARY' ? br.white : Colors.blueAccent,
                            ),
                            )
                          ),
                        ),
                      ),
                  
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(choose == 'ELABORATIONS' ? Colors.blueAccent : br.white),
                              side: WidgetStatePropertyAll(BorderSide(
                                color: Colors.blueAccent,
                                width: 2
                              ))
                            ),
                            onPressed: () {
                              setState(() {
                                choose = 'ELABORATIONS';
                              });
                            }, 
                            child: Text('ELABORATIONS',
                            style: GoogleFonts.viga(
                              color: choose == 'ELABORATIONS' ? br.white : Colors.blueAccent,
                            ),
                            )
                          ),
                        ),
                      ),
                  
                    ],
                  ),
                ),
              
                  
                  choose == 'SUMMARY' ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20),
                    child: TextFormField(
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      onChanged: (value) async {
                        await FirebaseFirestore.instance.collection('users').doc(uid).collection('elaboration').doc(widget.doc.id).update({
                          'summary':value
                        });
                      },
                      cursorColor: Colors.blueAccent,
                      initialValue: widget.doc['summary'],
                      decoration: InputDecoration(
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none
                      ),
                      style: GoogleFonts.bricolageGrotesque(
                        color: br.black,
                        fontSize: 14
                      ),
                    ),
                  ) : 
                  
                  Column(
                    children: [

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Row(
                          children: [
                            Expanded(child: Container()),
                        
                            IconButton(
                              onPressed: () async {
                              try {
                                 setState(() {
                                  widget.doc;
                                });
                                await FirebaseFirestore.instance.collection('users').doc(uid).collection('elaboration').doc(widget.doc.id).collection('list of elaborations').add({
                                  'title':'Add Title',
                                  'elaboration':'Type here...',
                                  'written':true,
                                  'date':DateTime.now()
                                });
                               
                              } catch (e) {
                                return br.snackbarMessage(context, 'Error. Unable to add elaboration.');
                              }
                              }, 
                              icon: Icon(Icons.add, color: Colors.blueAccent, size: 20,)
                            ),
                        
                            // IconButton(
                            //   onPressed: () {}, 
                            //   icon: Icon(Icons.mic, color: Colors.blueAccent, size: 20,)
                            // ),
                        
                            
                          ],
                        ),
                      ),


                      StreamBuilder(
                        stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('elaboration').doc(widget.doc.id).collection('list of elaborations').orderBy('date', descending: false).snapshots(), 
                        builder: ((context, snapshot) {
                      
                          if (snapshot.hasData) {
                            List<DocumentSnapshot> arrdata = snapshot.data!.docs;
                      
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: arrdata.length,   
                              itemBuilder: ((context, index) {
                                return ListTile(
                                  trailing: IconButton(
                                    onPressed: () async {
                                      await FirebaseFirestore.instance.collection('users').doc(uid).collection('elaboration').doc(widget.doc.id).collection('list of elaborations').doc(arrdata[index].id).delete();
                                    }, 
                                    icon: Icon(Icons.remove, size: 15,)
                                  ),
                                  title: TextFormField(
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      onChanged: (value) async {
                         await FirebaseFirestore.instance.collection('users').doc(uid).collection('elaboration').doc(widget.doc.id).collection('list of elaborations').doc(arrdata[index].id).update({
                          'title':value
                        });


                      },
                      cursorColor: Colors.blueAccent,
                      initialValue: arrdata[index]['title'],
                      decoration: InputDecoration(
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none
                      ),
                      style: GoogleFonts.bricolageGrotesque(
                        color: br.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w700
                      ),
                    ),


                    subtitle: TextFormField(
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      onChanged: (value) async {
                         await FirebaseFirestore.instance.collection('users').doc(uid).collection('elaboration').doc(widget.doc.id).collection('list of elaborations').doc(arrdata[index].id).update({
                          'elaboration':value
                        });
                      },
                      cursorColor: Colors.blueAccent,
                      initialValue: arrdata[index]['elaboration'],
                      decoration: InputDecoration(
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none
                      ),
                      style: GoogleFonts.bricolageGrotesque(
                        color: br.black,
                        fontSize: 14,
                        
                      ),
                    ),
                                );
                              })
                            );
                          }
                      
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator.adaptive();
                          }
                      
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Text('Unable to load elaborations.',
                            style: GoogleFonts.bricolageGrotesque(
                              color: Colors.grey[700],
                              fontSize: 12
                            ),
                            ),
                          );
                        })
                      ),
                    ],
                  )
                  
              
                ],
              ),
            ),
          )
        ),
      ),
    );
  }
}




class CreateElaboration extends StatefulWidget {
  const CreateElaboration({super.key});

  @override
  State<CreateElaboration> createState() => _CreateElaborationState();
}

class _CreateElaborationState extends State<CreateElaboration> {

  Branding br = Branding();
  TextEditingController topic = TextEditingController();
  TextEditingController notes = TextEditingController();
  PageController controller = PageController();

  //int audio = 0;

  List audio = [];

  String uid = FirebaseAuth.instance.currentUser!.uid;

  String chosenSubject = 'Other';
  String feel = 'Good';
  TextEditingController summary = TextEditingController();

  List elaborations = [];

  List elaborationControllers = [];

  final SpeechToText speechToText = SpeechToText();

  bool speechEnabled = false;
  double confidenceLevel = 0;
  bool isWorking = false;

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  // Initialize speech-to-text
  void initSpeech() async {
    speechEnabled = await speechToText.initialize();
    setState(() {});
  }

  void startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {
      isWorking = true;
    });
    setState(() {
      confidenceLevel = 0;
    });
  }

  // Stop listening to speech
  void stopListening() async {
    await speechToText.stop();
    setState(() {

    });

    setState(() {
      isWorking = false;
      elaborationControllers.last['elaboration'].text = elaborations.last['elaboration'];
    });
  }

  // Handle the speech result and update wordsSpoken
  void onSpeechResult(result) {
    setState(() {
      elaborations.last['elaboration'] = result.recognizedWords;  // Directly access recognized words
      confidenceLevel = result.confidence;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: br.white,
      bottomNavigationBar: BottomAppBar(
        color: br.white,
        elevation: 0,
        child: Row(
          children: [

            Expanded(
              child: IconButton(
                onPressed: () {
                  controller.previousPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
                }, 
                icon: Icon(Icons.arrow_back, color: br.black, size: 20,)
              )
            ),

            Expanded(
              child: IconButton(
                onPressed: () {
                  controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
                }, 
                icon: Icon(Icons.arrow_forward, color: br.black, size: 20,)
              )
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: br.white,
        iconTheme: IconThemeData(
          size: 20,
          color: Colors.grey
        ),
      ),

      body: PageView(
        controller: controller,
        children: [

          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                
                    ListTile(
                      title: Text('CHOOSE A PRECISE TOPIC',
                    style: GoogleFonts.viga(
                      fontSize: 16
                    ),
                    ),
                    ),
              
                    Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                 child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  style: TextStyle(
                    color: br.black
                  ),
                  obscureText: false,
                  onChanged: (value) async {
                   
              
                    QuerySnapshot feynman = await FirebaseFirestore.instance.collection('users').doc(uid).collection('elaboration').orderBy('date', descending: false).get();
              
                    await FirebaseFirestore.instance.collection('users').doc(uid).collection('elaboration').doc(feynman.docs.last.id).update({
                      'topic':value
                    });
              
                  },
                  cursorColor: Colors.amber,
                  controller: topic,
                  decoration: InputDecoration(
                    
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color.fromARGB(255, 159, 159, 159)),
                    ),
                 
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.amber,),
                    ),
                 
                    hintText: 'Type here...',
                    hintStyle: const TextStyle(
                      color: Color.fromARGB(255, 110, 110, 110),
                      fontSize: 13
                    )
                  ),
                 ),
               ),
                
                    
                  ],
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                ListTile(
                    title: Text('CHOOSE YOUR SUBJECT',
                  style: GoogleFonts.viga(
                    fontSize: 16
                  ),
                  ),
                  ),

                  Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: ListTile(
                    onTap: () async {
                      setState(() {
                        chosenSubject = 'Other';
                      });

                      QuerySnapshot feynman = await FirebaseFirestore.instance.collection('users').doc(uid).collection('elaboration').orderBy('date', descending: false).get();

                      await FirebaseFirestore.instance.collection('users').doc(uid).collection('elaboration').doc(feynman.docs.last.id).update({
                     'subject':chosenSubject
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: chosenSubject == 'Other' ? Colors.grey : Colors.transparent,
                        width: 2
                      )
                    ),
                    tileColor: Colors.grey[300],
                    title: Text('Other',
                    style: GoogleFonts.bricolageGrotesque(
                      color: br.black,
                      fontSize: 14
                    ),
                    ),
                    leading: Icon(Icons.circle, size: 15, color: Colors.grey,),
                  ),
                ),

                StreamBuilder(
            stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('subjects').snapshots(), 
            builder: ((context, snapshot) {

              if (snapshot.hasData) {

                List<DocumentSnapshot> arrdata = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: arrdata.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: ((context, index) {
                    return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
                  child: ListTile(
                    onTap: () async {
                      setState(() {
                        chosenSubject = arrdata[index]['name'];
                      });

                      QuerySnapshot feynman = await FirebaseFirestore.instance.collection('users').doc(uid).collection('elaboration').orderBy('date', descending: false).get();

                      await FirebaseFirestore.instance.collection('users').doc(uid).collection('elaboration').doc(feynman.docs.last.id).update({
                     'subject':chosenSubject
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: chosenSubject == arrdata[index]['name'] ? Colors.grey : Colors.transparent,
                        width: 2
                      )
                    ),
                    tileColor: Colors.grey[300],
                    title: Text(arrdata[index]['name'],
                    style: GoogleFonts.bricolageGrotesque(
                      color: br.black,
                      fontSize: 14
                    ),
                    ),

                    leading: Icon(Icons.circle, color: br.colors[arrdata[index]['color']], size: 15,),
                  ),
                );
                  })
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator.adaptive();
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text('Unable to load subjects.',
                style: TextStyle(
                  color: br.black
                ),
                ),
              );
            })
          ),
              ],
            ),
          ),
         
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  ListTile(
                      title: Text('WRITE DOWN A SUMMARY OF YOUR TOPIC HERE OR ON PAPER',
                    style: GoogleFonts.viga(
                      fontSize: 16
                    ),
                    ),
                    ),
            
            
                  ListTile(
                    title: TextField(
                      onChanged: (value) async {
                        QuerySnapshot feynman = await FirebaseFirestore.instance.collection('users').doc(uid).collection('elaboration').orderBy('date', descending: false).get();

                      await FirebaseFirestore.instance.collection('users').doc(uid).collection('elaboration').doc(feynman.docs.last.id).update({
                     'summary':value
                      });
                      },
                      cursorColor: Colors.amber,
                      controller: summary,
                      style: GoogleFonts.bricolageGrotesque(
                        color: br.black,
                        fontSize: 14
                      ),
                      decoration: InputDecoration(
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: 'Type here...',
                        hintStyle: GoogleFonts.bricolageGrotesque(
                          color: Colors.grey
                        )
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  ListTile(
                          title: Text('ELABORATE & ADD INFO TO DIFFERENT PARTS OF YOUR TOPIC',
                        style: GoogleFonts.viga(
                          fontSize: 16
                        ),
                        ),
                        ),
              
              
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
                    child: Row(
                      children: [
                    
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: TextButton.icon(
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(Colors.amber)
                              ),
                              onPressed: () {
                                setState(() {
                                  elaborationControllers.add({
                                    'title':TextEditingController(),
                                    'elaboration':TextEditingController()
                                  });
              
                                  elaborations.add({
                                    'title':elaborationControllers.last['title'],
                                    'elaboration':elaborationControllers.last['elaboration'],
                                    'written':true,
                                    'date':DateTime.now()
                                  });
              
              
                                });
              
                                
                              }, 
                              icon: Icon(Icons.edit, size: 15, color: br.white,),
                              label: Text('WRITE \nINFO',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.viga(
                                color: br.white,                  
                              ),
                              )
                            ),
                          ),
                        ),
                    
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: TextButton.icon(
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(Colors.deepPurple)
                              ),
                              onPressed: () {
                                setState(() {
                                   audio.add(1);
              
                                  elaborationControllers.add({
                                    'title':TextEditingController(),
                                    'elaboration':TextEditingController()
                                  });
              
                                  elaborations.add({
                                    'title':'Audio #${audio.length}',
                                    'elaboration':'',
                                    'written':false
                                  });
              
                                  elaborationControllers.last['elaboration'].text = '';
              
                                  startListening();
              
                                  
              
                                });
                              }, 
                              icon: Icon(Icons.mic, size: 15, color: br.white,),
                              label: Text('USE \nMICROPHONE',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.viga(
                                color: br.white,                  
                              ),
                              )
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
              
              
                  speechToText.isListening ? TextButton.icon(
                    onPressed: stopListening, 
                    icon: Icon(Icons.record_voice_over, color: Colors.red, size: 20,),
                    label: Text('stop recording',
                    style: GoogleFonts.bricolageGrotesque(
                      color: Colors.red
                    ),
                    )
                  ) : isWorking == true ? CircularProgressIndicator.adaptive() :
                  
                  Center(),
                
                
                ListView.builder(
                  itemCount: elaborations.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: ((context, index) {
              
                    return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
                                            child: ListTile(
                                              trailing: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    elaborationControllers.removeAt(index);
                                                    elaborations.removeAt(index);
                                                  });
                                                }, 
                                                icon: Icon(Icons.remove, color: Colors.grey[700], size: 15,)
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10)
                                              ),
                                              //tileColor: Colors.grey[300],
                                              title: TextField(
                                                onChanged: (value) {
                                                  setState(() {
                                                    elaborationControllers[index]['title'].text = value;
                                                  });
                                                },
                                                maxLines: null,
                                                keyboardType: TextInputType.multiline,
                                               controller: elaborationControllers[index]['title'],
                                                cursorColor: Colors.amber,                                          
                                                decoration: InputDecoration(
                                                  hintText: elaborations[index]['written'] == true ? 'What are you elaborating on?' : 'Audio #${audio.length}',
                                                  hintStyle: GoogleFonts.bricolageGrotesque(
                                                    color: Colors.grey
                                                  ),
                                                  enabledBorder: InputBorder.none,
                                                  focusedBorder: InputBorder.none
                                                ),
                                                style: GoogleFonts.bricolageGrotesque(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700
                                                ),
                                              ),
              
                                              subtitle: elaborations[index]['written'] == false && speechToText.isListening && elaborationControllers[index]['elaboration'].text.isEmpty ? Text('Listening...') : 
                                              TextFormField(
                                                //initialValue: elaborations[index]['elaboration'],
                                                maxLines: null,
                                                keyboardType: TextInputType.multiline,
                                                onChanged: (value) {
              
                                                  setState(() {
                                                    elaborationControllers[index]['elaboration'].text = value;
                                                  });
              
                                                  print(elaborationControllers[index]['elaboration'].text);
                                                },
                                                cursorColor: Colors.amber, 
                                                controller: elaborationControllers[index]['elaboration'],                    
                                                decoration: InputDecoration(
                                                  hintText: 'Elaboration...',
                                                  hintStyle: GoogleFonts.bricolageGrotesque(
                                                    color: Colors.grey
                                                  ),  
                                                  enabledBorder: InputBorder.none,
                                                  focusedBorder: InputBorder.none
                                                ),
                                                style: GoogleFonts.bricolageGrotesque(
                                                  fontSize: 14,
                                                  
                                                ),
                                              ),
                                            ),
                                          );
                  })
                )
                
                ],
              ),
            ),
          ),


          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              ListTile(
                title: Text('HOW DO YOU FEEL ABOUT YOUR UNDERSTANDING OF THIS TOPIC?',
                style: GoogleFonts.viga(
                  color: br.black
                ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
                child: GridView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: GestureDetector(
                        onTap: () async {
                          setState(() {
                            feel = 'Good';
                          });

                          QuerySnapshot feynman = await FirebaseFirestore.instance.collection('users').doc(uid).collection('elaboration').orderBy('date', descending: false).get();

                          await FirebaseFirestore.instance.collection('users').doc(uid).collection('elaboration').doc(feynman.docs.last.id).update({
                          'feel':feel
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: feel == 'Good' ? Colors.grey : Colors.transparent
                            ),
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10)
                          ),
                        
                          child: Center(child: Icon(Icons.thumb_up, color: Colors.green[600], size: 40,)),
                        ),
                      ),
                    ),
                
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: GestureDetector(
                        onTap: () async {
                           setState(() {
                            feel = 'Not sure';
                          });

                          QuerySnapshot feynman = await FirebaseFirestore.instance.collection('users').doc(uid).collection('elaboration').orderBy('date', descending: false).get();

                          await FirebaseFirestore.instance.collection('users').doc(uid).collection('elaboration').doc(feynman.docs.last.id).update({
                          'feel':feel
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: feel == 'Not sure' ? Colors.grey : Colors.transparent
                            ),
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10)
                          ),
                        
                          child: Center(child: Icon(Icons.question_mark, color: Colors.grey[600], size: 40,)),
                        ),
                      ),
                    ),
                
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: GestureDetector(
                        onTap: () async {
                           setState(() {
                            feel = 'Bad';
                          });

                          QuerySnapshot feynman = await FirebaseFirestore.instance.collection('users').doc(uid).collection('elaboration').orderBy('date', descending: false).get();

                          await FirebaseFirestore.instance.collection('users').doc(uid).collection('elaboration').doc(feynman.docs.last.id).update({
                          'feel':feel
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: feel == 'Bad' ? Colors.grey : Colors.transparent
                            ),
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10)
                          ),
                        
                          child: Center(child: Icon(Icons.thumb_down, color: Colors.red[600], size: 40,)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.amber)
                    ),
                    icon: Icon(Icons.emoji_objects, color: br.white, size: 20,),
                    onPressed: () async {

                      br.progress(context);

                      QuerySnapshot feynman = await FirebaseFirestore.instance.collection('users').doc(uid).collection('elaboration').orderBy('date', descending: false).get();

                      for (int i = 0; i < elaborations.length; i++) {
                        await FirebaseFirestore.instance.collection('users').doc(uid).collection('elaboration').doc(feynman.docs.last.id).collection('list of elaborations').add({
                          'elaboration':elaborations[i]['elaboration'].text,
                          'title':elaborations[i]['title'].text,
                          'date':DateTime.now()
                        });
                      }

                      Navigator.pop(context);
                      Navigator.pop(context);

                      return br.showMessage(context, 'Elaborations added.');
                    }, 
                    label: Text('COMPLETE',
                    style: GoogleFonts.viga(
                      color: br.white
                    ),
                    )
                  ),
                ),
              ),
            
            ],
          ),
        
        ],
      ),
    );
  }
}