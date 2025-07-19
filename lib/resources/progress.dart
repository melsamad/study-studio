import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studystudio/branding.dart';
import 'package:studystudio/home_page.dart';

class ProgressTracker extends StatefulWidget {
  const ProgressTracker({super.key});

  @override
  State<ProgressTracker> createState() => _ProgressTrackerState();
}

class _ProgressTrackerState extends State<ProgressTracker> {

  Branding br = Branding();
  String uid = FirebaseAuth.instance.currentUser!.uid;

  void addAllTasks() {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: br.white,
      context: context, 
      builder: ((context) {
        return AllToDoList();
      })
    );
  }

  void addAllGrades() {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: br.white,
      context: context, 
      builder: ((context) {
        return AllGrades();
      })
    );
  }

  
  DocumentReference user = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);

  


  @override
  Widget build(BuildContext context) {

    
    return Scaffold(
      backgroundColor: br.white,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [

            ListTile(
                title: Text('PROGRESS TRACKER',
                style: GoogleFonts.viga(
                  color: br.black
                ),
                ),
            ),

            TheSubjects(),

            SizedBox(
              height: 20,
            ),

            ListTile(
              trailing: TextButton.icon(
                onPressed: addAllTasks, 
                label: Text('add',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 13
                ),
                ),
                icon: Icon(Icons.add, size: 17, color: Colors.deepPurple,),
              ),
                title: Text('TO-DO LIST',
                style: GoogleFonts.viga(
                  color: br.black,
                  
                ),
                ),
            ), 

            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('todo list').orderBy('date', descending: false).snapshots(), 
              builder: ((context, snapshot) {

                if (snapshot.hasData) {
                  List<DocumentSnapshot> arrdata = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: arrdata.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: ((context, index) {
                      return ListTile(
                        trailing: IconButton(
                          onPressed: () async {
                            try {
                              await FirebaseFirestore.instance.collection('users').doc(uid).collection('todo list').doc(arrdata[index].id).delete();
                            } catch (e) {
                              return br.snackbarMessage(context, 'Something went wrong. Unable to delete grade.');
                            }
                          }, 
                          icon: Icon(Icons.remove, color: Colors.grey[700], size: 15,)
                        ),
                        leading: Checkbox(
                          value: arrdata[index]['done'], 
                          onChanged: ((val) async {
                            await FirebaseFirestore.instance.collection('users').doc(uid).collection('todo list').doc(arrdata[index].id).update({
                              'done':!arrdata[index]['done']
                            });
                          })
                        ),

                        title: TextFormField(
                          onChanged: (value) async {

                            String task = arrdata[index]['task'];

                            setState(() {
                              task = value;
                            });

                            await FirebaseFirestore.instance.collection('users').doc(uid).collection('todo list').doc(arrdata[index].id).update({
                              'task':task
                            });
                          },
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          initialValue: arrdata[index]['task'],
                          decoration: InputDecoration(
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none
                          ),
                          style: TextStyle(
                            color: arrdata[index]['done'] == true ? Colors.grey[600] : br.black,
                            fontSize: 14,
                            decoration: arrdata[index]['done'] == true ? TextDecoration.lineThrough : TextDecoration.none,
                            decorationColor: Colors.grey[600]
                          ),
                        ),

                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 7.0),
                          child: Text(arrdata[index]['subject'],
                          style: TextStyle(
                            color: Colors.grey[800],
                           fontSize: 12
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

                return Text('Unable to load tasks.');
              })
            ),

            ListTile(
              trailing: TextButton.icon(
                onPressed: addAllGrades, 
                label: Text('add',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 13
                ),
                ),
                icon: Icon(Icons.add, size: 17, color: Colors.deepPurple,),
              ),
                title: Text('GRADES',
                style: GoogleFonts.viga(
                  color: br.black
                ),
                ),
            ), 


            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('grades').snapshots(), 
              builder: ((context, snapshot) {

                if (snapshot.hasData) {
                  List<DocumentSnapshot> arrdata = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: arrdata.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: ((context, index) {
                      return ListTile(

                        trailing: IconButton(
                          onPressed: () async {
                            try {
                              await FirebaseFirestore.instance.collection('users').doc(uid).collection('grades').doc(arrdata[index].id).delete();
                            } catch (e) {
                              return br.snackbarMessage(context, 'Something went wrong. Unable to delete grade.');
                            }
                          }, 
                          icon: Icon(Icons.remove, color: Colors.grey[700], size: 15,)
                        ),
                        title: Text(arrdata[index]['grade'],
                        style: GoogleFonts.viga(
                          color: br.black,
                          fontSize: 14
                        ),
                        ),

                        subtitle: Text(arrdata[index]['subject'],
                        style: GoogleFonts.bricolageGrotesque(
                          color: Colors.grey[600],
                          fontSize: 13
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
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Text('Unable to load grades.',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 13
                  ),
                  ),
                );
              })
            ),

            ListTile(
              tileColor: Colors.grey[300],
                title: Text('TECHNIQUES USED',
                style: GoogleFonts.viga(
                  color: br.black
                ),
                ),
            ), 

            TechniquesUsed()
            
          ],
        ),
      ),
    );
  }
}




class TechniquesUsed extends StatefulWidget {
  const TechniquesUsed({super.key});

  @override
  State<TechniquesUsed> createState() => _TechniquesUsedState();
}

class _TechniquesUsedState extends State<TechniquesUsed> {

  DocumentReference users = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);


  @override
  Widget build(BuildContext context) {


    // feynman
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0, top: 20),
      child: StreamBuilder(
        stream: users.collection('feynman technique').snapshots(), 
        builder: ((context, feynman) {
      
          if (feynman.hasData) {
      
            int f = feynman.data!.docs.length;
      
      
            // leitner
            return StreamBuilder(
        stream: users.collection('leitner flashcards').snapshots(), 
        builder: ((context, leitner) {
        
      
          if (leitner.hasData) {
              int l = leitner.data!.docs.length;
      
            // elaboration
            return StreamBuilder(
        stream: users.collection('elaboration').snapshots(), 
        builder: ((context, elab) {
          
      
          if (elab.hasData) {
            int e = elab.data!.docs.length;
            
      
            // blurting 
            return StreamBuilder(
        stream: users.collection('blurting notes').snapshots(), 
        builder: ((context, blurting) {
          
      
          if (blurting.hasData) {
            int bn = blurting.data!.docs.length;
            
      
            // spaced repetition
            return StreamBuilder(
        stream: users.collection('spaced repetition').snapshots(), 
        builder: ((context, rep) {
          
      
          if (rep.hasData) {
            int sr = rep.data!.docs.length;
            
      
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 200,
                child: BarChart(
                  
                  BarChartData(

              
                 
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                   getTitlesWidget: (double value, TitleMeta meta) {
                     

                      return Text('Feynman - Leitner - Elaboration - Blurting - Spaced Repetition',
                      style: GoogleFonts.bricolageGrotesque(
                        color: Colors.grey[700],
                        fontSize: 10
                      ),
                      );
                    },
                  ),
                ),
              ),
              
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false
                  ),
                  barGroups: [
                    BarChartGroupData(
                      barsSpace: 20,
                      x: 5,
                      barRods: [
                
                        // f
                        BarChartRodData(
                          width: 15,
                          borderRadius: BorderRadius.circular(2),
                          color: Colors.red,
                          toY: f.toDouble(),
                        ),
                
                
                        //l
                        BarChartRodData(
                           width: 15,
                          borderRadius: BorderRadius.circular(2),
                          color: Colors.orange,
                          toY: l.toDouble(),
                        ),
                
                        // e
                        BarChartRodData(
                           width: 15,
                          borderRadius: BorderRadius.circular(2),
                          color: Colors.amber,
                          toY: e.toDouble(),
                        ),
                
                
                        // bn
                        BarChartRodData(
                           width: 15,
                          borderRadius: BorderRadius.circular(2),
                          color: Colors.green,
                          toY: bn.toDouble(),
                        ),
                
                        // sr
                        BarChartRodData(
                           width: 15,
                          borderRadius: BorderRadius.circular(2),
                          color: Colors.blueAccent,
                          toY: sr.toDouble(),
                        )
                      ]
                    )
                  ]
                )),
              ),
            );
          }
      
      
          return Center();
        })
      );
      
      
      
      
      
          }
      
      
          return Center();
        })
      );
      
      
      
          }
      
      
          return Center();
        })
      );
      
      
      
          }
      
      
          return Center();
        })
      );
      
      
          }
      
          return Center();
        })
      ),
    );
  }
}


class AllToDoList extends StatefulWidget {
  const AllToDoList({super.key});

  @override
  State<AllToDoList> createState() => _AllToDoListState();
}

class _AllToDoListState extends State<AllToDoList> {

  Branding br = Branding();
  TextEditingController task = TextEditingController();
  String uid = FirebaseAuth.instance.currentUser!.uid;
  //String chosenSubject = 'Other';

  @override
  void initState() {
    super.initState();
    setState(() {
      br.pickedSubject = 'Other';
    });
  }

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
      
            ListTile(
              title: Text('ADD A TASK',
              style: GoogleFonts.viga(
                color: br.black
              ),
              ),
            ),


            br.myTextField(false, task, 'Type here...', null),

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
                        br.pickedSubject = 'Other';
                      });
                      
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: br.pickedSubject == 'Other' ? Colors.grey : Colors.transparent,
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
                        br.pickedSubject = arrdata[index]['name'];
                      });

                    //   QuerySnapshot feynman = await FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').orderBy('date', descending: false).get();

                    //   await FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').doc(feynman.docs.last.id).update({
                    //  'subject':br.pickedSubject
                    //   });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: br.pickedSubject == arrdata[index]['name'] ? Colors.grey : Colors.transparent,
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.amber)
                ),
                onPressed: () async {
                  br.progress(context);
                  await FirebaseFirestore.instance.collection('users').doc(uid).collection('todo list').add({
                    'date':DateTime.now(),
                    'task':task.text,
                    'subject':br.pickedSubject,
                    'done':false
                  });

                  Navigator.pop(context);
                  Navigator.pop(context);
                }, 
                icon: Icon(Icons.add, color: br.white, size: 20,),
                label: Text('ADD',
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

class AllGrades extends StatefulWidget {
  const AllGrades({super.key});

  @override
  State<AllGrades> createState() => _AllGradesState();
}

class _AllGradesState extends State<AllGrades> {

  Branding br = Branding();
  TextEditingController grade = TextEditingController();
  String uid = FirebaseAuth.instance.currentUser!.uid;
  //String chosenSubject = 'Other';

  @override
  void initState() {
    super.initState();
    setState(() {
      br.pickedSubject = 'Other';
    });
  }

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
      
            ListTile(
              title: Text('ADD NEW GRADE',
              style: GoogleFonts.viga(
                color: br.black
              ),
              ),
            ),


            Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: br.myTextField(false, grade, 'Type here...', null),
            ),

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
                        br.pickedSubject = 'Other';
                      });
                      
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: br.pickedSubject == 'Other' ? Colors.grey : Colors.transparent,
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
                        br.pickedSubject = arrdata[index]['name'];
                      });

                    //   QuerySnapshot feynman = await FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').orderBy('date', descending: false).get();

                    //   await FirebaseFirestore.instance.collection('users').doc(uid).collection('feynman technique').doc(feynman.docs.last.id).update({
                    //  'subject':br.pickedSubject
                    //   });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: br.pickedSubject == arrdata[index]['name'] ? Colors.grey : Colors.transparent,
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.amber)
                ),
                onPressed: () async {
                  br.progress(context);
                  await FirebaseFirestore.instance.collection('users').doc(uid).collection('grades').add({
                    'date':DateTime.now(),
                    'grade':grade.text,
                    'subject':br.pickedSubject,
                    
                  });

                  Navigator.pop(context);
                  Navigator.pop(context);
                }, 
                icon: Icon(Icons.add, color: br.white, size: 20,),
                label: Text('ADD',
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



