import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:receiptapp/com/arcaneless/firestore_handler.dart';
import 'package:receiptapp/com/arcaneless/form_style.dart';
import 'package:receiptapp/com/arcaneless/job_editor.dart';
import 'package:receiptapp/com/arcaneless/parameters.dart';
import 'package:receiptapp/com/arcaneless/pdf/pdf_builder.dart';
import 'package:receiptapp/com/arcaneless/pdf_viewer.dart';
import 'package:receiptapp/com/arcaneless/structures/invoice.dart';
import 'package:receiptapp/com/arcaneless/structures/job.dart';

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

class JobsList extends StatefulWidget {
  // update is a callback which return modified list
  JobsList({Key key, this.originalList, this.typeId, this.add, this.modify, this.remove})
      : super(key: key);

  final List<Job> originalList;
  final String typeId;
  final Function(Job) add;
  final Function(Job, Job) modify;
  final Function(Job) remove;

  @override
  State createState() => _JobsListState();
}

class _JobsListState extends State<JobsList> {
  List<Job> jobList;

  @override
  void initState() {
    super.initState();
    jobList = widget.originalList;
  }

  void _update() async {
    await Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        jobList = widget.originalList;
      });
      Logger().i('joblist updated ${jobList.map((e) => e.toJson()).toList()}');
    });
  }

  void _openJobEditing(BuildContext context, {Job job}) {
    //assert(jobList.indexOf(job) != -1);
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return JobEditorWrapper(
        job: job,
        typeId: widget.typeId,
        onSaved: (newJob) async {
          // Logger().e('Hi Im back with ${newJob.objectName}');
          if (job == null) {
            await widget.add(newJob);
          } else {
            jobList[jobList.indexOf(job)] = newJob;
          }
          _update();
        },
      );
    }));
  }

  void _deleteJob(Job job) async {
    await widget.remove(job);
    _update();
  }

  void _deleteJobPrompt(BuildContext context, Job job) {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return AlertDialog(
        title: Text('刪除項目'),
        content: Text('確定刪除項目 ${job.objectName}?'),
        actions: <Widget>[
          FlatButton(
              onPressed: () {
                _deleteJob(job);
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

  Text _getSubtitleByState(Job job) {
    switch (job.jobState) {
      case JobState.Empty:
        return Text(JobStateExtension.names[0]);
      case JobState.TBC:
        return Text(JobStateExtension.names[3]);
      case JobState.Included:
        return Text(JobStateExtension.names[4]);
      case JobState.Single:
        return Text(
            '\$${job.pricePerUnit}@1, ${job.amount} ${job.unit}, 總共 \$${job.totalPrice.toStringAsFixed(1)} ');
      case JobState.Multiple:
        return Text(
            '第 ${job.range[0]} 至 ${job.range[1]} 項, 總共 \$${job.pricePerUnit} ');
      default:
        return Text('Error Job State');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          jobList.length != 0
              ? Container(
                  child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: jobList.length,
                  itemBuilder: (BuildContext context, int index) {
                    Job job = jobList.elementAt(index);
                    return Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      child: ListTile(
                        title: Text(job.objectName),
                        subtitle: _getSubtitleByState(job),
                        onTap: () => _openJobEditing(context, job: job),
                      ),
                      secondaryActions: <Widget>[
                        IconSlideAction(
                          caption: '刪除',
                          icon: Icons.delete,
                          color: Colors.red,
                          onTap: () => _deleteJobPrompt(context, job),
                        )
                      ],
                    );
                  },
                ))
              : Text('空'),
          ElevatedButton(
            child: Icon(Icons.add),
            onPressed: () => _openJobEditing(context),
          )
        ],
      ),
    );
  }
}
