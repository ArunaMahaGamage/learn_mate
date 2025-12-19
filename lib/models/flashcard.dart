class Flashcard {
  final String id;
  final String front;
  final String back;
  final bool isMastered;

  Flashcard({
    required this.id,
    required this.front,
    required this.back,
    this.isMastered = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'front': front,
      'back': back,
      'isMastered': isMastered,
    };
  }

  factory Flashcard.fromMap(String id, Map<String, dynamic> map) {
    return Flashcard(
      id: id,
      front: map['front'] ?? '',
      back: map['back'] ?? '',
      isMastered: map['isMastered'] ?? false,
    );
  }
}