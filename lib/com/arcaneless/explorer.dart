import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:receiptapp/com/arcaneless/firestore_handler.dart';
import 'package:receiptapp/com/arcaneless/invoice_editor.dart';
import 'package:receiptapp/com/arcaneless/main.dart';
import 'package:receiptapp/com/arcaneless/structures/invoice.dart';

class Explorer extends StatefulWidget {
  Explorer({Key key}) : super(key: key);
  @override
  State createState() {
    return _ExplorerState();
  }
}

class _ExplorerState extends State<Explorer> {
  Logger _logger = Logger();
  String newFileInputValue;

  FirestoreHandler _firestoreHandler = FirestoreHandler();
  List sectionList;
  List<Invoice> quotationList;
  bool fetchReady;

  @override
  void initState() {
    super.initState();
    newFileInputValue = '';
    sectionList = [];
    quotationList = [];
    fetchReady = false;
    refreshFileList();
  }

  Future<void> refreshFileList() async {
    sectionList = await _firestoreHandler.sectionList;
    List<QueryDocumentSnapshot> docList = await _firestoreHandler.documentList;

    setState(() {
      quotationList =
          docList.map((e) => Invoice.fromJson(sectionList, e.id, e.data())).toList();
      quotationList.sort((a, b) {
        if (a.invoiceDate.isBefore(b.invoiceDate)) {
          return 1;
        } else {
          return -1;
        }
      });
      fetchReady = true;
    });
    _logger.i('file list has been updated');
    // _logger.i(quotationList.map((e) => e.toJson(stringifyTimestamp: true)).toList());
  }

  void createNewFile(String filename) async {
    // check if have name same file
    Invoice newFile = new Invoice(sectionList, filename);
    if (await _firestoreHandler.addDocument(newFile)) {
      await refreshFileList();
    } else {
      // TODO: Toast maybe
    }
  }

  void deleteFile(Invoice invoice) async {
    // Cloud Integrated
    await _firestoreHandler.deleteDocument(invoice.firestoreId);
    await refreshFileList();
    // TODO: Toast
  }

  void deleteFilePrompt(Invoice invoice) {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return AlertDialog(
        title: Text('刪除報價單'),
        content: Text('確定刪除報價單 ${invoice.name}?'),
        actions: <Widget>[
          FlatButton(
              onPressed: () {
                deleteFile(invoice);
                Navigator.of(context).pop();
              },
              child: Text('是')),
          FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('否')),
        ],
      );
    }));
  }

  void newDocumentPage(BuildContext context) {
    newFileInputValue = '';
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return AlertDialog(
        title: Text('新的報價單'),
        content: TextField(
          decoration:
              InputDecoration(border: InputBorder.none, hintText: '名稱...'),
          onChanged: (text) => newFileInputValue = text,
        ),
        actions: <Widget>[
          TextButton(
              onPressed: () {
                if (newFileInputValue != '') {
                  createNewFile(newFileInputValue);
                  Navigator.of(context).pop();
                }
              },
              child: Text('確定')),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('取消'))
        ],
      );
    }));
  }

  void openDocumentEditing(BuildContext context, Invoice invoice) {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return InvoiceEditor(invoice, _firestoreHandler, sectionList);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('報價單'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '新的報價單',
            onPressed: () {
              newDocumentPage(context);
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshFileList,
        child: !fetchReady
            ? Center(
                child: CircularProgressIndicator(
                strokeWidth: 2.0,
              ))
            : fetchReady && quotationList.length == 0
                ? Align(
                    alignment: Alignment.center,
                    child: Text('+開始新的報價單'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(),
                    itemCount: quotationList.length,
                    itemBuilder: (BuildContext context, int index) {
                      Invoice item = quotationList[index];
                      String filename = item.name;
                      return Slidable(
                        actionPane: SlidableDrawerActionPane(),
                        child: ListTile(
                          title: Text(filename),
                          leading: Icon(Icons.insert_drive_file),
                          onTap: () => openDocumentEditing(context, item),
                        ),
                        secondaryActions: <Widget>[
                          IconSlideAction(
                            caption: '刪除',
                            icon: Icons.delete,
                            color: Colors.red,
                            onTap: () => deleteFilePrompt(item),
                          )
                        ],
                      );
                    },
                  ),
      ),
    );
  }
}
