class Constants {
  static const Map<String, String> langCodes = {
    'English': 'en-IN',
    'Hindi': 'hi-IN',
    'Bengali': 'bn-IN',
    'Tamil': 'ta-IN',
    'Telugu': 'te-IN',
  };

  static const int listenTimeoutSeconds = 10;
  static const int pauseTimeoutSeconds = 3;
  static const int nextQuestionDelayMs = 1500;
  static const String wakeWordPath = 'assets/hey_tutor.ppn';
  static const String picovoiceAccessKey = 'YOUR_KEY_HERE';
  static const String geminiApiKey = 'YOUR_GEMINI_KEY_HERE';
  static const String geminiModel = 'gemini-pro';

  static const Map<String, List<String>> examCategories = {
    'Engineering': ['JEE Main', 'JEE Advanced', 'BITSAT'],
    'Medical': ['NEET', 'AIIMS'],
    'Government': ['UPSC', 'SSC', 'Banking'],
    'School': ['Class 10', 'Class 12'],
  };

  static const Map<String, String> categoryEmojis = {
    'Engineering': '⚙️',
    'Medical': '🏥',
    'Government': '🏛️',
    'School': '📚',
  };

  static const List<String> subjects = [
    'Mathematics', 'Science', 'English', 'History', 'Geography',
  ];

  static const List<String> iDontKnowKeywords = [
    'i don\'t know', 'not sure', 'no idea', 'don\'t know', 'idk',
  ];

  static const List<String> stopKeywords = [
    'stop', 'exit', 'quit', 'end',
  ];

  static const List<String> skipKeywords = [
    'skip', 'next', 'pass',
  ];

  static const List<String> repeatKeywords = [
    'repeat', 'again', 'what', 'pardon',
  ];
}
