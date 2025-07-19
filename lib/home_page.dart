import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:studystudio/ai%20agents/ai.dart';
import 'package:studystudio/authentication/user.dart';
import 'package:studystudio/branding.dart';
import 'package:studystudio/resources/help.dart';
import 'package:studystudio/resources/methods.dart';
import 'package:studystudio/resources/progress.dart';
import 'package:studystudio/studybase/studybase.dart';
import 'package:studystudio/techniques/blurting.dart';
import 'package:studystudio/techniques/elaboration.dart';
import 'package:studystudio/techniques/feynman.dart';
import 'package:studystudio/techniques/leitner.dart';
import 'package:studystudio/techniques/pomodoro.dart';
import 'package:studystudio/techniques/spaced.dart';


class Streak extends StatefulWidget {
  const Streak({super.key});

  @override
  State<Streak> createState() => _StreakState();
}

class _StreakState extends State<Streak> {

  Branding br = Branding();
  String uid = FirebaseAuth.instance.currentUser!.uid;



  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [

          SafeArea(child: Container()),

          ListTile(
                    title: Text('UPDATE YOUR STREAK GOAL',
                    style: GoogleFonts.viga(
                      color: br.black
                    ),
                    ),
                    
                  ),


           StreamBuilder(
            stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('streaks').orderBy('date', descending: false).snapshots(), 
            builder: ((context, snapshot) {

              if (snapshot.hasData) {
                List<DocumentSnapshot> arrdata = snapshot.data!.docs;

                return Row(
                  children: [

                    Expanded(
                          child: IconButton(
                            onPressed: () async {

                              
                              if (arrdata.last['streak'] > 1) {
                                await FirebaseFirestore.instance.collection('users').doc(uid).collection('streaks').doc(arrdata.last.id).update({
                                'streak':arrdata.last['streak'] - 1
                              });
                              }

                              
                              
                            }, 
                            icon: Icon(Icons.remove)
                          )
                        ),
                    
                        
                       Expanded(
                        child: Center(
                          child: Text(arrdata.last['streak'].toString(),
                          style: GoogleFonts.viga(
                            color: br.black,
                            fontSize: 20
                          ),
                          ),
                        )
                      ),
                    
                        Expanded(
                          child: IconButton(
                            onPressed: () async {

                              
                              
                                await FirebaseFirestore.instance.collection('users').doc(uid).collection('streaks').doc(arrdata.last.id).update({
                                'streak':arrdata.last['streak'] + 1
                              });
                             
                              

                              

                              
                              
                              
                            }, 
                            icon: Icon(Icons.add)
                          )
                        )

                  ],
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator.adaptive();
              }

              return Text('Unable to load',
              style: GoogleFonts.bricolageGrotesque(
                color: Colors.grey[700],
                fontSize: 12
              ),
              );
            })
          ),

          SafeArea(child: Container()),

          
        ],
      ),
    );
  }
}



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Branding br = Branding();

  Future<void> configureSDK() async {
  await Purchases.setLogLevel(LogLevel.debug);
  PurchasesConfiguration? configuration;

  if (Platform.isIOS) {
    configuration = PurchasesConfiguration('appl_GJImVvKseXSBzxtHCrpoaNsrcTa');
  }


  if (configuration != null) {
    await Purchases.configure(configuration);
    final paywallResult = await RevenueCatUI.presentPaywallIfNeeded('Study Turbo');
    log('Paywall result: $paywallResult');
  }
}


Future<void> setupIsPro() async {

    try {
      Purchases.addCustomerInfoUpdateListener((customerInfo) async {
    EntitlementInfo? entitlement = customerInfo.entitlements.all['YouProve Pro'];
    setState(() {
      isPro = entitlement?.isActive ?? false;
    });

   });
    } catch (e) {
      log(e.toString());
    }
  
}

@override
  void initState() {
    super.initState();
    configureSDK();
    setupIsPro();
  }

  // lilita one
  // bricolage grotesque
  // viga
  // titan one
  // major mono display
  // chango
  // bowlby one
  // rum raisin
  // dynapuff

  ListTile listTile(String title, bool bool, IconData? icon, Function()? ontap) {

    return ListTile(
      onTap: ontap,
      leading: bool == true ? Icon(icon, size: 20,) : null,
      title: Text(title.toUpperCase(),
      style: GoogleFonts.viga(
        color: br.black,
        fontSize: 14
      ),
      ),
    );
  }

  String uid = FirebaseAuth.instance.currentUser!.uid;

  TextEditingController search = TextEditingController();

  PageController controller = PageController();

  

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        drawer: Drawer(
          width: 250,
          backgroundColor: br.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [

                DrawerHeader(
                  margin: EdgeInsets.symmetric(
                    horizontal: 20
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 35.0, horizontal: 15),
                    child: Lottie.asset('lib/animation/desk.json', width: double.infinity,),
                  )
                ),
                
                listTile('database', false, null, () {
                      setState(() {
                        br.index = 0;
                      });
                      Navigator.pop(context);
                    }),


                     ListTile(
      onTap: () {
       setState(() {
         br.index =9;
       });

       Navigator.pop(context);
      },
      trailing: Icon(LucideIcons.brainCircuit, size: 20, color: Colors.blue,),
      title: Text('knowbies'.toUpperCase(),
      style: GoogleFonts.viga(
        color: br.black,
        fontSize: 14
      ),
      ),
    ),

     listTile('other methods', false, null, () {
                      setState(() {
                        br.index = 8;
                      });
                
                      Navigator.pop(context);
                    }),
                    //listTile('notes library', false, null, () {}),
                    listTile('ALL TECHNIQUES', true, Icons.edit, () {}),
                    listTile('pomodoro', false, null, () {
                      setState(() {
                        br.index = 7;
                      });
                
                      Navigator.pop(context);
                    }),
                    listTile('feynman', false, null, () {
                      setState(() {
                        br.index = 4;
                      });
                
                      Navigator.pop(context);
                    }),

                    

                    listTile('progress tracker', false, null, () {

                      Purchases.addCustomerInfoUpdateListener((customerInfo) async {
                              CustomerInfo customerInfo = await Purchases.getCustomerInfo();
                              EntitlementInfo? entitlement = customerInfo.entitlements.all['Study Turbo'];
                              if (entitlement != null && entitlement.isActive) {
                                  setState(() {
                        br.index = 3;
                      });
                      Navigator.pop(context);
                              } else {
                                Navigator.pop(context);
                                final paywalResult = await RevenueCatUI.presentPaywallIfNeeded('Study Turbo');
                                log('Paywall results: $paywalResult');
                              }
                      }
                      );

                    
                    }
                    
                    
                    ),

                  


                
                   
                    //listTile('SQ3R / PQ4R', false, null, () {}),
                    listTile('Leitner', false, null, () {
                      
                      setState(() {
                        br.index = 1;
                      });
                      Navigator.pop(context);
                
                
                    }),
                    listTile('spaced repitition', false, null, () {
                      setState(() {
                        br.index = 5;
                      });
                
                      Navigator.pop(context);
                    }),
                    listTile('blurting', false, null, () {
                      setState(() {
                        br.index = 2;
                      });
                      Navigator.pop(context);
                    }),
                    listTile('elaboration', false, null, () {
                      setState(() {
                        br.index = 6;
                      });
                
                      Navigator.pop(context);
                    }),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          backgroundColor: br.white,
          actions: [

            TextButton.icon(
              icon: Icon(LucideIcons.brainCircuit, size: 15, color: Colors.blue,),
              onPressed: () {

                if (br.index != 9) {
                   setState(() {
                  br.index = 9;
                });
                } else {
                  setState(() {
                    br.index = 0;
                  });
                }
               
              }, 
              label: Text('KNOWBIES',
              style: GoogleFonts.viga(
                color: Colors.blue,
                fontSize: 12
              ),
              )
            ),

            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Help()));
              }, 
              icon: Icon(Icons.help_outline, size: 15,)
            ),


            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Account()));
              }, 
              icon: Icon(Icons.person, size: 15,)
            ),
          ],
        ),
        backgroundColor: br.white,
        body: br.index == 0 ?  StudyBase(): br.index == 1 ? Leitner() 
        : br.index == 2 ? Blurting() 
        : br.index == 3 ? ProgressTracker() 
        : br.index == 4 ? Feynman() : br.index == 5?
        SpacedRepetition() : br.index == 6 ?
        Elaboration() : br.index == 7 ? Pomodoro() : br.index == 8 ? OtherMethods() : MyAiAgent(),
      ),
    );
  }
}

class AddingSubjects extends StatefulWidget {
  const AddingSubjects({super.key});

  @override
  State<AddingSubjects> createState() => _AddingSubjectsState();
}

class _AddingSubjectsState extends State<AddingSubjects> {

  Branding br = Branding();
  TextEditingController subject = TextEditingController();
  String uid = FirebaseAuth.instance.currentUser!.uid;

  int chosenColor = 0;


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
      
                                        SafeArea(child: Container()),
                                         //SafeArea(child: Container()),
                                        
                                        br.myTextField(false, subject, 'Type here...', null),

                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
                                          child: AlignedGridView.count(
                                            itemCount: br.colors.length,
                                            shrinkWrap: true,
                                            physics: NeverScrollableScrollPhysics(),
                                            crossAxisCount: 5,
                                            mainAxisSpacing: 5,
                                            crossAxisSpacing: 0,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                                child: IconButton(
                                                  style: ButtonStyle(
                                                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(50),
                                                      side: BorderSide(
                                                        color: chosenColor == index ? br.colors[index]! : Colors.grey[300]!,
                                                        width: 1.5
                                                      )
                                                    ))
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      chosenColor = index;
                                                    });
                                                  }, 
                                                  icon: Icon(Icons.circle, color: br.colors[index],)
                                                ),
                                              );
                                            },
                                          ),
                                        ),
      
                                        Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.amber)
                      ),
                      onPressed: () async {
                        br.progress(context);

                        await FirebaseFirestore.instance.collection('users').doc(uid).collection('subjects').add({
                          'date':DateTime.now(),
                          'name':subject.text,
                          'color':chosenColor
                        });

                        Navigator.pop(context);
                        Navigator.pop(context);

                        subject.clear();

                        br.snackbarMessage(context, 'Subject added.');

                      }, 
                      child: Text("CREATE",
                      style: GoogleFonts.viga(
                        color: br.white
                      ),
                      )
                    ),
                  ),
                ),

                SafeArea(child: Container()),
                                      ],
                                    ),
                                  ),
    );
  }
}


class TheSubjects extends StatefulWidget {
  const TheSubjects({super.key});

  @override
  State<TheSubjects> createState() => _TheSubjectsState();
}

class _TheSubjectsState extends State<TheSubjects> {

  Branding br = Branding();
  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Padding(
                padding: const EdgeInsets.only(top: 5.0, left: 10),
                child: SizedBox(
                  height: 80,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        IconButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(Colors.grey[300])
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                              isScrollControlled: true,
                              context: context, 
                              builder: ((context) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).viewInsets.bottom
                                  ),
                                  child: AddingSubjects(),
                                );
                              })
                            );
                          }, 
                          icon: Icon(Icons.add, color: Colors.grey[700],)
                        ),

                        GestureDetector(
                          onTap: () {
                            setState(() {
                              br.pickedSubject = 'All';
                            });
                          },
                          child: Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 5
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          width: 2,
                                          color: br.pickedSubject == 'All' ? Colors.grey : Colors.transparent
                                        )
                                      ),
                          
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.circle, size: 15, color: Colors.grey),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text('All')
                                          ],
                                        ),
                                      ),
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
                                scrollDirection: Axis.horizontal,
                                itemBuilder: ((context, index) {

                                  DocumentSnapshot doc = arrdata[index];

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        br.pickedSubject = doc['name'];
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 5
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          width: 2,
                                          color: br.pickedSubject == doc['name'] ? Colors.grey : Colors.transparent
                                        )
                                      ),
                                    
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.circle, size: 15, color: br.colors[doc['color']],),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(doc['name'].toString().toLowerCase())
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                })
                              );
                            }

                            return Container();
                          })
                        )
                      ],
                    ),
                  ),
                ),
              );

  }
}


class DeleteSession extends StatefulWidget {
  final String name;
  final DocumentSnapshot doc;
  const DeleteSession({super.key,
  required this.name,
  required this.doc
  });

  @override
  State<DeleteSession> createState() => _DeleteSessionState();
}

class _DeleteSessionState extends State<DeleteSession> {

  Branding br = Branding();
  String uid = FirebaseAuth.instance.currentUser!.uid;


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('ARE YOU SURE YOU WANT TO DELETE THIS STUDY SESSION?',
      textAlign: TextAlign.center,
      style: GoogleFonts.viga(
        color: br.black,
        fontSize: 15
      ),
      ),

      content: Text('This action cannot be undone.',
      textAlign: TextAlign.center,
      style: GoogleFonts.bricolageGrotesque(
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
            color: Colors.blueAccent,
            fontSize: 13,
            fontWeight: FontWeight.w700
          ),
          )
        ),

        TextButton(
          onPressed: () async {

            br.progress(context);

            try {
              await FirebaseFirestore.instance.collection('users').doc(uid).collection(widget.name).doc(widget.doc.id).delete();
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
              return br.snackbarMessage(context, 'Study session deleted.');
            } catch (e) {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
              return br.snackbarMessage(context, 'Something went wrong. Please try again.');
            }

            

          }, 
          child: Text('Delete',
          style: GoogleFonts.bricolageGrotesque(
            color: Colors.red,
            fontSize: 13,
            fontWeight: FontWeight.w700
          ),
          )
        ),


      ],
    );
  }
}



/**
 * SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
      
              StreamBuilder(
                stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(), 
                builder: ((context, snapshot) {
      
                  if (snapshot.hasData) {
      
                    DocumentSnapshot doc = snapshot.data!;
      
                    return ListTile(
                    title: Text('welcome, ${doc['Full Name']}'.toUpperCase(),
                    style: GoogleFonts.viga(
                      color: br.black
                    ),
                    ),
                    leading: Icon(Icons.handshake, color: Colors.red[500],),
                  );
                  }
      
                  return ListTile(
                    title: Text('welcome, user'.toUpperCase(),
                    style: GoogleFonts.viga(
                      color: br.black
                    ),
                    ),
                    leading: Icon(Icons.handshake, color: Colors.red[500],),
                  );
                })
              ),
      
      
              //br.myTextField(false, search, 'Search', null), 

             

              TheSubjects(),

               Padding(
                 padding: const EdgeInsets.only(left: 15.0, right: 15, top: 25),
                 child: GestureDetector(
                  onTap: () async {
                    await RevenueCatUI.presentPaywallIfNeeded('Study Turbo');
                  },
                   child: SizedBox(
                    width: double.infinity,
                    child: Card(
                      color: Colors.red,
                      elevation: 2,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Text('UNLOCK ALL FEATURES \nWITH STUDY TURBO',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.viga(
                            color: br.white,
                            fontWeight: FontWeight.w900
                          ),
                          ),
                        ),
                      ),
                    ),
                                   ),
                 ),
               ),

              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Row(
                  
                  children: [
                    Lottie.asset('lib/animation/streak.json', height: 70),
                    Text("YOUR FOCUS \nSTREAK",
                     style: GoogleFonts.viga(
                      color: br.black,
                      fontSize: 15
                    ),
                    ),
                  ]
                ),
              ),

             

              StreamBuilder(
                stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('streaks').orderBy('date', descending: false).snapshots(),
                builder: (context, snapshot) {

                  if (snapshot.hasData) {


                    List<DocumentSnapshot> arrdata = snapshot.data!.docs;
                    int streaks = arrdata.last['streak'];
                    int streakDone = arrdata.last['streaks done'];
                   

                    return Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    
                        Expanded(
                          child: IconButton(
                            onPressed: () async {

                              
                              if (arrdata.last['streaks done'] > 0) {
                                await FirebaseFirestore.instance.collection('users').doc(uid).collection('streaks').doc(arrdata.last.id).update({
                                'streaks done':arrdata.last['streaks done'] - 1
                              });
                              }

                              
                              
                            }, 
                            icon: Icon(Icons.remove)
                          )
                        ),
                    
                        
                        GestureDetector(
                          onTap: () {
                             showModalBottomSheet(
                                    context: context, 
                                    builder: (context) {
                                      return Streak();
                                    }
                                  );
                          },
                          child: SizedBox(
                            width: 200,
                            height: 200,
                            child: Stack(
                              children: [
                          
                                Center(
                                                          child: Text("${arrdata.last['streaks done']}/${arrdata.last['streak']}",
                                                          style: GoogleFonts.bricolageGrotesque(
                                                            color: br.black,
                                                            fontSize: 30
                                                          ),
                                                          ),
                                                        ),
                          
                          
                                PieChart(
                                  PieChartData(
                                    
                                    sectionsSpace: 0,
                                    sections: [
                                      PieChartSectionData(
                                        showTitle: false,
                                        value: streaks - streakDone.toDouble(),
                                        radius: 20,
                                        color: Colors.grey[300]
                                      ),
                                                        
                                      PieChartSectionData(
                                        showTitle: false,
                                        value: streakDone.toDouble(),
                                        radius: 20,
                                        gradient: RadialGradient(
                                    colors: [Colors.orange, Colors.amber,],
                                    center: Alignment.center,
                                    radius: 0.8,
                                  ),
                                      )
                                    ]
                                )
                                ),
                              ],
                            ),
                          ),
                        ),
                    
                        Expanded(
                          child: IconButton(
                            onPressed: () async {

                              if (arrdata.last['streaks done'] < arrdata.last['streak']) {
                              
                                await FirebaseFirestore.instance.collection('users').doc(uid).collection('streaks').doc(arrdata.last.id).update({
                                'streaks done':arrdata.last['streaks done'] + 1
                              });
                             
                              }

                               if (arrdata.last['streak'] == arrdata.last['streaks done']) {
                            
                                await FirebaseFirestore.instance.collection('users').doc(uid).collection('streaks').doc(arrdata.last.id).update({
                                'streaks done':0
                              });
                              }

                              
                              
                              
                            }, 
                            icon: Icon(Icons.add)
                          )
                        )
                    
                    
                        
                      ],
                    ),
                  );
                    
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    
                        Expanded(
                          child: IconButton(
                            onPressed: () {}, 
                            icon: Icon(Icons.remove)
                          )
                        ),
                    
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              sections: [
                                PieChartSectionData(
                                  radius: 20,
                                  color: Colors.grey[300]
                                )
                              ]
                          )
                          ),
                        ),
                    
                        Expanded(
                          child: IconButton(
                            onPressed: () {}, 
                            icon: Icon(Icons.add)
                          )
                        )
                    
                    
                        
                      ],
                    ),
                  );
                }
              ),

              

              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ListTile(
                  title: Text('BEFORE YOU START...',
                  style: GoogleFonts.viga(
                    color: br.black,
                    fontSize: 15
                  ),
                  ),
                ),
              ),

              SizedBox(
                height: 200,
                child: PageView(
                  controller: controller,
                  children: [

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey[400]!
                          )
                        ),
                        child: Row(
                          children: [
                        
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Text('SET THE INTENTION TO STUDY WITH FOCUS.',
                                style: GoogleFonts.viga(
                                  color: br.black,
                                  fontSize: 18
                                ),
                                ),
                              ),
                            ),
                            Lottie.asset('lib/animation/intention.json')
                          ],
                        ),
                      ),
                    ),


                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey[400]!
                          )
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0,),
                              child: Text('ENSURE YOUR SPACE IS SET & ALL YOUR TOOLS ARE READY',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.viga(
                                color: br.black,
                                fontSize: 18
                              ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Lottie.asset('lib/animation/desk.json', height: 100),
                            )
                          ],
                        ),
                      ),
                    ),
                  
                  
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey[400]!
                          )
                        ),
                        child: Row(
                          children: [
                        
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 15.0),
                                child: Text('OPTIONALLY, \nPREPARE A DELICIOUS BEVERAGE \nOR SNACK OF CHOICE.',
                                style: GoogleFonts.viga(
                                  color: br.black,
                                  fontSize: 12.5
                                ),
                                ),
                              ),
                            ),
                            Lottie.asset('lib/animation/coffee.json')
                          ],
                        ),
                      ),
                    ),


                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey[400]!
                          )
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        
                            
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Lottie.asset('lib/animation/phone.json', height: 120),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                              
                              child: Text("AND DON'T FORGET TO CUT OUT ALL UNNECESSARY DISTRACTIONS.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.viga(
                                color: br.black,
                                fontSize: 16
                              ),
                              ),
                            
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: SmoothPageIndicator(
                  effect: ExpandingDotsEffect(
                    dotColor: Colors.grey[400]!,
                    activeDotColor: Colors.red,
                    dotHeight: 7,
                    dotWidth: 7
                  ),
                  controller: controller, 
                  count: 4
                ),
              ),

              SizedBox(
                height: 50,
              )
            ],
          ),
        )
 */