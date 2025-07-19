import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:studystudio/branding.dart';
import 'package:studystudio/home_page.dart';

// for flashcards
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

  //List questionStrings = [];


// for notes
List<TextEditingController> noteControllers = [];

//List noteStrings = [];

// for summaries
List<TextEditingController> summaryControllers = [];
//List summaryStrings = [];

List<TextEditingController> summariesControllers = [];
//List summariesStrings = [];



class SpacedRepetition extends StatefulWidget {
  const SpacedRepetition({super.key});

  @override
  State<SpacedRepetition> createState() => _SpacedRepetitionState();
}

class _SpacedRepetitionState extends State<SpacedRepetition> {

  Branding br = Branding();
  String uid = FirebaseAuth.instance.currentUser!.uid;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: br.white,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.grey[200],
        elevation: 2,
        onPressed: () async {

           br.progress(context);

          QuerySnapshot col = await FirebaseFirestore.instance.collection('users').doc(uid).collection('spaced repetition').get();

          if (isPro == true || col.docs.length < 2) {
                                   

          await FirebaseFirestore.instance.collection('users').doc(uid).collection('spaced repetition').add({
            'date':DateTime.now(),
            'topic':'',
            'subject':'Other',
            'notes':'',
            'feel':'Not sure'
          });

          Navigator.pop(context);


          Navigator.push(context, MaterialPageRoute(builder: (context) => NewRepetition()));

                              } else {
                                
                                Navigator.pop(context);
                                 await RevenueCatUI.presentPaywallIfNeeded('Study Turbo');
                                //log('Paywall results: $paywalResult');
                              }

         

         
        }, 
        icon: Icon(Icons.add, color: br.black, size: 20,),
        label: Text('study session')
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [

            ListTile(
              title: Text('SPACED REPETITION',
              style: GoogleFonts.viga(
                color: br.black
              ),
              ),

              subtitle: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text('Create your study materials, review them within 24 hours, and repeat over a period of time.',
                style: GoogleFonts.bricolageGrotesque(
                  color: br.black
                ),
                ),
              ),
            ),
          
          
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('spaced repetition').snapshots(), 
                builder: (context, snapshot) {
              
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
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => InsideRepetition(doc: arrdata[index])));
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                            ),
                            tileColor: Colors.grey[300],

                            title: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0),
                              child: Text(arrdata[index]['topic'],
                              style: GoogleFonts.bricolageGrotesque(
                                color: br.black,
                                fontSize: 14
                              ),
                              ),
                            ),

                            subtitle: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0),
                              child: Text(arrdata[index]['subject'],
                              style: GoogleFonts.bricolageGrotesque(
                                color: Colors.grey[700],
                                fontSize: 13
                              ),
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
                    child: Text('Unable to load session.'),
                  );
                }
              ),
            )
          
          ],
        ),
      ),
    );
  }
}


class InsideRepetition extends StatefulWidget {
  final DocumentSnapshot doc;
  const InsideRepetition({super.key,
  required this.doc
  });

  @override
  State<InsideRepetition> createState() => _InsideRepetitionState();
}

class _InsideRepetitionState extends State<InsideRepetition> {

  Branding br = Branding();

  //String uid = FirebaseAuth.instance.currentUser!.uid;

  CollectionReference col = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('spaced repetition');

  String chosenCards = 'QUESTIONS';

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



  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      
      length: 3,
      child: Scaffold(
        backgroundColor: br.white,
        appBar: AppBar(
          actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context, 
                builder: ((context) {
                  return DeleteSession(name: 'spaced repetition', doc: widget.doc);
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
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
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
                    color: br.black
                  ),
                  ),
                ),
            
                SizedBox(
                  height: 20,
                ),
            
                TabBar(
                  isScrollable: true,
                  indicatorColor: Colors.amber,
                  tabs: [
            
                    // Text('ROUTINE',
                    // style: GoogleFonts.viga(
                    //   color: br.black
                    // ),
                    // ),
            
                    Text('FLASHCARDS',
                    style: GoogleFonts.viga(
                      color: br.black
                    ),
                    ),
            
                    Text('NOTES',
                    style: GoogleFonts.viga(
                      color: br.black
                    ),
                    ),
            
                    Text('SUMMARIES',
                    style: GoogleFonts.viga(
                      color: br.black
                    ),
                    ),
            
                    
                  ]
                ),
                    
                
                SizedBox(
                  height: double.maxFinite,
                  child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                  
                     
                  
                      // flashcards
                      Column(
                        children: [
                      
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
                                    child: TextButton(
                                      style: ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(Colors.grey[300]),
                                        side: WidgetStatePropertyAll(BorderSide(
                                          color: chosenCards == 'QUESTIONS' ? Colors.grey : Colors.transparent,
                                          width: 2
                                        ))
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          chosenCards = 'QUESTIONS';
                                        });
                                      }, 
                                      child: Text('QUESTIONS',
                                      style: GoogleFonts.viga(
                                        color: br.black
                                       ),
                                      )
                                    ),
                                  )
                                ),
                            
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
                                    child: TextButton(
                                      style: ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(Colors.grey[300]),
                                        side: WidgetStatePropertyAll(BorderSide(
                                          color: chosenCards == 'ANSWERS' ? Colors.grey : Colors.transparent,
                                          width: 2
                                        ))
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          chosenCards = 'ANSWERS';
                                        });
                                      }, 
                                      child: Text('ANSWERS',
                                      style: GoogleFonts.viga(
                                        color: br.black
                                       ),
                                      )
                                    ),
                                  )
                                )
                            
                            
                              ],
                            ),
                          ),
                        
                        
                          StreamBuilder(
                            stream: col.doc(widget.doc.id).collection('flashcards').snapshots(), 
                            builder: ((context, snapshot) {
            
                              if (snapshot.hasData) {
            
                                List<DocumentSnapshot> arrdata = snapshot.data!.docs;
            
                                return Column(
                                  children: [

                                    Center(
                                      child: Text('$index/${arrdata.length}',
                                      style: GoogleFonts.viga(
                                        color: br.black,
                                        fontSize: 16
                                      ),
                                      ),
                                    ),
                                    arrdata.length >= 2 ? SizedBox(
                                      width: double.infinity,
                                      height: 500,
                                      child: CardSwiper(
                                        onSwipe: (previousIndex, currentIndex, direction) {
                                          _containerColor = getRandomColor();
                                          setState(() {
                                            index = currentIndex! + 1;
                                          });
                                          return true;
                                        },
                                        cardBuilder: ((context, index, y, x) {
                                          return GestureDetector(
                                            onDoubleTap: () async {
                                              await col.doc(widget.doc.id).collection('flashcards').doc(arrdata[index].id).delete();
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
                                                                padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 20),
                                                                child: SingleChildScrollView(
                                                                  scrollDirection: Axis.vertical,
                                                                  child: chosenCards == 'QUESTIONS' ? Text(arrdata[index]['question'].toString().toUpperCase(),
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
                                        }), 
                                        cardsCount: arrdata.length 
                                      ),
                                    ) : Center(),

                                    SizedBox(
                                      width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                                    child: TextButton.icon(
                                      style: ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(Colors.grey[300]),
                                        side: WidgetStatePropertyAll(BorderSide(
                                          color: Colors.grey[300]!,
                                          width: 2
                                        ))
                                      ),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          isScrollControlled: true,
                                          context: context, 
                                          builder: (context) {
                                            return AddingFlashcards(
                                              doc: widget.doc,
                                              col: 'spaced repetition',
                                              col2: 'flashcards',
                                            );
                                          }
                                        );
                                      }, 
                                      label: Text('ADD FLASHCARD',
                                      style: GoogleFonts.viga(
                                        color: br.black
                                       ),
                                      ),

                                      icon: Icon(Icons.add, color: br.black, size: 20,),
                                    ),
                                  )
                                )
                                  ],
                                );
            
                              }
            
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator.adaptive();
                              }
            
                              return Text('Unable to load flashcards.');
                            })
                          ),
                        
                        
                        
                        
                        ],
                      ),
                  
                      // notes
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: StreamBuilder(
                          stream: col.doc(widget.doc.id).collection('notes').snapshots(), 
                          builder: ((context, snapshot) {
                        
                            if (snapshot.hasData) {
                        
                              List<DocumentSnapshot> arrdata = snapshot.data!.docs;
                        
                              return Column(
                                children: [ 

                                  Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                            child: SizedBox(
                              width: double.infinity,
                              child: TextButton.icon(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(Colors.amber)
                                ),
                                onPressed: () async {
                                  await col.doc(widget.doc.id).collection('notes').add({
                                    'note':'Type here...',
                                   
                                  });
                                }, 
                                label: Text('ADD NOTES',
                                style: GoogleFonts.viga(
                                  color: br.white
                                ),
                                ),
                                icon: Icon(Icons.add, color: br.white, size: 20,),
                              ),
                            ),
                          ),


                                  ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: arrdata.length,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: ((context, index) {
                                              
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
                                      child: ListTile(
                                        trailing: IconButton(
                                  onPressed: () async {
                                    await col.doc(widget.doc.id).collection('notes').doc(arrdata[index].id).delete();
                                  }, 
                                  icon: Icon(Icons.remove, size: 15,)
                                ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10)
                                        ),
                                        tileColor: Colors.grey[300],
                                        subtitle: TextFormField(
                                          maxLines: null,
                                          keyboardType: TextInputType.multiline,
                                          onChanged: (value) async {
                                            
                                              
                                            await col.doc(widget.doc.id).collection('notes').doc(arrdata[index].id).update({
                                              'note':value
                                            });
                                          },
                                          cursorColor: Colors.amber,
                                          initialValue: arrdata[index]['note'],
                                          decoration: InputDecoration(
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none
                                          ),
                                          style: GoogleFonts.bricolageGrotesque(
                                            fontSize: 14
                                          ),
                                        ),
                                      ),
                                    );
                                  })
                                ),
                                ]
                              );
                            }
                        
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator.adaptive();
                            }
                        
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20.0),
                              child: Center(child: Text('Unable to load notes.')),
                            );
                          })
                        ),
                      ),
                  
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: StreamBuilder(
                          stream: col.doc(widget.doc.id).collection('summaries').snapshots(), 
                          builder: ((context, snapshot) {
                        
                            if (snapshot.hasData) {
                        
                              List<DocumentSnapshot> arrdata = snapshot.data!.docs;
                        
                              return Column(
                                children: [ 

                                   Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                            child: SizedBox(
                              width: double.infinity,
                              child: TextButton.icon(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(Colors.amber)
                                ),
                                onPressed: () async {
                                  await col.doc(widget.doc.id).collection('summaries').add({
                                    'title':'Add Title',
                                    'summary':'write summary',
                                  });
                                }, 
                                label: Text('ADD SUMMARY',
                                style: GoogleFonts.viga(
                                  color: br.white
                                ),
                                ),
                                icon: Icon(Icons.add, color: br.white, size: 20,),
                              ),
                            ),
                          ),


                                  ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: arrdata.length,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: ((context, index) {
                                              
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
                                      child: ListTile(
                                         trailing: IconButton(
                                  onPressed: () async {
                                    await col.doc(widget.doc.id).collection('summaries').doc(arrdata[index].id).delete();
                                  }, 
                                  icon: Icon(Icons.remove, size: 15,)
                                ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          side: BorderSide(
                                            color: Colors.grey
                                          )
                                        ),
                                        //tileColor: Colors.grey[300],
                                                      
                                        title: TextFormField(
                                          maxLines: null,
                                          keyboardType: TextInputType.multiline,
                                          onChanged: (value) async {
                                            
                                              
                                            await col.doc(widget.doc.id).collection('summaries').doc(arrdata[index].id).update({
                                              'title':value
                                            });
                                          },
                                          cursorColor: Colors.amber,
                                          initialValue: arrdata[index]['title'],
                                          decoration: InputDecoration(
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none
                                          ),
                                          style: GoogleFonts.bricolageGrotesque(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700
                                          ),
                                        ),
                                                      
                                                      
                                                      
                                        subtitle: TextFormField(
                                          maxLines: null,
                                          keyboardType: TextInputType.multiline,
                                          onChanged: (value) async {
                                            
                                              
                                            await col.doc(widget.doc.id).collection('summaries').doc(arrdata[index].id).update({
                                              'summary':value
                                            });
                                          },
                                          cursorColor: Colors.amber,
                                          initialValue: arrdata[index]['summary'],
                                          decoration: InputDecoration(
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none
                                          ),
                                          style: GoogleFonts.bricolageGrotesque(
                                            fontSize: 14
                                          ),
                                        ),
                                      ),
                                    );
                                  })
                                ),
                                ]
                              );
                            }
                        
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator.adaptive();
                            }
                        
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20.0),
                              child: Center(child: Text('Unable to load notes.')),
                            );
                          })
                        ),
                      ),
                          
                    ]
                  ),
                ),
            
              
                    
              ],
            ),
          ),
        ),
      ),
    );
  }
}









// creations

class AddingFlashcards extends StatefulWidget {
  final DocumentSnapshot doc;
  final String col;
  final String col2;
  const AddingFlashcards({super.key,
  required this.doc,
  required this.col,
  required this.col2
  });

  @override
  State<AddingFlashcards> createState() => _AddingFlashcardsState();
}

class _AddingFlashcardsState extends State<AddingFlashcards> {

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



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: br.white,
          iconTheme: IconThemeData(
                size: 20,
                color: Colors.transparent
              ),
        ),
        backgroundColor: br.white,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              backgroundColor: br.white,
              iconTheme: IconThemeData(
                size: 20,
                color: Colors.grey
              ),
            )
          ], 
          body: SingleChildScrollView(
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
      
                           
                          
                               for (int i = 0; i < questionStrings.length; i++) {

                             
                                 await FirebaseFirestore.instance.collection('users').doc(uid).collection(widget.col).doc(widget.doc.id).collection(widget.col2).add({
                                'question':questionStrings[i]['questions'],
                                'answer':questionStrings[i]['answers']
                          });
                              
                              
                            }
                            
                           
        
                         
      
                          print(questionStrings);
        
                          Navigator.pop(context);
                          Navigator.pop(context);
        
                          br.snackbarMessage(context, 'New flashcards added.');
                          } catch (e) {
                             Navigator.pop(context);
                          Navigator.pop(context);
        
                          br.snackbarMessage(context, 'Something went wrong. Could not add flashcards.');
                          print(e.toString());
                          }
      
                          
        
                         
      
                          
      
                          
                        }, 
                        label: Text('SAVE & ADD',
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
        ),
      ),
    );
  }
}



class NewRepetition extends StatefulWidget {
  const NewRepetition({super.key});

  @override
  State<NewRepetition> createState() => _NewRepetitionState();
}

class _NewRepetitionState extends State<NewRepetition> {

  Branding br = Branding();
  PageController controller = PageController();
  TextEditingController topic = TextEditingController();
  String studyMaterial = 'FLASHCARDS';
  String chosenSubject = 'Other';
  String uid = FirebaseAuth.instance.currentUser!.uid;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: br.white,
      appBar: AppBar(
        backgroundColor: br.white,
        iconTheme: IconThemeData(
          color: Colors.grey,
          size: 20
        ),
      ),

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
                icon: Icon(Icons.arrow_back, color: br.black,)
              )
            ),

            Expanded(
              child: IconButton(
                onPressed: () {
                  controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
                }, 
                icon: Icon(Icons.arrow_forward, color: br.black,)
              )
            ),
          ],
        ),
      ),

      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: controller,
        children: [
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              
                  ListTile(
                    title: Text('WRITE DOWN THE TOPIC YOU WANT TO STUDY',
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

                  QuerySnapshot spaced = await FirebaseFirestore.instance.collection('users').doc(uid).collection('spaced repetition').orderBy('date', descending: false).get();

                  await FirebaseFirestore.instance.collection('users').doc(uid).collection('spaced repetition').doc(spaced.docs.last.id).update({
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
          
                      QuerySnapshot spaced = await FirebaseFirestore.instance.collection('users').doc(uid).collection('spaced repetition').orderBy('date', descending: false).get();
          
                      await FirebaseFirestore.instance.collection('users').doc(uid).collection('spaced repetition').doc(spaced.docs.last.id).update({
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

                      QuerySnapshot spaced = await FirebaseFirestore.instance.collection('users').doc(uid).collection('spaced repetition').orderBy('date', descending: false).get();
          
                      await FirebaseFirestore.instance.collection('users').doc(uid).collection('spaced repetition').doc(spaced.docs.last.id).update({
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
                ListTile(
                    title: Text('CREATE YOUR STUDY MATERIALS',
                  style: GoogleFonts.viga(
                    fontSize: 16
                  ),
                  ),
                  ),


                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3.0),
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(Colors.grey[300]),
                              shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  width: 2,
                                  color: studyMaterial == 'FLASHCARDS' ? Colors.grey : Colors.transparent
                                )
                              ))
                            ),
                            onPressed: () {
                              setState(() {
                                studyMaterial = 'FLASHCARDS';
                              });
                            }, 
                            child: Text('FLASHCARDS',
                            style: GoogleFonts.bricolageGrotesque(
                              color: br.black,
                              fontSize: 13
                            ),
                            )
                          ),
                        ),
                      ),
                  
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3.0),
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(Colors.grey[300]),
                              shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  width: 2,
                                  color: studyMaterial == 'NOTES' ? Colors.grey : Colors.transparent
                                )
                              ))
                            ),
                            onPressed: () {
                              setState(() {
                                studyMaterial = 'NOTES';
                              });
                            }, 
                            child: Text('NOTES',
                            style: GoogleFonts.bricolageGrotesque(
                              color: br.black,
                              fontSize: 13
                            ),
                            )
                          ),
                        ),
                      ),
                  
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3.0),
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(Colors.grey[300]),
                              shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  width: 2,
                                  color: studyMaterial == 'SUMMARIES' ? Colors.grey : Colors.transparent
                                )
                              ))
                            ),
                            onPressed: () {
                              setState(() {
                                studyMaterial = 'SUMMARIES';
                              });
                            }, 
                            child: Text('SUMMARIES',
                            style: GoogleFonts.bricolageGrotesque(
                              color: br.black,
                              fontSize: 13
                            ),
                            )
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              
              
                studyMaterial == 'FLASHCARDS' ? CreateFlashcards() :
                studyMaterial == 'NOTES' ? CreateNotes() : CreateSummaries(),
              
              ],
            ),
          ),
        
          

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ListTile(
                title: Text("YOU'RE ALL SET! SAVE YOUR STUDY MATERIALS TO CONTINUE.",
                style: GoogleFonts.viga(
                  color: br.black
                ),
                ),
              ),


              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.green)
                    ),
                    icon: Icon(Icons.check, color: br.white, size: 20,),
                    onPressed: () async {

                      QuerySnapshot arrdata = await FirebaseFirestore.instance.collection('users').doc(uid).collection('spaced repetition').orderBy('date', descending: false).get();


                      br.progress(context);

                      try {

                        
                        for (int i = 0; i < questions.length; i++) {

                        if (questions[i].text.isNotEmpty) {
                          await FirebaseFirestore.instance.collection('users').doc(uid).collection('spaced repetition').doc(arrdata.docs.last.id).collection('flashcards').add({
                            'question':questions[i].text,
                            'answer':answers[i].text
                          });
                        }                      
                        
                      }
                       


                      for (int i = 0; i < noteControllers.length; i++) {
                        if (noteControllers[i].text.isNotEmpty) {
                          await FirebaseFirestore.instance.collection('users').doc(uid).collection('spaced repetition').doc(arrdata.docs.last.id).collection('notes').add({
                            'note':noteControllers[i].text,                         
                          });
                        }
                      }

                      for (int i = 0; i < summariesControllers.length; i++) {
                        if (summariesControllers[i].text.isNotEmpty) {
                          await FirebaseFirestore.instance.collection('users').doc(uid).collection('spaced repetition').doc(arrdata.docs.last.id).collection('summaries').add({
                            'title':summaryControllers[i].text,
                            'summary':summariesControllers[i].text
                          });
                        }
                      }

                      Navigator.pop(context);
                      Navigator.pop(context);
                      return br.showMessage(context, 'Study materials saved.');

                      } catch (e) {
                        Navigator.pop(context);
                      return br.showMessage(context, 'Something went wrong. Please try again.');
                      }

                      

                    }, 
                    label: Text('SAVE & PROCEED',
                    style: GoogleFonts.viga(
                      color: br.white
                    ),
                    )
                  ),
                ),
              )
            ],
          ),
        
        ],
      ),
    );
  }
}



class CreateFlashcards extends StatefulWidget {
  const CreateFlashcards({super.key});

  @override
  State<CreateFlashcards> createState() => _CreateFlashcardsState();
}

class _CreateFlashcardsState extends State<CreateFlashcards> {

  Branding br = Branding();
  String uid = FirebaseAuth.instance.currentUser!.uid;

  
  PageController pageController = PageController();

  

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


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: br.white,
          
          body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SizedBox(
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
            ),
        ),
      ),
    );
  }
}


class CreateNotes extends StatefulWidget {
  const CreateNotes({super.key});

  @override
  State<CreateNotes> createState() => _CreateNotesState();
}

class _CreateNotesState extends State<CreateNotes> {

  Branding br = Branding();


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
      
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: TextButton.icon(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.amber)
                ),
                onPressed: () {
                  setState(() {
                    noteControllers.add(TextEditingController());
                  });
                }, 
                label: Text('ADD NOTES',
                style: GoogleFonts.viga(
                  color: br.white
                ),
                ),
                icon: Icon(Icons.add, color: br.white, size: 20,),
              ),
            ),
      
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: noteControllers.length,
              itemBuilder: ((context, index) {
                return ListTile(
                  title: TextField(
                     maxLines: null,
                      keyboardType: TextInputType.multiline,
                    cursorColor: Colors.amber,
                    controller: noteControllers[index],
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () {
                          
                          setState(() {
                            noteControllers.removeAt(index);
                          });

                        
                        }, 
                        icon: Icon(Icons.remove)
                      ),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: 'Note...',
                      hintStyle: TextStyle(
                        color: Colors.grey
                      )
                    ),
                    
                    style: TextStyle(
                      fontSize: 14,
                      color: br.black
                    ),
                  ),
                );
              })
            ),
      
          ],
        ),
      ),
    );
  }
}




class CreateSummaries extends StatefulWidget {
  const CreateSummaries({super.key});

  @override
  State<CreateSummaries> createState() => _CreateSummariesState();
}

class _CreateSummariesState extends State<CreateSummaries> {

  Branding br = Branding();


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
      
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: TextButton.icon(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.amber)
                ),
                onPressed: () {
                   setState(() {
                              summaryControllers.add(TextEditingController());
                              summariesControllers.add(TextEditingController());
                            });
                }, 
                label: Text('CREATE SUMMARY',
                style: GoogleFonts.viga(
                  color: br.white
                ),
                ),
                icon: Icon(Icons.add, color: br.white, size: 20,),
              ),
            ), 
      
            ListView.builder(
              shrinkWrap: true,
              itemCount: summaryControllers.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: ((context, index) {
                return ListTile(
      
      
                  trailing: IconButton(
                    onPressed: () {
                       setState(() {
                              summaryControllers.removeAt(index);
                              summariesControllers.removeAt(index);
                            });
                    }, 
                    icon: Icon(Icons.remove, size: 20,)
                  ),
                  title: TextField(
                      cursorColor: Colors.amber,
                      controller: summaryControllers[index],
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: 'What are you summarizing?',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w700
                        )
                      ),
                      
                      style: TextStyle(
                        fontSize: 14,
                        color: br.black,
                        fontWeight: FontWeight.w700
                      ),
                    ),
      
      
      
                  subtitle: TextField(
                      cursorColor: Colors.amber,
                      controller: summariesControllers[index],
                       maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: 'Summary...',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          
                        )
                      ),
                      
                      style: TextStyle(
                        fontSize: 14,
                        color: br.black
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