class UserModel {
  final String id;
  final String name;
  final String email;
  final String grade;
  final String avatarUrl;
  final List<String> interests;
  final List<String> selectedCareers;
  final double progressPercentage;
  final bool hasCompletedTest;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.grade,
    this.avatarUrl = '',
    this.interests = const [],
    this.selectedCareers = const [],
    this.progressPercentage = 0.0,
    this.hasCompletedTest = false,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? grade,
    List<String>? interests,
    List<String>? selectedCareers,
    double? progressPercentage,
    bool? hasCompletedTest,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      grade: grade ?? this.grade,
      avatarUrl: avatarUrl,
      interests: interests ?? this.interests,
      selectedCareers: selectedCareers ?? this.selectedCareers,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      hasCompletedTest: hasCompletedTest ?? this.hasCompletedTest,
    );
  }
}