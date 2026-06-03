class Exam {
  final String name;
  final String category;
  final String code;
  final List<String> subjects;
  final String emoji;

  const Exam({
    required this.name,
    required this.category,
    required this.code,
    required this.subjects,
    this.emoji = '📚',
  });

  static const List<Exam> all = [
    // West Bengal
    Exam(
      name: 'WB Panchayat',
      category: 'West Bengal',
      code: 'WB_PANCHAYAT',
      emoji: '🏛',
      subjects: ['GK', 'Bengali', 'History', 'Geography', 'Polity', 'Science'],
    ),
    Exam(
      name: 'WB PSC Clerkship',
      category: 'West Bengal',
      code: 'WB_PSC',
      emoji: '🏛',
      subjects: ['GK', 'English', 'Bengali', 'Math', 'Reasoning'],
    ),
    Exam(
      name: 'WB Police Constable',
      category: 'West Bengal',
      code: 'WB_POLICE_CONSTABLE',
      emoji: '👮',
      subjects: ['GK', 'Bengali', 'Math', 'Reasoning', 'Science'],
    ),
    Exam(
      name: 'WB Police SI',
      category: 'West Bengal',
      code: 'WB_POLICE_SI',
      emoji: '👮',
      subjects: ['GK', 'Bengali', 'English', 'Math', 'Reasoning'],
    ),
    Exam(
      name: 'WBCS',
      category: 'West Bengal',
      code: 'WBCS',
      emoji: '🏛',
      subjects: ['GK', 'History', 'Geography', 'Polity', 'English', 'Bengali'],
    ),
    // SSC
    Exam(
      name: 'SSC CGL',
      category: 'SSC',
      code: 'SSC_CGL',
      emoji: '📚',
      subjects: ['GK', 'English', 'Math', 'Reasoning', 'Current Affairs'],
    ),
    Exam(
      name: 'SSC CHSL',
      category: 'SSC',
      code: 'SSC_CHSL',
      emoji: '📚',
      subjects: ['GK', 'English', 'Math', 'Reasoning'],
    ),
    Exam(
      name: 'SSC MTS',
      category: 'SSC',
      code: 'SSC_MTS',
      emoji: '📚',
      subjects: ['GK', 'English', 'Math', 'Reasoning'],
    ),
    // Railway
    Exam(
      name: 'RRB NTPC',
      category: 'Railway',
      code: 'RRB_NTPC',
      emoji: '🚂',
      subjects: ['GK', 'Current Affairs', 'Math', 'Reasoning', 'English'],
    ),
    Exam(
      name: 'RRB Group D',
      category: 'Railway',
      code: 'RRB_GROUP_D',
      emoji: '🚂',
      subjects: ['GK', 'Math', 'Reasoning', 'Science'],
    ),
    // Banking
    Exam(
      name: 'SBI PO',
      category: 'Banking',
      code: 'SBI_PO',
      emoji: '🏦',
      subjects: ['GK', 'English', 'Math', 'Reasoning', 'Current Affairs'],
    ),
    Exam(
      name: 'IBPS PO',
      category: 'Banking',
      code: 'IBPS_PO',
      emoji: '🏦',
      subjects: ['GK', 'English', 'Math', 'Reasoning', 'Current Affairs'],
    ),
  ];
}
