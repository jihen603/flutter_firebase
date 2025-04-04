import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';

class AESHelper {
  static const String _defaultKey = '1234567890ABCDEF';
  static const String _defaultIv = 'ABCDEFGHIJKLMNOP';

  static String decryptIotData(String encryptedData, {
    String? customKey,
    String? customIv,
  }) {
    try {
      final key = encrypt.Key.fromUtf8(customKey ?? _defaultKey);
      final iv = encrypt.IV.fromUtf8(customIv ?? _defaultIv);

      final cleaned = encryptedData
          .replaceAll(RegExp(r'[^a-zA-Z0-9+/=]'), '')
          .trim();

      final bytes = base64.decode(cleaned);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: null),
      );

      final decrypted = encrypter.decryptBytes(encrypt.Encrypted(bytes), iv: iv);
      final padLength = decrypted.last;
      final result = utf8.decode(decrypted.sublist(0, decrypted.length - padLength));

      return result;
    } catch (e) {
      debugPrint('Erreur déchiffrement: $e');
      return '0.0';
    }
  }

  static void testCompatibility() {
    const testValues = {
      'U2FsdGVkX19D5x8g7Z7nTq1JZ5YwD3z7J9Kp2vW1X0=': '25.5',
      'U2FsdGVkX1+3KZQ4n5qz9q0NTY5JZQ==': '1'
    };

    testValues.forEach((encrypted, expected) {
      final result = decryptIotData(encrypted);
      assert(result == expected, 'Test échoué: $encrypted -> $result');
    });
  }
}