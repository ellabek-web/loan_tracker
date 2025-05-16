import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loan_tracker/screens/home_page.dart';
import 'package:loan_tracker/screens/login_page.dart';
import 'package:loan_tracker/screens/signUp_page.dart';
import 'package:loan_tracker/screens/splash';

final GoRouter appRouter =GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/',
    name: 'splash',
    builder: (context, state) =>  SplashScreen(),),

    GoRoute(path: '/login',
    name: 'login',
    builder: (context, state) => const LoginScreen(),),
   
    GoRoute(path: '/home',
    name: 'home',
    builder: (context, state) => const HomePage(),),
// /SignUpPage
 GoRoute(path: '/SignUpPage',
    name: 'SignUpPage',
    builder: (context, state) => const SignUpPage(),),

  ]
  );