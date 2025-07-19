
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:studystudio/authentication/auth.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBk-jeW0ZFQ4PEoUqDmaUh1JlbpeMtGfRk",
  authDomain: "study-studio-783c8.firebaseapp.com",
  projectId: "study-studio-783c8",
  storageBucket: "study-studio-783c8.firebasestorage.app",
  messagingSenderId: "434750096218",
  appId: "1:434750096218:web:c40b3648128d24f68b6963",
  measurementId: "G-38BGP4PMVT"
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AuthPage()
    );
  }
}

