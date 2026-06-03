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

  static const List<String> subjects = [
    'Mathematics',
    'Science',
    'English',
    'History',
    'Geography',
  ];

  static const List<String> iDontKnowKeywords = [
    'i don\'t know',
    'not sure',
    'no idea',
    'don\'t know',
    'idk',
  ];
}
