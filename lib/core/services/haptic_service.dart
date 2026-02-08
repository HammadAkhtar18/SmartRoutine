import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HapticService {
  static const String _settingsBoxName = 'settings';
  static const String _hapticsKey = 'haptics_enabled';

  static Future<void> light() async {
    if (await _isEnabled()) {
      await HapticFeedback.lightImpact();
    }
  }

  static Future<void> medium() async {
    if (await _isEnabled()) {
      await HapticFeedback.mediumImpact();
    }
  }

  static Future<void> heavy() async {
    if (await _isEnabled()) {
      await HapticFeedback.heavyImpact();
    }
  }

  static Future<void> selection() async {
    if (await _isEnabled()) {
      await HapticFeedback.selectionClick();
    }
  }

  static Future<bool> _isEnabled() async {
    final box = await Hive.openBox(_settingsBoxName);
    return box.get(_hapticsKey, defaultValue: true);
  }

  static Future<void> toggle(bool value) async {
    final box = await Hive.openBox(_settingsBoxName);
    await box.put(_hapticsKey, value);
  }
  
  static Future<bool> isEnabled() async {
     return _isEnabled();
  }
}
