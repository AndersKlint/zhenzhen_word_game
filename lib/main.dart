// Flutter app: Kids Word Game
// Save as lib/main.dart
// Add to pubspec.yaml dependencies:
//   shared_preferences: ^2.0.15
//   google_fonts: ^5.0.0

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const KidsWordGameApp());
}

class KidsWordGameApp extends StatelessWidget {
  const KidsWordGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kids Word Match',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
      home: const HomePage(),
    );
  }
}

class Deck {
  String id;
  String name;
  List<String> words;

  Deck({required this.id, required this.name, required this.words});

  factory Deck.fromJson(Map<String, dynamic> j) => Deck(
    id: j['id'] as String,
    name: j['name'] as String,
    words: List<String>.from(j['words'] as List<dynamic>),
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'words': words};
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Deck> decks = [];
  String? selectedLeftId;
  String? selectedRightId;
  bool reuseWords = true; // switch: if false -> retire used words for session

  // Session sets to track used words when retire option is off
  List<String> usedLeft = [];
  List<String> usedRight = [];

  String leftWord = '';
  String rightWord = '';
  bool showingLeft = false;
  bool showingRight = false;
  bool isPlaying = false;

  final rnd = Random();

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  Future<void> _loadDecks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('decks');
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        setState(() {
          decks = list.map((e) => Deck.fromJson(e)).toList();
        });
      } catch (e) {
        // ignore
      }
    }
  }

  Future<void> _saveDecks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(decks.map((d) => d.toJson()).toList());
    await prefs.setString('decks', raw);
  }

  void _createDeck() {
    final nameCtl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create deck'),
        content: TextField(
          controller: nameCtl,
          decoration: const InputDecoration(
            hintText: 'Deck name (e.g. Animals)',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameCtl.text.trim();
              if (name.isNotEmpty) {
                final newDeck = Deck(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  words: [],
                );
                setState(() => decks.add(newDeck));
                _saveDecks();
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _editDeck(Deck deck) {
    final addCtl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit "${deck.name}"',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() => decks.removeWhere((d) => d.id == deck.id));
                      _saveDecks();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: deck.words
                    .map(
                      (w) => Chip(
                        label: Text(w),
                        onDeleted: () {
                          setState(() => deck.words.remove(w));
                          _saveDecks();
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: addCtl,
                      decoration: const InputDecoration(hintText: 'Add a word'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      final w = addCtl.text.trim();
                      if (w.isNotEmpty) {
                        setState(() => deck.words.add(w));
                        addCtl.clear();
                        _saveDecks();
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Deck? _deckById(String? id) => id == null
      ? null
      : decks.firstWhere(
          (d) => d.id == id,
          orElse: () => Deck(id: '0', name: 'Unknown', words: []),
        );

  void _startRound() async {
    if (selectedLeftId == null || selectedRightId == null) return;
    if (selectedLeftId == selectedRightId) {
      // allow same deck on both sides if wanted, but warn
    }
    setState(() {
      isPlaying = true;
      leftWord = '';
      rightWord = '';
      showingLeft = false;
      showingRight = false;
    });

    // pick left
    final leftDeck = _deckById(selectedLeftId)!;
    final rightDeck = _deckById(selectedRightId)!;

    final l = _pickRandom(leftDeck.words, usedLeft);
    if (l == null) {
      _showNoWordsSnack('Left deck has no available words');
      setState(() => isPlaying = false);
      return;
    }
    setState(() {
      leftWord = l;
      showingLeft = true;
      if (!reuseWords) usedLeft.add(l);
    });

    // small delay then show right
    await Future.delayed(const Duration(milliseconds: 800));

    final r = _pickRandom(rightDeck.words, usedRight);
    if (r == null) {
      _showNoWordsSnack('Right deck has no available words');
      setState(() => isPlaying = false);
      return;
    }
    setState(() {
      rightWord = r;
      showingRight = true;
      if (!reuseWords) usedRight.add(r);
    });

    // done
    setState(() => isPlaying = false);
  }

  String? _pickRandom(List<String> words, List<String> used) {
    final available = reuseWords
        ? List<String>.from(words)
        : words.where((w) => !used.contains(w)).toList();
    if (available.isEmpty) return null;
    return available[rnd.nextInt(available.length)];
  }

  void _nextRound() {
    _startRound();
  }

  void _showNoWordsSnack(String txt) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(txt)));
  }

  void _resetSession() {
    setState(() {
      usedLeft.clear();
      usedRight.clear();
      leftWord = '';
      rightWord = '';
      showingLeft = false;
      showingRight = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final leftDeck = _deckById(selectedLeftId);
    final rightDeck = _deckById(selectedRightId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kids Word Match'),
        actions: [
          IconButton(onPressed: _createDeck, icon: const Icon(Icons.add_box)),
        ],
      ),
      body: Row(
        children: [
          // Left column: decks list
          Container(
            width: 260,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFE082), Color(0xFFFFCC80)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Decks',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: decks.length,
                    itemBuilder: (context, idx) {
                      final d = decks[idx];
                      final isLeft = d.id == selectedLeftId;
                      final isRight = d.id == selectedRightId;
                      return Card(
                        elevation: 3,
                        child: ListTile(
                          title: Text(d.name),
                          subtitle: Text('${d.words.length} words'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _editDeck(d),
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    if (selectedLeftId == d.id)
                                      selectedLeftId = null;
                                    if (selectedRightId == d.id)
                                      selectedRightId = null;
                                    decks.removeAt(idx);
                                  });
                                  _saveDecks();
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            ],
                          ),
                          onTap: () {
                            _showDeckAssignOptions(d);
                          },
                          selected: isLeft || isRight,
                          selectedTileColor: Colors.purple.withOpacity(0.1),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Reuse words (off = retire for session)'),
                  value: reuseWords,
                  onChanged: (v) {
                    setState(() => reuseWords = v);
                    _resetSession();
                  },
                ),
                FilledButton.icon(
                  onPressed: () {
                    if (selectedLeftId == null || selectedRightId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Select two decks first')),
                      );
                      return;
                    }
                    _startRound();
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play'),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _nextRound,
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Next'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _resetSession,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset session'),
                ),
              ],
            ),
          ),

          // Right column: game area
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFB2DFDB), Color(0xFFB3E5FC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // Left deck area
                        Expanded(
                          child: _deckGamePanel(
                            title: leftDeck?.name ?? 'Left deck',
                            word: leftWord,
                            showing: showingLeft,
                            sideColor: const LinearGradient(
                              colors: [Color(0xFFFFAB91), Color(0xFFFFCCBC)],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Right deck area
                        Expanded(
                          child: _deckGamePanel(
                            title: rightDeck?.name ?? 'Right deck',
                            word: rightWord,
                            showing: showingRight,
                            sideColor: const LinearGradient(
                              colors: [Color(0xFFCE93D8), Color(0xFFB39DDB)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _statusBar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBar() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Left: ${_deckById(selectedLeftId)?.name ?? "-"}    Right: ${_deckById(selectedRightId)?.name ?? "-"}',
          ),
        ),
        Text('Reuse: ${reuseWords ? 'Yes' : 'No'}'),
      ],
    );
  }

  Widget _deckGamePanel({
    required String title,
    required String word,
    required bool showing,
    required LinearGradient sideColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
        ],
        gradient: sideColor,
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (child, anim) {
                  final slide =
                      Tween<Offset>(
                        begin: const Offset(0, 0.4),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: anim,
                          curve: Curves.easeOutBack,
                        ),
                      );
                  final scale = Tween<double>(begin: 0.6, end: 1.0).animate(
                    CurvedAnimation(parent: anim, curve: Curves.elasticOut),
                  );
                  return SlideTransition(
                    position: slide,
                    child: ScaleTransition(
                      scale: scale,
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                  );
                },
                child: showing && word.isNotEmpty
                    ? Container(
                        key: ValueKey(word),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          word,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Container(
                        key: const ValueKey('empty'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withOpacity(0.6),
                        ),
                        child: const Text(
                          'Ready',
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Used: ${word.isEmpty ? 0 : 1}'),
              ElevatedButton.icon(
                onPressed: () {
                  // show examples: long-press to hear? not implemented
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tap Next to show another pair'),
                    ),
                  );
                },
                icon: const Icon(Icons.info_outline),
                label: const Text('Tip'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeckAssignOptions(Deck d) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.chevron_left),
              title: Text('Assign to Left'),
              onTap: () {
                setState(() {
                  selectedLeftId = d.id;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chevron_right),
              title: Text('Assign to Right'),
              onTap: () {
                setState(() {
                  selectedRightId = d.id;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit deck'),
              onTap: () {
                Navigator.pop(context);
                _editDeck(d);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
