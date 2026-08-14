import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/adult_challenge_data.dart';
import '../models/adult_question.dart';

class OnlineContentResult {
  final List<AdultCategory> categories;
  final int version;
  final String message;
  final bool fromInternet;

  const OnlineContentResult({
    required this.categories,
    required this.version,
    required this.message,
    required this.fromInternet,
  });
}

class OnlineContentService {
  static const contentUrl =
      'https://muatasemm-cmd.github.io/brain-adventure/content/adult_content.json';
  static const _cacheKey = 'adult_online_content_v1';

  static Future<OnlineContentResult> load({bool forceRefresh = false}) async {
    final preferences = await SharedPreferences.getInstance();
    final cached = preferences.getString(_cacheKey);
    if (!forceRefresh && cached != null) {
      final cachedResult = _decode(cached, fromInternet: false);
      if (cachedResult != null) return cachedResult;
    }

    try {
      final uri = Uri.parse(contentUrl).replace(
        queryParameters: {
          't': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );
      final response = await http
          .get(uri, headers: const {'Cache-Control': 'no-cache'})
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final result = _decode(response.body, fromInternet: true);
        if (result != null) {
          await preferences.setString(_cacheKey, response.body);
          return result;
        }
      }
    } catch (_) {
      // The local and cached content below keep the game playable offline.
    }

    if (cached != null) {
      final cachedResult = _decode(cached, fromInternet: false);
      if (cachedResult != null) return cachedResult;
    }
    return OnlineContentResult(
      categories: buildAdultCategories(),
      version: 1,
      message: 'المحتوى الأساسي',
      fromInternet: false,
    );
  }

  static OnlineContentResult? _decode(
    String encoded, {
    required bool fromInternet,
  }) {
    try {
      final json = jsonDecode(encoded) as Map<String, dynamic>;
      final categories = (json['categories'] as List)
          .map((item) => AdultCategory.fromJson(item as Map<String, dynamic>))
          .where((item) => item.questions.length >= 5)
          .toList(growable: false);
      if (categories.isEmpty) return null;
      return OnlineContentResult(
        categories: categories,
        version: json['version'] as int? ?? 1,
        message: json['message'] as String? ?? 'تم تحديث المحتوى',
        fromInternet: fromInternet,
      );
    } catch (_) {
      return null;
    }
  }
}
