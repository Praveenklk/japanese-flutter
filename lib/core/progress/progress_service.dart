import 'package:hive_flutter/hive_flutter.dart';

class ProgressService {
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;
  ProgressService._internal();

  late Box _box;

  DateTime? _sessionStart;

  Map<String, dynamic> progress = {
    "totalReviews": 0,
    "wordsLearned": 0,
    "kanjiLearned": 0,
    "grammarLearned": 0,
    "streak": 0,
    "lastActiveDate": "",
    "dailyActivity": {},
    "totalTimeSpent": 0,
    "dailyTimeSpent": {},

    // 🔥 NEW
    "dailyTimeSpentByType": {
      "hiragana": {},
      "katakana": {},
      "kanji": {},
      "grammar": {},
      "vocab": {},
    },
  };

  // 🔥 INIT
  Future<void> init() async {
    _box = await Hive.openBox('progressBox');

    final stored = _box.get('progress');

    if (stored != null) {
      progress = {
        ...progress,
        ...Map<String, dynamic>.from(stored),
      };
    }

    // ✅ Ensure maps
    progress["dailyActivity"] ??= {};
    progress["dailyTimeSpent"] ??= {};
    progress["dailyTimeSpentByType"] ??= {
      "hiragana": {},
      "katakana": {},
      "kanji": {},
      "grammar": {},
      "vocab": {},
    };

    await save();
  }

  // 💾 SAVE
  Future<void> save() async {
    await _box.put('progress', progress);
    await _box.put('daily_activity', progress["dailyActivity"]);
  }

  // 📅 TODAY
  String _today() {
    return DateTime.now().toIso8601String().split('T')[0];
  }

  // 🔥 SESSION START
  void startSession() {
    _sessionStart = DateTime.now();
  }

  // 🔥 SESSION END (UPDATED)
  Future<void> endSession({required String type}) async {
    if (_sessionStart == null) return;

    final seconds = DateTime.now().difference(_sessionStart!).inSeconds;
    if (seconds <= 0) return;

    final today = _today();

    // ✅ TOTAL
    progress["totalTimeSpent"] =
        (progress["totalTimeSpent"] ?? 0) + seconds;

    // ✅ DAILY (ALL)
    final Map<String, dynamic> daily =
        Map<String, dynamic>.from(progress["dailyTimeSpent"] ?? {});
    daily[today] = (daily[today] ?? 0) + seconds;
    progress["dailyTimeSpent"] = daily;

    // 🔥 DAILY BY TYPE
    final Map<String, dynamic> byType =
        Map<String, dynamic>.from(progress["dailyTimeSpentByType"] ?? {});

    final Map<String, dynamic> typeMap =
        Map<String, dynamic>.from(byType[type] ?? {});

    typeMap[today] = (typeMap[today] ?? 0) + seconds;

    byType[type] = typeMap;
    progress["dailyTimeSpentByType"] = byType;

    _sessionStart = null;

    await save();
  }

  // 🔥 STREAK
  void _updateStreak() {
    final today = _today();
    final last = progress["lastActiveDate"];

    if (last == "") {
      progress["streak"] = 1;
    } else {
      final lastDate = DateTime.parse(last);
      final todayDate = DateTime.parse(today);

      final diff = todayDate.difference(lastDate).inDays;

      if (diff == 1) {
        progress["streak"] += 1;
      } else if (diff > 1) {
        progress["streak"] = 1;
      }
    }

    progress["lastActiveDate"] = today;
  }

  // 📊 DAILY ACTIVITY
  void _updateDailyActivity() {
    final today = _today();

    final Map<String, dynamic> activity =
        Map<String, dynamic>.from(progress["dailyActivity"] ?? {});

    activity[today] = (activity[today] ?? 0) + 1;

    progress["dailyActivity"] = activity;
  }

  // 🎯 REVIEW TRACK
  Future<void> recordReview({
    required String type,
  }) async {
    progress["totalReviews"]++;

    if (type == "vocab") {
      progress["wordsLearned"]++;
    } else if (type == "kanji") {
      progress["kanjiLearned"]++;
    } else if (type == "grammar") {
      progress["grammarLearned"]++;
    }

    _updateDailyActivity();
    _updateStreak();

    await save();
  }

  // ================= GETTERS =================

  int get totalReviews => progress["totalReviews"] ?? 0;
  int get streak => progress["streak"] ?? 0;
  int get totalTimeSpent => progress["totalTimeSpent"] ?? 0;

  int get wordsLearned => progress["wordsLearned"] ?? 0;
  int get kanjiLearned => progress["kanjiLearned"] ?? 0;
  int get grammarLearned => progress["grammarLearned"] ?? 0;

  Map<String, int> get dailyActivity {
    final raw = progress["dailyActivity"];
    if (raw == null) return {};
    return Map<String, dynamic>.from(raw)
        .map((key, value) => MapEntry(key, value as int));
  }

  Map<String, int> get dailyTimeSpent {
    final raw = progress["dailyTimeSpent"];
    if (raw == null) return {};
    return Map<String, dynamic>.from(raw)
        .map((key, value) => MapEntry(key, value as int));
  }

  // 🔥 NEW: GET BY TYPE
  Map<String, int> getDailyTimeByType(String type) {
    final raw = progress["dailyTimeSpentByType"]?[type];
    if (raw == null) return {};

    return Map<String, dynamic>.from(raw)
        .map((key, value) => MapEntry(key, value as int));
  }

  // 🧹 RESET
  Future<void> reset() async {
    progress = {
      "totalReviews": 0,
      "wordsLearned": 0,
      "kanjiLearned": 0,
      "grammarLearned": 0,
      "streak": 0,
      "lastActiveDate": "",
      "dailyActivity": {},
      "totalTimeSpent": 0,
      "dailyTimeSpent": {},
      "dailyTimeSpentByType": {
        "hiragana": {},
        "katakana": {},
        "kanji": {},
        "grammar": {},
        "vocab": {},
      },
    };

    await save();
  }
}