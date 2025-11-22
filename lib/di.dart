import 'package:get_it/get_it.dart';
import 'deck_service.dart';
import 'game_service.dart';

final getIt = GetIt.instance;

void setupDI() {
  getIt.registerLazySingleton<DeckService>(() => DeckService());
  getIt.registerFactory<GameService>(() => GameService());
}
