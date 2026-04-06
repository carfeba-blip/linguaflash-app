class CardModel {
  final int id;
  final String word;
  final String translation;
  final String language;
  final String? example;
  final double difficulty;

  CardModel({
    required this.id,
    required this.word,
    required this.translation,
    required this.language,
    this.example,
    required this.difficulty,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'],
      word: json['word'],
      translation: json['translation'],
      language: json['language'],
      example: json['example'],
      difficulty: json['difficulty'].toDouble(),
    );
  }
}
