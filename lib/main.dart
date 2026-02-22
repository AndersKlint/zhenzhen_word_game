import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'di.dart';
import 'deck_service.dart';
import 'locale_service.dart';
import 'deck_list/deck_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDI();
  await getIt<LocaleService>().init();
  await getIt<DeckService>().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeService = getIt<LocaleService>();

    return ListenableBuilder(
      listenable: localeService,
      builder: (context, _) {
        return MaterialApp(
          title: 'Kids Chinese Word Game',
          locale: localeService.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('zh')],
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.purple),
          home: const DeckListScreen(),
        );
      },
    );
  }
}
