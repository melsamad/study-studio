import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studystudio/branding.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  Branding br = Branding();

  TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController;
    super.dispose();
  }

  Future passwordReset() async {

    br.progress(context);

    try {
       await FirebaseAuth.instance.sendPasswordResetEmail(
      email: emailController.text.trim()
    );

    Navigator.pop(context);
    Navigator.pop(context);

    return br.showMessage(context, 'Success! Check your inbox to reset your password.');

    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      print(e);
      return br.showMessage(context, 'Something went wrong. Please try again.');
  }
  }




  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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

                const SizedBox(height: 20,),
      
                Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text('Enter your email, and we will send you a link to re-set your password.'.toUpperCase(), 
                style: GoogleFonts.viga(
                  color: br.black,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,),
              ),
        
              const SizedBox(height: 20,),
        
             br.myTextField(false, emailController, 'Enter your email...', null),
              //const SizedBox(height: 40,),
        
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.amber)
                    ),
                    onPressed: passwordReset, 
                    child: Text('SEND ME THE LINK',
                    style: GoogleFonts.viga(
                      color: br.white
                    ),
                    )
                  ),
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