import 'package:web/web.dart' as web;

Future<void> speak(String text) async {
  web.window.speechSynthesis.cancel();
  final utterance = web.SpeechSynthesisUtterance(text)
    ..lang = 'ar-SA'
    ..rate = 0.82
    ..pitch = 1.05;
  web.window.speechSynthesis.speak(utterance);
}

Future<void> stop() async => web.window.speechSynthesis.cancel();
