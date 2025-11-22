import 'package:flutter/material.dart';
import 'di.dart';
import 'deck_service.dart';
import 'screens_deck_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDI();
  await getIt<DeckService>().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kids Chinese Word Game',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.purple,
      ),
      home: const DeckListScaffold(),
    );
  }
}
