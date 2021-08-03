import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:receiptapp/com/arcaneless/firestore_handler.dart';
import 'package:receiptapp/com/arcaneless/form_style.dart';
import 'package:receiptapp/com/arcaneless/jobs_list.dart';
import 'package:receiptapp/com/arcaneless/parameters.dart';
import 'package:receiptapp/com/arcaneless/pdf/pdf_builder.dart';
import 'package:receiptapp/com/arcaneless/pdf_viewer.dart';
import 'package:receiptapp/com/arcaneless/structures/invoice.dart';
import 'package:receiptapp/com/arcaneless/structures/job.dart';

final List<String> chineseNumbers = ['一', '二', '三', '四'];


// TODO job max 10 limitation
class InvoiceEditor extends StatefulWidget {
  InvoiceEditor(this.invoice, this.firestoreHandler, this.sectionList,
      {Key key})
      : super(key: key);

  final Invoice invoice;
  final FirestoreHandler firestoreHandler;
  final List sectionList;

  @override
  State createState() => _InvoiceEditorState();
}

// remember to direct mutate
class _InvoiceEditorState extends State<InvoiceEditor>
    with WidgetsBindingObserver {
  final TextStyle _categoryTitle =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 24);

  Future<bool> _saveInvoice() async {
    try {
      await widget.firestoreHandler.updateDocument(widget.invoice);
      return true;
    } on Exception {
      return false;
    }
  }

  Future<void> _selectDate(BuildContext context, String dateCat) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2019, 1),
        lastDate: DateTime(2099, 1));
    if (picked != null)
      setState(() {
        switch (dateCat) {
          case 'invoice':
            widget.invoice.invoiceDate = picked;
            break;
          case 'start':
            widget.invoice.startDate = picked;
            break;
          case 'end':
            widget.invoice.endDate = picked;
            break;
          default:
            break;
        }
      });
  }

  void _openPdfBuilder() {
    PdfBuilder(widget.invoice.name)
        .addInvoice(widget.invoice)
        .then((value) => value.save().then((value) {
              if (value != '') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                      return PdfViewer(widget.invoice.name, value);
                    }));
              }
            }));
  }

  Future<bool> updateJobs() async {
    return await widget.firestoreHandler
        .updateJobs(widget.invoice.firestoreId, widget.invoice.jobs);
  }

  Future<bool> addJob(Job job) async {
    setState(() {
      widget.invoice.jobs.add(job);
    });
    return await updateJobs();
  }

  Future<bool> modifyJob(Job originalJob, Job newJob) async {
    setState(() {
      widget.invoice.jobs[widget.invoice.jobs.indexOf(originalJob)] = newJob;
    });
    return await updateJobs();
  }

  Future<bool> removeJob(Job job) async {
    setState(() {
      widget.invoice.jobs.remove(job);
    });
    return await updateJobs();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      Logger().i('Saving Invoice');
      _saveInvoice();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.invoice.name),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () => _openPdfBuilder(),
          )
        ],
      ),
      body: Scrollbar(
        child: WillPopScope(
          onWillPop: _saveInvoice,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: ListView(children: <Widget>[
              FormBigTitle('日期'),
              FormSpacer(),
              Row(
                children: [
                  Text('報價單日期: '),
                  FlatButton(
                    color: Parameters.subColor1,
                    child: Text(formatter.format(widget.invoice.invoiceDate)),
                    onPressed: () => _selectDate(context, 'invoice'),
                  )
                ],
              ),
              Row(
                children: [
                  Text('開工日期: '),
                  FlatButton(
                    color: Parameters.subColor1,
                    child: Text(formatter.format(widget.invoice.startDate)),
                    onPressed: () => _selectDate(context, 'start'),
                  )
                ],
              ),
              Row(
                children: [
                  Text('完工日期: '),
                  FlatButton(
                    color: Parameters.subColor1,
                    child: Text(formatter.format(widget.invoice.endDate)),
                    onPressed: () => _selectDate(context, 'end'),
                  )
                ],
              ),
              FormSpacer(),
              FormBigTitle('客戶資料'),
              FormSpacer(),
              ListTile(
                leading: const Icon(Icons.person),
                title: TextFormField(
                  decoration: InputDecoration(hintText: '姓名'),
                  initialValue: widget.invoice.customer.name,
                  onChanged: (value) => widget.invoice.customer.name = value,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: TextFormField(
                  decoration: InputDecoration(hintText: '電話號碼'),
                  initialValue: widget.invoice.customer.telno,
                  onChanged: (value) => widget.invoice.customer.telno = value,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: TextFormField(
                  decoration: InputDecoration(hintText: '電郵'),
                  initialValue: widget.invoice.customer.email,
                  onChanged: (value) => widget.invoice.customer.email = value,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: TextFormField(
                  decoration: InputDecoration(hintText: '工程地址'),
                  initialValue: widget.invoice.customer.address,
                  onChanged: (value) => widget.invoice.customer.address = value,
                ),
              ),
              FormBigTitle('折扣'),
              ListTile(
                leading: const Icon(Icons.monetization_on_sharp),
                title: TextFormField(
                  decoration: InputDecoration(hintText: '折扣'),
                  initialValue: widget.invoice.discount.toString(),
                  onChanged: (value) => widget.invoice.discount = int.tryParse(value) ?? 0,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                )
              ),
              FormBigTitle('付款安排'),
              ...widget.invoice.paymentArrangements.asMap().map((i, e) {
                return MapEntry(i, Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormSubtitle('第${chineseNumbers[i]}期'),
                    ListTile(
                        leading: const Icon(Icons.monetization_on_sharp),
                        title: TextFormField(
                          decoration: InputDecoration(hintText: '百分比交付時間'),
                          initialValue: e.percentageSplit.toString(),
                          onChanged: (value) => e.percentageSplit = int.tryParse(value) ?? 0,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        )
                    ),
                    ListTile(
                        leading: const Icon(Icons.date_range_outlined),
                        title: TextFormField(
                          decoration: InputDecoration(hintText: '交付時間'),
                          initialValue: e.whenToPay,
                          onChanged: (value) => e.whenToPay = value,
                        )
                    ),
                  ],
                ));
              }).values.toList(),
              ...widget.sectionList.map((e) {
                // Logger().i('id: ${e['id']}, ${widget.invoice.getJobList(e['id']).map((e) => e.toJson())}');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormSpacer(),
                    FormBigTitle(e['name']),
                    FormSpacer(),
                    JobsList(
                        originalList: widget.invoice.getJobList(e['id']),
                        typeId: e['id'],
                        add: addJob,
                        modify: modifyJob,
                        remove: removeJob),
                  ],
                );
              })
            ]),
          ),
        ),
      ),
    );
  }
}

