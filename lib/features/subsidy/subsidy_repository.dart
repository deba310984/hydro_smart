import 'package:cloud_firestore/cloud_firestore.dart';
import 'subsidy_model.dart';

class SubsidyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<SubsidyModel>> streamSubsidies() {
    return _firestore
        .collection('subsidies')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SubsidyModel.fromJson(doc.data(), doc.id))
            .toList());
  }
}
