import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:studystudio/branding.dart';

class SignUpPage extends StatefulWidget {
  final void Function()? onTap;
  const SignUpPage({super.key, required this.onTap});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  Branding br = Branding();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  CollectionReference users = FirebaseFirestore.instance.collection("users");

  void signUp() async {

    br.progress(context);

    try {
      
      if (password.text == confirmPassword.text && password.text.length >= 6) {

        
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text, 
          password: password.text
        );

       users.doc(userCredential.user!.uid).set({
          'Full Name':name.text,
          'Email':email.text,
          'Date':DateTime.now(),
          'Uid':userCredential.user!.uid, 
          'Pfp':'',
          'Username':''
        });

        users.doc(userCredential.user!.uid).collection('streaks').add({
          'streak':1,
          'streaks done':1,
          'date':DateTime.now()
        });


        Navigator.pop(context);
      } else {
        Navigator.pop(context);

        if (password.text != confirmPassword.text) {
          return br.showMessage(context, "Passwords don't match.");
        } if (password.text.length <= 6) {
          return br.showMessage(context, "Your password needs to be at least 6 characters.");
        } 

       
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
    print(e.message);
  } else {
    print("Unexpected error: $e");
  }
      Navigator.pop(context);
      br.showMessage(context, e.toString());
    }
  }

  PageController controller = PageController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
          FocusScope.of(context).unfocus();
        },
      child: Scaffold(

        bottomNavigationBar: BottomAppBar(
          color: br.white,
          elevation: 0,
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: SmoothPageIndicator(
                    effect: ExpandingDotsEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      activeDotColor: Colors.amber,
                      dotColor: Colors.grey[400]!
                    ),
                    controller: controller, 
                    count: 4
                  ),
                ),
              ),

              IconButton(
                onPressed: () {
                  controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                }, 
                icon: Icon(Icons.arrow_forward)
              )
            ],
          ),
        ),
        appBar: AppBar(
          backgroundColor: br.white,
        ),
        backgroundColor: br.white,
        body: PageView(
          controller: controller,
          children: [

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 15.0, left: 15, bottom: 15),
                  child: Text('A NEW TOOL FOR COMPLETE FOCUS',
                    style: GoogleFonts.viga(
                      color: br.black,
                      fontSize: 18
                    ),
                  ),
                ),
                
                Lottie.asset('lib/animation/desk.json', height: 150, repeat: true, reverse: true),
              ],
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                      padding: const EdgeInsets.only(right: 15.0, left: 25),
                      child: Text('SIMULATING A UNIQUE STUDY EXPERIENCE',
                      textAlign: TextAlign.center,
                        style: GoogleFonts.viga(
                          color: br.black,
                          fontSize: 18
                        ),
                      ),
                    ),
                    
                    Lottie.asset('lib/animation/study.json', height: 400, repeat: true, reverse: true),
              ],
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                      padding: const EdgeInsets.only(right: 15.0, left: 25),
                      child: Text('A MULTI-AGENT Ai SYSTEM FOR FULL COMPREHENSION OF TOPICS',
                      textAlign: TextAlign.center,
                        style: GoogleFonts.viga(
                          color: br.black,
                          fontSize: 18
                        ),
                      ),
                    ),
                    
                    Lottie.asset('lib/animation/robot_human.json', height: 400, repeat: true, reverse: true),
              ],
            ),


            SingleChildScrollView(
              child: Column(
                children: [
            
                  ListTile(
                    leading: Icon(Icons.emoji_objects, color: Colors.amber,),
                    title: Text('WELCOME TO \nYOUR STUDY STUDIO',
                    style: GoogleFonts.viga(
                      color: br.black
                    ),
                    ),
                  ),
            
                  SizedBox(
                    height: 20,
                  ),
                    
                  br.myTextField(false, name, 'What should we call you?', null),
                  br.myTextField(false, email, 'Email', null),
                  br.myTextField(false, password, 'Password', 1),
                  br.myTextField(true, confirmPassword, 'Confirm Password', 1),
            
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.amber)
                        ),
                        onPressed: signUp, 
                        child: Text("LET'S STUDY!",
                        style: GoogleFonts.viga(
                          color: br.white
                        ),
                        )
                      ),
                    ),
                  ),
            
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, top: 10),
                        child: TextButton(
                          onPressed: widget.onTap, 
                          child: Text('Already got an account? \nPress here to sign in.',
                          style: GoogleFonts.viga(
                            color: const Color.fromARGB(255, 66, 66, 66),
                            fontSize: 12
                          ),
                          )
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}