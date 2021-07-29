import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:receiptapp/com/arcaneless/structures/job.dart';
import 'structures/invoice.dart';

class FirestoreHandler {

  FirebaseFirestore firestore;
  Logger _logger;

  FirestoreHandler() {

    // Firestore
    firestore = FirebaseFirestore.instance;
    _logger = new Logger();
  }

  Future<List> get sectionList async {
    try {
      DocumentSnapshot doc = await firestore.collection('quotations').doc('quotation_sections').get();
      _logger.i('sectionList retrieved from Firestore');
      return doc.data()['sections'] as List;
    } catch (e) {
      _logger.e('sectionList failed with error: $e');
      return [];
    }
  }

  Future<List<QueryDocumentSnapshot>> get documentList async {
    try {
      QuerySnapshot result = await firestore.collection('quotations').where(FieldPath.documentId, isNotEqualTo: 'quotation_sections').get();
      _logger.i('documentList retrieved from Firestore');
      return result.docs;
    } catch (e) {
      _logger.e('documentList failed with error: $e');
      return [];
    }
  }

  Future<bool> updateJobs(String id, List<Job> jobs) async {
    try {
      _logger.i('${{'jobs' : jobs.map((e) => e.toJson())}}');
      await firestore.collection('quotations').doc(id).update({
        'jobs': jobs.map((e) => e.toJson()).toList()
      });
      _logger.i('updateJobs successful');
      return true;
    } catch (e) {
      _logger.i('updateJobs failed with error: $e');
      return false;
    }
  }

  Future<bool> addDocument(Invoice invoice) async {
    try {
      DocumentReference res = await firestore.collection('quotations').add(invoice.toJson());
      invoice.firestoreId = res.id;
      _logger.i('updateDocument successful');
      return true;
    } catch (e) {
      _logger.i('updateDocument failed with error: $e');
      return false;
    }
  }

  Future<bool> deleteDocument(String id) async {
    try {
      await firestore.collection('quotations').doc(id).delete();
      _logger.i('deleteDocument successful');
      return true;
    } catch (e) {
      _logger.i('deleteDocument failed with error: $e');
      return false;
    }
  }

  Future<bool> updateDocument(Invoice invoice) async {
    try {
      _logger.i(invoice.toJson(stringifyTimestamp: true));
      await firestore.collection('quotations').doc(invoice.firestoreId).set(invoice.toJson());
      _logger.i('updateDocument successful');
      return true;
    } catch (e) {
      _logger.i('updateDocument failed with error: $e');
      return false;
    }
  }

}