import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';

class AESHelper {
  // Configuration identique à Arduino
  static final _key = encrypt.Key.fromUtf8('1234567890ABCDEF');
  static final _iv = encrypt.IV.fromUtf8('ABCDEFGHIJKLMNOP');

  static final _encrypter = encrypt.Encrypter(
    encrypt.AES(
      _key,
      mode: encrypt.AESMode.cbc,
      padding: null, // Désactive le padding automatique
    ),
  );

  static String decryptFirebaseData(String encryptedData) {
    try {
      // Nettoyage rigoureux
      final cleaned = encryptedData
          .replaceAll(RegExp(r'[^a-zA-Z0-9+/=]'), '')
          .trim();

      // Padding Base64 si nécessaire
      final padded = cleaned.padRight(
          cleaned.length + (4 - cleaned.length % 4) % 4,
          '='
      );

      // Décodage Base64
      final bytes = base64.decode(padded);

      // Décryptage sans gestion automatique du padding
      final decrypted = _encrypter.decryptBytes(
        encrypt.Encrypted(bytes),
        iv: _iv,
      );

      // Gestion manuelle du padding PKCS7
      final padLength = decrypted.last;
      final validLength = decrypted.length - padLength;

      if (padLength > 16 || padLength < 1 || validLength < 0) {
        throw Exception('Padding invalide');
      }

      // Conversion en String
      final result = utf8.decode(decrypted.sublist(0, validLength));

      debugPrint('Déchiffrage réussi: $result');
      return result;
    } catch (e, stack) {
      debugPrint('''
⚠️ ERREUR CRITIQUE
Donnée: $encryptedData
Erreur: ${e.toString()}
Stack: ${stack.toString()}
''');
      return '0.0';
    }
  }

  // Test de compatibilité
  static void testDecryption() {
    const testData = {
      'U2FsdGVkX19D5x8g7Z7nTq1JZ5YwD3z7J9Kp2vW1X0=': '25.5',
      'U2FsdGVkX1+3KZQ4n5qz9q0NTY5JZQ==': '1'
    };

    testData.forEach((encrypted, expected) {
      final result = decryptFirebaseData(encrypted);
      assert(result == expected, 'Échec du test: $encrypted -> $result (attendu: $expected)');
    });
  }
}