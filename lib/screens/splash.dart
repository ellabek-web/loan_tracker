import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 2), () {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // User is logged in
        context.goNamed('home'); // or context.go('/home');
      } else {
        // Not logged in
        context.goNamed('login'); // or context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/splash1.svg',
            ),
            SizedBox(height: 20),
            Text(
              'Loan Tracker',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
