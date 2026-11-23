import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/auth_screen.dart';
import 'screens/home_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBQzzwIN4p6TC1DoBh_G7MH3tmce86RP0U',
      appId: '1:856867752468:android:68330df2fb608f58323501',
      messagingSenderId: '856867752468',
      projectId: 'mashharawifamily-84661',
      storageBucket: 'mashharawifamily-84661.firebasestorage.app',
    ),
  );
  runApp(const MashharawiApp());
}

class MashharawiApp extends StatelessWidget {
  const MashharawiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ملتقى عائلة المشهراوي',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'AE'),
      supportedLocales: const [Locale('ar', 'AE')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            return const HomeLayout();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
