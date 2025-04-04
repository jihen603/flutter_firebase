import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Ajoutez cette importation
import 'package:untitled123/firebase_options.dart';
import 'package:untitled123/services/iot_data_firebase.dart';
import 'package:untitled123/src/features/authentification/screens/AdminDashboard.dart';
import 'package:untitled123/src/features/authentification/screens/forget_password/forget_password_otp/otp_screen.dart';
import 'package:untitled123/src/features/authentification/screens/iot%20dashboard/sensordashboardscreen.dart';
import 'package:untitled123/src/features/authentification/screens/login_screen.dart';
import 'package:untitled123/src/features/authentification/screens/signup/signup.dart';
import 'package:untitled123/src/features/authentification/screens/splash_screen/splash_screen.dart';
import 'package:untitled123/src/features/authentification/screens/welcome/welcome_screen.dart';
import 'package:untitled123/src/utils/theme/theme.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );

  runApp(
    MultiProvider( // Enveloppez votre application avec MultiProvider
      providers: [
        Provider<IotDataFirebase>(create: (_) => IotDataFirebase()), // Ajoutez votre service
        // Vous pouvez ajouter d'autres providers ici si nécessaire
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(role: 'operator'),
        '/signup': (context) => const SignUpScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/otpScreen': (context) => OTPScreen(),
        '/adminDashboard': (context) => const AdminDashboard(),
        '/sensor_dashboard': (context) => SensorDataPage(),
      },
    );
  }
}