import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum AppMode {
  /// Mode Normal (Standar / Pemula):
  /// Pengalaman menulis catatan bersih, ramah, dan bebas dari kode atau simbol Markdown.
  /// Cocok untuk orang awam dan penggunaan catatan harian santai.
  normal,

  /// Mode Ahli (Lanjutan / Markdown / Developer):
  /// Untuk power-user atau pengguna Obsidian dengan toolbar lengkap (H1, H2, Bold, Italic,
  /// Underline, Coret, Stabilo), checklist Markdown, dan mode pratinjau baca.
  expert,
}

enum AppLanguage {
  /// Bahasa Indonesia (default)
  id,

  /// English
  en,
}

class AppSettingsService {
  AppSettingsService._();
  static final AppSettingsService instance = AppSettingsService._();

  static const String boxName = 'app_settings_box';
  static const String _keyAppMode = 'app_mode';
  static const String _keyLanguage = 'app_language';

  Box? _box;

  /// Reactive notifier for current app mode
  final ValueNotifier<AppMode> modeNotifier = ValueNotifier<AppMode>(AppMode.normal);

  /// Reactive notifier for current app language (default: Indonesian)
  final ValueNotifier<AppLanguage> languageNotifier =
      ValueNotifier<AppLanguage>(AppLanguage.id);

  AppMode get currentMode => modeNotifier.value;
  bool get isNormal => modeNotifier.value == AppMode.normal;
  bool get isExpert => modeNotifier.value == AppMode.expert;

  AppLanguage get currentLanguage => languageNotifier.value;
  bool get isIndonesian => languageNotifier.value == AppLanguage.id;
  bool get isEnglish => languageNotifier.value == AppLanguage.en;

  /// Initialize settings from persistent storage.
  /// Always defaults to [AppMode.normal] and [AppLanguage.id] on initial installation!
  Future<void> init({Box? overrideBox}) async {
    _box = overrideBox ?? await Hive.openBox(boxName);
    final storedVal = _box?.get(_keyAppMode, defaultValue: 'normal') as String?;

    if (storedVal == 'expert') {
      modeNotifier.value = AppMode.expert;
    } else {
      modeNotifier.value = AppMode.normal;
    }

    final storedLang = _box?.get(_keyLanguage, defaultValue: 'id') as String?;
    if (storedLang == 'en') {
      languageNotifier.value = AppLanguage.en;
    } else {
      languageNotifier.value = AppLanguage.id;
    }
  }

  /// Change and persist app mode
  Future<void> setAppMode(AppMode mode) async {
    modeNotifier.value = mode;
    final modeStr = mode == AppMode.expert ? 'expert' : 'normal';
    await _box?.put(_keyAppMode, modeStr);
  }

  /// Change and persist app language
  Future<void> setLanguage(AppLanguage language) async {
    languageNotifier.value = language;
    final langStr = language == AppLanguage.en ? 'en' : 'id';
    await _box?.put(_keyLanguage, langStr);
  }
}

