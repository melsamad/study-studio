import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studystudio/authentication/forgot_pass.dart';
import 'package:studystudio/branding.dart';

class SignInPage extends StatefulWidget {
  final void Function()? onTap;
  const SignInPage({super.key, required this.onTap});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  Branding br = Branding();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
          FocusScope.of(context).unfocus();
        },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: br.white,
        ),
        backgroundColor: br.white,
        body: SingleChildScrollView(
          child: Column(
            children: [

              ListTile(
                leading: Icon(Icons.emoji_objects, color: Colors.amber,),
                title: Text('WELCOME BACK TO \nYOUR STUDY STUDIO',
                style: GoogleFonts.viga(
                  color: br.black
                ),
                ),
              ),

              SizedBox(
                height: 20,
              ),
                
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
                    onPressed: () async {
                      br.progress(context);

                      try {

                        if (password.text == confirmPassword.text) {
                          FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text, 
        password: confirmPassword.text
      );

      Navigator.pop(context);
                        } else {
                          Navigator.pop(context);
      return br.showMessage(context, "Passwords don't match.");
                        }
      
      

    } catch (e) {
      
      Navigator.pop(context);
      return br.showMessage(context, e.toString());
    }

                    }, 
                    child: Text("LET'S STUDY!",
                    style: GoogleFonts.viga(
                      color: br.white
                    ),
                    )
                  ),
                ),
              ),

               Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0, top: 0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPassword()));
                      }, 
                      child: Text('Forgot Password?',
                      style: GoogleFonts.viga(
                        color: const Color.fromARGB(255, 66, 66, 66),
                        fontSize: 12
                      ),
                      )
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 10),
                    child: TextButton(
                      onPressed: widget.onTap, 
                      child: Text('New here? \nPress here to create an account.',
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
      ),
    );
  }
}