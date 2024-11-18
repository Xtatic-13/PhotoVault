import 'dart:io';
import 'dart:typed_data';
import 'package:app/services/encryption_service.dart';
import 'package:app/services/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:share/share.dart';

class PhotoService {
  final log = LoggerService().logger(PhotoService);

  Future<List<String>> movePhotosToSecureFolder(BuildContext context) async {
    var status = await Permission.storage.status.isGranted &&
        await Permission.manageExternalStorage.status.isGranted;
    if (!status) {
      await Permission.storage.request();
      await Permission.manageExternalStorage.request();
    }

    final appDir = await getApplicationDocumentsDirectory();
    final secureDir = Directory('${appDir.path}/secure_photos');
    if (!await secureDir.exists()) {
      await secureDir.create(recursive: true);
    }
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: const AssetPickerConfig(
        requestType: RequestType.image,
        maxAssets: 100,
      ),
    );

    if (result == null) return [];

    List<String> newPaths = [];
    for (var asset in result) {
      final File? file = await asset.file;
      if (file != null) {
        final String fileName = path.basename(file.path);
        final String newPath = '${secureDir.path}/$fileName.enc';
        try {
          final encryptedFile = await EncryptionService.encryptFile(file);
          await encryptedFile.copy(newPath);
          LoggerService.logFileMoved(fileName, newPath);
          await encryptedFile.delete();
          await file.delete();
          newPaths.add(newPath);
        } catch (e) {
          log.e(e);
        }
      }
    }
    return newPaths;
  }

  Future<List<File>> getSecurePhotos() async {
    final appDir = await getApplicationDocumentsDirectory();
    final secureDir = Directory('${appDir.path}/secure_photos');
    if (!await secureDir.exists()) {
      return [];
    }
    return secureDir.listSync().whereType<File>().toList();
  }

  Future<List<String?>> moveMultiplePhotosFromSecureFolder(
      List<String> sourcePaths) async {
    try {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        return List.filled(sourcePaths.length, null);
      }
      List<String?> results = [];
      for (String sourcePath in sourcePaths) {
        try {
          File sourceFile = File(sourcePath);
          String fileName = path.basenameWithoutExtension(sourcePath);
          String destinationPath = path.join(selectedDirectory, fileName);
          File decryptedFile = await EncryptionService.decryptFile(sourceFile);
          await decryptedFile.copy(destinationPath);
          LoggerService.logFileMoved(fileName, destinationPath);
          await sourceFile.delete();
          await decryptedFile.delete();
          results.add(destinationPath);
        } catch (e) {
          log.e(e);
        }
      }
      return results;
    } catch (e) {
      log.e("Error in moveMultiplePhotosFromSecureFolder $e");
      return List.filled(sourcePaths.length, null);
    }
  }

  Future<bool> sharePhotoFromSecureFolder(String sourcePath) async {
    File? tempFile;
    try {
      File sourceFile = File(sourcePath);
      if (await sourceFile.exists()) {
        final directory = await getTemporaryDirectory();
        String originalFileName = path.basenameWithoutExtension(sourcePath);
        originalFileName = originalFileName.endsWith('.enc')
            ? originalFileName.substring(0, originalFileName.length - 4)
            : originalFileName;
        tempFile = File('${directory.path}/$originalFileName');
        Uint8List decryptedData =
            await EncryptionService.decryptFileToMemory(sourceFile);
        await tempFile.writeAsBytes(decryptedData);
        await Share.shareFiles([tempFile.path]);
        return true;
      } else {
        log.i("File Doesn't Exist");
        return false;
      }
    } catch (e) {
      log.e('Error sharing file: $e');
      return false;
    } finally {
      if (tempFile != null && await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }

  Future<bool> deletePhotoFromFolder(String path) async {
    try {
      final file = File(path);
      await file.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Uint8List?> getDecryptedPhoto(File encryptedFile) async {
    try {
      return await EncryptionService.decryptFileToMemory(encryptedFile);
    } catch (e) {
      log.e('Error decrypting file: $e');
      return null;
    }
  }
}
