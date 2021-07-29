import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart';

class PdfStorage {

  Future<String> checkRawDirectory() async {
    final path = await localPath;
    final dirraw = Directory('$path/pdf/');
    if (await dirraw.exists()) return dirraw.path;
    final dirraw2 = await dirraw.create();
    //Logger().i("new created");
    return dirraw2.path;
  }

  Future<String> get localPath async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  Future<File> getLocalFile(String filename) async {
    final path = await localPath;
    return File('$path/pdf/$filename.pdf');
  }

  Future<File> writeLocalFilePdf(String filename, Document document) async {
    final file = await getLocalFile(filename);
    return file.writeAsBytes(document.save());
  }

  Future<List<FileSystemEntity>> get fileList async {
    final path = await localPath;
    return Directory('$path/pdf/').listSync();
  }

  Future<File> deleteLocalFile(String filename) async {
    final file = await getLocalFile(filename);
    return file.delete();
  }
}