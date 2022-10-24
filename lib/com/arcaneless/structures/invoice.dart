// invoice main object
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:receiptapp/com/arcaneless/firestore_handler.dart';
import 'package:receiptapp/com/arcaneless/structures/customer.dart';
import 'package:receiptapp/com/arcaneless/structures/job.dart';
import 'package:receiptapp/com/arcaneless/structures/payment_arrangment.dart';

class Invoice {
  String name;
  DateTime invoiceDate;  // invoice date
  DateTime startDate;    // construction work start date
  DateTime endDate;      // construction work end date
  Customer customer;
  int discount;
  List<Job> jobs;
  List<PaymentArrangement> paymentArrangements;

  Map<String, String> jobsNameChinese;

  String firestoreId;
  FirestoreHandler _firestoreDelegate;

  Invoice(List<dynamic> sectionList, this.name) {
    invoiceDate = DateTime.now();
    startDate = DateTime.now();
    endDate = DateTime.now();
    customer = Customer();
    discount = 0;
    paymentArrangements = List.filled(4, PaymentArrangement());

    jobsNameChinese = Map();
    jobs = [];
    sectionList.forEach((element) {
      jobsNameChinese[element['id']] = element['name'];
    });
  }

  List<Job> getJobList(String typeId) {
    return jobs.where((job) => job.typeId == typeId).toList();
  }

  @deprecated
  void updateJobList(String name, List<Job> job) {
    
  }


  double getCategoryTotalPrice(String typeId) {
    return jobs
        .where((job) => job.typeId == typeId)
        .fold(0, (previousValue, job) => previousValue + job.totalPrice);
  }

  double get discountedTotalPrice {
    return totalTotalPrice * (1.0 - discount / 100.0);
  }

  double get totalTotalPrice {
    return jobs.where((element) => element.typeId != 'additional').fold(0, (previousValue, job) => previousValue + job.totalPrice);
  }

  Future<bool> addJob(Job job) async {
    jobs.add(job);

    // call firestore update
    return _firestoreDelegate.updateJobs(firestoreId, jobs);
  }

  Future<bool> removeJob(Job job) async {
    bool result = jobs.remove(job);

    // call firestore update
    if (result) {
      return true;
      return _firestoreDelegate.updateJobs(firestoreId, jobs);
    } else {
      return false;
    }
  }

  Map<String, dynamic> toJson({bool stringifyTimestamp: false}) {
    return {
      'name': name,
      'invoiceDate': stringifyTimestamp ? invoiceDate.toIso8601String() : Timestamp.fromDate(invoiceDate),
      'startDate': stringifyTimestamp ? startDate.toIso8601String() : Timestamp.fromDate(startDate),
      'endDate': stringifyTimestamp ? endDate.toIso8601String() : Timestamp.fromDate(endDate),
      'customer': customer.toJson(),
      'discount': discount,
      'jobs': jobs.map((job) => job.toJson()).toList(),
      'percentageSplits': paymentArrangements.map((pa) => pa.toJson()).toList()
    };
  }

  factory Invoice.fromJson(List<dynamic> sectionList, String id, dynamic json) {
    Invoice i = Invoice(sectionList, json['name'] as String);
    i.firestoreId = id;
    i.invoiceDate = json['invoiceDate'].toDate() ?? DateTime.now();
    i.startDate = json['startDate'].toDate() ?? DateTime.now();
    i.endDate = json['endDate'].toDate() ?? DateTime.now();
    i.customer = Customer.fromJson(json['customer']);
    i.discount = json['discount'] ?? 0;
    i.jobs = (json['jobs'] as List).map((e) => Job.fromJson(e)).toList();
    i.paymentArrangements = (json['paymentArrangements'] != null
        ? (json['paymentArrangements'] as List)
                .asMap()
                .map((i, e) => MapEntry(i, PaymentArrangement.fromJson(e, i)))
                .values.toList()
        : [0, 1, 2, 3].map((e) => PaymentArrangement.fromDefaultIndex(e)).toList());
    return i;
  }

}