import 'package:flutter/material.dart';

class ForgetPasswordButtonWidget extends StatelessWidget {
  final IconData btnIcon;
  final String title, subTitle;
  final VoidCallback onTap;
  final Color iconColor; // Ajout de la couleur de l'icône

  const ForgetPasswordButtonWidget({
    Key? key,
    required this.btnIcon,
    required this.title,
    required this.subTitle,
    required this.onTap,
    required this.iconColor, // Ajout de la couleur de l'icône
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.blueAccent,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.grey.shade200,
          boxShadow: [
            BoxShadow(blurRadius: 5.0, color: Colors.grey.shade400),
          ],
        ),
        child: Row(
          children: [
            Icon(
              btnIcon,
              size: 40.0,
              color: iconColor, // Utilisation de la couleur dynamique
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subTitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}