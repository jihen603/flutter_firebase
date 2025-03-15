import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:untitled123/src/features/authentification/screens/forget_password/forget_password_mail/forget_password_mail.dart';
import 'package:untitled123/src/features/authentification/screens/forget_password/forget_password_phone/forget_password_phone.dart';

import '../../../../../constants/sizes.dart';
import '../../../../../constants/text_strings.dart';
import '../../login_screen.dart';
import 'forget_password_btn_widget.dart';

class ForgetPasswordScreen {
  static Future<dynamic> buildShowModalBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      backgroundColor: Colors.transparent, // Permet de voir l'image de fond
      builder: (context) => Stack(
        children: [
          // Image de fond
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgroundd.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Effet de flou
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.2), // Légère opacité pour améliorer la lisibilité
              ),
            ),
          ),
          // Contenu de la Bottom Sheet
          Padding(
            padding: const EdgeInsets.all(tDefaultSize),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  tForgetPasswordTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  tForgetPasswordSubTitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 25),
                ForgetPasswordButtonWidget(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgetPasswordMailScreen(),
                      ),
                    );
                  },
                  btnIcon: Icons.email_outlined,
                  iconColor: Colors.white,
                  title: tEmail,
                  subTitle: tResetViaEMail,
                ),
                const SizedBox(height: 15),
                ForgetPasswordButtonWidget(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgetPasswordPhoneScreen(),
                      ),
                    );
                  },
                  btnIcon: Icons.phone_android_rounded,
                  iconColor: Colors.white,
                  title: tPhone,
                  subTitle: tResetViaPhone,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}