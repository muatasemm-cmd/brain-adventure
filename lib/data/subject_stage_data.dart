import '../models/forest_stage.dart';
import '../models/learning_challenge.dart';
import '../models/subject_adventure.dart';

LearningChallenge _item({
  required String id,
  required LearningSubject subject,
  required String title,
  required String question,
  required List<String> options,
  required String answer,
  required int difficulty,
  ChallengeType type = ChallengeType.multipleChoice,
  String hint = 'اقرأ السؤال بهدوء واستبعد الخيارات غير المناسبة.',
}) => LearningChallenge(
  id: id,
  type: type,
  subject: subject,
  title: title,
  question: question,
  options: options,
  correctAnswer: answer,
  hints: [hint, 'جرّب تقسيم المشكلة إلى خطوات صغيرة.'],
  explanation: 'الإجابة الصحيحة هي: $answer.',
  difficulty: difficulty,
);

List<ForestStage> subjectStagesFor({
  required SubjectAdventure adventure,
  required int age,
}) {
  final band = age <= 7
      ? 1
      : age <= 10
      ? 2
      : 3;
  return List.generate(20, (index) {
    final stage = index + 1;
    final difficulty = (index ~/ 4 + 1).clamp(1, 5);
    final prefix = '${adventure.subject.name}_${band}_$stage';
    return ForestStage(
      number: stage,
      name: stage == 20 ? '👑 مواجهة الزعيم' : 'المرحلة $stage',
      icon: adventure.icon,
      description: stage == 20
          ? 'المعركة الأخيرة وشهادة البطل'
          : 'المستوى $difficulty • مناسب لعمر $age سنة',
      challenges: switch (adventure.subject) {
        LearningSubject.math => _math(prefix, band, stage, difficulty),
        LearningSubject.science => _science(prefix, band, stage, difficulty),
        LearningSubject.culture => _culture(prefix, band, stage, difficulty),
        LearningSubject.logic => _logic(prefix, band, stage, difficulty),
        LearningSubject.mixed => const [],
      },
    );
  });
}

List<LearningChallenge> _math(String p, int band, int stage, int d) {
  final a = band * 4 + stage + 2;
  final b = band + stage % 7 + 2;
  final sum = a + b;
  final difference = a > b ? a - b : b - a;
  final product = band == 1 ? b * 2 : a * b;
  final divisor = band == 1 ? 2 : b;
  final quotient = band == 1 ? a : a + band;
  final dividend = divisor * quotient;
  return [
    _item(
      id: '${p}_q1',
      subject: LearningSubject.math,
      title: 'الجمع',
      question: 'ما ناتج $a + $b؟',
      options: ['$sum', '${sum + 1}', '${sum - 1}', '${sum + b}'],
      answer: '$sum',
      difficulty: d,
    ),
    _item(
      id: '${p}_q2',
      subject: LearningSubject.math,
      title: 'الطرح',
      question: 'ما الفرق بين $a و$b؟',
      options: [
        '$difference',
        '${difference + 2}',
        '$sum',
        '${difference + 1}',
      ],
      answer: '$difference',
      difficulty: d,
    ),
    _item(
      id: '${p}_q3',
      subject: LearningSubject.math,
      title: 'الضرب',
      question: band == 1 ? 'ما ضعف العدد $b؟' : 'ما ناتج $a × $b؟',
      options: [
        '$product',
        '${product + b}',
        '${product - 1}',
        '${product + 1}',
      ],
      answer: '$product',
      difficulty: d,
    ),
    _item(
      id: '${p}_q4',
      subject: LearningSubject.math,
      title: 'القسمة',
      question: 'ما ناتج $dividend ÷ $divisor؟',
      options: ['$quotient', '${quotient + 1}', '${quotient - 1}', '$divisor'],
      answer: '$quotient',
      difficulty: d,
    ),
    _item(
      id: '${p}_q5',
      subject: LearningSubject.math,
      title: 'مسألة كلامية',
      question: 'مع سامر $a قطعة، وأعطاه صديقه $b. كم أصبح معه؟',
      options: const [],
      answer: '$sum',
      difficulty: d,
      type: ChallengeType.numberInput,
    ),
  ];
}

List<LearningChallenge> _science(String p, int band, int stage, int d) {
  final pools = band == 1
      ? [
          (
            'أي جزء يمتص الماء في النبات؟',
            ['الجذور', 'الزهرة', 'الثمرة'],
            'الجذور',
          ),
          ('بأي حاسة نسمع؟', ['السمع', 'الذوق', 'الشم'], 'السمع'),
          ('أي حيوان يعيش في الماء؟', ['السمكة', 'القطة', 'الأرنب'], 'السمكة'),
          ('ماذا نحتاج للتنفس؟', ['الهواء', 'التراب', 'الضوء'], 'الهواء'),
          ('أيها مصدر للضوء؟', ['الشمس', 'الحجر', 'الماء'], 'الشمس'),
        ]
      : band == 2
      ? [
          ('من يضخ الدم؟', ['القلب', 'المعدة', 'الرئة'], 'القلب'),
          ('ما حالة الجليد؟', ['صلبة', 'سائلة', 'غازية'], 'صلبة'),
          (
            'ما عملية صنع النبات لغذائه؟',
            ['البناء الضوئي', 'التجمد', 'التكاثف'],
            'البناء الضوئي',
          ),
          ('أي كوكب نعيش عليه؟', ['الأرض', 'المريخ', 'الزهرة'], 'الأرض'),
          (
            'ما الغاز الذي نتنفسه؟',
            ['الأكسجين', 'الهيليوم', 'الهيدروجين'],
            'الأكسجين',
          ),
        ]
      : [
          ('ما وحدة بناء الكائن الحي؟', ['الخلية', 'الذرة', 'العضو'], 'الخلية'),
          (
            'ما القوة التي تجذبنا للأرض؟',
            ['الجاذبية', 'الاحتكاك', 'الطفو'],
            'الجاذبية',
          ),
          ('ما الرمز الكيميائي للماء؟', ['H₂O', 'CO₂', 'O₂'], 'H₂O'),
          ('أي عضو ينقي الدم؟', ['الكليتان', 'القلب', 'الجلد'], 'الكليتان'),
          ('ما أقرب كوكب للشمس؟', ['عطارد', 'الأرض', 'المشتري'], 'عطارد'),
        ];
  return List.generate(5, (i) {
    final q = pools[(stage + i) % pools.length];
    return _item(
      id: '${p}_q${i + 1}',
      subject: LearningSubject.science,
      title: 'مختبر العلوم',
      question: q.$1,
      options: q.$2,
      answer: q.$3,
      difficulty: d,
    );
  });
}

List<LearningChallenge> _culture(String p, int band, int stage, int d) {
  final pools = [
    ('كم يومًا في الأسبوع؟', ['7', '5', '10'], '7'),
    ('في أي قارة تقع فلسطين؟', ['آسيا', 'أوروبا', 'أفريقيا'], 'آسيا'),
    ('ما عاصمة مصر؟', ['القاهرة', 'عمّان', 'بيروت'], 'القاهرة'),
    ('ما أكبر محيط؟', ['الهادئ', 'الأطلسي', 'الهندي'], 'الهادئ'),
    ('كم فصلًا في السنة؟', ['4', '3', '5'], '4'),
    ('ما لغة القرآن الكريم؟', ['العربية', 'الفرنسية', 'اللاتينية'], 'العربية'),
  ];
  return List.generate(5, (i) {
    final q = pools[(stage + i + band) % pools.length];
    return _item(
      id: '${p}_q${i + 1}',
      subject: LearningSubject.culture,
      title: 'رحلة المعرفة',
      question: q.$1,
      options: q.$2,
      answer: q.$3,
      difficulty: d,
    );
  });
}

List<LearningChallenge> _logic(String p, int band, int stage, int d) {
  final start = stage + band;
  final step = band + 1;
  final ordered = List.generate(4, (i) => '${start + i * step}');
  final next = start + 4 * step;
  return [
    _item(
      id: '${p}_q1',
      subject: LearningSubject.logic,
      title: 'الترتيب',
      question: 'رتّب من الأصغر إلى الأكبر.',
      options: [ordered[2], ordered[0], ordered[3], ordered[1]],
      answer: ordered.join('|'),
      difficulty: d,
      type: ChallengeType.ordering,
    ),
    _item(
      id: '${p}_q2',
      subject: LearningSubject.logic,
      title: 'النمط',
      question: 'ما العدد التالي: ${ordered.join('، ')}، ...؟',
      options: ['$next', '${next + 1}', '${next - 1}', '${next + step}'],
      answer: '$next',
      difficulty: d,
    ),
    _item(
      id: '${p}_q3',
      subject: LearningSubject.logic,
      title: 'المختلف',
      question: 'أيها مختلف عن الباقي؟',
      options: ['🍎', '🍌', '🍇', '🚗'],
      answer: '🚗',
      difficulty: d,
    ),
    _item(
      id: '${p}_q4',
      subject: LearningSubject.logic,
      title: 'الاستنتاج',
      question: 'كل الطيور لها ريش. العصفور طائر. هل للعصفور ريش؟',
      options: ['صح', 'خطأ'],
      answer: 'صح',
      difficulty: d,
      type: ChallengeType.trueFalse,
    ),
    _item(
      id: '${p}_q5',
      subject: LearningSubject.logic,
      title: 'الذاكرة',
      question: 'اكشف كل الأزواج المتطابقة.',
      options: ['🌟', '🌙', '🌈'],
      answer: 'matched',
      difficulty: d,
      type: ChallengeType.memory,
    ),
  ];
}
