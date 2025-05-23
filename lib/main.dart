import 'package:flutter/material.dart';
import 'package:loan_tracker/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:loan_tracker/providers/auth_provider.dart';
import 'package:loan_tracker/providers/group_provider.dart';
import 'package:loan_tracker/providers/user_service.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';


 


void main() async {
  debugPrint("App started!");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        

         ChangeNotifierProvider(create: (_) => UserServiceProvider()),
    ChangeNotifierProxyProvider<UserServiceProvider, GroupProvider>(
      create: (_) => GroupProvider(UserServiceProvider()),
      update: (_, userService, __) => GroupProvider(userService),
    ),

        // Add other providers here
      ],
      child: const App(),
    ),
  );
}