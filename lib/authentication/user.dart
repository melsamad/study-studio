import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studystudio/authentication/forgot_pass.dart';
import 'package:studystudio/branding.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {

  Branding br = Branding();
  String uid = FirebaseAuth.instance.currentUser!.uid;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(), 
              builder: (context, snapshot) {

                if (snapshot.hasData) {
                  DocumentSnapshot doc = snapshot.data!;
                  Timestamp timestamp = doc['Date'];
                  DateTime date = timestamp.toDate();

                  return Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.person, color: Colors.grey,),
                        title: Text(doc['Full Name'].toString().toUpperCase(),
                        style: GoogleFonts.viga(
                          color: br.black
                        ),
                        ),
                      
                        subtitle: Text(doc['Email']),
                      ),

                      ListTile(
                        leading: Icon(Icons.calendar_month, color: Colors.grey, size: 20,),
                        title: Text("Joined: ${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute < 10 ? '0${date.minute}' : date.minute}",
                        style: GoogleFonts.bricolageGrotesque(
                          color: br.black,
                          fontSize: 14
                        ),
                        ),
                      
                        
                      ),
                    ],
                  );
                }

                return ListTile();
              }
            ),
          
          

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.grey[300])
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPassword()));
                  }, 
                  child: Text('FORGOT PASSWORD?',
                  style: GoogleFonts.viga(
                    color: br.black
                  ),
                  )
                ),
              ),
            ),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.amber)
                  ),
                  onPressed: () {
                    showDialog(
                      context: context, 
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: br.white,
                          title: Text('ARE YOU SURE YOU WANT TO SIGN OUT?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.viga(
                            color: br.black,
                            fontSize: 15
                          ),
                          ),

                          content: Text('You can log back in anytime.',
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

                                await FirebaseAuth.instance.signOut();

                                Navigator.pop(context);
                                Navigator.pop(context);
                                Navigator.pop(context);

                              }, 
                              child: Text('Sign Out',
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
                    );
                  }, 
                  child: Text('SIGN OUT',
                  style: GoogleFonts.viga(
                    color: br.white
                  ),
                  )
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.red)
                  ),
                  onPressed: () async {
                    showDialog(
                        context: context, 
                        builder: ((context) {
                          return AlertDialog(
                            backgroundColor: br.white,
                            title: Center(
                              child: Text('Are you sure you want to delete your account?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: br.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w700
                              ),
                              ),
                            ),
                            content: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                  child: Text('You cannot undo this action and all your shared media and info will be deleted as well.\nNOTE: If this operation does not work, please sign out and sign in again in order to delete your account.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: br.black
                                  ),
                                  ),
                                ),
                              ),
                            ),

                            actionsAlignment: MainAxisAlignment.center,
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                }, 
                                child: Text('Cancel',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 13
                                ),
                                )
                              ),

                              TextButton(
                                onPressed: () async {
                                  br.progress(context);

                                  try {

                                    QuerySnapshot worldwide = await FirebaseFirestore.instance.collection('worldwide flashcards').get();

                                    for (int i = 0; i < worldwide.docs.length; i++) {

                                      if (worldwide.docs[i]['creator'] == uid) {
                                        worldwide.docs[i].reference.delete();
                                      }
                                      
                                    }
                                    
                                   

                                    FirebaseAuth.instance.currentUser!.delete().then((value) => {
                                      FirebaseFirestore.instance.collection("users").doc(uid).delete()
                                    }); 

                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    

                                  } catch (e) {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    return br.showMessage(context, 'Something went wrong. Please try again.');
                                  }
                                }, 
                                child: const Text('Delete',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 13
                                ),
                                )
                              )
                            ],
                          );
                        })
                      );
                      
                  }, 
                  child: Text('DELETE ACCOUNT',
                  style: GoogleFonts.viga(
                    color: br.white
                  ),
                  )
                ),
              ),
            ),
          
          ],
        ),
      ),
    );
  }
}


/**
 * Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 15.0),
                 child: SizedBox(
                  width: double.infinity,
                   child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: const MaterialStatePropertyAll(Colors.red),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                      ))
                    ),
                    onPressed: () {

                      showDialog(
                        context: context, 
                        builder: ((context) {
                          return AlertDialog(
                            backgroundColor: br.color,
                            title: Center(
                              child: Text('Are you sure you want to delete your account?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: br.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700
                              ),
                              ),
                            ),
                            content: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                  child: Text('You cannot undo this action and all your shared media and info will be deleted as well.\nNOTE: If this operation does not work, please sign out and sign in again in order to delete your account.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: br.white
                                  ),
                                  ),
                                ),
                              ),
                            ),

                            actionsAlignment: MainAxisAlignment.center,
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                }, 
                                child: const Text('Cancel',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13
                                ),
                                )
                              ),

                              TextButton(
                                onPressed: () async {
                                  br.progress(context);

                                  try {
                                    
                                    QuerySnapshot inspire = await FirebaseFirestore.instance.collection('inspire').where('uid', isEqualTo: uid).get();
                                    QuerySnapshot skills = await FirebaseFirestore.instance.collection('skills').where('uid', isEqualTo: uid).get();
                                    QuerySnapshot challenges = await FirebaseFirestore.instance.collection('challenges').where('uid', isEqualTo: uid).get();

                                    for (var doc in inspire.docs) {
                                      if (doc.exists) {
                                        doc.reference.delete();
                                      }
                                    }

                                    for (var doc in skills.docs) {
                                      if (doc.exists) {
                                        doc.reference.delete();
                                      }
                                    }

                                    for (var doc in challenges.docs) {
                                      if (doc.exists) {
                                        doc.reference.delete();
                                      }
                                    }

                                    FirebaseAuth.instance.currentUser!.delete().then((value) => {
                                      FirebaseFirestore.instance.collection("users").doc(uid).delete()
                                    }); 

                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    

                                  } catch (e) {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    return br.showMessage(context, 'Something went wrong. Please try again.');
                                  }
                                }, 
                                child: const Text('Delete',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 13
                                ),
                                )
                              )
                            ],
                          );
                        })
                      );
                      
                    }, 
                    child: Text("DELETE ACCOUNT",
                    style: GoogleFonts.archivoBlack(
                      color: br.white,
                      letterSpacing: 1.2
                    ),
                    )
                  ),
                 ),
               ),

 */