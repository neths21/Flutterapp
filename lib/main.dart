import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kanye Quotes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      home: LoginScreen(),
    );
  }
}

// ---------------- LOGIN SCREEN ----------------
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';

  void login() {
    if (usernameController.text == 'user' &&
        passwordController.text == 'pass') {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => QuoteScreen()));
    } else {
      setState(() {
        errorMessage = 'Invalid username or password';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Kanye Propaganda',
                style: GoogleFonts.roboto(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 30),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: login,
                child: Text('Login'),
              ),
              SizedBox(height: 10),
              Text(
                errorMessage,
                style: TextStyle(color: Colors.redAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- QUOTE SCREEN ----------------
class QuoteScreen extends StatefulWidget {
  @override
  _QuoteScreenState createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  String quote = "Tap Kanye to get a quote!";
  bool showBubble = false;
  final AudioPlayer audioPlayer = AudioPlayer();

  Future<void> fetchQuote() async {
    final response = await http.get(Uri.parse('https://api.kanye.rest'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        quote = data['quote'];
        showBubble = true;
      });

      // Play the song (local asset)
      await audioPlayer.play(AssetSource('audio/cant_tell_me_nothing.mp3'));

      // Hide bubble after 3 seconds
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          showBubble = false;
        });
      });
    } else {
      setState(() {
        quote = "Failed to fetch quote.";
        showBubble = true; // show error bubble
      });
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kanye Propaganda"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Kanye image button
            GestureDetector(
              onTap: fetchQuote,
              child: Image.asset(
                'assets/images/kanye.jpg',
                width: 250,
                height: 250,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 30),

            // Quote bubble with fade animation
            AnimatedOpacity(
              opacity: showBubble ? 1 : 0,
              duration: Duration(milliseconds: 300),
              child: Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  quote,
                  style: GoogleFonts.roboto(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
