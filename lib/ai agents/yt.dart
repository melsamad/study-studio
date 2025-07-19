import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:pdf/pdf.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:studystudio/branding.dart';
import 'package:http/http.dart' as http;
import 'package:studystudio/gemini.dart';
import 'package:youtube_caption_scraper/youtube_caption_scraper.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


// https://www.youtube.com/watch?v=LPZh9BOjkQs

class StudyAi extends StatefulWidget {
  const StudyAi({super.key});

  @override
  State<StudyAi> createState() => _StudyAiState();
}

class _StudyAiState extends State<StudyAi> {

// basic variables used
String ytKey = 'AIzaSyCkBCwTsY8YDlOdHtur0t480YIvrrI2KiU';
Branding br = Branding();
bool exists = true;
String videoID = '';
TextEditingController id = TextEditingController();
bool autoFocus = true;

String uid = FirebaseAuth.instance.currentUser!.uid;

// first, bob checks if the youtube video exists
Future<void> doesYouTubeVideoExist(BuildContext context) async {
  // Unfocus the text field to avoid key event issues
  FocusScope.of(context).unfocus();

  String input = id.text.trim();
  String? extractedId = extractYouTubeVideoId(input);

  if (extractedId == null) {
    setState(() {
      exists = false;
      autoFocus = false;
    });
    print('Invalid YouTube URL or ID');
    return;
  }

  videoID = extractedId;
  final url = 'https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=$videoID&format=json';
  final response = await http.get(Uri.parse(url));

  setState(() {
    autoFocus = false;
    if (response.statusCode == 200) {
      exists = true;
      print('Video available');
      controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
      getSubtitles();
    } else {
      exists = false;
      print('Video does not exist or is unavailable.');
    }
  });

  print(videoID);
}

// Bob: Helper to extract the video ID from a URL or raw input
String? extractYouTubeVideoId(String input) {
  final uri = Uri.tryParse(input);
  if (uri == null || input.isEmpty) return null;

  if (uri.host.contains('youtu.be')) {
    return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
  }

  if (uri.host.contains('youtube.com')) {
    return uri.queryParameters['v'];
  }

  // If input looks like a raw 11-char ID
  final regExp = RegExp(r'^[\w-]{11}$');
  if (regExp.hasMatch(input)) {
    return input;
  }

  return null;
}

String formattedSubtitles = ''; // full subtitles

// Bob extracts subtitles from youtube video
Future<void> getSubtitles() async {


  final captionScraper = YouTubeCaptionScraper();
  final captionTracks = await captionScraper.getCaptionTracks('https://www.youtube.com/watch?v=$videoID');

  final englishTrack = captionTracks.firstWhere(
  (track) => track.languageCode == 'en',
  orElse: () => captionTracks[0], // fallback if English is not found
);


  final subtitles = await captionScraper.getSubtitles(englishTrack);

  String combinedSubtitles = '';
  for (var subtitle in subtitles) {
    print(subtitle.text);
    combinedSubtitles += subtitle.text + '\n';
  }

  setState(() {
    formattedSubtitles = combinedSubtitles;
  });

  controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeInOut);

  youtubeSubtitlesToPDF();

  print(formattedSubtitles);
}


// gemini functions 

String _fullResponse = "";
String _animatedResponse = "";

Future<void> youtubeSubtitlesToPDF() async {
  String prompt = "You are a professor who wants to turn and format the following text into a lesson highlighting key details. Your goal is to make the written lesson easy to understand the topic. It needs to include the title of the topic, the things (goals) the students should be able to know after reading it, a well-written and precise explanation of the topic, and finally a list of the terminology (the vocabulary) that they should know for this material. Here is the text: $formattedSubtitles";
  final results = await GeminiService.generateContent(prompt);

  setState(() {
    _fullResponse = results;
  });

  // Start animating the text after getting the full result
  await _startTypingEffect();
  generateAndPrintPdf();
  controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
  
}

final ScrollController _scrollController = ScrollController();

Future<void> generateAndPrintPdf() async {
  final pdf = pw.Document();

  // Load NotoSans from Google Fonts (built-in to package)
  final ttf = await PdfGoogleFonts.notoSansRegular();

 pdf.addPage(
  pw.MultiPage(
    theme: pw.ThemeData.withFont(base: ttf),
    build: (context) => [
      pw.Paragraph(text: _fullResponse),
    ],
  ),
);


  // Display the PDF preview or allow sharing/printing
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );

}


Future<void> _startTypingEffect() async {
  _animatedResponse = "";
  
  for (int i = 0; i < _fullResponse.length; i++) {
    await Future.delayed(const Duration(milliseconds: 30)); // Adjust speed here
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


PageController controller = PageController();


bool isLoading = false;

List<String> flashcards = [];

Future<void> createFlashcards() async {

  await controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
  setState(() {
      isLoading = true;
  });

  try {
    await FirebaseFirestore.instance.collection('users').doc(uid).collection('Ai Knowbies Lesson').add({
      'video ID':videoID, 
      'date':DateTime.now(),
      'explanation':_fullResponse
  });

  String prompt = "Generate a list of questions and/or exercises about the following lesson, ranging from easy to medium to hard: $_fullResponse. NOTE: Each question or exercise MUST be separated by one completely empty line. Do not write anything other than the questions or exercises. Write the questions and/or exercises using the same language the proposed topic was written in.";
  final flashcardResults = await GeminiService.generateContent(prompt);

  setState(() {
    flashcards = flashcardResults
      .split(RegExp(r'\n\s*\n')) // handles any whitespace in the empty line
      .map((q) => q.trim())      // remove extra spaces around each question
      .where((q) => q.isNotEmpty) // remove any accidental empty strings
      .toList();
  });

  print(flashcards);

  QuerySnapshot lessonReference = await FirebaseFirestore.instance.collection('users').doc(uid).collection('Ai Knowbies Lesson').orderBy('date', descending: true).get();

  for (int i = 0; i < flashcards.length; i++) {
    await FirebaseFirestore.instance.collection('users').doc(uid).collection('Ai Knowbies Lesson').doc(lessonReference.docs.first.id).collection('Ai Knowbies Lesson').add({
      'answer':'', 
      'question':flashcards[i]
  });
  }

  setState(() {
    isLoading = false;
  });

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Success! Your lesson and flashcards both got saved.')));
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Something went wrong. Could not save lesson or create flashcards.')));
  }
               
  


}


// card swiper
// Initially selected random color
  Color? _containerColor;

  // Function to get a random color from the list
  Color? getRandomColor() {
    final random = Random();
    return br.colors[random.nextInt(br.colors.length)];
  }

  @override
  void initState() {
    super.initState();
    // Set an initial random color
    _containerColor = getRandomColor();
  }

  // Function to change the color
  void changeColor() {
    setState(() {
      _containerColor = getRandomColor();
    });
  }

  int index = 1;

@override
void dispose() {
  _scrollController.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: br.white,
        child: Center(
          child: SmoothPageIndicator(
            effect: ExpandingDotsEffect(
              dotHeight: 7,
              dotWidth: 7,
              dotColor: Colors.grey[400]!,
              activeDotColor: Colors.red
            ),
            controller: controller, 
            count: 5
          ),
        ),
      ),
      backgroundColor: br.white,
      appBar: AppBar(
        backgroundColor: br.white,
        iconTheme: IconThemeData(
          size: 20,
          color: Colors.grey[400]
        ),
      ),
      body: PageView(
        
        controller: controller,
        physics: NeverScrollableScrollPhysics(),
        children: [

          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [

                   Padding(
                     padding: const EdgeInsets.only(bottom: 20.0),
                     child: ListTile(
                      leading: Lottie.asset('lib/animation/youtube.json'),
                                     title: Text('BOB',
                                     style: GoogleFonts.viga(
                                       color: br.black,
                                       fontSize: 17
                                     ),
                                   ),
                                   
                                 ),
                   ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: ListTile(
                                    title: Text('INSERT A VALID YOUTUBE URL AND \nWE WILL TAKE CARE OF THE REST!',
                                    style: GoogleFonts.viga(
                    color: br.black,
                    fontSize: 14
                                    ),
                                  ),
                                  
                                ),
                  ),
            
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                    child: TextField(
                      autofocus: autoFocus,
                      cursorColor: const Color.fromARGB(255, 219, 45, 45),
                      controller: id,
                                  decoration: InputDecoration(
                                    hintText: 'insert valid youtube url',
                                    hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                                    enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: const Color.fromARGB(255, 219, 45, 45)),
                                    ),
                                    filled: false, // no inside fill color
                                  ),
                                ),
                  ), 


                  exists == false ? ListTile(
                    title: Text('Invalid YouTube URL',
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.w500
                    ),
                    ),
                  ) 
                  
                  : Container(),


                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.red),
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                          ))
                        ),
                        onPressed: () => doesYouTubeVideoExist(context),
                        child: Text('NEXT',
                        style: GoogleFonts.viga(
                          color: br.white
                        ),
                        )
                      ),
                    ),
                  ),
            
            
            
                ],
              ),
            ),
          ),



          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('lib/animation/youtube.json', height: 200),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text('BOB',
                style: GoogleFonts.viga(
                  color: br.black,
                  fontSize: 17
                ),
                ),
              ),

              Text('RETRIEVING SUBTITLES...',
              style: GoogleFonts.viga(
                color: br.black,
                fontSize: 15
              ),
              )
            ],
          ),


          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
          
              Lottie.asset('lib/animation/pdf.json', height: 100),

               Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text('MIA',
                style: GoogleFonts.viga(
                  color: br.black,
                  fontSize: 17
                ),
                ),
              ),

              Text('CREATING YOUR LESSON \nIN THE FORM OF A PDF...\nPLEASE DO NOT LEAVE THIS PAGE',
              textAlign: TextAlign.center,
              style: GoogleFonts.viga(
                color: br.black,
                fontSize: 15
              ),
              ),

              Expanded(
                child: Container(
                   margin: EdgeInsets.only(
                          left: 15,
                          right: 15,
                          top: 20
                        ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey[500]!,
                          width: 1.2
                        )
                      ),
                  height: 300,

                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    controller: _scrollController,
                    child: ListTile(
                      title: Text(_animatedResponse,
                      style: TextStyle(
                        fontFamily: 'NotoSans',
                        color: br.black,
                        fontSize: 14
                      ),
                      ),
                    ),
                  ),
                ),

              )
            ],
          ),
        
        
        Column(
          children: [
             Lottie.asset('lib/animation/pdf.json', height: 200),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text('MIA',
                style: GoogleFonts.viga(
                  color: br.black,
                  fontSize: 17
                ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Text('YOUR LESSON IS READY! \nWE RECOMMEND SAVING IT TO YOUR DEVICE.',
                textAlign: TextAlign.center,
                style: GoogleFonts.viga(
                  color: br.black,
                  fontSize: 15
                ),
                ),
              ),

              SizedBox(
                height: 15,
              ),

              Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.green),
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                          ))
                        ),
                        onPressed: generateAndPrintPdf,
                        child: Text('VIEW PDF',
                        style: GoogleFonts.viga(
                          color: br.white
                        ),
                        )
                      ), 
                    ),
                  ),



                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                                  children: [
                                    Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: TextButton(
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(Colors.blue),
                                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                    ))
                                  ),
                                  onPressed: createFlashcards,
                                  child: Text('CREATE \nFLASHCARDS',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.viga(
                                    color: br.white
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
                                    backgroundColor: WidgetStatePropertyAll(Colors.red),
                                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                    ))
                                  ),
                                  onPressed: () async {

                                    setState(() {
                                      isLoading = true;
                                    });


                                    try {
                                      await FirebaseFirestore.instance.collection('users').doc(uid).collection('Ai Knowbies Lesson').add({
                                        'video ID':videoID, 
                                        'date':DateTime.now(),
                                        'explanation':_fullResponse
                                      });
                                     
                                      Navigator.pop(context);

                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lesson saved. Access it anytime.')));

                                    } catch (e) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Something went wrong. If the lesson is too long, save it to your files on your phone.')));
                                    }
                                  },
                                  child: Text('SAVE \nLESSON',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.viga(
                                    color: br.white
                                  ),
                                  )
                                ),
                    ),
                                    ),
                                  ],
                                ),
                  ), 
            

            isLoading == true ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: CircularProgressIndicator.adaptive(),
            ) : Container()
          ],
        ),


        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            isLoading == true && flashcards.length <= 2 ? Column(
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
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Text('CREATING YOUR FLASHCARDS...\nPLEASE DO NOT LEAVE THIS PAGE',
                textAlign: TextAlign.center,
                style: GoogleFonts.viga(
                  color: br.black,
                  fontSize: 15
                ),
                ),
              ),
              ],
            ) 
            
            
            : flashcards.length >= 2 ? 
            
            Expanded(
              child: CardSwiper(
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
                                child: Text("${index + 1}) ${flashcards[index].toUpperCase()}",
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
                            ),
            )  : Container()



          ],
        ),
        
        ],
      ),
    );
  }
}