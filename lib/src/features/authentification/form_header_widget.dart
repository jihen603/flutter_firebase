import 'package:flutter/material.dart';

class FormHeaderWidget extends StatelessWidget {
  final String image, title, subTitle;
  final double heightBetween;
  final CrossAxisAlignment crossAxisAlignment;

  const FormHeaderWidget({
    Key? key,
    required this.image,
    required this.title,
    required this.subTitle,
    this.heightBetween = 20.0, // Valeur par défaut
    this.crossAxisAlignment = CrossAxisAlignment.center, // Valeur par défaut
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        // Affichage de l'image (taille fixe à 150 pixels de hauteur)
        Image.asset(image, height: 150),
        SizedBox(height: heightBetween), // Espacement entre l'image et le titre
        Text(
          title, // Affichage du titre
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold, // Titre en gras
          ),
          textAlign: TextAlign.center, // Centrage du titre
        ),
        SizedBox(height: heightBetween / 2), // Espacement entre le titre et le sous-titre
        Text(
          subTitle, // Affichage du sous-titre
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center, // Centrage du sous-titre
        ),
      ],
    );
  }
}