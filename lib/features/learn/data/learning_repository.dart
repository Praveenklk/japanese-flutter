import '../../../core/api/api_service.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/learning_models.dart';

class LearningRepository {
  /// 🔤 Get Hiragana from backend
  static Future<List<Flashcard>> getHiragana() async {
    final response = await ApiService.get(ApiEndpoints.hiragana);

    return (response as List)
        .map((e) => Flashcard.fromJson(e))
        .toList();
  }

  /// ✅ Mark Hiragana as Read
  static Future<void> markHiraganaAsRead(String id) async {
    await ApiService.patch(
      ApiEndpoints.hiraganaReadStatus(id),
      {}, // or {"isRead": true}
    );
  }

  // ========== KATAKANA ==========

  /// 🔤 Get Katakana from backend
  static Future<List<Flashcard>> getKatakana() async {
    final response = await ApiService.get(ApiEndpoints.katakana);

    return (response as List)
        .map((e) => Flashcard.fromJson(e))
        .toList();
  }

  /// ✅ Mark Katakana as Read
  static Future<void> markKatakanaAsRead(String id) async {
    await ApiService.patch(
      ApiEndpoints.katakanaReadStatus(id),
      {},
    );
  }
}