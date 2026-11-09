import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/services/app_settings_service.dart';
import 'core/theme/nostra_theme.dart';
import 'features/library/data/notebook_repository.dart';
import 'features/library/presentation/home_screen.dart';
import 'features/notes/data/free_notes_repository.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/reader/data/reader_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive local storage
  await Hive.initFlutter();

  // Initialize Settings (default: AppMode.normal for clean newcomer experience)
  await AppSettingsService.instance.init();

  // Check first-launch onboarding state
  final appSettingsBox = await Hive.openBox('app_settings');
  final bool hasSeenOnboarding =
      appSettingsBox.get('has_seen_onboarding', defaultValue: false) as bool;

  // Initialize Notebook, Reader & Free Notes repositories
  await NotebookRepository.instance.init();
  await ReaderRepository.instance.init();
  await FreeNotesRepository.instance.init();

  runApp(NostraApp(hasSeenOnboarding: hasSeenOnboarding));
}

class NostraApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const NostraApp({super.key, this.hasSeenOnboarding = false});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: AppSettingsService.instance.languageNotifier,
      builder: (context, language, _) {
        return MaterialApp(
          title: 'Nostra',
          debugShowCheckedModeBanner: false,
          theme: NostraTheme.lightTheme,
          home: hasSeenOnboarding
              ? const HomeScreen()
              : const OnboardingScreen(),
        );
      },
    );
  }
}
