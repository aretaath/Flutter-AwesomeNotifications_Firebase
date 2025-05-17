import 'package:flutter_firebase/screens/home.dart';
import 'package:flutter_firebase/screens/signin.dart';
import 'package:flutter_firebase/screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'timer_channel',
      channelName: 'Timer Notifications',
      channelDescription: 'Timer finished notification',
      defaultColor: const Color(0xFF9050DD),
      ledColor: Colors.white,
      importance: NotificationImportance.High,
    ),
  ], debug: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'signin',
      routes: {
        'home': (context) => const HomeScreen(),
        'signin': (context) => const SigninScreen(),
        'signup': (context) => const SignupScreen(),
      },
    );
  }
}
