import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:web_dex/services/file_loader/file_loader.dart';
import 'package:web_dex/shared/utils/zip.dart';

class FileLoaderNativeDesktop implements FileLoader {
  const FileLoaderNativeDesktop();

  @override
  Future<void> save({
    required String fileName,
    required String data,
    required LoadFileType type,
  }) async {
    switch (type) {
      case LoadFileType.text:
        await _saveAsTextFile(fileName, data);
      case LoadFileType.compressed:
        await _saveAsCompressedFile(fileName, data);
    }
  }

  @override
  Future<void> upload({
    required void Function(String name, String content) onUpload,
    required void Function(String) onError,
    LoadFileType? fileType,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.isEmpty) {
        return;
      }
      final file = result.files.first;
      final path = file.path;
      if (path == null) return;

      final selectedFile = File(path);
      final data = await selectedFile.readAsString();

      onUpload(file.name, data);
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> _saveAsTextFile(String fileName, String data) async {
    final String? fileFullPath =
        await FilePicker.platform.saveFile(fileName: '$fileName.txt');
    if (fileFullPath == null) return;
    final File file = File(fileFullPath)..createSync(recursive: true);
    await file.writeAsString(data);
  }

  Future<void> _saveAsCompressedFile(
    String fileName,
    String data,
  ) async {
    final String? fileFullPath =
        await FilePicker.platform.saveFile(fileName: '$fileName.zip');
    if (fileFullPath == null) return;

    final compressedBytes =
        createZipOfSingleFile(fileName: fileName, fileContent: data);

    final File compressedFile = File(fileFullPath);
    await compressedFile.writeAsBytes(compressedBytes);
  }
}
