import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/career_model.dart';
import 'career_detail_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<CareerModel> _bookmarkedCareers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  void _loadBookmarks() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userData = await _firestoreService.getUserData(uid);
    if (userData == null) return;

    final bookmarkIds = List<String>.from(userData['bookmarks'] ?? []);
    final List<CareerModel> careers = [];

    for (final id in bookmarkIds) {
      final career = await _firestoreService.getCareerById(id);
      if (career != null) careers.add(career);
    }

    setState(() {
      _bookmarkedCareers = careers;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0B1E),
      appBar: AppBar(
        backgroundColor: const Color(0XFF0D0B1E),
        title: Text(
          'Bookmarks',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00B4D8)))
          : _bookmarkedCareers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bookmark_border,
                          color: Colors.grey, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'No bookmarks yet!',
                        style: GoogleFonts.poppins(
                            color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the bookmark icon on any career to save it.',
                        style: GoogleFonts.poppins(
                            color: Colors.grey, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookmarkedCareers.length,
                  itemBuilder: (context, index) {
                    final career = _bookmarkedCareers[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CareerDetailScreen(career: career),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: const Color(0xFF00B4D8).withOpacity(0.15)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00B4D8)
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      career.category,
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF00B4D8),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    career.name,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    career.description,
                                    style: GoogleFonts.poppins(
                                        color: Colors.grey, fontSize: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                color: Colors.grey, size: 14),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}