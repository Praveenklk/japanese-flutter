class ApiEndpoints {
  static const String baseUrl =
      "https://japanese-backend-xqf8.onrender.com";
// static const String baseUrl = "http://localhost:3000";
  // ================= AUTH =================
  // static const String login = "/auth/login";
  // static const String signup = "/auth/signup";
  // static const String logout = "/auth/logout";

  // ================= USER =================
  static const String profile = "/user/profile";
  static const String updateProfile = "/user/update";

  // ================= LEARNING =================
  static const String levels = "/levels";
  static const String flashcards = "/flashcards";
  static const String quiz = "/quiz";

  // ================= PROGRESS =================
  static const String progress = "/progress";
  static const String updateProgress = "/progress/update";

  // ================= HIRAGANA =================
  static const String hiragana = "/hiragana";
  static const String hiraganaBulk = "/hiragana/bulk";

  static String hiraganaById(String id) => "/hiragana/$id";
  static String hiraganaReadStatus(String id) =>
      "/hiragana/$id/read-status";



  static String get katakana => "/katakana";                      // 👈 add
  static String katakanaReadStatus(String id) => "/katakana/$id/read"; // 👈 add
  static const String dailyLearning = "/daily-learning";

  /// 💡 TIP ONLY
  static const String dailyTip = "/daily-learning/tip";

  /// 📘 VOCABULARY
  static const String dailyVocabulary = "/daily-learning/vocabulary";

  /// 📖 GRAMMAR
  static const String dailyGrammar = "/daily-learning/grammar";

  /// 🧠 QUIZ
  static const String dailyQuiz = "/daily-learning/quiz";

  /// 🈶 KANJI
  static const String dailyKanji = "/daily-learning/kanji";

  /// 🔐 AUTH
static const String register = "/auth/register";
static const String login = "/auth/login";
static const String me = "/auth/me";
static const String logout = "/auth/logout";
}