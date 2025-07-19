import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:studystudio/branding.dart';

class Blurting extends StatefulWidget {
  const Blurting({super.key});

  @override
  State<Blurting> createState() => _BlurtingState();
}

class _BlurtingState extends State<Blurting> {

  Branding br = Branding();

  late int remainingTime;

  @override
  void initState() {
    super.initState();
    remainingTime = 900; // Initial title comes from the widget.
  }

  bool createNote = true;


  bool isStarted = false;

  Timer? _timer;

  void stopTimer() {
    setState(() {
      isStarted = !isStarted;
    });
    _timer?.cancel();

  }

   @override
  void dispose() {
    _timer?.cancel(); // Clean up the timer
    super.dispose();
  }

  

  TextEditingController notes = TextEditingController();



  @override
  Widget build(BuildContext context) {
    String formattedTime() {
    final minutes = (remainingTime ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingTime % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String uid = FirebaseAuth.instance.currentUser!.uid;
  String formattedT = formattedTime();

  

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: br.white,
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
      
                ListTile(
                title: Text('BLURTING',
                style: GoogleFonts.viga(
                  color: br.black
                ),
                ),
      
                subtitle: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text('This method focuses on writing everything you know about the subjectin 15 mins, taking a break, then filling the gaps in your knowledge.',
                  style: GoogleFonts.bricolageGrotesque(
                    color: br.black,
                    fontSize: 13
                  ),
                  ),
                ),
              ),
      
              const SizedBox(
                  height: 40,
                ),
      
              Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 250,
                      child: PieChart(
                        
                        PieChartData(
                        sectionsSpace: 0,
                        sections: [
                          
                          PieChartSectionData(
                            value: 900 - remainingTime.toDouble(),
                            radius: 20,
                            showTitle: false,
                            color: const Color.fromARGB(255, 209, 209, 209)
                          ),
      
                          PieChartSectionData(
                            value: remainingTime.toDouble(),
                            radius: 20,
                            showTitle: false,
                            color: remainingTime >= remainingTime / 2 ? Colors.green :
                            remainingTime < remainingTime / 2 && remainingTime > remainingTime / 4 ?
                            Colors.yellow : Colors.red
                          ),
                        ]
                      )),
                    ),
      
                   Center(child: Lottie.asset('lib/animation/writing.json', width: 200, repeat: isStarted))
                  ],
                ),
      
                const SizedBox(
                  height: 40,
                ),
      
                Text(formattedT,
                   style: TextStyle(
                    color: br.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 30
                   ),
                   ),
      
                !isStarted ? 
                
                IconButton(
                  onPressed: () {
                    setState(() {
        isStarted = !isStarted;
        remainingTime = 900;
      });
      _timer = Timer.periodic(
        const Duration(seconds: 1), (timer) {
        if (remainingTime > 0) {
      
          setState(() {
            remainingTime--;
          });
        } else {
          _timer?.cancel();
          
           setState(() {
        isStarted = !isStarted;
      });
        }
      });
                  }, 
                  icon: Icon(Icons.play_arrow, color: br.black, size: 40,)
                ) : 
                
                IconButton(
                  onPressed: stopTimer, 
                  icon: Icon(Icons.pause, color: br.black, size: 40,)
                ),
      
      
                SizedBox(
                  height: 10,
                ),
      
                remainingTime == 0 ? 
                Center(
                  child: Text('TAKE A BREAK!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.viga(
                    color: Colors.red,
                    fontSize: 15
                  ),
                  ),
                ) 
                
                : Container(),
      
                SizedBox(
                  height: 10,
                ),

                TextButton.icon(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.grey[300])
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => BlurtingNotes()));
                }, 
                icon: Icon(Icons.list, color: Colors.amber, size: 20,),
                label: Text('CHECK NOTES LIBRARY',
                style: GoogleFonts.viga(
                  color: br.black
                ),
                )
              ),
      
                createNote ? TextButton.icon(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.grey[300])
                ),
                onPressed: () async {

                  await FirebaseFirestore.instance.collection('users').doc(uid).collection('blurting notes').add({
                    'date':DateTime.now(),
                    'notes':notes.text,
                  });

                  setState(() {
                    createNote = !createNote;
                  });
                }, 
                icon: Icon(Icons.add, color: Colors.green, size: 20,),
                label: Text('CREATE NOTES',
                style: GoogleFonts.viga(
                  color: br.black
                ),
                )
              ) : 
      
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('blurting notes').orderBy('date').snapshots(),
                builder: (context, snapshot) {

                  if (snapshot.hasData) {

                    List<DocumentSnapshot> doc = snapshot.data!.docs;


                    return StreamBuilder<Object>(
                      stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('blurting notes').doc(doc.last.id).snapshots(),
                      builder: (context, snapshot) {
                        return Padding(
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

                            await FirebaseFirestore.instance.collection('users').doc(uid).collection('blurting notes').doc(doc.last.id).update({
                              'notes':value
                            });
                          },
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          controller: notes,
                          decoration: InputDecoration(
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: 'Notes...',
                            hintStyle: TextStyle(
                              color: Colors.grey
                            )
                          ),
                        ),
                                          ),
                                          );
                      }
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator.adaptive();
                  }


                  return Text('Failed to load notes.');
                  
                }
              ),

              SizedBox(
                height: 100,
              )
              
              
      
      
      
      
      
              ],
            ),
          )
      ),
    );
  }
}



class BlurtingNotes extends StatefulWidget {
  const BlurtingNotes({super.key});

  @override
  State<BlurtingNotes> createState() => _BlurtingNotesState();
}

class _BlurtingNotesState extends State<BlurtingNotes> {

  Branding br = Branding();
  String uid = FirebaseAuth.instance.currentUser!.uid;

  bool isShown = false;
  


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
          iconTheme: IconThemeData(
            size: 20,
            color: Colors.grey
          ),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
        
        
              ListTile(
                leading: Lottie.asset('lib/animation/writing.json', repeat: true, reverse: true),
                title: Text('BLURTING NOTES',
                style: GoogleFonts.viga(
                  color: br.black
                ),
                ),
        
                subtitle: Text('a personal study archive',
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.grey[700]
                ),
                ),
              ),
        
        
        
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('blurting notes').orderBy('date', descending: false).snapshots(), 
                  builder: ((context, snapshot) {
                
                    if (snapshot.hasData) {
                
                      List<DocumentSnapshot> arrdata = snapshot.data!.docs;
                
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: arrdata.length,
                        itemBuilder: ((context, index) {
        
                          Timestamp timestamp = arrdata[index]['date'];
                          DateTime date = timestamp.toDate();
                          
                
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
                            child: ListTile(
                               onLongPress: () async {
                                      await FirebaseFirestore.instance.collection('users').doc(uid).collection('blurting notes').doc(arrdata[index].id).delete();
                                    }, 
                              onTap: () {
                                setState(() {
                                  isShown = !isShown;
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                
                              ),
                              tileColor: Colors.grey[300],
                              title: Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text('${date.day}/${date.month}/${date.year}',
                                    style: GoogleFonts.bricolageGrotesque(
                                      color: Colors.blueAccent,
                                      fontSize: 13
                                    ),
                                    ),
                                  ],
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: TextFormField(
                                  onChanged: (value) async {
                                    await FirebaseFirestore.instance.collection('users').doc(uid).collection('blurting notes').doc(arrdata[index].id).update({
                                      'notes':value
                                    });
                                  },
                                  maxLines: isShown == false ? 3 : null,
                                  keyboardType: TextInputType.multiline,
                                  initialValue: arrdata[index]['notes'],
                                  style: GoogleFonts.bricolageGrotesque(
                                    color: br.black,
                                    fontSize: 14
                                  ),
                                  decoration: InputDecoration(
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none
                                  ),
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
                      child: Center(
                        child: Text('Unable to load notes.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13
                        ),
                        ),
                      ),
                    );
                  })
                ),
              )
        
            ],
          ),
        ),
      ),
    );
  }
}
