import 'learning_challenge.dart';

class SubjectAdventure {
  final LearningSubject subject;
  final String title;
  final String icon;
  final String description;
  final String backgroundAsset;
  final int colorValue;

  const SubjectAdventure({
    required this.subject,
    required this.title,
    required this.icon,
    required this.description,
    required this.backgroundAsset,
    required this.colorValue,
  });
}

const subjectAdventures = <SubjectAdventure>[
  SubjectAdventure(
    subject: LearningSubject.math,
    title: 'الرياضيات',
    icon: '🧮',
    description: '20 مرحلة • 100 سؤال',
    backgroundAsset: 'assets/images/forest_map.png',
    colorValue: 0xFF2563EB,
  ),
  SubjectAdventure(
    subject: LearningSubject.science,
    title: 'العلوم',
    icon: '🔬',
    description: '20 مرحلة • 100 سؤال',
    backgroundAsset: 'assets/images/garden_path.png',
    colorValue: 0xFF16A34A,
  ),
  SubjectAdventure(
    subject: LearningSubject.culture,
    title: 'المعرفة',
    icon: '🌍',
    description: '20 مرحلة • 100 سؤال',
    backgroundAsset: 'assets/images/cartoon_map.png',
    colorValue: 0xFFF59E0B,
  ),
  SubjectAdventure(
    subject: LearningSubject.logic,
    title: 'المنطق',
    icon: '🧩',
    description: '20 مرحلة • 100 سؤال',
    backgroundAsset: 'assets/images/forest_path.png',
    colorValue: 0xFF7C3AED,
  ),
];
