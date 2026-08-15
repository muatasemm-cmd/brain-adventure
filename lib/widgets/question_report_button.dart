import 'package:flutter/material.dart';

import '../models/adult_question.dart';
import '../services/adult_storage.dart';

class QuestionReportButton extends StatelessWidget {
  final String playerId;
  final AdultQuestion question;

  const QuestionReportButton({
    super.key,
    required this.playerId,
    required this.question,
  });

  Future<void> report(BuildContext context) async {
    const reasons = [
      'الإجابة غير صحيحة',
      'السؤال مكرر',
      'الصياغة غير واضحة',
      'معلومة قديمة',
      'سبب آخر',
    ];
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('ما المشكلة في السؤال؟', textAlign: TextAlign.center),
        children: [
          for (final item in reasons)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, item),
              child: Text(item, textDirection: TextDirection.rtl),
            ),
        ],
      ),
    );
    if (reason == null) return;
    await AdultStorage.reportQuestion(
      playerId: playerId,
      questionId: question.id,
      question: question.question,
      reason: reason,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('شكرًا، تم حفظ البلاغ للمراجعة.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: () => report(context),
    icon: const Icon(Icons.flag_outlined, size: 18),
    label: const Text('أبلغ عن مشكلة'),
  );
}
