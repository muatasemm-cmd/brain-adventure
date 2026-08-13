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
        LearningSubject.math => _math(prefix, band, age, stage, difficulty),
        LearningSubject.science => _science(
          prefix,
          band,
          age,
          stage,
          difficulty,
        ),
        LearningSubject.culture => _culture(
          prefix,
          band,
          age,
          stage,
          difficulty,
        ),
        LearningSubject.logic => _logic(prefix, band, age, stage, difficulty),
        LearningSubject.arabic => _knowledgeQuestions(
          prefix,
          LearningSubject.arabic,
          age,
          stage,
          difficulty,
          _arabicPool,
        ),
        LearningSubject.history => _knowledgeQuestions(
          prefix,
          LearningSubject.history,
          age,
          stage,
          difficulty,
          _historyPool,
        ),
        LearningSubject.geography => _knowledgeQuestions(
          prefix,
          LearningSubject.geography,
          age,
          stage,
          difficulty,
          _geographyPool,
        ),
        LearningSubject.mixed => const [],
      },
    );
  });
}

typedef _QuizFact = (String, List<String>, String);

const _arabicPool = <_QuizFact>[
  ('ما جمع كلمة كتاب؟', ['كتب', 'كاتب', 'مكتبة'], 'كتب'),
  ('ما ضد كلمة كبير؟', ['صغير', 'طويل', 'قريب'], 'صغير'),
  ('أي كلمة تبدأ بحرف الشمس؟', ['شجرة', 'قمر', 'بيت'], 'شجرة'),
  ('ما مؤنث كلمة معلم؟', ['معلمة', 'تعليم', 'مدرسة'], 'معلمة'),
  ('أكمل: ذهب الطفل ... المدرسة.', ['إلى', 'من', 'على'], 'إلى'),
  ('أي كلمة فعل؟', ['يلعب', 'كرة', 'جميل'], 'يلعب'),
  ('أي كلمة اسم؟', ['حديقة', 'يكتب', 'سريعًا'], 'حديقة'),
  ('ما مفرد كلمة أشجار؟', ['شجرة', 'شجرات', 'غابة'], 'شجرة'),
  ('أي كلمة فيها تنوين؟', ['كتابٌ', 'الكتاب', 'كتابي'], 'كتابٌ'),
  ('ما الحرف الذي يأتي بعد د؟', ['ذ', 'ر', 'ج'], 'ذ'),
];

const _historyPool = <_QuizFact>[
  ('أين بُنيت الأهرامات؟', ['مصر', 'العراق', 'المغرب'], 'مصر'),
  (
    'ما الذي يستخدمه المؤرخ لمعرفة الماضي؟',
    ['المصادر', 'التوقعات', 'الألعاب'],
    'المصادر',
  ),
  (
    'من اخترع الكتابة المسمارية؟',
    ['السومريون', 'الرومان', 'الفراعنة'],
    'السومريون',
  ),
  ('في أي مدينة يوجد المسجد الأقصى؟', ['القدس', 'القاهرة', 'دمشق'], 'القدس'),
  (
    'ما اسم طريق التجارة القديم بين الشرق والغرب؟',
    ['طريق الحرير', 'طريق البحر', 'طريق القمر'],
    'طريق الحرير',
  ),
  (
    'أي حضارة اشتهرت بالأهرامات؟',
    ['المصرية القديمة', 'الصينية', 'الأندلسية'],
    'المصرية القديمة',
  ),
  (
    'ما وظيفة المتحف؟',
    ['حفظ الآثار', 'زراعة الأشجار', 'صناعة السيارات'],
    'حفظ الآثار',
  ),
  (
    'ماذا نسمي الأشياء التي تركها القدماء؟',
    ['آثارًا', 'طقسًا', 'خرائط'],
    'آثارًا',
  ),
  ('من بنى مدينة البتراء؟', ['الأنباط', 'الفراعنة', 'الفينيقيون'], 'الأنباط'),
  (
    'أي مادة استُخدمت قديمًا للكتابة في مصر؟',
    ['البردي', 'البلاستيك', 'الحديد'],
    'البردي',
  ),
];

const _geographyPool = <_QuizFact>[
  ('في أي قارة تقع فلسطين؟', ['آسيا', 'أوروبا', 'أفريقيا'], 'آسيا'),
  ('ما أكبر محيط في العالم؟', ['الهادئ', 'الأطلسي', 'الهندي'], 'الهادئ'),
  ('ما عاصمة الأردن؟', ['عمّان', 'القدس', 'بيروت'], 'عمّان'),
  ('أي جهة تشرق منها الشمس؟', ['الشرق', 'الغرب', 'الشمال'], 'الشرق'),
  ('ما أكبر قارة؟', ['آسيا', 'أفريقيا', 'أوروبا'], 'آسيا'),
  (
    'ما الأداة التي توضح الأماكن والطرق؟',
    ['الخريطة', 'الساعة', 'المجهر'],
    'الخريطة',
  ),
  (
    'ما اليابسة المحاطة بالماء من كل الجهات؟',
    ['جزيرة', 'وادي', 'جبل'],
    'جزيرة',
  ),
  ('أي نهر يمر في مصر؟', ['النيل', 'الأمازون', 'الفرات'], 'النيل'),
  ('ما عاصمة لبنان؟', ['بيروت', 'دمشق', 'الدوحة'], 'بيروت'),
  (
    'ما الخط الذي يقسم الأرض إلى نصفين شمالي وجنوبي؟',
    ['خط الاستواء', 'خط الطول', 'الأفق'],
    'خط الاستواء',
  ),
];

List<LearningChallenge> _knowledgeQuestions(
  String prefix,
  LearningSubject subject,
  int age,
  int stage,
  int difficulty,
  List<_QuizFact> pool,
) => List.generate(5, (index) {
  final fact = pool[((stage - 1) * 5 + index + age) % pool.length];
  return _item(
    id: '${prefix}_q${index + 1}',
    subject: subject,
    title: switch (subject) {
      LearningSubject.arabic => 'لغتي الجميلة',
      LearningSubject.history => 'رحلة عبر الزمن',
      LearningSubject.geography => 'مستكشف العالم',
      _ => 'تحدي المعرفة',
    },
    question: fact.$1,
    options: fact.$2,
    answer: fact.$3,
    difficulty: difficulty,
  );
});

List<LearningChallenge> _math(String p, int band, int age, int stage, int d) {
  final a = age + stage + 2;
  final b = band + age % 5 + stage % 7 + 2;
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

List<LearningChallenge> _science(
  String p,
  int band,
  int age,
  int stage,
  int d,
) {
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
    final q = pools[(stage + i + age) % pools.length];
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

List<LearningChallenge> _culture(
  String p,
  int band,
  int age,
  int stage,
  int d,
) {
  final pools = [
    ('كم يومًا في الأسبوع؟', ['7', '5', '10'], '7'),
    ('في أي قارة تقع فلسطين؟', ['آسيا', 'أوروبا', 'أفريقيا'], 'آسيا'),
    ('ما عاصمة مصر؟', ['القاهرة', 'عمّان', 'بيروت'], 'القاهرة'),
    ('ما أكبر محيط؟', ['الهادئ', 'الأطلسي', 'الهندي'], 'الهادئ'),
    ('كم فصلًا في السنة؟', ['4', '3', '5'], '4'),
    ('ما لغة القرآن الكريم؟', ['العربية', 'الفرنسية', 'اللاتينية'], 'العربية'),
  ];
  return List.generate(5, (i) {
    final q = pools[(stage + i + band + age) % pools.length];
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

List<LearningChallenge> _logic(String p, int band, int age, int stage, int d) {
  final start = stage + age;
  final step = band + 1;
  final ordered = List.generate(4, (i) => '${start + i * step}');
  final next = start + 4 * step;
  return [
    _item(
      id: '${p}_q1',
      subject: LearningSubject.logic,
      title: 'الترتيب',
      question:
          'رتّب الأعداد ${ordered.reversed.join('، ')} من الأصغر إلى الأكبر.',
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
