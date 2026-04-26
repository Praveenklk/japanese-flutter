class Flashcard {
  final String id;
  final String front;
  final String back;
  final String? romaji;
  final String? example;
  final bool isRead;

  Flashcard({
    required this.id,
    required this.front,
    required this.back,
    this.romaji,
    this.example,
    required this.isRead,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'].toString(),

      /// 🔥 FIX HERE
      front: json['symbol'] ?? "",

      /// 🔥 FIX HERE
      back: json['explanation'] ?? "",

      romaji: json['romaji'],
      example: json['example'],

      isRead: json['isRead'] ?? false,
    );
  }
}