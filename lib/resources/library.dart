import 'package:flutter/material.dart';
import 'package:studystudio/branding.dart';

class BlurtingLibrary extends StatefulWidget {
  const BlurtingLibrary({super.key});

  @override
  State<BlurtingLibrary> createState() => _BlurtingLibraryState();
}

class _BlurtingLibraryState extends State<BlurtingLibrary> {

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