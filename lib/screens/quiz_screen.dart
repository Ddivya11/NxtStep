import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import 'recommendations_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  int _currentQuestion = 0;
  final Map<int, String> _answers = {};

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What kind of work excites you most?',
      'options': [
        {'text': 'Working with people and helping them', 'tag': 'people'},
        {'text': 'Solving technical or logical problems', 'tag': 'tech'},
        {'text': 'Creating things — art, design, writing', 'tag': 'creative'},
        {'text': 'Researching and discovering new things', 'tag': 'research'},
      ],
    },
    {
      'question': 'How do you feel about long study years before earning well?',
      'options': [
        {'text': 'Fine with it — I play the long game', 'tag': 'longterm'},
        {'text': 'Prefer a faster path to earning', 'tag': 'shortterm'},
        {'text': 'Okay with it if the work is meaningful', 'tag': 'meaningful'},
        {'text': 'I want to keep learning throughout my career', 'tag': 'learning'},
        {'text': 'Honestly no idea', 'tag': 'mixed'},
      ],
    },
    {
      'question': 'Which environment suits you best?',
      'options': [
        {'text': 'Lab or research setting', 'tag': 'lab'},
        {'text': 'Office or corporate setting', 'tag': 'office'},
        {'text': 'Outdoors or fieldwork', 'tag': 'field'},
        {'text': 'Studio or creative space', 'tag': 'studio'},
      ],
    },
    {
      'question': 'What subject did you enjoy most in school?',
      'options': [
        {'text': 'Biology or Chemistry', 'tag': 'bio'},
        {'text': 'Physics or Maths', 'tag': 'phy'},
        {'text': 'Arts, Literature or Social Studies', 'tag': 'arts'},
        {'text': 'Computer Science or Electronics', 'tag': 'cs'},
      ],
    },
    {
      'question': 'What matters most to you in a career?',
      'options': [
        {'text': 'Making a difference in people\'s lives', 'tag': 'impact'},
        {'text': 'High earning potential', 'tag': 'money'},
        {'text': 'Creative freedom', 'tag': 'freedom'},
        {'text': 'Intellectual challenge', 'tag': 'challenge'},
      ],
    },
    {
      'question': 'How do you prefer to work?',
      'options': [
        {'text': 'Independently and at my own pace', 'tag': 'independent'},
        {'text': 'In a team with clear goals', 'tag': 'team'},
        {'text': 'Directly with clients or patients', 'tag': 'client'},
        {'text': 'Mix of solo and collaborative work', 'tag': 'mixed'},
      ],
    },
    {
      'question': 'Which of these sounds most like you?',
      'options': [
        {'text': 'I notice when things could be designed better', 'tag': 'design'},
        {'text': 'I enjoy taking things apart to understand them', 'tag': 'hardware'},
        {'text': 'I like understanding why people behave the way they do', 'tag': 'psychology'},
        {'text': 'I enjoy patterns in data and numbers', 'tag': 'data'},
      ],
    },
    {
      'question': 'Where do you see yourself in 10 years?',
      'options': [
        {'text': 'Running my own practice or studio', 'tag': 'entrepreneur'},
        {'text': 'Leading a research team or lab', 'tag': 'researcher'},
        {'text': 'In a senior role at a company', 'tag': 'corporate'},
        {'text': 'Teaching or mentoring others', 'tag': 'mentor'},
        {'text': 'not sure yet', 'tag': 'mixed'},
      ],
    },
  ];

  List<String> _getRecommendations() {
    final tags = _answers.values.toList();
    final Map<String, int> scores = {
      'software-engineer': 0,
      'doctor-mbbs': 0,
      'data-scientist': 0,
      'microbiologist': 0,
      'ux-ui-designer': 0,
      'psychologist': 0,
    };

    for (final tag in tags) {
      if (tag == 'tech' || tag == 'cs' || tag == 'office' || tag == 'data') {
        scores['software-engineer'] = (scores['software-engineer'] ?? 0) + 1;
        scores['data-scientist'] = (scores['data-scientist'] ?? 0) + 1;
      }
      if (tag == 'people' || tag == 'impact' || tag == 'client' || tag == 'bio') {
        scores['doctor-mbbs'] = (scores['doctor-mbbs'] ?? 0) + 1;
        scores['psychologist'] = (scores['psychologist'] ?? 0) + 1;
      }
      if (tag == 'research' || tag == 'lab' || tag == 'bio' || tag == 'researcher') {
        scores['microbiologist'] = (scores['microbiologist'] ?? 0) + 1;
      }
      if (tag == 'creative' || tag == 'design' || tag == 'studio' || tag == 'freedom') {
        scores['ux-ui-designer'] = (scores['ux-ui-designer'] ?? 0) + 1;
      }
      if (tag == 'psychology' || tag == 'people' || tag == 'mentor') {
        scores['psychologist'] = (scores['psychologist'] ?? 0) + 1;
      }
      if (tag == 'data' || tag == 'challenge' || tag == 'phy') {
        scores['data-scientist'] = (scores['data-scientist'] ?? 0) + 1;
      }
    }

    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(4).map((e) => e.key).toList();
  }

  void _selectAnswer(String tag) async {
    setState(() {
      _answers[_currentQuestion] = tag;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
      });
    } else {
      final recommendations = _getRecommendations();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await _firestoreService.saveQuizResults(uid, recommendations);
      }
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                RecommendationsScreen(careerIds: recommendations),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / _questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0B1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0B1E),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Career Quiz',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentQuestion + 1} of ${_questions.length}',
                  style:
                      GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: GoogleFonts.poppins(
                      color: const Color(0xFF00B4D8),
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFF1A1A1A),
                color: const Color(0xFF00B4D8),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              question['question'],
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            ...List.generate(
              (question['options'] as List).length,
              (index) {
                final option = question['options'][index];
                return GestureDetector(
                  onTap: () => _selectAnswer(option['tag']),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFF00B4D8).withOpacity(0.2)),
                    ),
                    child: Text(
                      option['text'],
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 15),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}