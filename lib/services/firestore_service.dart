import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/career_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all careers
  Future<List<CareerModel>> getCareers() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('careers').get();
      return snapshot.docs
          .map((doc) => CareerModel.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Fetch single career by ID
  Future<CareerModel?> getCareerById(String id) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('careers').doc(id).get();
      if (doc.exists) {
        return CareerModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  // Toggle bookmark
  Future<void> toggleBookmark(String uid, String careerId, bool isBookmarked) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'bookmarks': isBookmarked
            ? FieldValue.arrayRemove([careerId])
            : FieldValue.arrayUnion([careerId]),
      });
    } catch (e) {
      return;
    }
  }

  // Save quiz results
  Future<void> saveQuizResults(String uid, List<String> careerIds) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'quizCompleted': true,
        'quizResults': careerIds,
      });
    } catch (e) {
      return;
    }
  }

  // Mark entry point as shown
  Future<void> markEntryPointShown(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'entryPointShown': true,
      });
    } catch (e) {
      return;
    }
  }
}