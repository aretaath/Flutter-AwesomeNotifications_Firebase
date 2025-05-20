# Flutter Simple Application

| Name  | Areta Athayayumna Arwaa |
|-------|-------------------------|
| NRP   | 5025221068              |


## Explanation and Flow
1. In `main.dart`, Firebase is set up first before being used. The `Firebase.initializeApp()` function prepares the connection to Firebase. Then, the app connects to the Firebase project using the `firebase_options.dart` file.

```
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

```

3. In `signin.dart`, the email and password entered during sign in are saved to Firebase Authentication. If sign in is successful the screen will switch to the Homescreen using Navigator.pushReplacementNamed(context, 'home') with the function `navigateHome()`. `navigateRegister()` for switch to the sign up screen.

```
  void signIn() async {
    setState(() {
      _isLoading = true;
      _errorCode = "";
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      navigateHome();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorCode = e.code;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }
```

4. In `signup.dart`, users can create a new account using Firebase Auth. After signing up successfully, they are taken back to the login screen. 

```
  void signUp() async {
    setState(() {
      _isLoading = true;
      _errorCode = "";
    });

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorCode = "Please fill all fields";
        _isLoading = false;
      });
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() {
        _errorCode = "Password must be at least 6 characters";
        _isLoading = false;
      });
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(
        context,
        'signin',
        arguments: 'Your registration has been successful. Please sign in.',
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorCode = e.code;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }
```

5. In `home.dart`, when the logout button is pressed, the user session is removed `FirebaseAuth.instance.signOut()`, and the app goes back to the `SignInScreen` because `authStateChanges` detects the logout.

```
void signout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, 'signin');
    }
  }
```

6. In `main.dart`, Awesome Notifications is used to show a notification when the timer ends. Before that, the notification system is initialized using a channel called `timer_channel`.

```
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
```

7. Then, in `home.dart` the notification shows a simple alert when time is up by calling `showNotif()`, and the channelKey must match the one initialized earlier.

```
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
```

8. The timer logic triggers the notification. The timer runs every second, and when the time reaches 0, the timer stops and `showNotif()` is called.


```
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

```

## Result
![Image](https://github.com/user-attachments/assets/97066dfc-f5a0-493d-86e1-0499bd2b94f3)
![Image](https://github.com/user-attachments/assets/147bc8ff-b0d6-4552-9496-8464729f4080)
![Image](https://github.com/user-attachments/assets/c06a6115-e26b-4ab1-b350-60c987cf93c6)
![Image](https://github.com/user-attachments/assets/36423506-3713-4707-887d-236d54a491ac)

## Reference
https://github.com/agusbudi/mobile-programming/tree/main/09.%20Firebase%20Auth