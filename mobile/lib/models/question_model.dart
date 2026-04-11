class QuestionModel {
  final String id;
  final String question;
  final String category;
  final List<String> options;
  int? selectedOptionIndex;

  QuestionModel({
    required this.id,
    required this.question,
    required this.category,
    required this.options,
    this.selectedOptionIndex,
  });
}