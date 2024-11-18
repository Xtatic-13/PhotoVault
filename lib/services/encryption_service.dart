import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static const _storage = FlutterSecureStorage();
  static const _keyName = 'encryption_key';
  static const _ivName = 'encryption_iv';

  static Future<void> generateAndStoreKeyIV() async {
    final key = encrypt.Key.fromSecureRandom(32);
    final iv = encrypt.IV.fromSecureRandom(16);

    await _storage.write(key: _keyName, value: key.base64);
    await _storage.write(key: _ivName, value: iv.base64);
  }

  static Future<encrypt.Encrypter> _getEncrypter() async {
    final keyString = await _storage.read(key: _keyName);
    final key = encrypt.Key.fromBase64(keyString!);
    return encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
  }

  static Future<encrypt.IV> _getIV() async {
    final ivString = await _storage.read(key: _ivName);
    return encrypt.IV.fromBase64(ivString!);
  }

  static Future<File> encryptFile(File file) async {
    final encrypter = await _getEncrypter();
    final iv = await _getIV();

    final plainBytes = await file.readAsBytes();
    final encryptedBytes = encrypter.encryptBytes(plainBytes, iv: iv).bytes;

    final encryptedFile = File('${file.path}.enc');
    await encryptedFile.writeAsBytes(encryptedBytes);

    return encryptedFile;
  }

  static Future<File> decryptFile(File encryptedFile) async {
    final encrypter = await _getEncrypter();
    final iv = await _getIV();

    final encryptedBytes = await encryptedFile.readAsBytes();
    final decryptedBytes =
        encrypter.decryptBytes(encrypt.Encrypted(encryptedBytes), iv: iv);

    final decryptedFile = File(encryptedFile.path.replaceAll('.enc', ''));
    await decryptedFile.writeAsBytes(decryptedBytes);

    return decryptedFile;
  }

  static Future<Uint8List> decryptFileToMemory(File encryptedFile) async {
    final encrypter = await _getEncrypter();
    final iv = await _getIV();

    final encryptedBytes = await encryptedFile.readAsBytes();
    final decryptedList =
        encrypter.decryptBytes(encrypt.Encrypted(encryptedBytes), iv: iv);
    return Uint8List.fromList(decryptedList);
  }
}
