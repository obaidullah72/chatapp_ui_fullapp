import 'dart:async';
import 'package:fluter_chat_app_provider/main.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the home screen after 5 seconds
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => AuthenticationWrapper()));
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E44AD), Color(0xFF6C3483)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie animation
              Lottie.asset(
                'assets/chatapp.json',
                width: MediaQuery.of(context).size.width,
                height: 350,
              ),
              Text(
                'ChatApp',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              // Tagline
              Text(
                'Connect. Communicate. Collaborate.',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 26,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              // Lottie.asset(
              //   'assets/loading.json', // Replace with your custom loading animation
              //   width: MediaQuery.of(context).size.width,
              //   height: 300,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
