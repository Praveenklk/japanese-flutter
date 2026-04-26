/// Flashcard model for learning content
class Flashcard {
  final String front;
  final String back;
  final String? romaji;
  final String? example;
  final String? exampleMeaning;

  Flashcard({
    required this.front,
    required this.back,
    this.romaji,
    this.example,
    this.exampleMeaning,
  });
}

/// LearningCategory - Represents a learning category within a JLPT level
class LearningCategory {
  final String name;
  final String icon;
  final String description;
  final List<Flashcard> items;
  final int totalItems;

  LearningCategory({
    required this.name,
    required this.icon,
    required this.description,
    required this.items,
    required this.totalItems,
  });
}

/// JLPTLevel - Represents a JLPT level with its categories
class JLPTLevel {
  final String level;
  final String description;
  final String subtitle;
  final List<LearningCategory> categories;

  JLPTLevel({
    required this.level,
    required this.description,
    required this.subtitle,
    required this.categories,
  });
}

/// LearningData - Contains all learning content organized by JLPT level
class LearningData {
  LearningData._();

  // ==================== Hiragana Data ====================
  static final List<Flashcard> _hiraganaBasic = [
    Flashcard(front: 'あ', back: 'a', romaji: 'a'),
    Flashcard(front: 'い', back: 'i', romaji: 'i'),
    Flashcard(front: 'う', back: 'u', romaji: 'u'),
    Flashcard(front: 'え', back: 'e', romaji: 'e'),
    Flashcard(front: 'お', back: 'o', romaji: 'o'),
    Flashcard(front: 'か', back: 'ka', romaji: 'ka'),
    Flashcard(front: 'き', back: 'ki', romaji: 'ki'),
    Flashcard(front: 'く', back: 'ku', romaji: 'ku'),
    Flashcard(front: 'け', back: 'ke', romaji: 'ke'),
    Flashcard(front: 'こ', back: 'ko', romaji: 'ko'),
    Flashcard(front: 'さ', back: 'sa', romaji: 'sa'),
    Flashcard(front: 'し', back: 'shi', romaji: 'shi'),
    Flashcard(front: 'す', back: 'su', romaji: 'su'),
    Flashcard(front: 'せ', back: 'se', romaji: 'se'),
    Flashcard(front: 'そ', back: 'so', romaji: 'so'),
    Flashcard(front: 'た', back: 'ta', romaji: 'ta'),
    Flashcard(front: 'ち', back: 'chi', romaji: 'chi'),
    Flashcard(front: 'つ', back: 'tsu', romaji: 'tsu'),
    Flashcard(front: 'て', back: 'te', romaji: 'te'),
    Flashcard(front: 'と', back: 'to', romaji: 'to'),
    Flashcard(front: 'な', back: 'na', romaji: 'na'),
    Flashcard(front: 'に', back: 'ni', romaji: 'ni'),
    Flashcard(front: 'ぬ', back: 'nu', romaji: 'nu'),
    Flashcard(front: 'ね', back: 'ne', romaji: 'ne'),
    Flashcard(front: 'の', back: 'no', romaji: 'no'),
    Flashcard(front: 'は', back: 'ha', romaji: 'ha'),
    Flashcard(front: 'ひ', back: 'hi', romaji: 'hi'),
    Flashcard(front: 'ふ', back: 'fu', romaji: 'fu'),
    Flashcard(front: 'へ', back: 'he', romaji: 'he'),
    Flashcard(front: 'ほ', back: 'ho', romaji: 'ho'),
    Flashcard(front: 'ま', back: 'ma', romaji: 'ma'),
    Flashcard(front: 'み', back: 'mi', romaji: 'mi'),
    Flashcard(front: 'む', back: 'mu', romaji: 'mu'),
    Flashcard(front: 'め', back: 'me', romaji: 'me'),
    Flashcard(front: 'も', back: 'mo', romaji: 'mo'),
    Flashcard(front: 'や', back: 'ya', romaji: 'ya'),
    Flashcard(front: 'ゆ', back: 'yu', romaji: 'yu'),
    Flashcard(front: 'よ', back: 'yo', romaji: 'yo'),
    Flashcard(front: 'ら', back: 'ra', romaji: 'ra'),
    Flashcard(front: 'り', back: 'ri', romaji: 'ri'),
    Flashcard(front: 'る', back: 'ru', romaji: 'ru'),
    Flashcard(front: 'れ', back: 're', romaji: 're'),
    Flashcard(front: 'ろ', back: 'ro', romaji: 'ro'),
    Flashcard(front: 'わ', back: 'wa', romaji: 'wa'),
    Flashcard(front: 'を', back: 'wo', romaji: 'wo'),
    Flashcard(front: 'ん', back: 'n', romaji: 'n'),
  ];

  // ==================== Katakana Data ====================
  static final List<Flashcard> _katakanaBasic = [
    Flashcard(front: 'ア', back: 'a', romaji: 'a'),
    Flashcard(front: 'イ', back: 'i', romaji: 'i'),
    Flashcard(front: 'ウ', back: 'u', romaji: 'u'),
    Flashcard(front: 'エ', back: 'e', romaji: 'e'),
    Flashcard(front: 'オ', back: 'o', romaji: 'o'),
    Flashcard(front: 'カ', back: 'ka', romaji: 'ka'),
    Flashcard(front: 'キ', back: 'ki', romaji: 'ki'),
    Flashcard(front: 'ク', back: 'ku', romaji: 'ku'),
    Flashcard(front: 'ケ', back: 'ke', romaji: 'ke'),
    Flashcard(front: 'コ', back: 'ko', romaji: 'ko'),
    Flashcard(front: 'サ', back: 'sa', romaji: 'sa'),
    Flashcard(front: 'シ', back: 'shi', romaji: 'shi'),
    Flashcard(front: 'ス', back: 'su', romaji: 'su'),
    Flashcard(front: 'セ', back: 'se', romaji: 'se'),
    Flashcard(front: 'ソ', back: 'so', romaji: 'so'),
    Flashcard(front: 'タ', back: 'ta', romaji: 'ta'),
    Flashcard(front: 'チ', back: 'chi', romaji: 'chi'),
    Flashcard(front: 'ツ', back: 'tsu', romaji: 'tsu'),
    Flashcard(front: 'テ', back: 'te', romaji: 'te'),
    Flashcard(front: 'ト', back: 'to', romaji: 'to'),
    Flashcard(front: 'ナ', back: 'na', romaji: 'na'),
    Flashcard(front: 'ニ', back: 'ni', romaji: 'ni'),
    Flashcard(front: 'ヌ', back: 'nu', romaji: 'nu'),
    Flashcard(front: 'ネ', back: 'ne', romaji: 'ne'),
    Flashcard(front: 'ノ', back: 'no', romaji: 'no'),
    Flashcard(front: 'ハ', back: 'ha', romaji: 'ha'),
    Flashcard(front: 'ヒ', back: 'hi', romaji: 'hi'),
    Flashcard(front: 'フ', back: 'fu', romaji: 'fu'),
    Flashcard(front: 'ヘ', back: 'he', romaji: 'he'),
    Flashcard(front: 'ホ', back: 'ho', romaji: 'ho'),
    Flashcard(front: 'マ', back: 'ma', romaji: 'ma'),
    Flashcard(front: 'ミ', back: 'mi', romaji: 'mi'),
    Flashcard(front: 'ム', back: 'mu', romaji: 'mu'),
    Flashcard(front: 'メ', back: 'me', romaji: 'me'),
    Flashcard(front: 'モ', back: 'mo', romaji: 'mo'),
    Flashcard(front: 'ヤ', back: 'ya', romaji: 'ya'),
    Flashcard(front: 'ユ', back: 'yu', romaji: 'yu'),
    Flashcard(front: 'ヨ', back: 'yo', romaji: 'yo'),
    Flashcard(front: 'ラ', back: 'ra', romaji: 'ra'),
    Flashcard(front: 'リ', back: 'ri', romaji: 'ri'),
    Flashcard(front: 'ル', back: 'ru', romaji: 'ru'),
    Flashcard(front: 'レ', back: 're', romaji: 're'),
    Flashcard(front: 'ロ', back: 'ro', romaji: 'ro'),
    Flashcard(front: 'ワ', back: 'wa', romaji: 'wa'),
    Flashcard(front: 'ヲ', back: 'wo', romaji: 'wo'),
    Flashcard(front: 'ン', back: 'n', romaji: 'n'),
  ];

  // ==================== N5 Vocabulary ====================
  static final List<Flashcard> _n5Vocabulary = [
    Flashcard(
      front: 'いえ',
      back: 'House',
      romaji: 'ie',
      example: 'わたしのいえはおおきいです。',
      exampleMeaning: 'My house is big.',
    ),
    Flashcard(
      front: 'みず',
      back: 'Water',
      romaji: 'mizu',
      example: 'みずをのみます。',
      exampleMeaning: 'I drink water.',
    ),
    Flashcard(
      front: 'たべる',
      back: 'To eat',
      romaji: 'taberu',
      example: 'ごはんをたべる。',
      exampleMeaning: 'To eat rice/a meal.',
    ),
    Flashcard(
      front: 'ねこ',
      back: 'Cat',
      romaji: 'neko',
      example: 'ねこがすきです。',
      exampleMeaning: 'I like cats.',
    ),
    Flashcard(
      front: 'いぬ',
      back: 'Dog',
      romaji: 'inu',
      example: 'いぬといっしょにさんぽする。',
      exampleMeaning: 'To walk with the dog.',
    ),
    Flashcard(
      front: 'ほん',
      back: 'Book',
      romaji: 'hon',
      example: 'ほんをよみます。',
      exampleMeaning: 'I read a book.',
    ),
    Flashcard(
      front: 'ともだち',
      back: 'Friend',
      romaji: 'tomodachi',
      example: 'ともだちとあそびます。',
      exampleMeaning: 'I play with friends.',
    ),
    Flashcard(
      front: 'がっこう',
      back: 'School',
      romaji: 'gakkou',
      example: 'がっこうにいきます。',
      exampleMeaning: 'I go to school.',
    ),
    Flashcard(
      front: 'あさ',
      back: 'Morning',
      romaji: 'asa',
      example: 'あさごはんをたべる。',
      exampleMeaning: 'To eat breakfast.',
    ),
    Flashcard(
      front: 'ひる',
      back: 'Noon/Daytime',
      romaji: 'hiru',
      example: 'ひるやすみです。',
      exampleMeaning: 'It is lunch break.',
    ),
  ];

  // ==================== N5 Kanji ====================
  static final List<Flashcard> _n5Kanji = [
    Flashcard(
      front: '日',
      back: 'Day/Sun',
      romaji: 'hi/bi/nichi',
      example: 'きょうはいいひです。',
      exampleMeaning: 'Today is a good day.',
    ),
    Flashcard(
      front: '月',
      back: 'Moon/Month',
      romaji: 'tsuki/getsu/gatsu',
      example: 'つきがきれいです。',
      exampleMeaning: 'The moon is beautiful.',
    ),
    Flashcard(
      front: '火',
      back: 'Fire',
      romaji: 'hi/ka',
      example: 'ひがつよい。',
      exampleMeaning: 'The fire is strong.',
    ),
    Flashcard(
      front: '水',
      back: 'Water',
      romaji: 'mizu/sui',
      example: 'みずがひつようです。',
      exampleMeaning: 'Water is necessary.',
    ),
    Flashcard(
      front: '木',
      back: 'Tree/Wood',
      romaji: 'ki/moku',
      example: 'きがたかい。',
      exampleMeaning: 'The tree is tall.',
    ),
    Flashcard(
      front: '金',
      back: 'Gold/Money',
      romaji: 'kane/kin',
      example: 'かねをためる。',
      exampleMeaning: 'To save money.',
    ),
    Flashcard(
      front: '土',
      back: 'Earth/Ground',
      romaji: 'tsuchi/do',
      example: 'つちがやわらかい。',
      exampleMeaning: 'The soil is soft.',
    ),
    Flashcard(
      front: '人',
      back: 'Person',
      romaji: 'hito/jin/nin',
      example: 'ひとがおおい。',
      exampleMeaning: 'There are many people.',
    ),
  ];

  // ==================== N5 Grammar ====================
  static final List<Flashcard> _n5Grammar = [
    Flashcard(
      front: '〜です',
      back: 'To be (polite)',
      romaji: 'desu',
      example: 'わたしはがくせいです。',
      exampleMeaning: 'I am a student.',
    ),
    Flashcard(
      front: '〜ます',
      back: 'Verb ending (polite)',
      romaji: 'masu',
      example: 'たべます。',
      exampleMeaning: 'I eat. (polite)',
    ),
    Flashcard(
      front: '〜は',
      back: 'Topic marker',
      romaji: 'wa',
      example: 'わたしはにほんじんです。',
      exampleMeaning: 'As for me, I am Japanese.',
    ),
    Flashcard(
      front: '〜を',
      back: 'Object marker',
      romaji: 'wo/o',
      example: 'ほんをよみます。',
      exampleMeaning: 'I read a book.',
    ),
    Flashcard(
      front: '〜に',
      back: 'Location/Time marker',
      romaji: 'ni',
      example: 'がっこうにいきます。',
      exampleMeaning: 'I go to school.',
    ),
    Flashcard(
      front: '〜へ',
      back: 'Direction marker',
      romaji: 'e/he',
      example: 'にほんへいきます。',
      exampleMeaning: 'I go to Japan.',
    ),
  ];

  // ==================== N4 Vocabulary ====================
  static final List<Flashcard> _n4Vocabulary = [
    Flashcard(
      front: 'けいかん',
      back: 'Police officer',
      romaji: 'keikan',
      example: 'けいかんにききました。',
      exampleMeaning: 'I asked a police officer.',
    ),
    Flashcard(
      front: 'びょうき',
      back: 'Illness/Sickness',
      romaji: 'byouki',
      example: 'びょうきでがっこうをやすみました。',
      exampleMeaning: 'I was absent from school due to illness.',
    ),
    Flashcard(
      front: 'かんたん',
      back: 'Easy/Simple',
      romaji: 'kantan',
      example: 'このもんだいはかんたんです。',
      exampleMeaning: 'This problem is easy.',
    ),
  ];

  // ==================== N4 Grammar ====================
  static final List<Flashcard> _n4Grammar = [
    Flashcard(
      front: '〜ている',
      back: 'Ongoing action/Current state',
      romaji: 'te iru',
      example: 'いまべんきょうしています。',
      exampleMeaning: 'I am studying now.',
    ),
    Flashcard(
      front: '〜てもいい',
      back: 'It\'s OK to ~',
      romaji: 'te mo ii',
      example: 'ここでしゃしんをとってもいいですか。',
      exampleMeaning: 'Is it OK to take photos here?',
    ),
  ];

  // ==================== Build Levels ====================
  static List<JLPTLevel> get allLevels => [
        _buildN5(),
        _buildN4(),
        _buildN3(),
        _buildN2(),
        _buildN1(),
      ];

  static JLPTLevel _buildN5() {
    return JLPTLevel(
      level: 'N5',
      description: 'Beginner',
      subtitle: 'Basic Japanese. Learn hiragana, katakana, and simple vocabulary.',
      categories: [
        LearningCategory(
          name: 'Hiragana',
          icon: 'あ',
          description: 'Learn the 46 basic hiragana characters',
          items: _hiraganaBasic,
          totalItems: 46,
        ),
        LearningCategory(
          name: 'Katakana',
          icon: 'ア',
          description: 'Learn the 46 basic katakana characters',
          items: _katakanaBasic,
          totalItems: 46,
        ),
        LearningCategory(
          name: 'Kanji',
          icon: '漢',
          description: 'Basic N5 kanji characters (80+ characters)',
          items: _n5Kanji,
          totalItems: 80,
        ),
        LearningCategory(
          name: 'Vocabulary',
          icon: '単',
          description: 'Essential N5 vocabulary (800+ words)',
          items: _n5Vocabulary,
          totalItems: 800,
        ),
        LearningCategory(
          name: 'Grammar',
          icon: '文',
          description: 'Basic grammar patterns and sentence structures',
          items: _n5Grammar,
          totalItems: 60,
        ),
      ],
    );
  }

  static JLPTLevel _buildN4() {
    return JLPTLevel(
      level: 'N4',
      description: 'Elementary',
      subtitle: 'Elementary Japanese. Expand vocabulary and learn more grammar.',
      categories: [
        LearningCategory(
          name: 'Vocabulary',
          icon: '単',
          description: 'N4 level vocabulary (1500+ words)',
          items: _n4Vocabulary,
          totalItems: 1500,
        ),
        LearningCategory(
          name: 'Grammar',
          icon: '文',
          description: 'More complex grammar patterns',
          items: _n4Grammar,
          totalItems: 100,
        ),
        LearningCategory(
          name: 'Kanji',
          icon: '漢',
          description: 'N4 kanji characters (300 total)',
          items: _n5Kanji, // Placeholder - would have N4 kanji
          totalItems: 300,
        ),
      ],
    );
  }

  static JLPTLevel _buildN3() {
    return JLPTLevel(
      level: 'N3',
      description: 'Intermediate',
      subtitle: 'Intermediate Japanese. Understand everyday situations.',
      categories: [
        LearningCategory(
          name: 'Vocabulary',
          icon: '単',
          description: 'N3 level vocabulary (3750+ words)',
          items: _n4Vocabulary, // Placeholder
          totalItems: 3750,
        ),
        LearningCategory(
          name: 'Grammar',
          icon: '文',
          description: 'Intermediate grammar patterns',
          items: _n4Grammar, // Placeholder
          totalItems: 150,
        ),
        LearningCategory(
          name: 'Kanji',
          icon: '漢',
          description: 'N3 kanji characters (650 total)',
          items: _n5Kanji, // Placeholder
          totalItems: 650,
        ),
      ],
    );
  }

  static JLPTLevel _buildN2() {
    return JLPTLevel(
      level: 'N2',
      description: 'Advanced',
      subtitle: 'Advanced Japanese. Understand complex texts and conversations.',
      categories: [
        LearningCategory(
          name: 'Vocabulary',
          icon: '単',
          description: 'N2 level vocabulary (6000+ words)',
          items: _n4Vocabulary, // Placeholder
          totalItems: 6000,
        ),
        LearningCategory(
          name: 'Grammar',
          icon: '文',
          description: 'Advanced grammar patterns',
          items: _n4Grammar, // Placeholder
          totalItems: 200,
        ),
        LearningCategory(
          name: 'Kanji',
          icon: '漢',
          description: 'N2 kanji characters (1000 total)',
          items: _n5Kanji, // Placeholder
          totalItems: 1000,
        ),
      ],
    );
  }

  static JLPTLevel _buildN1() {
    return JLPTLevel(
      level: 'N1',
      description: 'Mastery',
      subtitle: 'Master level. Understand Japanese in complex situations.',
      categories: [
        LearningCategory(
          name: 'Vocabulary',
          icon: '単',
          description: 'N1 level vocabulary (10000+ words)',
          items: _n4Vocabulary, // Placeholder
          totalItems: 10000,
        ),
        LearningCategory(
          name: 'Grammar',
          icon: '文',
          description: 'Master-level grammar patterns',
          items: _n4Grammar, // Placeholder
          totalItems: 250,
        ),
        LearningCategory(
          name: 'Kanji',
          icon: '漢',
          description: 'N1 kanji characters (2000+ total)',
          items: _n5Kanji, // Placeholder
          totalItems: 2000,
        ),
      ],
    );
  }

  /// Get a specific level
  static JLPTLevel? getLevel(String level) {
    try {
      return allLevels.firstWhere((l) => l.level == level);
    } catch (e) {
      return null;
    }
  }

  /// Get total kanji count for a level
  static int getKanjiCount(String level) {
    switch (level) {
      case 'N5':
        return 80;
      case 'N4':
        return 300;
      case 'N3':
        return 650;
      case 'N2':
        return 1000;
      case 'N1':
        return 2000;
      default:
        return 0;
    }
  }

  /// Get total vocabulary count for a level
  static int getVocabCount(String level) {
    switch (level) {
      case 'N5':
        return 800;
      case 'N4':
        return 1500;
      case 'N3':
        return 3750;
      case 'N2':
        return 6000;
      case 'N1':
        return 10000;
      default:
        return 0;
    }
  }
}
