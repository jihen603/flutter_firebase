import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;

class AESHelper {
  // Constructor to accept dynamic key and IV values
  final encrypt.Key key;
  final encrypt.IV iv;

  AESHelper(this.key, this.iv);

  // Function to decrypt the encrypted text using AES
  String decryptAES(String encryptedText) {
    try {
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
      );
      print('Decrypting: $encryptedText');
      final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
      print('Decrypted: $decrypted');
      return decrypted;
    } catch (e) {
      print("Decryption error: $e");
      return "Decryption Failed"; // Message in case of decryption failure
    }
  }

  // Static function for decryption with predefined key and IV
  static String staticDecryptAES(String encryptedText) {
    final key = encrypt.Key(Uint8List.fromList([
      0x12, 0x34, 0x56, 0x78, 0x90, 0xAB, 0xCD, 0xEF,
      0x12, 0x34, 0x56, 0x78, 0x90, 0xAB, 0xCD, 0xEF
    ]));

    final iv = encrypt.IV(Uint8List.fromList([
      0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88,
      0x99, 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF, 0x00
    ]));

    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
    );

    try {
      final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
      print('Decrypted: $decrypted');
      return decrypted;
    } catch (e) {
      print("Decryption error: $e");
      return "Decryption Failed"; // Message in case of decryption failure
    }
  }
}
