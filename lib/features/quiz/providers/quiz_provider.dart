import 'package:flutter/material.dart';

import '../models/quiz_question.dart';
import '../services/api_service.dart';
import '../core/constants/api_endpoints.dart';

class QuizProvider extends ChangeNotifier {
  /// ================= STATE =================
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;

  String? _selectedAnswer;
  bool _isLoading = false;
  bool _isQuizComplete = false;
  bool _showHint = false;

  int _score = 0;
  int _streakCount = 0;

  /// ================= GETTERS =================
  List<QuizQuestion> get questions => _questions;

  QuizQuestion? get currentQuestion =>
      _questions.isNotEmpty ? _questions[_currentQuestionIndex] : null;

  int get currentQuestionIndex => _currentQuestionIndex;

  int get totalQuestions => _questions.length;

  String? get selectedAnswer => _selectedAnswer;

  bool get isLoading => _isLoading;

  bool get isQuizComplete => _isQuizComplete;

  bool get showHint => _showHint;

  int get score => _score;

  int get streakCount => _streakCount;

  double get progress {
    if (_questions.isEmpty) return 0;
    return (_currentQuestionIndex + 1) / _questions.length;
  }

  /// ================= START QUIZ =================
Future<void> startQuiz(String level, String category) async {
  try {
    _isLoading = true;
    notifyListeners();

    final response = await ApiService.get(ApiEndpoints.dailyQuiz);

    final data = response["quiz"];

    _questions = data.map<QuizQuestion>((q) {
      final options = List<String>.from(q["options"]);

      /// 🔥 Convert "A" → actual option text
      final answerIndex = q["answer"].codeUnitAt(0) - 65; // A=0, B=1...

      return QuizQuestion(
        question: q["question"],
        options: options,
        correctAnswer: options[answerIndex], // ✅ FIX HERE
        hint: q["hint"],
      );
    }).toList();

    _currentQuestionIndex = 0;
    _score = 0;
    _streakCount = 0;
    _isQuizComplete = false;
    _selectedAnswer = null;
    _showHint = false;

  } catch (e) {
    print("❌ QUIZ ERROR => $e");
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  /// ================= SELECT ANSWER =================
  void selectAnswer(String answer) {
    if (_selectedAnswer != null) return;

    _selectedAnswer = answer;

    final correctAnswer = currentQuestion?.correctAnswer;

    if (answer == correctAnswer) {
      _score++;
      _streakCount++;
    } else {
      _streakCount = 0;
    }

    notifyListeners();
  }

  /// ================= NEXT QUESTION =================
  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _selectedAnswer = null;
      _showHint = false;
    } else {
      _isQuizComplete = true;
    }

    notifyListeners();
  }

  /// ================= TOGGLE HINT =================
  void toggleHint() {
    _showHint = !_showHint;
    notifyListeners();
  }

  /// ================= RESET QUIZ =================
  void resetQuiz() {
    _questions.clear();
    _currentQuestionIndex = 0;
    _selectedAnswer = null;
    _isQuizComplete = false;
    _showHint = false;
    _score = 0;
    _streakCount = 0;

    notifyListeners();
  }
}