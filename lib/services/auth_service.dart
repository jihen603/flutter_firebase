import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:untitled123/src/features/authentification/screens/login_screen.dart';
import 'package:untitled123/src/features/authentification/screens/welcome/welcome_screen.dart';

class AuthService {

  // SIGNUP FUNCTION
  Future<bool> signup({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Afficher un message de succès
      Fluttertoast.showToast(
        msg: "Account created successfully!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 14.0,
      );

      // Redirection vers la page Welcome
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );

      return true; // Succès
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email.';
      } else {
        message = "Signup failed. Please try again.";
      }

      // Afficher l'erreur avec un Toast
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );

      return false; // Échec
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An unexpected error occurred.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );

      return false; // Échec
    }
  }

  // LOGIN FUNCTION
  Future<bool> login({
    required String email,
    required String password,
    required String role, // Ajout du paramètre role ici
    required BuildContext context,
  }) async {
    try {
      // Connexion à Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Message de succès
      Fluttertoast.showToast(
        msg: "Login successful!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 14.0,
      );

      // Redirection selon le rôle de l'utilisateur
      if (role == 'Administrator') {
        // Rediriger vers une page spécifique pour les administrateurs
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WelcomeScreen()),
        );
      } else if (role == 'Operator') {
        // Rediriger vers une autre page pour les opérateurs (si nécessaire)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WelcomeScreen()), // Remplacez par une page spécifique si nécessaire
        );
      } else {
        // Redirection par défaut si le rôle n'est pas défini
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WelcomeScreen()),
        );
      }

      return true; // Succès
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'invalid-email') {
        message = 'No user found for that email.';
      } else if (e.code == 'invalid-credential') {
        message = 'Wrong password provided for that user.';
      } else {
        message = "Login failed. Please try again.";
      }

      // Afficher un message d'erreur
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );

      return false; // Échec
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An unexpected error occurred.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );

      return false; // Échec
    }
  }

  // SIGNOUT FUNCTION
  Future<void> signout({required BuildContext context}) async {
    await FirebaseAuth.instance.signOut();

    // Redirection vers LoginScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen(role: '')), // Passez un rôle vide ici, car l'utilisateur se déconnecte
    );
  }
}
