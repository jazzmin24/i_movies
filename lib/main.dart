import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:imovies/firebase_options.dart';

import 'package:imovies/pages/AuthPages/otp.dart';
import 'package:imovies/pages/AuthPages/phone.dart';
import 'package:imovies/pages/screens/detailded_view.dart';
import 'package:imovies/pages/screens/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(     
      debugShowCheckedModeBanner: false,
      initialRoute: 'home',
      routes: {'phone': (context) => MyPhone(), 
      'otp': (context) => MyOtp(),
       'home': (context) => MyHome(),
       'details':(context) => DetailedView(title: 'title', description: 'description', location: 'location', image: 'image',),
      },
      // home: MyPhone(),
    );
  }
}


