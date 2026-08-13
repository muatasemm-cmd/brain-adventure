import 'package:flutter/services.dart';

const _channel = MethodChannel('brain_adventure/narrator');

Future<void> speak(String text) async {
  try {
    await _channel.invokeMethod<void>('speak', {'text': text});
  } on MissingPluginException {
    // Unsupported native platform.
  }
}

Future<void> stop() async {
  try {
    await _channel.invokeMethod<void>('stop');
  } on MissingPluginException {
    // Unsupported native platform.
  }
}
