import 'dart:convert';
import 'dart:io';

import 'package:brain_adventure/data/adult_challenge_data.dart';

void main() {
  final content = {
    'version': 2,
    'updatedAt': DateTime.now().toUtc().toIso8601String(),
    'message': '20 مرحلة و100 سؤال مختلف في كل مجال',
    'categories': buildAdultCategories().map((item) => item.toJson()).toList(),
  };
  const encoder = JsonEncoder.withIndent('  ');
  Directory('web/content').createSync(recursive: true);
  File(
    'web/content/adult_content.json',
  ).writeAsStringSync(encoder.convert(content));
}
