import 'package:flutter/material.dart';
import 'package:studystudio/authentication/sign_in.dart';
import 'package:studystudio/authentication/sign_up.dart';

class TogglePage extends StatefulWidget {
  const TogglePage({super.key});

  @override
  State<TogglePage> createState() => _TogglePageState();
}

class _TogglePageState extends State<TogglePage> {

  bool showPage = true;

  void togglePage() {
    setState(() {
      showPage = !showPage;
    });
  }

  
  @override
  Widget build(BuildContext context) {

    if (showPage) {
      return SignUpPage(
        onTap: togglePage,
      );
    } else {
      return SignInPage(
        onTap: togglePage,
      );
    }
  }
}