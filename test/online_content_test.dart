import 'dart:convert';
import 'dart:io';

import 'package:brain_adventure/models/adult_question.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ملف التحديث الأونلاين صالح ويحتوي كل المجالات والأسئلة', () {
    final json =
        jsonDecode(File('web/content/adult_content.json').readAsStringSync())
            as Map<String, dynamic>;
    expect(json['version'], isA<int>());
    final categories = (json['categories'] as List)
        .map((item) => AdultCategory.fromJson(item as Map<String, dynamic>))
        .toList();
    expect(categories, hasLength(10));
    expect(
      categories.fold<int>(0, (sum, item) => sum + item.questions.length),
      500,
    );
  });
}
