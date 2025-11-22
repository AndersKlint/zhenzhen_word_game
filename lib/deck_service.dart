import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class DeckService extends ChangeNotifier {
  List<Deck> decks = [];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('decks');
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      decks = list.map((e) => Deck.fromJson(Map<String, dynamic>.from(e))).toList();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('decks', jsonEncode(decks.map((d) => d.toJson()).toList()));
  }

  String _id() => DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(999).toString();

  Future<void> addDeck(String name) async {
    decks.add(Deck(id: _id(), name: name));
    await _save();
    notifyListeners();
  }

  Future<void> removeDeck(String id) async {
    decks.removeWhere((d) => d.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> addWord(String deckId, String word) async {
    final deck = decks.firstWhere((d) => d.id == deckId);
    deck.words.add(word);
    await _save();
    notifyListeners();
  }

  Future<void> removeWord(String deckId, int idx) async {
    final deck = decks.firstWhere((d) => d.id == deckId);
    deck.words.removeAt(idx);
    await _save();
    notifyListeners();
  }

  Deck getDeck(String id) => decks.firstWhere((d) => d.id == id);
}
