import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:printing/printing.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:studystudio/branding.dart';
import 'package:studystudio/elevenlabs.dart';
import 'package:studystudio/gemini.dart';

// sk_30bbc5db8c29cf473ccc0b01df116b662b7b5aacfd09f65a <- Luke

class BaseLesson extends StatefulWidget {
  final DocumentSnapshot doc;
  const BaseLesson({super.key,
  required this.doc
  });
  @override
  State<BaseLesson> createState() => _BaseLessonState();
}

class _BaseLessonState extends State<BaseLesson> {

  Branding br = Branding();

  Uint8List? pdfBytes;
  pdfx.PdfDocument? pdfDocument;
  late Future<pdfx.PdfPageImage> thumbnailFuture;
  pdfx.PdfController? _pdfController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _containerColor = getRandomColor();
    _generatePdf();
  }

  Future<void> _generatePdf() async {
  final doc = pw.Document();

   // Load NotoSans from Google Fonts (built-in to package)
  final ttf = await PdfGoogleFonts.notoSansRegular();

  doc.addPage(
    pw.MultiPage(
    theme: pw.ThemeData.withFont(base: ttf),
    build: (context) => [
      pw.Paragraph(text: widget.doc['explanation']),
    ],
  ),
  );

  final bytes = await doc.save();
  final document = await pdfx.PdfDocument.openData(bytes);
  final page = await document.getPage(1);
  final pageImage = await page.render(
    width: page.width,
    height: page.height,
    format: pdfx.PdfPageImageFormat.png,
  );

  if (pageImage != null) {
    setState(() {
      pdfBytes = bytes;
      _pdfController = pdfx.PdfController(
  document: Future.value(document),
);

      thumbnailFuture = Future.value(pageImage); // wrap in a future for builder
      isLoading = false;
    });
  }
}

String picked = 'LESSON';

String uid = FirebaseAuth.instance.currentUser!.uid;

@override
  void dispose() {
    _pdfController?.dispose();
    // Set an initial random color
    super.dispose();
  }

  // card swiper
// Initially selected random color
  Color? _containerColor;

  // Function to get a random color from the list
  Color? getRandomColor() {
    final random = Random();
    return br.colors[random.nextInt(br.colors.length)];
  }

  // Function to change the color
  void changeColor() {
    setState(() {
      _containerColor = getRandomColor();
    });
  }

  int index = 1;


  // speech to text
  final SpeechToText _speech = SpeechToText();
  String _userSpokenText = '';
  List convo = [];

  Future<void> listenToUser() async {
  bool available = await _speech.initialize();
  if (available) {
    _speech.listen(
      onResult: (result) {
        _userSpokenText = result.recognizedWords;
        // Optional: Show live transcription
        setState(() {});
      },
    );
  }
}

// stop listening
Future<void> stopListening() async {
  if (_speech.isListening) {
    await _speech.stop();
    setState(() {
      convo.add({
        'speaker':'human',
        'response':_userSpokenText
      });
    });

    askGemini();
  }
}



  String _fullResponse = "";
  String _animatedResponse = "";
  final ScrollController _scrollController = ScrollController();
  // ask gemini
  Future<void> askGemini() async {
    String prompt = 'You are a professor who explained the following topic to a student: ${widget.doc['explanation']}. The student is now asking you the following question: $_userSpokenText. With the help of your lesson, answer his question.';

    final results = await GeminiService.generateContent(prompt);

  setState(() {
    _fullResponse = results;
    convo.add({
      'speaker':'robot',
      'response':_fullResponse
    });
  });

  ElevenLabsService.speakText(_fullResponse); // still await if you want to wait until TTS is done
  await _startTypingEffect(); // no await
  

   setState(() {
     _userSpokenText = '';
     _fullResponse = '';
   });

  }

  Future<void> _startTypingEffect() async {
  _animatedResponse = "";
  
  for (int i = 0; i < _fullResponse.length; i++) {
    await Future.delayed(const Duration(milliseconds: 50)); // Adjust speed here
    setState(() {
      _animatedResponse += _fullResponse[i];
    });

    // Scroll to bottom after every few characters
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );
  }

}
  // text-to-speech
  // save the conversation to firebase
  Future<void> generateAndPrintPdf() async {
  final pdf = pw.Document();

  // Load NotoSans from Google Fonts (built-in to package)
  final ttf = await PdfGoogleFonts.notoSansRegular();

 pdf.addPage(
  pw.MultiPage(
    theme: pw.ThemeData.withFont(base: ttf),
    build: (context) => [
      pw.Paragraph(text: widget.doc['explanation']),
    ],
  ),
);


  // Display the PDF preview or allow sharing/printing
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );

}


  bool creatingCards = false;
  List<String> flashcards = [];

  Future<void> addToCollection() async {

    QuerySnapshot flashcardsID =
                                                                    await studybase
                                                                        .doc(widget.doc.id)
                                                                        .collection(
                                                                            'flashcards')
                                                                        .get();

                                                                         showDialog(context: context, builder: (context) {
      return CircularProgressIndicator.adaptive();
    });

 
  try {


   

    studybase
                                                                    .doc(widget.doc.id)
                                                                    .collection('saves')
                                                                    .add({'uid': uid});

                                                                FirebaseFirestore.instance
                                                                    .collection('users')
                                                                    .doc(uid)
                                                                    .collection(
                                                                        'my collection')
                                                                    .doc(widget.doc.id)
                                                                    .set({
                                                                  'creator': widget.doc['uid'],
                                                                  'video ID':
                                                                      widget.doc['video ID'],
                                                                  'explanation':
                                                                      widget.doc['explanation'],
                                                                  'date added': DateTime.now(),
                                                                  'date created':
                                                                      widget.doc['date']
                                                                });

                                                                if (flashcardsID
                                                                    .docs.isNotEmpty) {
                                                                  for (int i = 0;
                                                                      i <
                                                                          flashcardsID
                                                                              .docs.length;
                                                                      i++) {
                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection('users')
                                                                        .doc(uid)
                                                                        .collection(
                                                                            'my collection')
                                                                        .doc(widget.doc.id)
                                                                        .collection(
                                                                            'flashcards')
                                                                        .add({
                                                                      'answer': '',
                                                                      'question':
                                                                          flashcardsID
                                                                              .docs[i]['question']
                                                                    });
                                                                  }
                                                                }


                                                                Navigator.pop(context);
                                                                Navigator.pop(context);
                                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Notes have been added  to your collection.')));

  } catch (e) {
    Navigator.pop(context);
                                                                Navigator.pop(context);
                                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Something went wrong. Please try again.')));
  }
               

}

CollectionReference studybase = FirebaseFirestore.instance.collection('studies in studio');

 


   
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: br.white,
        elevation: 0,
        child: Row(
          children: [

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: TextButton(
                  style: ButtonStyle(
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    )),
                    side: WidgetStatePropertyAll(BorderSide(
                      color: br.black
                    )),
                    backgroundColor: WidgetStatePropertyAll(picked == 'LESSON' ? br.black : br.white)
                  ),
                  onPressed: () {
                    setState(() {
                      picked = 'LESSON';
                    });
                    
                  }, 
                  child: Text('LESSON',
                  style: GoogleFonts.viga(
                    color: picked == 'LESSON' ? br.white : br.black,
                  ),
                  )
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: TextButton(
                  style: ButtonStyle(
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    )),
                    side: WidgetStatePropertyAll(BorderSide(
                      color: br.black
                    )),
                    backgroundColor: WidgetStatePropertyAll(picked == 'CARDS' ? br.black : br.white)
                  ),
                  onPressed: () {
                    setState(() {
                      picked = 'CARDS';
                    });
                  }, 
                  child: Text('CARDS',
                  style: GoogleFonts.viga(
                    color: picked == 'CARDS' ? br.white : br.black,
                  ),
                  )
                ),
              ),
            ),


            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: TextButton(
                  style: ButtonStyle(
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    )),
                    side: WidgetStatePropertyAll(BorderSide(
                      color: br.black
                    )),
                    backgroundColor: WidgetStatePropertyAll(picked == 'NAYA' ? br.black : br.white)
                  ),
                  onPressed: () {
                    setState(() {
                      picked = 'NAYA';
                    });
                  }, 
                  child: Text('NAYA',
                  style: GoogleFonts.viga(
                    color: picked == 'NAYA' ? br.white : br.black,
                  ),
                  )
                ),
              ),
            ),


            

          ],
        ),
      ),
      backgroundColor: br.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: br.white,
            iconTheme: IconThemeData(
              size: 20,
              color: Colors.grey[500]
            ),

            actions: [

              TextButton.icon(
                icon: Icon(Icons.download, color: Colors.blue, size: 15,),
                onPressed: generateAndPrintPdf, 
                label: Text('Download PDF',
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.blue,
                  fontSize: 13
                ),
                )
              )
            ],
          )
        ], 
        body: picked == 'LESSON'
            ? ( isLoading || _pdfController == null
                ? Center(child: Lottie.asset('lib//animation/robot_human.json', height: 90))
                : pdfx.PdfView(controller: _pdfController!)
              )
            : picked == 'CARDS' ? 
            
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('studies in studio').doc(widget.doc.id).collection('flashcards').snapshots(), 
              builder: ((context, snapshot) {

                if (snapshot.hasData) {

                  List<DocumentSnapshot> flashcards = snapshot.data!.docs;

                  return flashcards.length >= 2 ? 
            
                  CardSwiper(
                    onSwipe: (previousIndex, currentIndex, direction) {
                      _containerColor = getRandomColor();
                      setState(() {
                        index = currentIndex! + 1;
                      });
                      
                      
                      return true;
                    },
                    
                            cardsCount: flashcards.length,
                            cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                      
                  return Card(
                    color: _containerColor,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: br.white,
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 30),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Text("${index + 1}) ${flashcards[index]['question'].toString().toUpperCase()}",
                                                                  textAlign: TextAlign.center,
                                                                  style: GoogleFonts.viga(
                                                                    color: br.black
                                                                  ),
                                                                  )
                            ),
                          )),
                      )
                    ),
                  );
                            },
                          )  : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              Lottie.asset('lib/animation/flashcards.json', height: 200),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text('LUKE',
                style: GoogleFonts.viga(
                  color: br.black,
                  fontSize: 17
                ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text("YOU NEED TO ADD THIS LESSON TO YOUR COLLECTION BEFORE CREATING FLASHCARDS SINCE IT DOES NOT HAVE ANY.",
                textAlign: TextAlign.center,
                style: GoogleFonts.viga(
                  color: br.black,
                  fontSize: 15
                ),
                ),
              ),

              Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.red),
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                          ))
                        ),
                        onPressed: addToCollection,
                        child: Text('ADD TO COLLECTION',
                        style: GoogleFonts.viga(
                          color: br.white
                        ),
                        )
                      ), 
                    ),
                  ),

                  creatingCards == true ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: CircularProgressIndicator.adaptive(),
                  ) 
                  
                  
                  : Container()

              


                            ],
                          );


                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator.adaptive());
                }

                

                return Center(
                  child: Text('No flashcards',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 13,
                    color: br.black
                  ),
                  ),
                );

                
              })
            ) : 
            
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                Lottie.asset('lib/animation/robot.json', height: 220),

                _speech.isListening ? TextButton.icon(
                  icon: Icon(Icons.record_voice_over, size: 20, color: Colors.blue[800],),
                  onPressed: stopListening, 
                  label: Text('STOP RECORDING',
                  style: GoogleFonts.viga(
                    color: Colors.blue[800],
                    fontSize: 17
                  ),
                  )
                )
                
                : TextButton.icon(
                  icon: Icon(Icons.mic, size: 20, color: Colors.blue[800],),
                  onPressed: listenToUser, 
                  label: Text('TALK',
                  style: GoogleFonts.viga(
                    color: Colors.blue[800],
                    fontSize: 17
                  ),
                  )
                ),


                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 7),
                  child: Container(
                    
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 221, 221, 221)
                    ),
                    child: Center(
                      child: ListTile(
                        title: Text(_userSpokenText,
                        style: GoogleFonts.bricolageGrotesque(
                          color: br.black,
                          fontSize: 13
                        ),
                        ),
                      ),
                    ),
                  ),
                ), 


                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: _animatedResponse.isNotEmpty ? Colors.blue[800] : Colors.transparent
                    ),
                    margin: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5
                    ),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.vertical,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5),
                        child: ListTile(
                          title: Text(_animatedResponse,
                          style: GoogleFonts.actor(
                            color: br.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700
                          ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )

              ],
            ),
      
      ),
    );
  }
}



