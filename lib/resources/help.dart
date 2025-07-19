import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studystudio/branding.dart';

class Help extends StatefulWidget {
  const Help({super.key});

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {

  Branding br = Branding();

  List faq = [

    [
      'HOW DOES STUDY STUDIO HELP ME STUDY?',
      'This app is a study technique simulator for the most popular study techniques in the world. It makes it easier and faster to use these techniques no matter where you are or whether you have the materials or space for them.'
    ],

    [
      'IS THE APP REGULARLY MAINTAINED?',
      'Yes, regular bug fixes and performance enhancements are made and new features are integrated occasionally.'
    ],

    [
      'WHY SHOULD I GO FOR THE STUDY TURBO PLAN?',
      'Study Turbo allows you to create as many study sessions as you want with no limitations, as well as access special features such as sharing your own flashcards with other students and using theirs as well. '
    ],

  ];

  TextEditingController question = TextEditingController();


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
            
            ListTile(
              leading: Icon(Icons.help, color: br.black,),
              title: Text('FAQ',
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
                    backgroundColor: WidgetStatePropertyAll(Colors.amber)
                  ),
                  onPressed: () {
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
                            
                                  br.myTextField(false, question, 'What study technique would you like to be simulated?', null),
                            
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
                                                  await FirebaseFirestore.instance.collection('questions').add({
                                                    'date':DateTime.now(),
                                                    'request':question.text,
                                                    'uid':FirebaseAuth.instance.currentUser!.uid
                                                  });

                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                  return br.snackbarMessage(context, 'Thank you for your request!');
                                                } catch (e) {
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                  return br.snackbarMessage(context, 'Something went wrong. Request was not sent.');
                                                }
                                                
                                              }, 
                                              icon: Icon(Icons.done, color: br.white, size: 20,),
                                              label: Text('SEND QUESTION',
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
                  icon: Icon(Icons.question_answer, color: br.white, size: 20,),
                  label: Text('ASK A QUESTION',
                  style: GoogleFonts.viga(
                    color: br.white
                  ),
                  )
                ),
              ),
            ),


            ListView.builder(
              itemCount: faq.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: ((context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        width: 1.5,
                        color: Colors.grey[400]!
                      )
                    ),
                  
                    title: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(faq[index][0],
                      style: GoogleFonts.viga(
                        fontSize: 15,
                        color: br.black
                      ),
                      ),
                    ),


                    subtitle: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(faq[index][1],
                      style: GoogleFonts.bricolageGrotesque(
                        color: Colors.grey[700],
                        fontSize: 14
                      ),
                      ),
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