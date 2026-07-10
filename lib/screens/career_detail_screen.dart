import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/career_model.dart';
import '../services/firestore_service.dart';
import '../widgets/gradient_background.dart';
import '../widgets/sage_fab.dart';

class CareerDetailScreen extends StatefulWidget {
  final CareerModel career;
  const CareerDetailScreen({super.key, required this.career});

  @override
  State<CareerDetailScreen> createState() => _CareerDetailScreenState();
}

class _CareerDetailScreenState extends State<CareerDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
     _checkBookmarkStatus();
  }

   void _checkBookmarkStatus() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final userData = await _firestoreService.getUserData(uid);
    if (userData == null) return;
    final bookmarks = List<String>.from(userData['bookmarks'] ?? []);
    setState(() {
      _isBookmarked = bookmarks.contains(widget.career.id);
    });
  }

  void _toggleBookmark() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _firestoreService.toggleBookmark(uid, widget.career.id, _isBookmarked);
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final career = widget.career;
    return  GradientBackground(
  child: Scaffold(
    floatingActionButton: const SageFAB(),
    backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(career),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryChip(career.category),
                  const SizedBox(height: 12),
                  Text(
                    career.name,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFF5EFE6),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    career.description,
                    style: GoogleFonts.poppins(
                        color: Colors.grey, fontSize: 14, height: 1.6),
                  ),
                  const SizedBox(height: 24),
                  _buildSection('Who is this for?', career.whoIsThisFor),
                  const SizedBox(height: 24),
                  _buildSection('Scope in India', career.scopeInIndia),
                  const SizedBox(height: 24),
                  _buildCareerProgression(career.careerProgression),
                  const SizedBox(height: 24),
                  _buildSection('A Day in the Life', career.dayInLife),
                  const SizedBox(height: 24),
                  _buildProsAndCons(career.pros, career.cons),
                  const SizedBox(height: 24),
                  _buildRoadmap(career.roadmap),
                  const SizedBox(height: 24),
                  _buildListSection('Skills Required', career.skillsRequired,
                      Icons.star_rounded),
                  const SizedBox(height: 24),
                  _buildListSection(
                      'Top Colleges', career.topColleges, Icons.school_rounded),
                  const SizedBox(height: 24),
                  _buildListSection('Entrance Exams', career.entranceExams,
                      Icons.assignment_rounded),
                  const SizedBox(height: 24),
                  _buildQuickStats(career.quickStats),
                  const SizedBox(height: 24),
                  _buildFamousIndians(career.famousIndians),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
     ) );
    
  }

  Widget _buildAppBar(CareerModel career) {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0D0B1A),
      pinned: true,
      iconTheme: const IconThemeData(color: Color(0xFFF5EFE6)),
      actions: [
        IconButton(
          icon: Icon(
            _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: const Color(0xFFC8A8E9),
          ),
          onPressed: _toggleBookmark,
        ),
      ],
    );
  } 
  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFC8A8E9).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category,
        style: GoogleFonts.poppins(
          color: const Color(0xFFC8A8E9),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: const Color(0xFFF5EFE6),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: GoogleFonts.poppins(
              color: Colors.grey, fontSize: 14, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildCareerProgression(Map<String, dynamic> progression) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Career Progression',
          style: GoogleFonts.poppins(
            color: const Color(0xFFF5EFE6),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildProgressionCard(
            'Entry Level',
            progression['entryLevel'] ?? {},
            const Color(0xFF4CAF50)),
        const SizedBox(height: 12),
        _buildProgressionCard(
            'Mid Level',
            progression['midLevel'] ?? {},
            const Color(0xFFC8A8E9)),
        const SizedBox(height: 12),
        _buildProgressionCard(
            'Senior Level',
            progression['seniorLevel'] ?? {},
            const Color(0xFFFFB347)),
      ],
    );
  }

  Widget _buildProgressionCard(
      String level, Map<String, dynamic> data, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1628),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level,
                  style: GoogleFonts.poppins(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data['role'] ?? '',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFF5EFE6),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data['salary'] ?? '',
                  style: GoogleFonts.poppins(
                      color: Colors.grey, fontSize: 12),
                ),
                Text(
                  data['years'] ?? '',
                  style: GoogleFonts.poppins(
                      color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProsAndCons(List<String> pros, List<String> cons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pros & Cons',
          style: GoogleFonts.poppins(
            color: const Color(0xFFF5EFE6),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pros',
                      style: GoogleFonts.poppins(
                          color: const Color(0xFF4CAF50),
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...pros.map((pro) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.add_circle,
                                color: Color(0xFF4CAF50), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(pro,
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontSize: 13,
                                      height: 1.4)),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cons',
                      style: GoogleFonts.poppins(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...cons.map((con) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.remove_circle,
                                color: Colors.redAccent, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(con,
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontSize: 13,
                                      height: 1.4)),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoadmap(Map<String, dynamic> roadmap) {
    final beginner = List<String>.from(roadmap['beginner'] ?? []);
    final careerChanger = List<String>.from(roadmap['careerChanger'] ?? []);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Roadmap',
          style: GoogleFonts.poppins(
            color: const Color(0xFFF5EFE6),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1628),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFFC8A8E9),
            labelColor: const Color(0xFFC8A8E9),
            unselectedLabelColor: Colors.grey,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Beginner'),
              Tab(text: 'Career Changer'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRoadmapSteps(beginner),
              _buildRoadmapSteps(careerChanger),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoadmapSteps(List<String> steps) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC8A8E9),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFF5EFE6),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (index < steps.length - 1)
                  Container(
                    width: 2,
                    height: 40,
                    color: const Color(0xFFC8A8E9).withValues(alpha: 0.3),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                child: Text(
                  steps[index],
                  style: GoogleFonts.poppins(
                      color: Colors.grey, fontSize: 13, height: 1.5),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildListSection(
      String title, List<String> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: const Color(0xFFF5EFE6),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(icon, color: const Color(0xFFC8A8E9), size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.poppins(
                          color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildQuickStats(Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: GoogleFonts.poppins(
            color: const Color(0xFFF5EFE6),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1628),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildStatRow('Further Study', stats['furtherStudyNeeded'] ?? ''),
              const Divider(color: Colors.white10),
              _buildStatRow('Work-Life Balance', stats['workLifeBalance'] ?? ''),
              const Divider(color: Colors.white10),
              _buildStatRow('Years to First Job', stats['yearsToFirstJob'] ?? ''),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
                color: Colors.grey, fontSize: 13),
          ),
          const Spacer(),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                color: const Color(0xFFF5EFE6),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamousIndians(List<String> people) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Famous Indians in this Field',
          style: GoogleFonts.poppins(
            color: const Color(0xFFF5EFE6),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...people.map((person) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFF1A1628),
                    child: Icon(Icons.person,
                        color: Color(0xFFC8A8E9), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    person,
                    style: GoogleFonts.poppins(
                        color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}