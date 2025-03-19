import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled123/src/constants/sizes.dart';
import 'package:untitled123/src/constants/text_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({Key? key}) : super(key: key);

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String verificationId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Récupérer le verificationId passé depuis l'écran précédent
    verificationId = ModalRoute.of(context)!.settings.arguments as String;
    print("Verification ID: $verificationId"); // Log de verificationId
  }

  // Fonction pour vérifier le code OTP
  void _verifyOTP(String code) async {
    if (code.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter the OTP code");
      return;
    }

    try {
      // Crée un PhoneAuthCredential avec l'OTP entré
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );

      // Essayer de connecter l'utilisateur avec l'OTP
      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Si la connexion réussit, naviguer vers l'écran d'accueil
        Navigator.pushReplacementNamed(context, '/welcomeScreen');
      } else {
        Fluttertoast.showToast(msg: "Failed to sign in, please try again");
      }
    } catch (e) {
      print("Error during OTP verification: $e"); // Log d'erreur détaillé
      Fluttertoast.showToast(msg: "Invalid OTP, please try again");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A90E2), Color(0xFF1453A5)], // Bleu dégradé
          ),
        ),
        padding: const EdgeInsets.all(tDefaultSize),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tOtpTitle,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 28.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10.0),
            Text(
              tOtpSubTitle.toUpperCase(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40.0),
            Text(
              "$tOtpMessage at your E-Mail",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20.0),

            // Champ OTP
            OtpTextField(
              numberOfFields: 6,
              fillColor: Colors.white.withOpacity(0.2),
              filled: true,
              textStyle: const TextStyle(color: Colors.white),
              onSubmit: (code) {
                print("OTP entered: $code");
                _verifyOTP(code); // Vérifier l'OTP et passer à l'écran de bienvenue
              },
            ),
          ],
        ),
      ),
    );
  }
}
