import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:untitled123/src/constants/image_strings.dart';
import 'package:untitled123/src/constants/sizes.dart';
import 'package:untitled123/src/constants/text_strings.dart';
import 'package:untitled123/src/features/authentification/form_header_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgetPasswordPhoneScreen extends StatelessWidget {
  const ForgetPasswordPhoneScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    final FirebaseAuth _auth = FirebaseAuth.instance;

    // Fonction pour envoyer le code OTP via Firebase
    void _sendOTP() async {
      final phoneNumber = phoneController.text.trim();
      if (phoneNumber.isEmpty) {
        Fluttertoast.showToast(msg: "Please enter a phone number");
        return;
      }

      // Demander un code OTP via Firebase
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Si la vérification est automatique (par exemple sur Android avec SIM)
          await _auth.signInWithCredential(credential);
          Navigator.pushReplacementNamed(context, '/welcomeScreen');
        },
        verificationFailed: (FirebaseAuthException e) {
          Fluttertoast.showToast(msg: e.message ?? "Verification failed");
        },
        codeSent: (String verificationId, int? resendToken) {
          // Si un code OTP a été envoyé, naviguer vers l'écran OTP
          Navigator.pushNamed(context, '/otpScreen', arguments: verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgroundd.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(tDefaultSize),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: tDefaultSize * 4),
                const FormHeaderWidget(
                  image: tForgetPasswordImage,
                  title: tForgetPassword,
                  subTitle: tForgetPhoneSubTitle,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  heightBetween: 30.0,
                ),
                const SizedBox(height: 30),
                const Icon(Icons.phone, size: 60, color: Colors.white),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: "Enter your phone number",
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.phone_outlined, color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                    ),
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Phone number cannot be empty';
                      } else if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(value)) {
                        return 'Enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Appeler la fonction pour envoyer l'OTP
                        _sendOTP();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text("Next", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
