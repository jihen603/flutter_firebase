import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  TextEditingController otpController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    verificationId = ModalRoute.of(context)!.settings.arguments as String;
    print("Verification ID: $verificationId");  // Log du verificationId
  }

  // Vérification de l'OTP
  void _verifyOTP() async {
    String code = otpController.text.trim();
    if (code.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter the OTP code");
      return;
    }

    print("Entered OTP: $code");  // Log du code OTP saisi

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );

      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        Navigator.pushReplacementNamed(context, '/welcomeScreen');
      } else {
        Fluttertoast.showToast(msg: "Failed to sign in, please try again");
      }
    } catch (e) {
      print("Error during OTP verification: $e");  // Log détaillé
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "OTP Verification",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10.0),
            Text(
              "Enter the OTP sent to your phone",
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40.0),
            TextField(
              controller: otpController,
              decoration: InputDecoration(
                labelText: "Enter OTP",
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              maxLength: 6,  // Limite de caractères à 6 chiffres pour l'OTP
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _verifyOTP,
              child: Text(
                "Verify OTP",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Remplacement de 'primary' par 'backgroundColor'
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

