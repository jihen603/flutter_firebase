import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onFailed,
  }) async {
    print("Attempting to verify phone number: $phoneNumber");  // Log du numéro de téléphone
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        Fluttertoast.showToast(
          msg: "Phone number verified successfully!",
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        print("Verification failed: ${e.message}");  // Log de l'erreur
        onFailed(e.message ?? "Verification failed");
      },
      codeSent: (String verificationId, int? resendToken) {
        print("Verification code sent to: $phoneNumber");  // Log de l'envoi du code
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<bool> signInWithOTP(String verificationId, String smsCode) async {
    print("Attempting to sign in with OTP: $smsCode");  // Log du code OTP
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);
      Fluttertoast.showToast(
        msg: "Login successful!",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      return true;
    } catch (e) {
      print("Error: OTP invalid or verification failed. ${e.toString()}");  // Log détaillé
      Fluttertoast.showToast(
        msg: "Invalid OTP. Please try again.",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return false;
    }
  }
}

