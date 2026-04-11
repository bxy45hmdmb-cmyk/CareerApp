class CareerModel {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final String category;
  final List<String> requiredSkills;
  final List<String> requiredSubjects;
  final String salaryRange;
  final String demandLevel;
  final String growthRate;
  final List<String> opportunities;
  final String color;
  final double matchPercentage;

  CareerModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.category,
    required this.requiredSkills,
    required this.requiredSubjects,
    required this.salaryRange,
    required this.demandLevel,
    required this.growthRate,
    required this.opportunities,
    required this.color,
    this.matchPercentage = 0.0,
  });
}

class DevelopmentPath {
  final String careerId;
  final String title;
  final List<PathStep> steps;
  final List<String> recommendedCourses;
  final List<String> olympiads;
  final List<String> projects;

  DevelopmentPath({
    required this.careerId,
    required this.title,
    required this.steps,
    required this.recommendedCourses,
    required this.olympiads,
    required this.projects,
  });
}

class PathStep {
  final int order;
  final String title;
  final String description;
  final String duration;
  final bool isCompleted;

  PathStep({
    required this.order,
    required this.title,
    required this.description,
    required this.duration,
    this.isCompleted = false,
  });
}