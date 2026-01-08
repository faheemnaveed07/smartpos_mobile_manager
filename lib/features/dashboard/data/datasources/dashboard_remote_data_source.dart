import 'package:cloud_firestore/cloud_firestore.dart';

// Remote data source - Firebase
class DashboardRemoteDataSource {
  final FirebaseFirestore firestore;

  DashboardRemoteDataSource(this.firestore);

  // Same methods as local, but querying Firestore
  // For now, return same dummy data
  Future<double> getTodaySales() async {
    // TODO: Query Firestore
    return 0;
  }
}
