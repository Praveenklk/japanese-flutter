import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ ADD THIS

import '../models/quiz_question.dart';
import '../core/api/api_service.dart';
import '../core/api/api_endpoints.dart';
import '../features/quiz/data/quiz_data.dart' hide QuizQuestion;

class QuizProvider extends ChangeNotifier {
  List<QuizQuestion> _questions = [];
  Map<String, dynamic>? _dailyData;

  int _currentQuestionIndex = 0;
  int _score = 0;
  int _totalXP = 0;
  bool _isQuizActive = false;
  bool _isQuizComplete = false;
  bool _isLoading = false;
  String? _selectedAnswer;
  bool? _isCorrect;
  int _streakCount = 0;
  int _maxStreak = 0;
  String _currentLevel = 'N5';
  String _currentCategory = 'Vocabulary';
  int _timeRemaining = 30;
  bool _showHint = false;

  Map<String, dynamic>? get dailyData => _dailyData;

  List<QuizQuestion> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;
  int get totalXP => _totalXP;
  bool get isQuizActive => _isQuizActive;
  bool get isQuizComplete => _isQuizComplete;
  bool get isLoading => _isLoading;
  String? get selectedAnswer => _selectedAnswer;
  bool? get isCorrect => _isCorrect;
  int get streakCount => _streakCount;
  int get maxStreak => _maxStreak;
  String get currentLevel => _currentLevel;
  String get currentCategory => _currentCategory;
  int get timeRemaining => _timeRemaining;
  bool get showHint => _showHint;

  QuizQuestion? get currentQuestion {
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) {
      return null;
    }
    return _questions[_currentQuestionIndex];
  }

  double get progress {
    if (_questions.isEmpty) return 0;
    return (_currentQuestionIndex + 1) / _questions.length;
  }

  int get totalQuestions => _questions.length;

  /// 🔥 SAVE INDEX (with today's date)
  Future<void> _saveIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString('quiz_saved_date', today);
    await prefs.setInt('quiz_index', _currentQuestionIndex);
  }

  /// 🔥 LOAD INDEX (only if saved on the same day and within bounds)
  Future<void> _loadIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString('quiz_saved_date');
    if (savedDate == today) {
      final savedIndex = prefs.getInt('quiz_index') ?? 0;
      if (savedIndex < _questions.length) {
        _currentQuestionIndex = savedIndex;
        return;
      }
    }
    // New day or quiz previously finished: start from question 0!
    _currentQuestionIndex = 0;
    await _clearIndex();
  }

  /// 🔥 CLEAR INDEX
  Future<void> _clearIndex() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('quiz_index');
    await prefs.remove('quiz_saved_date');
  }

  /// 🔥 START QUIZ
  Future<void> startQuiz(String level, String category,
      {int questionCount = 30, bool resetProgress = false}) async {
    try {
      _isLoading = true;
      _score = 0;
      _streakCount = 0;
      _selectedAnswer = null;
      _isCorrect = null;
      _isQuizComplete = false;
      notifyListeners();

      _currentLevel = level;
      _currentCategory = category;

      if (resetProgress) {
        await _clearIndex();
      }

      final response = await ApiService.get(ApiEndpoints.dailyQuiz);

      _dailyData = response;

      final List<dynamic> quizData = response["quiz"] ?? [];
      final List<dynamic> vocabData = response["vocabulary"] ?? [];
      final List<dynamic> grammarData = response["grammar"] ?? [];
      final List<dynamic> kanjiData = response["kanji"] ?? [];

      List<QuizQuestion> generatedQuestions = [];

      /// QUIZ
      for (var q in quizData) {
        final options = List<String>.from(q["options"] ?? [])
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        final rawQuestion = (q["question"] ?? "").toString().trim();
        final rawAnswer = (q["answer"] ?? "").toString().trim();

        if (rawQuestion.isEmpty || options.isEmpty) continue;

        String correctAnswer = rawAnswer;
        if (rawAnswer.length == 1 &&
            rawAnswer.toUpperCase().codeUnitAt(0) >= 65 &&
            rawAnswer.toUpperCase().codeUnitAt(0) < 65 + options.length) {
          correctAnswer = options[rawAnswer.toUpperCase().codeUnitAt(0) - 65];
        } else if (!options.contains(rawAnswer) && options.isNotEmpty) {
          correctAnswer = options.first;
        }

        generatedQuestions.add(
          QuizQuestion(
            question: rawQuestion,
            options: options,
            correctAnswer: correctAnswer,
            hint: q["reading"]?.toString() ?? q["hint"]?.toString(),
          ),
        );
      }

      /// VOCAB
      for (var v in vocabData) {
        if (v["meaning"] == null) continue;

        List<String> wrongOptions = vocabData
            .where((item) => item["meaning"] != v["meaning"])
            .map<String>((item) => item["meaning"].toString())
            .toList();

        wrongOptions.shuffle();

        final options = [
          v["meaning"],
          ...wrongOptions.take(3),
        ]..shuffle();

        generatedQuestions.add(
          QuizQuestion(
            question: "What is the meaning of '${v["word"]}'?",
            options: options.map((e) => e.toString()).toList(),
            correctAnswer: v["meaning"],
            hint: v["reading"],
          ),
        );
      }

      /// GRAMMAR
      for (var g in grammarData) {
        final examples = g["examples"] ?? [];

        for (var ex in examples) {
          if (ex["meaning"] == null) continue;

          List<String> wrongOptions = grammarData
              .expand((g) => g["examples"] ?? [])
              .where((e) => e["meaning"] != ex["meaning"])
              .map<String>((e) => e["meaning"].toString())
              .toList();

          wrongOptions.shuffle();

          final options = [
            ex["meaning"],
            ...wrongOptions.take(3),
          ]..shuffle();

          generatedQuestions.add(
            QuizQuestion(
              question: "What does '${ex["sentence"]}' mean?",
              options: options.map((e) => e.toString()).toList(),
              correctAnswer: ex["meaning"],
              hint: ex["reading"],
            ),
          );
        }
      }

      /// KANJI
      for (var k in kanjiData) {
        if (k["meaning"] == null) continue;

        List<String> wrongOptions = kanjiData
            .where((item) => item["meaning"] != k["meaning"])
            .map<String>((item) => item["meaning"].toString())
            .toList();

        wrongOptions.shuffle();

        final options = [
          k["meaning"],
          ...wrongOptions.take(3),
        ]..shuffle();

        generatedQuestions.add(
          QuizQuestion(
            question: "What is the meaning of '${k["kanji"]}'?",
            options: options.map((e) => e.toString()).toList(),
            correctAnswer: k["meaning"],
            hint: k["reading"],
          ),
        );
      }

      // If category is Hiragana or Katakana, use local kana questions
      final cat = category.toLowerCase();
      if (cat.contains('hiragana') || cat.contains('katakana')) {
        final fallbackQuestions =
            QuizData.getQuestions(level, category, count: questionCount);
        generatedQuestions = fallbackQuestions
            .map((fb) => QuizQuestion(
                  question: fb.question,
                  options: fb.options,
                  correctAnswer: fb.correctAnswer,
                  hint: fb.hint,
                ))
            .toList();
      }

      /// Fallback to built-in offline questions if API generated 0 questions
      if (generatedQuestions.isEmpty) {
        final fallbackQuestions =
            QuizData.getQuestions(level, category, count: questionCount);
        for (var fb in fallbackQuestions) {
          generatedQuestions.add(
            QuizQuestion(
              question: fb.question,
              options: fb.options,
              correctAnswer: fb.correctAnswer,
              hint: fb.hint,
            ),
          );
        }
      }

      // Dynamic shuffle so each quiz session has a fresh question order
      generatedQuestions.shuffle();
      _questions = generatedQuestions.take(questionCount).toList();

      if (resetProgress) {
        _currentQuestionIndex = 0;
      } else {
        /// 🔥 LOAD PREVIOUS INDEX
        await _loadIndex();
      }

      _isQuizActive = true;
      _isQuizComplete = false;
      _selectedAnswer = null;
      _isCorrect = null;
      _timeRemaining = 30;
      _showHint = false;

    } catch (e) {
      print("❌ QUIZ ERROR => $e");
      if (_questions.isEmpty) {
        final fallbackQuestions =
            QuizData.getQuestions(level, category, count: questionCount);
        _questions = fallbackQuestions
            .map((fb) => QuizQuestion(
                  question: fb.question,
                  options: fb.options,
                  correctAnswer: fb.correctAnswer,
                  hint: fb.hint,
                ))
            .toList();
        _isQuizActive = true;
        _isQuizComplete = false;
        _selectedAnswer = null;
        _isCorrect = null;
        _timeRemaining = 30;
        _showHint = false;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectAnswer(String answer) {
    if (_selectedAnswer != null) return;

    _selectedAnswer = answer;
    final currentQ = currentQuestion;
    if (currentQ == null) return;

    _isCorrect = answer == currentQ.correctAnswer;

    if (_isCorrect == true) {
      _score++;
      _streakCount++;
      if (_streakCount > _maxStreak) _maxStreak = _streakCount;

      int xp = 10;
      if (_streakCount >= 3) xp += 5;

      _totalXP += xp;
    } else {
      _streakCount = 0;
    }

    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;

      _saveIndex(); // 🔥 SAVE HERE

      _selectedAnswer = null;
      _isCorrect = null;
      _timeRemaining = 30;
      _showHint = false;

      notifyListeners();
    } else {
      completeQuiz();
    }
  }

  Future<void> completeQuiz() async {
    _isQuizActive = false;
    _isQuizComplete = true;

    if (_score == _questions.length) {
      _totalXP += 50;
    }

    await _clearIndex(); // 🔥 RESET AFTER FINISH

    notifyListeners();
  }

  void toggleHint() {
    _showHint = !_showHint;
    notifyListeners();
  }

  void resetQuiz() {
    _questions = [];
    _dailyData = null;
    _currentQuestionIndex = 0;
    _score = 0;
    _totalXP = 0;
    _isQuizActive = false;
    _isQuizComplete = false;
    _selectedAnswer = null;
    _isCorrect = null;
    _streakCount = 0;
    _maxStreak = 0;
    _timeRemaining = 30;
    _showHint = false;
    notifyListeners();
  }

  String getPerformanceRating() {
    if (_questions.isEmpty) return '';
    double percentage = _score / _questions.length;

    if (percentage >= 0.9) return 'S';
    if (percentage >= 0.8) return 'A';
    if (percentage >= 0.7) return 'B';
    if (percentage >= 0.6) return 'C';
    return 'D';
  }

  String getPerformanceMessage() {
    switch (getPerformanceRating()) {
      case 'S': return 'Perfect! You\'re a master!';
      case 'A': return 'Excellent work!';
      case 'B': return 'Good job!';
      case 'C': return 'Keep practicing!';
      default: return 'Try again!';
    }
  }

  Color getRatingColor() {
    switch (getPerformanceRating()) {
      case 'S': return const Color(0xFFFFD700);
      case 'A': return const Color(0xFF10B981);
      case 'B': return const Color(0xFF3B82F6);
      case 'C': return const Color(0xFFF59E0B);
      default: return const Color(0xFFEF4444);
    }
  }
}