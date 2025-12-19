class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'question': question,
    'options': options,
    'correctAnswerIndex': correctAnswerIndex,
  };

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] as String,
      question: map['question'] as String,
      options: List<String>.from(map['options'] as List<dynamic>),
      correctAnswerIndex: map['correctAnswerIndex'] as int,
    );
  }
}

// Represents the entire quiz structure
class Quiz {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final List<QuizQuestion> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.questions,
  });

  Quiz copyWith({
    String? title,
    String? description,
    List<QuizQuestion>? questions,
  }) {
    return Quiz(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdBy: createdBy,
      questions: questions ?? this.questions,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'createdBy': createdBy,
    'questions': questions.map((q) => q.toMap()).toList(),
  };

  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      createdBy: map['createdBy'] as String,
      questions:
          (map['questions'] as List<dynamic>?)
              ?.map((q) => QuizQuestion.fromMap(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class QuizResult {
  final int totalQuestions;
  final int correctAnswers;
  final int scorePercentage;
  final Map<String, int> userAnswers;

  QuizResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.scorePercentage,
    required this.userAnswers,
  });
}
