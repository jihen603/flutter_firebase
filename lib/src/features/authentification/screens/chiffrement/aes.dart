import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

class AESHelper {
  late final Encrypter encrypter;
  late final IV iv;

  AESHelper(String keyBase64, String ivBase64) {
    final keyBytes = base64.decode(keyBase64);
    final ivBytes = base64.decode(ivBase64);

    final key = Key(Uint8List.fromList(keyBytes));
    iv = IV(Uint8List.fromList(ivBytes));

    encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: null));
  }

  // 📌 Chiffrement AES
  String encryptAES(String plainText) {
    Uint8List inputBytes = _addPadding(utf8.encode(plainText));
    final encrypted = encrypter.encryptBytes(inputBytes, iv: iv);
    return base64.encode(encrypted.bytes);
  }

  // 📌 Déchiffrement AES
  String decryptAES(String encryptedText) {
    try {
      Uint8List encryptedBytes = base64.decode(encryptedText);
      final decrypted = encrypter.decryptBytes(Encrypted(encryptedBytes), iv: iv);
      return utf8.decode(_removePadding(decrypted));
    } catch (e) {
      return "Decryption Error";
    }
  }

  // Ajout du padding manuel (Zero Padding)
  static Uint8List _addPadding(List<int> data) {
    int padLength = 16 - (data.length % 16);
    return Uint8List.fromList([...data, ...List.filled(padLength, 0)]);
  }

  // Suppression du padding
  static List<int> _removePadding(List<int> data) {
    while (data.isNotEmpty && data.last == 0) {
      data.removeLast();
    }
    return data;
  }
}

