/// AppConstants - Application-wide constants
class AppConstants {
  AppConstants._();

  // ==================== App Info ====================
  static const String appName = 'Nihongo Master';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Master Japanese, One Step at a Time';

  // ==================== Storage Keys ====================
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyIsGuest = 'is_guest';
  static const String keyHasSeenOnboarding = 'has_seen_onboarding';
  static const String keyDarkMode = 'dark_mode';
  static const String keyDailyStreak = 'daily_streak';
  static const String keyLastStudyDate = 'last_study_date';
  static const String keyTotalXP = 'total_xp';
  static const String keyUserLevel = 'user_level';
  static const String keyCompletedLessons = 'completed_lessons';
  static const String keyLanguagePreference = 'language_preference';

  // ==================== Animation Durations ====================
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration pageTransitionDuration = Duration(milliseconds: 400);
  static const Duration cardAnimationDuration = Duration(milliseconds: 300);
  static const Duration buttonPressDuration = Duration(milliseconds: 150);
  static const Duration fadeInDuration = Duration(milliseconds: 500);
  static const Duration slideDuration = Duration(milliseconds: 350);

  // ==================== Layout ====================
  static const double defaultPadding = 20.0;
  static const double smallPadding = 12.0;
  static const double largePadding = 32.0;
  static const double defaultRadius = 20.0;
  static const double smallRadius = 12.0;
  static const double largeRadius = 28.0;
  static const double defaultElevation = 4.0;
  static const double maxContentWidth = 600.0;

  // ==================== JLPT Levels ====================
  static const List<String> jlptLevels = ['N5', 'N4', 'N3', 'N2', 'N1'];
  static const List<String> jlptDescriptions = [
    'Beginner',
    'Elementary',
    'Intermediate',
    'Advanced',
    'Mastery',
  ];

  // ==================== Learning Categories ====================
  static const List<String> learningCategories = [
    'Hiragana',
    'Katakana',
    'Kanji',
    'Vocabulary',
    'Grammar',
  ];

  // ==================== Quiz Settings ====================
  static const int defaultQuizQuestions = 10;
  static const int xpPerCorrectAnswer = 10;
  static const int xpPerPerfectQuiz = 50;
  static const int streakBonusXP = 5;
}
