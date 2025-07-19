import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:studystudio/branding.dart';
import 'package:studystudio/home_page.dart';

class MySpeechToText extends StatefulWidget {
  const MySpeechToText({super.key});

  @override
  State<MySpeechToText> createState() => _MySpeechToTextState();
}

class _MySpeechToTextState extends State<MySpeechToText> {
  Branding br = Branding();

  final SpeechToText speechToText = SpeechToText();

  bool speechEnabled = false;
  String wordsSpoken = "";
  double confidenceLevel = 0;

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

  // Start listening to speech
  void startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {
      confidenceLevel = 0;
    });
  }

  // Stop listening to speech
  void stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  // Handle the speech result and update wordsSpoken
  void onSpeechResult(result) {
    setState(() {
      wordsSpoken = result.recognizedWords;  // Directly access recognized words
      confidenceLevel = result.confidence;
    });
  }

  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: br.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[200],
        elevation: 3,
        onPressed:
            // If not yet listening for speech start, otherwise stop
            speechToText.isNotListening ? startListening : stopListening,
        tooltip: 'Listen',
        child: Icon(speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      ),
      body: Column(
        children: [

          ListTile(
                    title: Text('EXPLAIN YOUR TOPIC SIMPLY & DIVIDE IT INTO PARTS. SAVE YOUR EXPLANATION EACH TIME.',
                  style: GoogleFonts.viga(
                    fontSize: 15
                  ),
                  ),
                  ),


          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Text(
              // If listening is active show the recognized words
              speechToText.isListening
                  ? 'Listening'
                  // If listening isn't active but could be tell the user
                  // how to start it, otherwise indicate that speech
                  // recognition is not yet ready or not supported on
                  // the target device
                  : speechEnabled
                      ? 'Tap the microphone to turn your explanation to text...'
                      : 'Speech not available',
            ),
          ),

         
          
            wordsSpoken.isNotEmpty ? TextButton.icon(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.grey[300])
            ),
            icon: Icon(Icons.done, color: Colors.green[600], size: 20,),
            onPressed: () async {
              QuerySnapshot feynman = await FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').orderBy('date', descending: false).get();

              if (wordsSpoken.isNotEmpty) {
                await FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').doc(feynman.docs.last.id).collection('explanations').add({
                        'date':DateTime.now(),
                        'explanation':wordsSpoken
                      });

              br.snackbarMessage(context, 'Explanation saved.');
              }                    
                     
                      
            }, 
            label: Text('SAVE EXPLANATION',
            style: GoogleFonts.viga(
              color: br.black
            ),
            )
          ) : Center(),

          SizedBox(
            height: 15,
          ),
          
         
          //Display the spoken words in real-time
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Text(wordsSpoken,
                style: TextStyle(
                  fontSize: 21,
                ),
                )
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class Feynman extends StatefulWidget {
  const Feynman({super.key});

  @override
  State<Feynman> createState() => _FeynmanState();
}

class _FeynmanState extends State<Feynman> {

  Branding br = Branding();
  String uid = FirebaseAuth.instance.currentUser!.uid;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.grey[200],
        elevation: 2,
        onPressed: () async {
          br.progress(context);

          QuerySnapshot col = await FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').get();

          if (isPro == true || col.docs.length < 2) {
                                   

          await FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').add({
            'date':DateTime.now(),
            'topic':'',
            'subject':'Other',
            'notes':'',
            'feel':'Not sure'
          });

          Navigator.pop(context);

          Navigator.push(context, MaterialPageRoute(builder: (context) => NewFeynman()));
                              } else {
                                
                                Navigator.pop(context);
                                 await RevenueCatUI.presentPaywallIfNeeded('Study Turbo');
                                //log('Paywall results: $paywalResult');
                              }

         
        }, 
        label: Text('study session',
        style: GoogleFonts.bricolageGrotesque(
          color: br.black
        ),
        ),
        icon: Icon(Icons.add, size: 20, color: br.black,),
      ),
      backgroundColor: br.white,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [

            ListTile(
                title: Text('FEYNMAN TECHNIQUE',
                style: GoogleFonts.viga(
                  color: br.black
                ),
              ),
              subtitle: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text('Choose your topic, write down everything you know about it, fill in the gaps of your knowledge then explain it as if you were to do it to a child.',
                  style: GoogleFonts.bricolageGrotesque(
                    color: br.black,
                    fontSize: 13
                  ),
                  ),
                ),
            ),

            //TheSubjects(),

            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').orderBy('date', descending: false).snapshots(), 
              builder: ((context, snapshot) {

                if (snapshot.hasData) {
                  List<DocumentSnapshot> arrdata = snapshot.data!.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: arrdata.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: ((context, index) {

                      Timestamp timestamp = arrdata[index]['date'];
                      DateTime date = timestamp.toDate();

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => InsideFeynman(doc: arrdata[index])));
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                          ),
                          tileColor: Colors.grey[300],
                          title: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Text(arrdata[index]['topic'],
                            style: GoogleFonts.bricolageGrotesque(),
                            ),
                          ),

                          subtitle: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Text(arrdata[index]['subject'],
                            style: GoogleFonts.bricolageGrotesque(),
                            ),
                          ),

                          trailing: Text('${date.day}/${date.month}/${date.year}',
                          style: TextStyle(
                            color: Colors.blueGrey
                          ),
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
                  child: Text('Unable to load study sessions.'),
                );
              })
            )



          ],
        ),
      ),
    );
  }
}


class NewFeynman extends StatefulWidget {
  const NewFeynman({super.key});

  @override
  State<NewFeynman> createState() => _NewFeynmanState();
}

class _NewFeynmanState extends State<NewFeynman> {

  Branding br = Branding();
  TextEditingController topic = TextEditingController();
  TextEditingController notes = TextEditingController();
  PageController controller = PageController();

  String uid = FirebaseAuth.instance.currentUser!.uid;

  String chosenSubject = 'Other';
  String feel = 'Good';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: br.white,
        child: Row(
          children: [

            Expanded(
              child: IconButton(
                onPressed: () {
                  controller.previousPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
                }, 
                icon: Icon(Icons.arrow_back, color: br.black, size: 25,)            
              )
            ),

            Expanded(
              child: IconButton(
                onPressed: () {
                  controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
                }, 
                icon: Icon(Icons.arrow_forward, color: br.black, size: 25,)            
              )
            )
          ],
        ),
      ),
      backgroundColor: br.white,
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
                    setState(() {
                      value = topic.text;
                    });
              
                    QuerySnapshot feynman = await FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').orderBy('date', descending: false).get();
              
                    await FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').doc(feynman.docs.last.id).update({
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

                      QuerySnapshot feynman = await FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').orderBy('date', descending: false).get();

                      await FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').doc(feynman.docs.last.id).update({
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

                      QuerySnapshot feynman = await FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').orderBy('date', descending: false).get();

                      await FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').doc(feynman.docs.last.id).update({
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
                      title: Text('WRITE DOWN WHAT YOU KNOW & USE LEARNING RESOURCES TO GRADUALLY FILL IN THE GAPS WHICH YOU MISSED',
                    style: GoogleFonts.viga(
                      fontSize: 14
                    ),
                    ),
                    ),
            
                  Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                              
                          child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                          child: TextField(
                            onChanged: (value) async {
            
                             setState(() {
                               value = notes.text;
                             });

                             QuerySnapshot feynman = await FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').orderBy('date', descending: false).get();

                      await FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').doc(feynman.docs.last.id).update({
                     'notes':value
                      });
                            },
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            controller: notes,
                            decoration: InputDecoration(
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hintText: 'Notes (preferably on a paper)...',
                              hintStyle: TextStyle(
                                color: Colors.grey
                              )
                            ),
                          ),
                                            ),
                                            ),


                   
                ],
              ),
            ),
          ),


          MySpeechToText(),


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

                          QuerySnapshot feynman = await FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').orderBy('date', descending: false).get();

                          await FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').doc(feynman.docs.last.id).update({
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

                          QuerySnapshot feynman = await FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').orderBy('date', descending: false).get();

                          await FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').doc(feynman.docs.last.id).update({
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

                          QuerySnapshot feynman = await FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').orderBy('date', descending: false).get();

                          await FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').doc(feynman.docs.last.id).update({
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
                    onPressed: () {
                      Navigator.pop(context);
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
      )
    );
  }
}



class InsideFeynman extends StatefulWidget {
  final DocumentSnapshot doc;
  const InsideFeynman({super.key,
  required this.doc
  });

  @override
  State<InsideFeynman> createState() => _InsideFeynmanState();
}

class _InsideFeynmanState extends State<InsideFeynman> {

  String wordsSpoken = '';
   final SpeechToText speechToText = SpeechToText();

  bool speechEnabled = false;

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

  // Start listening to speech
  void startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    
  }

  // Stop listening to speech
  void stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  // Handle the speech result and update wordsSpoken
  void onSpeechResult(result) {
    setState(() {
      wordsSpoken = result.recognizedWords;  // Directly access recognized words
    });
  }

  Branding br = Branding();

  String choose = 'NOTES';

  String uid = FirebaseAuth.instance.currentUser!.uid;

  GlobalKey<FormState> key = GlobalKey();

  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: br.white,
      appBar: AppBar(

        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context, 
                builder: ((context) {
                  return DeleteSession(name: 'feynman technique', doc: widget.doc);
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
      ),
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
                  color: Colors.grey[700]
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
                            backgroundColor: WidgetStatePropertyAll(choose == 'NOTES' ? Colors.deepPurple : br.white),
                            side: WidgetStatePropertyAll(BorderSide(
                              color: Colors.deepPurple,
                              width: 2
                            ))
                          ),
                          onPressed: () {
                            setState(() {
                              choose = 'NOTES';
                            });
                          }, 
                          child: Text('NOTES',
                          style: GoogleFonts.viga(
                            color: choose == 'NOTES' ? br.white : Colors.deepPurple,
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
                            backgroundColor: WidgetStatePropertyAll(choose == 'EXPLANATIONS' ? Colors.deepPurple : br.white),
                            side: WidgetStatePropertyAll(BorderSide(
                              color: Colors.deepPurple,
                              width: 2
                            ))
                          ),
                          onPressed: () {
                            setState(() {
                              choose = 'EXPLANATIONS';
                            });
                          }, 
                          child: Text('EXPLANATIONS',
                          style: GoogleFonts.viga(
                            color: choose == 'EXPLANATIONS' ? br.white : Colors.deepPurple,
                          ),
                          )
                        ),
                      ),
                    ),
                
                  ],
                ),
              ),
          
            
            
              choose == 'NOTES' ? 
              
              Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                            child: TextFormField(
                              onChanged: (value) async {
              
                              
          
                               //QuerySnapshot feynman = await FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').orderBy('date', descending: false).get();
          
                        await FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').doc(widget.doc.id).update({
                       'notes':value
                        });
                              },
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              initialValue: widget.doc['notes'],
                              decoration: InputDecoration(
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                hintText: 'Type here...',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14
                                ),
                                
                              ),
                              style: GoogleFonts.bricolageGrotesque(
                                color: br.black,
                                fontSize: 14
                              ),
                            ),
                                              )
              
              : 
              
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Column(
                  children: [

                    Row(
                      children: [

                        SizedBox(
                          width: 10,
                        ),
                        wordsSpoken.isNotEmpty ? TextButton.icon(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.grey[300])
            ),
            icon: Icon(Icons.done, color: Colors.green[600], size: 20,),
            onPressed: () async {
              QuerySnapshot feynman = await FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').orderBy('date', descending: false).get();

              if (wordsSpoken.isNotEmpty) {
                await FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').doc(feynman.docs.last.id).collection('explanations').add({
                        'date':DateTime.now(),
                        'explanation':wordsSpoken
                      });

                      setState(() {
                        wordsSpoken = '';
                      });

              br.snackbarMessage(context, 'Explanation saved.');
              }                    
                     
                      
            }, 
            label: Text('SAVE EXPLANATION',
            style: GoogleFonts.viga(
              color: br.black
            ),
            )
          ) : TextButton.icon(
                          onPressed: startListening, 
                          icon: Icon(Icons.mic, color: Colors.deepPurple, size: 20,),
                          label: Text('add explanation',
                          style: GoogleFonts.bricolageGrotesque(color: Colors.deepPurple),
                          )
                        )
                      ],
                    ),

                    speechToText.isListening ? 
                    TextButton.icon(
                      onPressed: stopListening, 
                      icon: Icon(Icons.mic_external_off,color: Colors.red, size: 20,),
                      label: Text('stop recording',
                      style: GoogleFonts.bricolageGrotesque(
                        color: Colors.red,
                        fontSize: 20
                      ),
                      )
                    ) 
                    : Center(),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
                      child: Text(wordsSpoken,
                      style: TextStyle(
                        fontSize: 21,
                      ),
                      )
                    ),


                    StreamBuilder(
                      stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').doc(widget.doc.id).collection('explanations').orderBy('date', descending: true).snapshots(), 
                      builder: ((context, snapshot) {
                    
                        if (snapshot.hasData) {
                    
                          List<DocumentSnapshot> arrdata = snapshot.data!.docs;
                    
                          return ListView.builder(
                            itemCount: arrdata.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: ((context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                                child: ListTile(
                                  trailing: IconButton(
                                        onPressed: () async {
                                          await FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').doc(widget.doc.id).collection('explanations').doc(arrdata[index].id).delete();
                                        }, 
                                        icon: Icon(Icons.remove, size: 15,)
                                      ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)
                                  ),
                                  tileColor: Colors.grey[300],
                                  title: TextFormField(
                                    initialValue: arrdata[index]['explanation'],
                                    onChanged: (value) async {
                                          
                                
                                await FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').doc(widget.doc.id).collection('explanations').doc(arrdata[index].id).update({
                                                     'explanation':value
                                });
                                      },
                                      maxLines: null,
                                      keyboardType: TextInputType.multiline,
                                      
                                      decoration: InputDecoration(
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                       
                                       
                                      ),
                                
                                      style: GoogleFonts.bricolageGrotesque(
                                        color: br.black,
                                        fontSize: 14
                                      ),
                                  )
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
                          child: Text('Unable to load explanations.',
                          style: GoogleFonts.bricolageGrotesque(
                            color: Colors.grey[700],
                            fontSize: 13
                          ),
                          ),
                        );
                      })
                    ),
                  ],
                ),
              )     
              
              
            
            ],
          ),
        ),
      ),
    );
  }
}


