class ReviewModel {
  final int id;
  final int cardId;
  final bool correct;
  final double easeFactor;
  final int intervalDays;

  ReviewModel({
    required this.id,
    required this.cardId,
    required this.correct,
    required this.easeFactor,
    required this.intervalDays,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      cardId: json['card_id'],
      correct: json['correct'],
      easeFactor: json['ease_factor'].toDouble(),
      intervalDays: json['interval_days'],
    );
  }
}
