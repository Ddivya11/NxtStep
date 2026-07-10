import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/career_model.dart';
import 'career_detail_screen.dart';
import 'login_screen.dart';
import 'bookmarks_screen.dart';
import 'profile_screen.dart';
import '../widgets/gradient_background.dart';
import 'sage_chat_screen.dart';
import '../widgets/sage_fab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  List<CareerModel> _allCareers = [];
  List<CareerModel> _filteredCareers = [];
  bool _isLoading = true;
  int _selectedIndex = 0;
  String _searchQuery = '';

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Traditional':
        return const Color(0xFFE8C98A);
      case 'Emerging Tech':
        return const Color(0xFF7EC8C8);
      case 'Science':
        return const Color(0xFF98C9A3);
      case 'Creative':
        return const Color(0xFFF4A896);
      case 'Underrated but Growing':
        return const Color(0xFFC8A8E9);
      default:
        return const Color(0xFFC8A8E9);
    }
  }

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'All',
      'icon': Icons.grid_view_rounded,
      'color': const Color(0xFFC8A8E9),
    },
    {
      'name': 'Traditional',
      'icon': Icons.account_balance_rounded,
      'color': const Color(0xFFFFB347),
    },
    {
      'name': 'Emerging Tech',
      'icon': Icons.computer_rounded,
      'color': const Color(0xFFC8A8E9),
    },
    {
      'name': 'Science',
      'icon': Icons.science_rounded,
      'color': const Color(0xFF4CAF50),
    },
    {
      'name': 'Creative',
      'icon': Icons.brush_rounded,
      'color': const Color(0xFFB388FF),
    },
    {
      'name': 'Underrated but Growing',
      'icon': Icons.trending_up_rounded,
      'color': const Color(0xFFFF6B6B),
    },
  ];

  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadCareers();
  }

  void _loadCareers() async {
    final careers = await _firestoreService.getCareers();
    setState(() {
      _allCareers = careers;
      _filteredCareers = careers;
      _isLoading = false;
    });
  }

  void _filterCareers(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredCareers = _allCareers.where((career) {
      final matchesSearch = career.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesCategory =
          _selectedCategory == 'All' || career.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
      
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildCategoryChips(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFC8A8E9),
                        ),
                      )
                    : _filteredCareers.isEmpty
                    ? Center(
                        child: Text(
                          'No careers found',
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredCareers.length,
                        itemBuilder: (context, index) {
                          return _buildCareerCard(_filteredCareers[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
        floatingActionButton: const SageFAB(),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NxtStep',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFC8A8E9),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Find your path',
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          const CircleAvatar(
            backgroundColor: Color(0xFF1A1628),
            child: Icon(Icons.person, color: Color(0xFFC8A8E9)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: _filterCareers,
        style: const TextStyle(color: Color(0xFFF5EFE6)),
        decoration: InputDecoration(
          hintText: 'Search careers...',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF1A1628),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category['name'];
          final color = category['color'] as Color;
          return GestureDetector(
            onTap: () => _filterByCategory(category['name']),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? color : const Color(0xFF1A1628),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? color : color.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    category['icon'],
                    size: 16,
                    color: isSelected ? Colors.white : color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category['name'],
                    style: GoogleFonts.poppins(
                      color: isSelected ? Colors.white : color,
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCareerCard(CareerModel career) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CareerDetailScreen(career: career)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1628), Color(0xFF0D1635)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF9D4EDD).withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(
                      career.category,
                    ).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    career.category,
                    style: GoogleFonts.poppins(
                      color: _getCategoryColor(career.category),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 14,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              career.name,
              style: GoogleFonts.poppins(
                color: const Color(0xFFF5EFE6),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              career.description,
              style: GoogleFonts.poppins(
                color: Colors.grey,
                fontSize: 13,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.attach_money,
                  color: Color(0xFFC8A8E9),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  career.careerProgression['entryLevel']?['salary'] ?? '',
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF1A1628),
      selectedItemColor: const Color(0xFFC8A8E9),
      unselectedItemColor: Colors.grey,
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() => _selectedIndex = index);
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BookmarksScreen()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_rounded),
          label: 'Bookmarks',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
