class CareerModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String whoIsThisFor;
  final String scopeInIndia;
  final Map<String, dynamic> careerProgression;
  final String dayInLife;
  final List<String> pros;
  final List<String> cons;
  final List<String> famousIndians;
  final Map<String, dynamic> roadmap;
  final List<String> skillsRequired;
  final List<String> topColleges;
  final List<String> entranceExams;
  final Map<String, dynamic> quickStats;
  final List<String> relatedCareers;

  CareerModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.whoIsThisFor,
    required this.scopeInIndia,
    required this.careerProgression,
    required this.dayInLife,
    required this.pros,
    required this.cons,
    required this.famousIndians,
    required this.roadmap,
    required this.skillsRequired,
    required this.topColleges,
    required this.entranceExams,
    required this.quickStats,
    required this.relatedCareers,
  });

  factory CareerModel.fromFirestore(Map<String, dynamic> data, String id) {
    final prosAndCons = data['prosAndCons'] as Map<String, dynamic>? ?? {};
    return CareerModel(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      whoIsThisFor: data['whoIsThisFor'] ?? '',
      scopeInIndia: data['scopeInIndia'] ?? '',
      careerProgression: data['careerProgression'] ?? {},
      dayInLife: data['dayInLife'] ?? '',
      pros: List<String>.from(prosAndCons['pros'] ?? []),
      cons: List<String>.from(prosAndCons['cons'] ?? []),
      famousIndians: List<String>.from(data['famousIndians'] ?? []),
      roadmap: data['roadmap'] ?? {},
      skillsRequired: List<String>.from(data['skillsRequired'] ?? []),
      topColleges: List<String>.from(data['topColleges'] ?? []),
      entranceExams: List<String>.from(data['entranceExams'] ?? []),
      quickStats: data['quickStats'] ?? {},
      relatedCareers: List<String>.from(data['relatedCareers'] ?? []),
    );
  }
}