

import 'dart:io';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:receiptapp/com/arcaneless/pdf/pdf_storage_handler.dart';

class PdfViewer extends StatelessWidget {

  PdfViewer(this._title, this._path, {Key key}) : super(key: key);

  final String _title;
  final String _path;

  Future<void> _share() async {
    File pdf = File(_path);
    final byteData = pdf.readAsBytesSync();
    await Share.file(_title, '$_title.pdf', byteData, 'application/pdf');
  }

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _share,
          )
        ],
      ),
      path: _path,
    );
  }
}