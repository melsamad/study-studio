import 'package:flutter/material.dart';
import 'package:studystudio/branding.dart';

class SQ3R extends StatefulWidget {
  const SQ3R({super.key});

  @override
  State<SQ3R> createState() => _SQ3RState();
}

class _SQ3RState extends State<SQ3R> {

  Branding br = Branding();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: br.white,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            
          ],
        ),
      ),
    );
  }
}