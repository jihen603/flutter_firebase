import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;

class AESHelper {
  static final key = encrypt.Key.fromUtf8('1234567890123456');
  static final iv = encrypt.IV.fromUtf8('1234567890123456');

  static final encrypter = encrypt.Encrypter(
    encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: null),
  );

  static String decryptAES(String encryptedText) {
    try {
      encryptedText = normalizeBase64(encryptedText);
      final encryptedBytes = base64.decode(encryptedText);
      final decrypted = encrypter.decryptBytes(
          encrypt.Encrypted(encryptedBytes), iv: iv);
      return utf8.decode(decrypted);
    } catch (e) {
      print("Erreur de déchiffrement : $e");
      return "Decryption Error";
    }
  }

  static String normalizeBase64(String base64String) {
    while (base64String.length % 4 != 0) {
      base64String += "=";
    }
    return base64String;
  }
}

