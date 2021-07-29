import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:logger/logger.dart';
import 'package:receiptapp/com/arcaneless/form_style.dart';
import 'package:receiptapp/com/arcaneless/parameters.dart';
import 'package:receiptapp/com/arcaneless/structures/job.dart';

class JobEditorWrapper extends StatelessWidget {
  JobEditorWrapper({Key key, this.job, this.typeId, this.onSaved, this.onCancelled})
      : super(key: key);

  final Job job;
  final String typeId;
  final Function(Job) onSaved;
  final Function(Job) onCancelled;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('工作細節'),
      ),
      body: JobEditor(
        job: job,
        typeId: typeId,
        onSaved: onSaved,
        onCancelled: onCancelled,
      ),
    );
  }
}

class JobEditor extends StatefulWidget {
  JobEditor({Key key, this.job, this.typeId, this.onSaved, this.onCancelled})
      : super(key: key);

  final Job job;
  final String typeId;
  final Function(Job) onSaved; // callback on user click save
  final Function(Job) onCancelled; // callback on use click cancel

  @override
  State createState() => _JobEditorState();
}

class _JobEditorState extends State<JobEditor> {
  String dropdownValue = '空';
  Job job;
  @override
  void initState() {
    super.initState();
    job = widget.job ?? Job(typeId: widget.typeId); // no job then create new
    dropdownValue = JobStateExtension.names[job.jobState.index];
  }

  void onSave() {
    if (widget.onSaved != null) widget.onSaved(job);
    Navigator.pop(context);
  }

  void onCancel() {
    if (widget.onCancelled != null) widget.onCancelled(job);
    Navigator.pop(context);
  }

  void dropdownChangeVal(String val) {
    dropdownValue = val;
    setState(() {
      job.jobState =
          JobState.values[JobStateExtension.names.indexOf(dropdownValue)];
    });
  }

  @override
  Widget build(BuildContext context) {
    double cheight = MediaQuery.of(context).size.height - kToolbarHeight * 2;
    return Container(
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: SizedBox(
          height: cheight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: [
                        DropdownButton(
                          value: dropdownValue,
                          icon: Icon(Icons.arrow_downward),
                          style: TextStyle(color: Colors.black),
                          underline: Container(
                            height: 2,
                            color: Parameters.subColor2,
                          ),
                          items: JobStateExtension.namesDropdown,
                          onChanged: dropdownChangeVal,
                        ),
                        Expanded(child: Container(
                          padding: const EdgeInsets.all(16),
                          child: JobDetailForm(job),
                        ))
                      ],
                    ),
                  )),
              //Expanded(child: Container()),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Parameters.themeColor),
                      ),
                      color: Parameters.themeColor,
                      textColor: Colors.white,
                      child: Text('儲存'),
                      onPressed: onSave,
                    ),
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Parameters.themeColor),
                      ),
                      color: Colors.white,
                      textColor: Parameters.themeColor,
                      child: Text('取消'),
                      onPressed: onCancel,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}

class JobDetailForm extends StatefulWidget {
  JobDetailForm(this.job, {Key key}) : super(key: key);

  final Job job;
  @override
  State createState() => _JobDetailFormState();
}

class _JobDetailFormState extends State<JobDetailForm> {
  final TextInputFormatter _moneyFormatter =
      TextInputFormatter.withFunction((oldValue, newValue) {
    final regEx = RegExp(r'^\d*\.?\d{0,2}');
    String ns = regEx.stringMatch(newValue.text) ?? "";
    return ns == newValue.text ? newValue : oldValue;
  });
  final List<String> _unitList = [
    '單',
    '個',
    '套',
    '件',
    '呎',
    '部',
    '台',
    '對',
  ];

  Widget _jobNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormSubtitle('項目名稱'),
        TextFormField(
          initialValue: widget.job.objectName,
          onChanged: (val) {
            setState(() {
              widget.job.objectName = val;
            });
          },
        )
      ],
    );
  }

  Widget _jobPerPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormSubtitle('單價'),
        TextFormField(
          initialValue: widget.job.pricePerUnit.toString(),
          keyboardType: TextInputType.number,
          inputFormatters: [_moneyFormatter],
          onChanged: (val) {
            setState(() {
              widget.job.pricePerUnit = double.tryParse(val) ?? 0;
            });
          },
        )
      ],
    );
  }

  Widget _jobAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormSubtitle('數目'),
        TextFormField(
          initialValue: widget.job.amount.toString(),
          keyboardType: TextInputType.number,
          inputFormatters: [_moneyFormatter],
          onChanged: (val) {
            setState(() {
              widget.job.amount = double.tryParse(val) ?? 0;
            });
          },
        )
      ],
    );
  }

  Widget _jobUnitField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormSubtitle('單位'),
        DropdownButton(
          value: widget.job.unit,
          icon: Icon(Icons.arrow_downward),
          style: TextStyle(color: Colors.black),
          underline: Container(
            height: 2,
            color: Parameters.subColor2,
          ),
          items: _unitList
              .map<DropdownMenuItem<String>>(
                  (e) => DropdownMenuItem<String>(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) {
            setState(() {
              widget.job.unit = val;
            });
          },
        )
      ],
    );
  }

  void _showPickerNumber() {
    Picker(
      adapter: NumberPickerAdapter(
        data: [
          NumberPickerColumn(begin: 1, end: 20),
          NumberPickerColumn(begin: 1, end: 20)
        ],
      ),
      delimiter: [
        PickerDelimiter(child: Container(
          width: 30.0,
          alignment: Alignment.center,
          child: Text('-')
        ))
      ],
      selecteds: widget.job.range.map((e) => e-1).toList(),
      hideHeader: true,
      title: Text('請選擇'),
      onConfirm: (picker, val) {
        setState(() {
          widget.job.range = Uint8List(2);
          widget.job.range[0] = val[0]+1;
          widget.job.range[1] = val[1]+1;
        });
      }
    ).showDialog(context);
  }


  Widget _jobRangeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormSubtitle('範圍'),
        FlatButton(
          color: Parameters.subColor2,
          child: Text('第${widget.job.range[0]}至${widget.job.range[1]}項'),
          onPressed: () => _showPickerNumber(),
        )
      ],
    );
  }

  Widget _jobPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormSubtitle('總共價錢'),
        TextFormField(
          initialValue: widget.job.pricePerUnit.toString(),
          keyboardType: TextInputType.number,
          inputFormatters: [_moneyFormatter],
          onChanged: (val) {
            setState(() {
              widget.job.pricePerUnit = double.tryParse(val) ?? 0;
            });
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.job.jobState) {
      case JobState.Empty:
      case JobState.TBC:
      case JobState.Included:
        return _jobNameField();
      case JobState.Single:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _jobNameField(),
            FormSpacer(),
            _jobPerPriceField(),
            FormSpacer(),
            _jobAmountField(),
            FormSpacer(),
            _jobUnitField()
          ],
        );
      case JobState.Multiple:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _jobNameField(),
            FormSpacer(),
            _jobRangeField(),
            _jobPriceField()
          ],
        );
      default:
        return Text('Error Job State');
    }
  }
}
