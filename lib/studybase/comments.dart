import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studystudio/branding.dart';

class Comments extends StatefulWidget {
  final DocumentSnapshot doc;
  const Comments({super.key,
  required this.doc
  });

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {

  Branding br = Branding();
  TextEditingController comment = TextEditingController();
  String uid = FirebaseAuth.instance.currentUser!.uid;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: br.white,
            iconTheme: IconThemeData(
              color: Colors.transparent
            ),
          ),

         
        ],
        body: Scaffold(
          appBar: AppBar(
            actions: [

              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                }, 
                icon: Icon(Icons.keyboard_arrow_down, size: 25,)
              )
            ],
            leading: Icon(Icons.question_answer_outlined, color: Colors.amber,),
            backgroundColor: br.white,
            centerTitle: false,
            iconTheme: IconThemeData(
              color: Colors.grey,
              size: 20
            ),
            title: Text('COMMENTS',
            style: GoogleFonts.viga(
              color: br.black,
              fontSize: 16
            ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: BottomAppBar(
              color: br.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                              cursorColor: Colors.amber,
                              controller: comment,
                              decoration: InputDecoration(
                                hintText: 'Type here...',
                                hintStyle: GoogleFonts.bricolageGrotesque(
                                  color: Colors.grey[500]!,
                                  fontSize: 13
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey[400]!
                                  )
                                ),
                            
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.amber
                                  )
                                )
                              ),
                            ),
                  ),
            
            
                  IconButton(
                    onPressed: () async {
                      
                      if (comment.text.isNotEmpty) {
                        await FirebaseFirestore.instance.collection('studies in studio').doc(widget.doc.id).collection('comments').add({
                          'comment':comment.text,
                          'uid':uid,
                          'date':DateTime.now()
                        });
        
                        comment.clear();
                      }
                    }, 
                    icon: Icon(Icons.send, color: Colors.amber,)
                  )
                ],
              ),
            ),
          ),
          backgroundColor: br.white,
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('studies in studio').doc(widget.doc.id).collection('comments').orderBy('date', descending: false).snapshots(),
              builder: (context, snapshot) {
                    
                if (snapshot.hasData) {
                    
                  List<DocumentSnapshot> arrdata = snapshot.data!.docs;
                    
                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: arrdata.length,
                    itemBuilder: ((context, index) {
                      return ListTile(
                          
                        title: StreamBuilder(
                          stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(), 
                          builder: ((context, user) {
                          
                            if (user.hasData) {
                              return Text(user.data!['Full Name'],
                            style: GoogleFonts.bricolageGrotesque(
                          fontSize: 12,
                          color: Colors.grey[600]
                        ),
                            );
                            }
                          
                            return Text('User',
                            style: GoogleFonts.bricolageGrotesque(
                          fontSize: 12,
                          color: Colors.grey[600]
                        ),
                            );
                          })
                        ),
                        subtitle: Text(arrdata[index]['comment'],
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 14,
                          color: br.black
                        ),
                        ),
                      );
                    })
                  );
                }
                    
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator.adaptive();
                }
                
                return Center(
                  child: Text('Failed to load comments.',
                  textAlign: TextAlign.center,
                  ),
                );
              }
            ),
          ),
        ),
      ),
    );
  }
}