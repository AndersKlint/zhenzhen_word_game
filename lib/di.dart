import 'package:get_it/get_it.dart';
import 'deck_service.dart';
import 'game_service.dart';
import 'locale_service.dart';
import 'theme/theme_service.dart';

final getIt = GetIt.instance;

Future<void> setupDI() async {
  getIt.registerSingleton<LocaleService>(LocaleService());
  getIt.registerSingleton<ThemeService>(ThemeService());
  getIt.registerLazySingleton<DeckService>(() => DeckService());
  getIt.registerFactory<GameService>(() => GameService());
}
