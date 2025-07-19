import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

bool isPro = false;

class Branding {

  int nb = 0;

  int index = 0;

  String pickedSubject = 'All';

  Color white = const Color.fromARGB(255, 240, 240, 240);
  Color black = const Color.fromARGB(255, 13, 13, 13);

  Widget myTextField(bool showText, TextEditingController controller, String hintText, int? lines) {
    return Padding(
               padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
               child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: lines,
                style: TextStyle(
                  color: black
                ),
                obscureText: showText,
                cursorColor: Colors.amber,
                controller: controller,
                decoration: InputDecoration(
                  
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color.fromARGB(255, 159, 159, 159)),
                  ),
               
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.amber,),
                  ),
               
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    color: Color.fromARGB(255, 110, 110, 110),
                    fontSize: 13
                  )
                ),
               ),
             );
  }

  void progress(BuildContext context) {
    showDialog(
      context: context, 
      builder: ((context) {
        return const CircularProgressIndicator.adaptive();
      })
    );
  }

  void showMessage(BuildContext context, String error) {
    showDialog(
      context: context, 
      builder: ((context) {
        return AlertDialog(
          backgroundColor: white,
          content: Text(error,
          style: GoogleFonts.abel(
            color: black,
            fontWeight: FontWeight.w700,
            letterSpacing: 1
          ),
          ),
        );
      })
    );
  }

  void snackbarMessage(BuildContext context, String string) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(string)));
  }

  List<Color?> colors = [
    Colors.red[900],
    Colors.red[700],
    Colors.red[500],
    Colors.red[300],
    Colors.red[100],

    Colors.orange[900],
    Colors.orange[700],
    Colors.orange[500],
    Colors.orange[300],
    Colors.orange[100], 

    Colors.yellow[900],
    Colors.yellow[700],
    Colors.yellow[500],
    Colors.yellow[300],
    Colors.yellow[100], 

    Colors.green[900], 
    Colors.green[700],
    Colors.green[500], 
    Colors.green[300],  
    Colors.green[100], 

    Colors.blue[900],
    Colors.blue[700],
    Colors.blue[500],
    Colors.blue[300],
    Colors.blue[100],

    Colors.purple[900],
    Colors.purple[700],
    Colors.purple[500],
    Colors.purple[300],
    Colors.purple[100]
  ];

  
}


