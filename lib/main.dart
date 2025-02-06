import 'registration_screen.dart';
import 'home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

// If you generated firebase_options.dart using the FlutterFire CLI, you can import it:
// import 'firebase_options.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MicrofinanceApp());
}

class MicrofinanceApp extends StatelessWidget {
  const MicrofinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Microfinance App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(), // The starting screen
      debugShowCheckedModeBanner: false,
    );
  }
}
