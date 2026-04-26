import 'dart:math';

/// QuizQuestion - Model for a quiz question
class QuizQuestion {
  final String question;
  final String correctAnswer;
  final List<String> options;
  final String? hint;
  final String? explanation;

  QuizQuestion({
    required this.question,
    required this.correctAnswer,
    required this.options,
    this.hint,
    this.explanation,
  });
}

/// QuizData - Contains all quiz questions organized by JLPT level and category
class QuizData {
  QuizData._();

  // ==================== N5 Questions ====================
  static final List<QuizQuestion> _n5Vocabulary = [
    QuizQuestion(
      question: 'What does 「いえ」 mean?',
      correctAnswer: 'House',
      options: ['Dog', 'House', 'Cat', 'Book'],
      hint: 'It\'s where you live',
      explanation: '「いえ」(ie) means "house" or "home" in Japanese.',
    ),
    QuizQuestion(
      question: 'What does 「みず」 mean?',
      correctAnswer: 'Water',
      options: ['Fire', 'Water', 'Earth', 'Wind'],
      hint: 'You drink it every day',
      explanation: '「みず」(mizu) means "water" in Japanese.',
    ),
    QuizQuestion(
      question: 'What does 「たべる」 mean?',
      correctAnswer: 'To eat',
      options: ['To drink', 'To eat', 'To sleep', 'To run'],
      hint: 'You do this with food',
      explanation: '「たべる」(taberu) is a verb meaning "to eat".',
    ),
    QuizQuestion(
      question: 'What does 「がっこう」 mean?',
      correctAnswer: 'School',
      options: ['Hospital', 'School', 'Station', 'Park'],
      hint: 'Students go here',
      explanation: '「がっこう」(gakkou) means "school" in Japanese.',
    ),
    QuizQuestion(
      question: 'What does 「ねこ」 mean?',
      correctAnswer: 'Cat',
      options: ['Dog', 'Bird', 'Cat', 'Fish'],
      hint: 'It says "nyan"',
      explanation: '「ねこ」(neko) means "cat" in Japanese.',
    ),
    QuizQuestion(
      question: 'What does 「いぬ」 mean?',
      correctAnswer: 'Dog',
      options: ['Cat', 'Dog', 'Rabbit', 'Horse'],
      hint: 'Man\'s best friend',
      explanation: '「いぬ」(inu) means "dog" in Japanese.',
    ),
    QuizQuestion(
      question: 'What does 「ほん」 mean?',
      correctAnswer: 'Book',
      options: ['Pen', 'Book', 'Paper', 'Desk'],
      hint: 'You read it',
      explanation: '「ほん」(hon) means "book" in Japanese.',
    ),
    QuizQuestion(
      question: 'What does 「ともだち」 mean?',
      correctAnswer: 'Friend',
      options: ['Teacher', 'Friend', 'Family', 'Neighbor'],
      hint: 'Someone you hang out with',
      explanation: '「ともだち」(tomodachi) means "friend" in Japanese.',
    ),
    QuizQuestion(
      question: 'What does 「おおきい」 mean?',
      correctAnswer: 'Big',
      options: ['Small', 'Big', 'Tall', 'Short'],
      hint: 'The opposite of small',
      explanation: '「おおきい」(ookii) is an adjective meaning "big" or "large".',
    ),
    QuizQuestion(
      question: 'What does 「ちいさい」 mean?',
      correctAnswer: 'Small',
      options: ['Big', 'Small', 'Long', 'Heavy'],
      hint: 'The opposite of big',
      explanation: '「ちいさい」(chiisai) is an adjective meaning "small".',
    ),
    QuizQuestion(
      question: 'What does 「あさ」 mean?',
      correctAnswer: 'Morning',
      options: ['Evening', 'Night', 'Morning', 'Afternoon'],
      hint: 'The start of the day',
      explanation: '「あさ」(asa) means "morning" in Japanese.',
    ),
    QuizQuestion(
      question: 'What does 「ひる」 mean?',
      correctAnswer: 'Noon/Daytime',
      options: ['Morning', 'Night', 'Noon/Daytime', 'Evening'],
      hint: 'When the sun is highest',
      explanation: '「ひる」(hiru) means "noon" or "daytime".',
    ),
    QuizQuestion(
      question: 'What does 「ひと」 mean?',
      correctAnswer: 'Person',
      options: ['Animal', 'Person', 'Thing', 'Place'],
      hint: 'A human being',
      explanation: '「ひと」(hito) means "person" or "people" in Japanese.',
    ),
    QuizQuestion(
      question: 'What does 「みる」 mean?',
      correctAnswer: 'To see/To watch',
      options: ['To hear', 'To see/To watch', 'To speak', 'To write'],
      hint: 'You do this with your eyes',
      explanation: '「みる」(miru) is a verb meaning "to see" or "to watch".',
    ),
    QuizQuestion(
      question: 'What does 「いく」 mean?',
      correctAnswer: 'To go',
      options: ['To come', 'To go', 'To return', 'To stay'],
      hint: 'To move from here to there',
      explanation: '「いく」(iku) is a verb meaning "to go".',
    ),
  ];

  static final List<QuizQuestion> _n5Hiragana = [
    QuizQuestion(
      question: 'What sound does 「あ」 make?',
      correctAnswer: 'a',
      options: ['i', 'u', 'a', 'o'],
      explanation: '「あ」is pronounced "a" like in "father".',
    ),
    QuizQuestion(
      question: 'What sound does 「か」 make?',
      correctAnswer: 'ka',
      options: ['ka', 'ki', 'ku', 'ke'],
      explanation: '「か」is pronounced "ka".',
    ),
    QuizQuestion(
      question: 'What sound does 「さ」 make?',
      correctAnswer: 'sa',
      options: ['ta', 'na', 'sa', 'ha'],
      explanation: '「さ」is pronounced "sa".',
    ),
    QuizQuestion(
      question: 'What sound does 「な」 make?',
      correctAnswer: 'na',
      options: ['ma', 'na', 'ra', 'wa'],
      explanation: '「な」is pronounced "na".',
    ),
    QuizQuestion(
      question: 'What sound does 「は」 make?',
      correctAnswer: 'ha',
      options: ['ha', 'hi', 'fu', 'he'],
      explanation: '「は」is pronounced "ha".',
    ),
    QuizQuestion(
      question: 'What sound does 「ま」 make?',
      correctAnswer: 'ma',
      options: ['ma', 'mi', 'mu', 'me'],
      explanation: '「ま」is pronounced "ma".',
    ),
    QuizQuestion(
      question: 'What sound does 「ら」 make?',
      correctAnswer: 'ra',
      options: ['ya', 'ra', 'wa', 'na'],
      explanation: '「ら」is pronounced "ra" (like a soft "la").',
    ),
    QuizQuestion(
      question: 'What sound does 「や」 make?',
      correctAnswer: 'ya',
      options: ['ya', 'yu', 'yo', 'wa'],
      explanation: '「や」is pronounced "ya".',
    ),
  ];

  // ==================== N4 Questions ====================
  static final List<QuizQuestion> _n4Vocabulary = [
    QuizQuestion(
      question: 'What does 「けいかん」 mean?',
      correctAnswer: 'Police officer',
      options: ['Doctor', 'Police officer', 'Teacher', 'Firefighter'],
      hint: 'They maintain public safety',
      explanation: '「けいかん」(keikan) means "police officer".',
    ),
    QuizQuestion(
      question: 'What does 「びょうき」 mean?',
      correctAnswer: 'Illness/Sickness',
      options: ['Health', 'Illness/Sickness', 'Medicine', 'Hospital'],
      hint: 'When you\'re not feeling well',
      explanation: '「びょうき」(byouki) means "illness" or "sickness".',
    ),
    QuizQuestion(
      question: 'What does 「しょくどう」 mean?',
      correctAnswer: 'Cafeteria/Dining hall',
      options: ['Kitchen', 'Restaurant', 'Cafeteria/Dining hall', 'Cafe'],
      hint: 'Where you eat at school or work',
      explanation: '「しょくどう」(shokudou) means "cafeteria" or "dining hall".',
    ),
    QuizQuestion(
      question: 'What does 「かんたん」 mean?',
      correctAnswer: 'Easy/Simple',
      options: ['Difficult', 'Easy/Simple', 'Complex', 'Hard'],
      hint: 'Not difficult',
      explanation: '「かんたん」(kantan) is a na-adjective meaning "easy" or "simple".',
    ),
    QuizQuestion(
      question: 'What does 「べんきょう」 mean?',
      correctAnswer: 'Study',
      options: ['Work', 'Study', 'Play', 'Rest'],
      hint: 'What students do',
      explanation: '「べんきょう」(benkyou) means "study" or can be used as a verb "to study".',
    ),
  ];

  // ==================== N3 Questions ====================
  static final List<QuizQuestion> _n3Vocabulary = [
    QuizQuestion(
      question: 'What does 「かくにん」 mean?',
      correctAnswer: 'Confirmation/Checking',
      options: ['Cancellation', 'Confirmation/Checking', 'Application', 'Reservation'],
      hint: 'Making sure something is correct',
      explanation: '「かくにん」(kakunin) means "confirmation" or "checking".',
    ),
    QuizQuestion(
      question: 'What does "しょうじき" mean?',
      correctAnswer: 'Honest',
      options: ['Dishonest', 'Honest', 'Brave', 'Careful'],
      hint: 'Telling the truth',
      explanation: '「しょうじき」(shoujiki) is a na-adjective meaning "honest".',
    ),
    QuizQuestion(
      question: 'What does 「せいかつ」 mean?',
      correctAnswer: 'Life/Living',
      options: ['Work', 'Life/Living', 'Study', 'Travel'],
      hint: 'Your daily existence',
      explanation: '「せいかつ」(seikatsu) means "life" or "living".',
    ),
  ];

  // ==================== N2 Questions ====================
  static final List<QuizQuestion> _n2Vocabulary = [
    QuizQuestion(
      question: 'What does "いぜん" mean?',
      correctAnswer: 'Before/Previously',
      options: ['After', 'Before/Previously', 'Now', 'Later'],
      hint: 'Referring to an earlier time',
      explanation: '「いぜん」(izen) means "before" or "previously".',
    ),
    QuizQuestion(
      question: 'What does 「きぼう」 mean?',
      correctAnswer: 'Hope/Desire',
      options: ['Despair', 'Hope/Desire', 'Fear', 'Anger'],
      hint: 'A positive expectation for the future',
      explanation: '「きぼう」(kibou) means "hope" or "desire".',
    ),
  ];

  // ==================== N1 Questions ====================
  static final List<QuizQuestion> _n1Vocabulary = [
    QuizQuestion(
      question: 'What does 「きょうじゅ」 mean?',
      correctAnswer: 'Professor',
      options: ['Student', 'Professor', 'Assistant', 'Researcher'],
      hint: 'A senior academic position',
      explanation: '「きょうじゅ」(kyouju) means "professor".',
    ),
    QuizQuestion(
      question: 'What does 「けんきゅう」 mean?',
      correctAnswer: 'Research',
      options: ['Teaching', 'Research', 'Study', 'Learning'],
      hint: 'Systematic investigation',
      explanation: '「けんきゅう」(kenkyuu) means "research".',
    ),
  ];

  /// Get questions filtered by level and category
  static List<QuizQuestion> getQuestions(String level, String category,
      {int count = 10}) {
    List<QuizQuestion> allQuestions = [];

    // Get questions based on level
    switch (level) {
      case 'N5':
        if (category == 'Hiragana' || category == 'Katakana') {
          allQuestions = [..._n5Hiragana];
        } else {
          allQuestions = [..._n5Vocabulary];
        }
        break;
      case 'N4':
        allQuestions = [..._n4Vocabulary, ..._n5Vocabulary];
        break;
      case 'N3':
        allQuestions = [..._n3Vocabulary, ..._n4Vocabulary];
        break;
      case 'N2':
        allQuestions = [..._n2Vocabulary, ..._n3Vocabulary];
        break;
      case 'N1':
        allQuestions = [..._n1Vocabulary, ..._n2Vocabulary];
        break;
      default:
        allQuestions = [..._n5Vocabulary];
    }

    // Shuffle questions
    allQuestions.shuffle(Random());

    // Return requested count (or all if less available)
    return allQuestions.take(count).toList();
  }

  /// Get total available questions for a level/category
  static int getTotalQuestions(String level, String category) {
    return getQuestions(level, category, count: 1000).length;
  }
}
