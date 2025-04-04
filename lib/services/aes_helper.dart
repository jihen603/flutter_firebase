import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';

class AESHelper {
  // Configuration identique à Arduino
  static final _key = encrypt.Key.fromUtf8('1234567890ABCDEF');
  static final _iv = encrypt.IV.fromUtf8('ABCDEFGHIJKLMNOP');

  static final _encrypter = encrypt.Encrypter(
    encrypt.AES(_key, mode: encrypt.AESMode.cbc, padding: null),
  );

  static String decryptFirebaseData(String encryptedData) {
    try {
      // 1. Nettoyage Base64
      final cleaned = encryptedData
          .replaceAll(RegExp(r'[^a-zA-Z0-9+/=]'), '')
          .trim();

      // 2. Padding Base64 si nécessaire
      final padded = cleaned.padRight(
          cleaned.length + (4 - cleaned.length % 4) % 4,
          '='
      );

      // 3. Décodage et décryptage
      final bytes = base64.decode(padded);
      final decrypted = _encrypter.decryptBytes(encrypt.Encrypted(bytes), iv: _iv);

      // 4. Gestion manuelle du padding PKCS7
      final padLength = decrypted.last;
      final validLength = decrypted.length - padLength;
      final result = utf8.decode(decrypted.sublist(0, validLength));

      debugPrint('✅ Donnée [$encryptedData] déchiffrée: $result');
      return result;
    } catch (e, stack) {
      debugPrint('''
⚠️ ERREUR de déchiffrement
Donnée: $encryptedData
Erreur: $e
Stack: $stack
''');
      return '0.0';
    }
  }

  static void testDecryption() {
    const testValues = {
      'U2FsdGVkX19D5x8g7Z7nTq1JZ5YwD3z7J9Kp2vW1X0=': '25.5',
      'U2FsdGVkX1+3KZQ4n5qz9q0NTY5JZQ==': '1'
    };

    testValues.forEach((encrypted, expected) {
      final result = decryptFirebaseData(encrypted);
      assert(result == expected, 'Test échoué: $encrypted -> $result');
    });
  }
}