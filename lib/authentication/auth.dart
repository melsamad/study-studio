import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studystudio/authentication/toggle.dart';
import 'package:studystudio/home_page.dart';
//import 'package:studystudio/studybase/studybase.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(), 
      builder: ((context, snapshot) {
        
        if (snapshot.hasData) {
          return const HomePage();
        } else {
          return const TogglePage();
        }
      })
    );
  }
}