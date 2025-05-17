import 'package:flutter_firebase/screens/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _countdown;
  int _timeRemain = 0;
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;

  void notifPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  @override
  void initState() {
    super.initState();
    notifPermission();
  }

  void startTimer(int seconds) {
    if (_countdown != null) {
      _countdown!.cancel();
    }

    setState(() {
      _timeRemain = seconds;
    });

    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemain > 1) {
          _timeRemain--;
        } else {
          timer.cancel();
          _timeRemain = 0;
          showNotif();
        }
      });
    });
  }

  void cancelTimer() {
    if (_countdown != null) {
      _countdown!.cancel();
      _countdown = null;
      setState(() {
        _timeRemain = 0;
      });
    }
  }

  void showNotif() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'timer_channel',
        title: 'Time is Up!',
        body: 'Your timer has finished.',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  void signout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, 'signin');
    }
  }

  String formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  List<DropdownMenuItem<int>> dropdownTime(int max) {
    return List.generate(
      max + 1,
      (index) => DropdownMenuItem(
        value: index,
        child: Text(index.toString().padLeft(2, '0')),
      ),
    );
  }

  Widget dropdownStyle({
    required int value,
    required List<DropdownMenuItem<int>> items,
    required ValueChanged<int?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromARGB(255, 64, 80, 143)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: DropdownButton<int>(
        value: value,
        items: items,
        onChanged: onChanged,
        underline: const SizedBox(),
        style: const TextStyle(
          color: Color.fromARGB(255, 64, 80, 143),
          fontSize: 16,
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SigninScreen();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Timer'),
            centerTitle: true,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.account_circle,
                  size: 36,
                  color: Color.fromARGB(255, 64, 80, 143),
                ),
                onSelected: (value) {
                  if (value == 'signout') {
                    signout(context);
                  }
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem<String>(
                        value: 'email',
                        enabled: false,
                        child: Text(snapshot.data?.email ?? 'No email'),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'signout',
                        child: Text('Sign Out'),
                      ),
                    ],
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Text('Hours'),
                        dropdownStyle(
                          value: _hours,
                          items: dropdownTime(23),
                          onChanged: (value) => setState(() => _hours = value!),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Minutes'),
                        dropdownStyle(
                          value: _minutes,
                          items: dropdownTime(59),
                          onChanged:
                              (value) => setState(() => _minutes = value!),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Seconds'),
                        dropdownStyle(
                          value: _seconds,
                          items: dropdownTime(59),
                          onChanged:
                              (value) => setState(() => _seconds = value!),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        final totalSeconds =
                            _hours * 3600 + _minutes * 60 + _seconds;
                        if (totalSeconds > 0) {
                          startTimer(totalSeconds);
                        }
                      },
                      child: const Text('Start Timer'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: cancelTimer,
                      child: const Text('Cancel Timer'),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                if (_timeRemain > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Remaining time: ',
                          style: TextStyle(
                            fontSize: 18,
                            color: const Color.fromARGB(255, 64, 80, 143),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          formatTime(_timeRemain),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 64, 80, 143),
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
