import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studystudio/branding.dart';

class OtherMethods extends StatefulWidget {
  const OtherMethods({super.key});

  @override
  State<OtherMethods> createState() => _OtherMethodsState();
}

class _OtherMethodsState extends State<OtherMethods> {

  // 7-3-2-1 method
  // sq3r / pq4r 
  // mind mapping 
  // active recall

  Branding br = Branding();

  List methods = [
    [
      '7-3-2-1 METHOD', 
      'This technique stands for 7 days, 3 days, 2 days and today. If you are looking to memorize something efficiently, read it today, tomorrow, after tomorrow, and lastly 7 days after you initially started.'
    ],

    [
      'SQ3R METHOD', 
      'SQ3R stands for Survery (S), Question (Q), Read-Recite-Review (3R). By surveying the topic you are studying, do a quick revision to grasp the overal sense of it. Next, come up with questions regarding your topic and focus on understanding the most important aspects. Lastly, thoroughly read over everything and recite all the information. You can now end your session by reviewing everything you have learned.'
    ],

    [
      'MIND MAPPING',
      'This is a visual way of learning, which focuses dividing the entire topic into multiple themes, categories, sub-categories and ideas. Usually, it is done by writing down the name of the topic in the middle of the page then using arrows to draw to conclusions. This helps break down complex or big chapters.'
    ],

    [
      'ACTIVE RECALL',
      'This method relies on your memory and can be paired with many other study techniques. You start off by studying your topic, then setting aside some time to memorize it step-by-step. Some techniques you can pair this with are the Feynman & Pomodoro techniques.'
    ],

    [
      'MNEMONIC TECHNIQUES',
      'This is a unique way of memorizing things by linking them to certain images, sounds, keywords or memories. For example, you can try to memorize the names of all the states using a song or the name of a painter by associating him to a specific artwork.'
    ]
  ];

  TextEditingController request = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: br.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          
        ], 
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [

              ListTile(
              title: Text('OTHER METHODS',
              style: GoogleFonts.viga(
                color: br.black,
              ),
              ),

              subtitle: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text('Different types of study methods you can try on your own.',
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.grey[700],
                  fontSize: 13
                ),
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
                            
                                  br.myTextField(false, request, 'What study technique would you like to be simulated?', null),
                            
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
                                                  await FirebaseFirestore.instance.collection('requests').add({
                                                    'date':DateTime.now(),
                                                    'request':request.text,
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
                                              label: Text('SEND REQUEST',
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
                  icon: Icon(Icons.emoji_objects, color: br.white, size: 20,),
                  label: Text('REQUEST A METHOD',
                  style: GoogleFonts.viga(
                    color: br.white
                  ),
                  )
                ),
              ),
            ),



            ListView.builder(
              itemCount: methods.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: ((context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: Colors.grey[400]!,
                        width: 1.5
                      )
                    ),

                    title: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(methods[index][0],
                      style: GoogleFonts.viga(
                        color: br.black,
                        fontSize: 15
                      ),
                      ),
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(methods[index][1],
                      style: GoogleFonts.bricolageGrotesque(
                        color: Colors.grey[700],
                        fontSize: 14
                      ),
                      ),
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