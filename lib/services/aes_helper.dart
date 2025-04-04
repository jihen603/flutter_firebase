import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';

class AESHelper {
  // Clé et IV identiques à l'Arduino (16 octets)
  static final _key = encrypt.Key.fromUtf8('1234567890ABCDEF');
  static final _iv = encrypt.IV.fromUtf8('ABCDEFGHIJKLMNOP');

  static final _encrypter = encrypt.Encrypter(
    encrypt.AES(
      _key,
      mode: encrypt.AESMode.cbc,
      padding: 'PKCS7',
    ),
  );

  /// Décrypte les données Firebase avec gestion d'erreur améliorée
  static String decryptFirebaseData(String encryptedData) {
    try {
      if (encryptedData.isEmpty) return '0.0';

      // Nettoyage Base64
      final cleaned = encryptedData
          .replaceAll(RegExp(r'[^a-zA-Z0-9+/=]'), '')
          .trim();

      // Padding Base64 si nécessaire
      final padded = cleaned.padRight(
          cleaned.length + (4 - cleaned.length % 4) % 4,
          '='
      );

      // Décodage et décryptage
      final bytes = base64.decode(padded);
      final decrypted = _encrypter.decryptBytes(encrypt.Encrypted(bytes), iv: _iv);

      // Suppression du padding PKCS7
      final padValue = decrypted.last;
      final result = utf8.decode(decrypted.sublist(0, decrypted.length - padValue));

      if (kDebugMode) {
        print('Décryptage réussi [$encryptedData] -> $result');
      }

      return result;
    } catch (e, stack) {
      if (kDebugMode) {
        print('''
⚠️ ERREUR de décryptage
Donnée: $encryptedData
Erreur: $e
Stack: $stack
''');
      }
      return '0.0'; // Valeur par défaut sécurisée
    }
  }

  /// Test de compatibilité Arduino-Flutter
  static void testDecryption() {
    const testValues = {
      'U2FsdGVkX19D5x8g7Z7nTq1JZ5YwD3z7J9Kp2vW1X0=': '25.5', // Exemple de donnée chiffrée
      'U2FsdGVkX1+3KZQ4n5qz9q0NTY5JZQ==': '1'               // Format vibration
    };

    testValues.forEach((encrypted, expected) {
      final result = decryptFirebaseData(encrypted);
      print('Test: $encrypted -> $result (attendu: $expected)');
      assert(result == expected, 'Échec du test de décryptage');
    });
  }
}