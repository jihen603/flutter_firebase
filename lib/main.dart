import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:untitled123/firebase_options.dart';
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

  // Initialiser Firebase Cloud Messaging
  await FirebaseMessaging.instance.requestPermission();

  // Obtenir le token FCM
  String? token = await FirebaseMessaging.instance.getToken();
  print("FCM Token: $token");

  // Écouter les notifications en arrière-plan
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Notification reçue: ${message.notification?.title}");
    // Gérer l'affichage de la notification ici
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("Notification ouverte depuis l'arrière-plan: ${message.notification?.title}");
    // Naviguer vers un écran spécifique, si nécessaire
  });

  runApp(const MyApp());
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
        '/sensor_dashboard': (context) => SensorDashboard(),
      },
    );
  }
}
