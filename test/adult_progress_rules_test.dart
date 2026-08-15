import 'package:brain_adventure/services/adult_progress_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('المرحلة الأولى مفتوحة دائمًا وما بعدها مقفل', () {
    expect(AdultProgressRules.isLevelUnlocked({}, 'arabic', 1), isTrue);
    expect(AdultProgressRules.isLevelUnlocked({}, 'arabic', 2), isFalse);
  });

  test('إكمال المرحلة يفتح المرحلة التالية في نفس المجال فقط', () {
    final progress = {'arabic:1': 4};
    expect(AdultProgressRules.isLevelUnlocked(progress, 'arabic', 2), isTrue);
    expect(AdultProgressRules.isLevelUnlocked(progress, 'science', 2), isFalse);
    expect(AdultProgressRules.isLevelUnlocked(progress, 'arabic', 3), isFalse);
  });
}
