// each job row
import 'dart:typed_data';

import 'package:flutter/material.dart';

class Job {

  // typeId
  String typeId;

  // elements
  String objectName;
  double pricePerUnit; // single item, or multiple item
  double amount;
  String unit; // if single => unit, else useless
  List<int> range; // multiple => from what to what [0,1]
  JobState jobState;


  Job({
    this.typeId,
    this.objectName : '',
    this.pricePerUnit : 0.0,
    this.amount : 0.0,
    this.unit : '單',
    this.range : const [1, 1],
    this.jobState : JobState.Empty
  });

  double get totalPrice {
    if (jobState == JobState.Single) return amount == 0 ? 0 : pricePerUnit * amount;
    else if (jobState == JobState.Multiple) return pricePerUnit;
    else return 0;
  }

  Map toJson() {
    return {
      'typeId': typeId,
      'objectName': objectName,
      'pricePerUnit': pricePerUnit,
      'amount': amount,
      'unit': unit,
      'range': range,
      'jobState': jobState.to_string(),
    };
  }

  factory Job.fromJson(dynamic json) {
    return Job(
        typeId: json['typeId'] as String,
        objectName : json['objectName'] as String,
        pricePerUnit : json['pricePerUnit'].toDouble(),
        amount : json['amount'].toDouble(),
        unit : json['unit'] as String,
        range : List.from(json['range']),
        jobState : JobStateExtension.from_string(json['jobState'] as String)
    );
  }
  
}

enum JobState {
  Empty,    // empty
  Single,   // single job included
  Multiple, // multiple job included
  TBC,      // to be confirmed
  Included // included, not counted
}

extension JobStateExtension on JobState {
  static List<String> get names
      => ['空', '單項', '多項合計', '待定', '已包'];

  static List<DropdownMenuItem<String>> get namesDropdown
      => names.map<DropdownMenuItem<String>>((e) => DropdownMenuItem<String>(
        value: e,
        child: Text(e),
      )).toList();

  String to_string() {
    return names[this.index];
  }

  static JobState from_string(String name) {
    return JobState.values[names.indexOf(name)];
  }
}