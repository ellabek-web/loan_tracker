import 'package:flutter/material.dart';
import 'package:loan_tracker/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:loan_tracker/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Add other providers here
      ],
      child: const App(),
    ),
  );
}