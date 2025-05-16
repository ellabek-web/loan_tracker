import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loan_tracker/screens/home_page.dart';
import 'package:loan_tracker/screens/login_page.dart';
import 'package:loan_tracker/screens/splash.dart';
import 'package:loan_tracker/screens/group_page.dart'; // Add this import

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/group',
      name: 'group',
      builder: (context, state) => CbeStaffPage(), // Add this route
    ),
  ],
);
