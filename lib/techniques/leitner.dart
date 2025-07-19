import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:studystudio/branding.dart';
import 'package:studystudio/home_page.dart';
import 'package:studystudio/techniques/spaced.dart';

class Leitner extends StatefulWidget {
  const Leitner({super.key});

  @override
  State<Leitner> createState() => _LeitnerState();
}

class _LeitnerState extends State<Leitner> {

  Branding br = Branding();
  String uid = FirebaseAuth.instance.currentUser!.uid;

  String cards = 'MY FLASHCARDS';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        elevation: 2,
        backgroundColor: const Color.fromARGB(255, 234, 234, 234),
        onPressed: () async {

         

          QuerySnapshot l = await FirebaseFirestore.instance.collection('users').doc(uid).collection('leitner flashcards').get();

          if (isPro == true || l.docs.length < 2) {
                                  

         Navigator.push(context, MaterialPageRoute(builder: (context) => CreateLeitner()));
                              } else {
                                
                                await RevenueCatUI.presentPaywallIfNeeded('Study Turbo');
                                
                              }

         
        }, 
        icon: Icon(Icons.add, color: br.black, size: 20,),
        label: Text('study session',
        style: GoogleFonts.bricolageGrotesque(
          color: br.black
        ),
        )
      ),
      backgroundColor: br.white,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [

            ListTile(
              title: Text('LEITNER',
              style: GoogleFonts.viga(
                color: br.black
              ),
              ),

              subtitle: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text('Write questions and answers on flashcards, then run the simulation while answering on paper. Gradually increase the difficulty.',
                style: GoogleFonts.bricolageGrotesque(
                  color: br.black,
                  fontSize: 13
                ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.grey[300]),
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                            side: BorderSide(
                              color: cards == 'MY FLASHCARDS' ? Colors.grey : Colors.transparent,
                              width: 2
                            )
                          ))
                        ),
                        onPressed: () {
                          setState(() {
                            cards = 'MY FLASHCARDS';
                          });
                        }, 
                        child: Text('MY FLASHCARDS',
                        style: GoogleFonts.viga(
                          color: br.black
                        ),
                        )
                      ),
                    )
                  ),
              
              
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.grey[300]),
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                            side: BorderSide(
                              color: cards == 'WORLDWIDE' ? Colors.grey : Colors.transparent,
                              width: 2
                            )
                          ))
                        ),
                        onPressed: () async {

                          if (isPro) {
                             setState(() {
                            cards = 'WORLDWIDE';
                          });
                          } else {
                            await RevenueCatUI.presentPaywallIfNeeded('Study Turbo');
                          }
                         
                        }, 
                        child: Text('WORLDWIDE',
                        style: GoogleFonts.viga(
                          color: br.black
                        ),
                        )
                      ),
                    )
                  ),
                ],
              ),
            ),

            
            cards == 'MY FLASHCARDS' ? StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('leitner flashcards').snapshots(), 
              builder: ((context, snapshot) {

                if (snapshot.hasData) {
                  List<DocumentSnapshot> arrdata = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: arrdata.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: ((context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 7),
                        child: ListTile(
                          trailing: IconButton(
                            onPressed: () {
                              showDialog(
                                
                                context: context, 
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: br.white,
                                    title: Icon(Icons.send_rounded, color: Colors.blueAccent,),
                                    content: Text('WOULD YOU LIKE TO SHARE YOUR FLASHCARDS WITH USERS WORLDWIDE?',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.viga(
                                      color: br.black,
                                      fontSize: 14
                                    ),
                                    ),

                                    actionsAlignment: MainAxisAlignment.center,
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        }, 
                                        child: Text('Cancel',
                                        style: GoogleFonts.bricolageGrotesque(
                                          color: Colors.grey,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700
                                        ),
                                        )
                                      ),

                                      TextButton(
                                        onPressed: () async {

                                         QuerySnapshot col = await FirebaseFirestore.instance.collection('users').doc(uid).collection('leitner flashcards').doc(arrdata[index].id).collection('cards').get();
QuerySnapshot col2 = await FirebaseFirestore.instance.collection('worldwide flashcards').doc(arrdata[index].id).collection('cards').get();

br.progress(context); // Show progress indicator

try {
   
   await FirebaseFirestore.instance.collection('worldwide flashcards').doc(arrdata[index].id).set({
    'color':arrdata[index]['color'],
    'creator':arrdata[index]['creator'],
    'date':DateTime.now(),
    'name':arrdata[index]['name'],
    'subject':arrdata[index]['subject']

   });

  // Only add new cards if col2 has fewer cards than col
  if (col2.docs.length < col.docs.length) {
    for (int i = col2.docs.length; i < col.docs.length; i++) {
      await FirebaseFirestore.instance.collection('worldwide flashcards').doc(arrdata[index].id).collection('cards').add({
        'answer': col.docs[i]['answer'],
        'question': col.docs[i]['question'],
      });
    }
  }

  Navigator.pop(context); // Close progress indicator
  Navigator.pop(context); // Go back in navigation stack

  if (isPro) {
    setState(() {
    cards = 'WORLDWIDE'; // Update UI state
  });
  }
  

  return br.snackbarMessage(context, 'Thank you for sharing your flashcards!');
} catch (e) {
  Navigator.pop(context); // Close progress indicator on error
  Navigator.pop(context); // Go back in navigation stack
  return br.snackbarMessage(context, 'Something went wrong. Could not share flashcards.');
}

                                        }, 
                                        child: Text("Yes, let's do it!",
                                        style: GoogleFonts.bricolageGrotesque(
                                          color: Colors.blueAccent,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700
                                        ),
                                        )
                                      ),

                                    ],
                                  );
                                }
                              );
                            }, 
                            icon: Icon(Icons.more_horiz, color: Colors.grey[500], size: 15,)
                          ),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => InsideFlashcards(
                              doc: arrdata[index],
                              index: index,
                            )));
                          },
                          tileColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            
                          ),

                          title: Text(arrdata[index]['name'],
                           style: GoogleFonts.viga(
                            color: br.black,
                            fontSize: 15
                          ),
                          ),

                          subtitle: Text(arrdata[index]['subject'],
                           style: GoogleFonts.bricolageGrotesque(
                            color: br.black,
                            fontSize: 12
                          ),
                          ),

                          leading: Icon(Icons.circle, size: 20, color: br.colors[arrdata[index]['color']],),
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
                  child: Text('No flashcards yet. Create your first pack!',
                  style: GoogleFonts.bricolageGrotesque(
                    color: Colors.red
                  ),
                  ),
                );
              })
            ) : 
            
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('worldwide flashcards').snapshots(), 
              builder: ((context, snapshot) {

                if (snapshot.hasData) {

                  List<DocumentSnapshot> arrdata = snapshot.data!.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: arrdata.length,
                    itemBuilder: ((context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => InsideWorldwideFlashcards(doc: arrdata[index], index: index)));
                          },
                          title: Text(arrdata[index]['name'],
                          style: GoogleFonts.viga(
                            color: br.black,
                            fontSize: 15
                          ),
                          ),
                          subtitle: Text(arrdata[index]['subject'],
                          style: GoogleFonts.bricolageGrotesque(
                            color: br.black,
                            fontSize: 13
                          ),
                          ),
                          trailing: Icon(Icons.keyboard_arrow_right, color: Colors.grey, size: 15,),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: Colors.grey
                            )
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
                  child: Text('Unable to load flashcards.',
                  style: GoogleFonts.bricolageGrotesque(
                    color: Colors.grey[700],
                    fontSize: 13
                  ),
                  ),
                );
              })
            )


      
          ],
        ),
      )
    );
  }
}


class CreateLeitner extends StatefulWidget {
  const CreateLeitner({super.key});

  @override
  State<CreateLeitner> createState() => _CreateLeitnerState();
}

class _CreateLeitnerState extends State<CreateLeitner> {

  Branding br = Branding();
  String uid = FirebaseAuth.instance.currentUser!.uid;

  String pickedSubject = 'None';
  PageController pageController = PageController();

  List<TextEditingController> questions = [
    TextEditingController(),
    TextEditingController(), //1
  ];

  List<TextEditingController> answers = [
    TextEditingController(),
    TextEditingController(), //1
  ];

  List<DateTime> dateTime = [
    DateTime.now(),
    DateTime.now(),
  ];

  List questionStrings = [];

  // Initially selected random color
  Color? _containerColor;

  // Function to get a random color from the list
  Color? getRandomColor() {
    final random = Random();
    return br.colors[random.nextInt(br.colors.length)];
  }

  @override
  void initState() {
    super.initState();
    // Set an initial random color
    _containerColor = getRandomColor();
  }

  // Function to change the color
  void changeColor() {
    setState(() {
      _containerColor = getRandomColor();
    });
  }

  TextEditingController topic = TextEditingController();
  String chosenSubject = 'Other';

 


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: br.white,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Row(
            children: [
              Expanded(child: IconButton(
                onPressed: () {
                  pageController.previousPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
                }, 
                icon: Icon(Icons.arrow_back))),
          
              Expanded(child: IconButton(
                onPressed: () {
                  pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
                }, 
                icon: Icon(Icons.arrow_forward))),
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
          physics: NeverScrollableScrollPhysics(),
          controller: pageController,
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
                      title: Text('CHOOSE A TOPIC',
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




            SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
            
                    TextButton.icon(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.grey[300]),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        ))
                      ),
                      icon: Icon(Icons.done, size: 20, color: Colors.green[600],),
                      onPressed: () async {
                        br.progress(context);

                        try {
                           for (int i = 0; i < questions.length; i++) {

                          if (questions[i].text.isNotEmpty) {
                             questionStrings.add({
                            'questions':questions[i].text,
                            'date':dateTime[i],
                            'answers':answers[i].text
                          });
                          }
                         
                        }

                        if (questionStrings.length <= 1) {
                          Navigator.pop(context);
                          return br.showMessage(context, 'You need at least 2 flashcards to proceed.');
                        } else {

                        
      
                        await FirebaseFirestore.instance.collection('users').doc(uid).collection('leitner flashcards').add({
                          'subject':chosenSubject,
                          'date':DateTime.now(),
                          'name':topic.text,
                          'color':0,
                          'creator':uid
                        });

                        QuerySnapshot col = await FirebaseFirestore.instance.collection('users').doc(uid).collection('leitner flashcards').orderBy('date', descending: false).get();

                        for (int i = 0; i < questionStrings.length; i++) {
                          await FirebaseFirestore.instance.collection('users').doc(uid).collection('leitner flashcards').doc(col.docs.last.id).collection('cards').add({
                            'question':questionStrings[i]['questions'],
                            'answer':questionStrings[i]['answers']
                          });
                        }

                        

                        print(questionStrings);
      
                        Navigator.pop(context);
                        Navigator.pop(context);
      
                        br.snackbarMessage(context, 'New flashcards added.');

                        }
                        } catch (e) {
                          Navigator.pop(context);
                          br.showMessage(context, 'Something went wrong. Please try again.');
                        }

                        
      
                       

                        
                      }, 
                      label: Text('SAVE & COMPLETE',
                      style: GoogleFonts.viga(
                        color: br.black
                      ),
                      )
                    ), 
      
                    SizedBox(
                height: 500,
                width: double.infinity,
                child: CardSwiper(
                  onSwipe: (previousIndex, currentIndex, direction) {

                    _containerColor = getRandomColor();

                    setState(() {
                      questions.add(TextEditingController());
                    answers.add(TextEditingController());
                    dateTime.add(DateTime.now());
      
                    print(questions.length);
                    });
      
                    
                    
                    return true;
                  },
                  
                          cardsCount: questions.length,
                          cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
      
                return Card(
                  color: _containerColor,
                  child: Center(
                    child: Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                 child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      style: TextStyle(
                        color: br.black
                      ),
                      obscureText: false,
                      cursorColor: Colors.grey,
                      controller: questions[index],
                      
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: br.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.transparent)
                        ),
                     
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.transparent)
                        ),
                                   
                     
                        hintText: 'Type the question...',
                        hintStyle: const TextStyle(
                          color: Color.fromARGB(255, 110, 110, 110),
                          fontSize: 13
                        )
                      ),
                     ),
      
                     SizedBox(
                      height: 10,
                     ),
      
                     TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      style: TextStyle(
                        color: br.black
                      ),
                      obscureText: false,
                      cursorColor: Colors.grey,
                      controller: answers[index],
                      
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: br.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.transparent)
                        ),
                     
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.transparent)
                        ),
                                   
                     
                        hintText: 'Type the answer...',
                        hintStyle: const TextStyle(
                          color: Color.fromARGB(255, 110, 110, 110),
                          fontSize: 13
                        )
                      ),
                     ),
                   ],
                 ),
               )
                  ),
                );
                          },
                        ),
              ),
            
                  ],
                ),
              )
            
          
          
          ],
        ),
      ),
    );
  }
}


class InsideFlashcards extends StatefulWidget {
  final DocumentSnapshot doc;
  final int index;
  const InsideFlashcards({super.key,
  required this.doc,
  required this.index
  });

  @override
  State<InsideFlashcards> createState() => _InsideFlashcardsState();
}

class _InsideFlashcardsState extends State<InsideFlashcards> {

  Branding br = Branding();

  // Initially selected random color
  Color? _containerColor;

  // Function to get a random color from the list
  Color? getRandomColor() {
    final random = Random();
    return br.colors[random.nextInt(br.colors.length)];
  }

  @override
  void initState() {
    super.initState();
    // Set an initial random color
    _containerColor = getRandomColor();
  }

  // Function to change the color
  void changeColor() {
    setState(() {
      _containerColor = getRandomColor();
    });
  }

  int index = 1;
 

  String string = 'QUESTIONS';
  CollectionReference col = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('leitner flashcards');


  @override
  Widget build(BuildContext context) {

    
    //DocumentReference doc = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('leitner flashcards').doc(widget.doc.id);

    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: br.white,
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.grey[300]),
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: BorderSide(
                      color: string == 'QUESTIONS' ? Colors.grey : Colors.transparent,
                      width: 2
                    )
                  ))
                ),
              onPressed: () {
                setState(() {
                  string = 'QUESTIONS';
                });
              }, 
              child: Text('QUESTIONS',
              style: GoogleFonts.viga(
                color: br.black
              ),
              ))),

              SizedBox(
                width: 10,
              ),

              Expanded(
              child: TextButton(
               
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.grey[300]),
                   shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: BorderSide(
                      color: string == 'ANSWERS' ? Colors.grey : Colors.transparent,
                      width: 2
                    )
                  )),
                ),
              onPressed: () {
                setState(() {
                  string = 'ANSWERS';
                });
              }, 
              child: Text('ANSWERS',
              style: GoogleFonts.viga(
                color: br.black
              ),
              )))
          ],
        ),
      ),
      backgroundColor: br.white,
      appBar: AppBar(
        actions: [

          IconButton(
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: br.white,
                context: context, 
                builder: ((context) {
                  return AddingFlashcards(
                    doc: widget.doc,
                    col: 'leitner flashcards',
                    col2: 'cards',
                  );
                })
              );
            }, 
            icon: Icon(Icons.add, color: br.black, size: 20,)
          ),


          IconButton(
            onPressed: () {
              showDialog(
                context: context, 
                builder: ((context) {
                  return DeleteSession(name: 'leitner flashcards', doc: widget.doc);
                })
              );
            }, 
            icon: Icon(Icons.more_horiz, color: Colors.grey, size: 15,)
          ),

          
        ],
        centerTitle: true,
        title: Text("$index",
        style: GoogleFonts.viga(
          color: br.black
        ),
        ),
        backgroundColor: br.white,
        iconTheme: IconThemeData(
          size: 20,
          color: Colors.grey
        ),
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('leitner flashcards').doc(widget.doc.id).collection('cards').snapshots(),
        builder: (context, snapshot) {

          if (snapshot.hasData) {

            List<DocumentSnapshot> arrdata = snapshot.data!.docs;

            return arrdata.length >= 2 ? CardSwiper(
                    onSwipe: (previousIndex, currentIndex, direction) {
                      _containerColor = getRandomColor();
                      setState(() {
                        index = currentIndex! + 1;
                      });
                      
                      
                      return true;
                    },
                    
                            cardsCount: arrdata.length,
                            cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
          
                  return GestureDetector(
                    onDoubleTap: () async {
                       await col.doc(widget.doc.id).collection('cards').doc(arrdata[index].id).delete();
                                              return br.snackbarMessage(context, 'Flashcard deleted.');
                    },
                    child: Card(
                      color: _containerColor,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: br.white,
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 30.0,horizontal: 30),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: string == 'QUESTIONS' ? Text(arrdata[index]['question'].toString().toUpperCase(),
                                                                    textAlign: TextAlign.center,
                                                                    style: GoogleFonts.viga(
                                                                      color: br.black
                                                                    ),
                                                                    ) : Text(arrdata[index]['answer'],
                                                                    textAlign: TextAlign.center,
                                                                    style: GoogleFonts.viga(
                                                                      color: br.black
                                                                    ),
                                                                    )
                              ),
                            )),
                        )
                      ),
                    ),
                  );
                            },
                          ) : Center(child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text('You need at least 2 flashcards in your set. Add more to access them.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.bricolageGrotesque(
                              color: br.black
                            ),
                            ),
                          ));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator.adaptive();
          }

          return Text('Unable to load flashcards.');
          
        }
      ),
    );
  }
}



class InsideWorldwideFlashcards extends StatefulWidget {
  final DocumentSnapshot doc;
  final int index;
  const InsideWorldwideFlashcards({super.key,
  required this.doc,
  required this.index
  });

  @override
  State<InsideWorldwideFlashcards> createState() => _InsideWorldwideFlashcardsState();
}

class _InsideWorldwideFlashcardsState extends State<InsideWorldwideFlashcards> {

  Branding br = Branding();

  // Initially selected random color
  Color? _containerColor;

  // Function to get a random color from the list
  Color? getRandomColor() {
    final random = Random();
    return br.colors[random.nextInt(br.colors.length)];
  }

  @override
  void initState() {
    super.initState();
    // Set an initial random color
    _containerColor = getRandomColor();
  }

  // Function to change the color
  void changeColor() {
    setState(() {
      _containerColor = getRandomColor();
    });
  }

  int index = 1;
  GlobalKey<FormState> key = GlobalKey();

  String string = 'QUESTIONS';
  CollectionReference cols = FirebaseFirestore.instance.collection('worldwide flashcards');
  String uid = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController question = TextEditingController();


  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: br.white,
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.grey[300]),
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: BorderSide(
                      color: string == 'QUESTIONS' ? Colors.grey : Colors.transparent,
                      width: 2
                    )
                  ))
                ),
              onPressed: () {
                setState(() {
                  string = 'QUESTIONS';
                });
              }, 
              child: Text('QUESTIONS',
              style: GoogleFonts.viga(
                color: br.black
              ),
              ))),

              SizedBox(
                width: 10,
              ),

              Expanded(
              child: TextButton(
               
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.grey[300]),
                   shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: BorderSide(
                      color: string == 'ANSWERS' ? Colors.grey : Colors.transparent,
                      width: 2
                    )
                  )),
                ),
              onPressed: () {
                setState(() {
                  string = 'ANSWERS';
                });
              }, 
              child: Text('ANSWERS',
              style: GoogleFonts.viga(
                color: br.black
              ),
              )))
          ],
        ),
      ),
      backgroundColor: br.white,
      appBar: AppBar(
        actions: [

           IconButton(
            onPressed: () async {

              QuerySnapshot col = await FirebaseFirestore.instance.collection('users').doc(uid).collection('leitner flashcards').doc(widget.doc.id).collection('cards').get();
QuerySnapshot col2 = await FirebaseFirestore.instance.collection('worldwide flashcards').doc(widget.doc.id).collection('cards').get();

br.progress(context); // Show progress indicator

try {
  // Add or update the document for the user's personal flashcards collection
  await FirebaseFirestore.instance.collection('users').doc(uid).collection('leitner flashcards').doc(widget.doc.id).set({
    'color': widget.doc['color'],
    'creator': widget.doc['creator'],
    'date': DateTime.now(),
    'name': widget.doc['name'],
    'subject': widget.doc['subject']
  });

  // Only add new cards if col has fewer cards than col2
  if (col.docs.length < col2.docs.length) {
    for (int i = col.docs.length; i < col2.docs.length; i++) {
      await FirebaseFirestore.instance.collection('users').doc(uid).collection('leitner flashcards').doc(widget.doc.id).collection('cards').add({
        'answer': col2.docs[i]['answer'],
        'question': col2.docs[i]['question'],
      });
    }
  }

  Navigator.pop(context); // Close progress indicator
  Navigator.pop(context); // Go back in navigation stack

  
   
  

  return br.snackbarMessage(context, 'Thank you for adding worldwide flashcards to your personal collection!');
} catch (e) {
  Navigator.pop(context); // Close progress indicator on error
  Navigator.pop(context); // Go back in navigation stack
  return br.snackbarMessage(context, 'Something went wrong. Could not add flashcards.');
}

              
            }, 
            icon: Icon(Icons.add, color: br.black, size: 20,)
          ),


          IconButton(
            onPressed: () async {
              showModalBottomSheet(
                      backgroundColor: br.white,
                      isScrollControlled: true,
                      context: context, 
                      builder: ((context) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: GestureDetector(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                            },
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                children: [
                            
                                  SafeArea(child: Container()),
                            
                                  br.myTextField(false, question, 'Why are you reporting these flashcards?', null),
                            
                                  Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: TextButton.icon(
                                              style: ButtonStyle(
                                                backgroundColor: WidgetStatePropertyAll(Colors.green)
                                              ),
                                              onPressed: () async {

                                                br.progress(context);

                                                try {
                                                  await FirebaseFirestore.instance.collection('reports').add({
                                                    'date':DateTime.now(),
                                                    'report':question.text,
                                                    'uid':FirebaseAuth.instance.currentUser!.uid
                                                  });

                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                  return br.snackbarMessage(context, 'Thank you for your report.');
                                                } catch (e) {
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                  return br.snackbarMessage(context, 'Something went wrong. Report was not sent.');
                                                }
                                                
                                              }, 
                                              icon: Icon(Icons.done, color: br.white, size: 20,),
                                              label: Text('SEND REPORT',
                                              style: GoogleFonts.viga(
                                                color: br.white
                                              ),
                                              )
                                            ),
                                          ),
                                        ),
                            
                                        SafeArea(child: Container()),
                            
                            
                            
                                ],
                              )
                            ),
                          ),
                        );
                      })
                    );
            }, 
            icon: Icon(Icons.report_problem, color: Colors.grey, size: 15,)
          ),

         
        ],
        centerTitle: true,
        title: Text("$index",
        style: GoogleFonts.viga(
          color: br.black
        ),
        ),
        backgroundColor: br.white,
        iconTheme: IconThemeData(
          size: 20,
          color: Colors.grey
        ),
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('worldwide flashcards').doc(widget.doc.id).collection('cards').snapshots(),
        builder: (context, snapshot) {

          if (snapshot.hasData) {

            List<DocumentSnapshot> arrdata = snapshot.data!.docs;

          return arrdata.length > 2 ? CardSwiper(
                    onSwipe: (previousIndex, currentIndex, direction) {
                      _containerColor = getRandomColor();
                      setState(() {
                        index = currentIndex! + 1;
                      });
                      
                      
                      return true;
                    },
                    
                            cardsCount: arrdata.length,
                            cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
          
                  return Card(
                    color: _containerColor,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: br.white,
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30.0,horizontal: 30),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: string == 'QUESTIONS' ? Text(arrdata[index]['question'].toString().toUpperCase(),
                              style: GoogleFonts.viga(
                                color: br.black,
                                fontSize: 14
                              ),
                              ) : Text(arrdata[index]['answer'].toString().toUpperCase(),
                              style: GoogleFonts.viga(
                                color: br.black,
                                fontSize: 14
                              ),
                              )
                            ),
                          )),
                      )
                    ),
                  );
                            },
                          ) : Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Text('2 flashcards are needed in order to display all cards.',
                              textAlign: TextAlign.center,
                              ),
                            ),
                          );
        }

         if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator.adaptive();
         }

         return Center(child: Text('Unable to load cards.'));
        }

       
      ),
    );
  }
}