import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mirello_utbk/core/services/app_settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppSettingsService Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('app_settings_test_');
      Hive.init(tempDir.path);
    });

    tearDown(() async {
      await Hive.close();
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    });

    test('Initial installation defaults to AppMode.normal', () async {
      final box = await Hive.openBox(AppSettingsService.boxName);
      await AppSettingsService.instance.init(overrideBox: box);

      expect(AppSettingsService.instance.currentMode, AppMode.normal);
      expect(AppSettingsService.instance.isNormal, isTrue);
      expect(AppSettingsService.instance.isExpert, isFalse);
    });

    test('Switching to AppMode.expert updates state and persists in storage', () async {
      final box = await Hive.openBox(AppSettingsService.boxName);
      await AppSettingsService.instance.init(overrideBox: box);

      await AppSettingsService.instance.setAppMode(AppMode.expert);

      expect(AppSettingsService.instance.currentMode, AppMode.expert);
      expect(AppSettingsService.instance.isExpert, isTrue);
      expect(AppSettingsService.instance.isNormal, isFalse);
      expect(box.get('app_mode'), 'expert');

      // Re-init from persisted box
      await AppSettingsService.instance.init(overrideBox: box);
      expect(AppSettingsService.instance.currentMode, AppMode.expert);
    });

    test('Switching back to AppMode.normal updates state and persists in storage', () async {
      final box = await Hive.openBox(AppSettingsService.boxName);
      await AppSettingsService.instance.init(overrideBox: box);

      await AppSettingsService.instance.setAppMode(AppMode.expert);
      expect(AppSettingsService.instance.isExpert, isTrue);

      await AppSettingsService.instance.setAppMode(AppMode.normal);
      expect(AppSettingsService.instance.currentMode, AppMode.normal);
      expect(AppSettingsService.instance.isNormal, isTrue);
      expect(box.get('app_mode'), 'normal');
    });

    test('Initial installation defaults to AppLanguage.id', () async {
      final box = await Hive.openBox(AppSettingsService.boxName);
      await AppSettingsService.instance.init(overrideBox: box);

      expect(AppSettingsService.instance.currentLanguage, AppLanguage.id);
      expect(AppSettingsService.instance.isIndonesian, isTrue);
      expect(AppSettingsService.instance.isEnglish, isFalse);
    });

    test('Switching language to English updates state and persists in storage',
        () async {
      final box = await Hive.openBox(AppSettingsService.boxName);
      await AppSettingsService.instance.init(overrideBox: box);

      await AppSettingsService.instance.setLanguage(AppLanguage.en);

      expect(AppSettingsService.instance.currentLanguage, AppLanguage.en);
      expect(AppSettingsService.instance.isEnglish, isTrue);
      expect(AppSettingsService.instance.isIndonesian, isFalse);
      expect(box.get('app_language'), 'en');

      // Re-init from persisted box
      await AppSettingsService.instance.init(overrideBox: box);
      expect(AppSettingsService.instance.currentLanguage, AppLanguage.en);
    });
  });
}

