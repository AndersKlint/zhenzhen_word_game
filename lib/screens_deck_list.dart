import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'deck_service.dart';
import 'di.dart';
import 'screens_deck_editor.dart';
import 'screens_game_selection.dart';
import 'models.dart';

class DeckListScaffold extends StatefulWidget {
  const DeckListScaffold({super.key});

  @override
  State<DeckListScaffold> createState() => _DeckListScaffoldState();
}

class _DeckListScaffoldState extends State<DeckListScaffold> {
  final deckService = getIt<DeckService>();
  final Set<String> _expandedGroups = {};

  @override
  void initState() {
    super.initState();
    deckService.addListener(_update);
  }

  @override
  void dispose() {
    deckService.removeListener(_update);
    super.dispose();
  }

  void _update() => setState(() {});

  Future<void> _createDeck({String? groupId}) async {
    final name = await _ask(context, 'Deck name?');
    if (name != null && name.trim().isNotEmpty) {
      await deckService.addDeck(name.trim(), groupId: groupId);
    }
  }

  Future<void> _createGroup() async {
    final name = await _ask(context, 'Group name?');
    if (name != null && name.trim().isNotEmpty) {
      await deckService.addGroup(name.trim());
    }
  }

  Future<void> _renameGroup(DeckGroup group) async {
    final name = await _ask(context, 'New name?', initialValue: group.name);
    if (name != null && name.trim().isNotEmpty) {
      await deckService.renameGroup(group.id, name.trim());
    }
  }

  Future<void> _deleteGroup(DeckGroup group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete group?'),
        content: Text(
          'Delete "${group.name}"? Decks in this group will become ungrouped.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await deckService.removeGroup(group.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE1C5E5), Color(0xFF80DEEA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Your Decks',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _createDeck,
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Add Deck'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _createGroup,
                      icon: const Icon(Icons.folder_outlined, size: 20),
                      label: const Text('Add Group'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildDeckList()),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        backgroundColor: Colors.cyan.shade300,
                      ),
                      onPressed: deckService.decks.isEmpty
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const GameSelectionScreen(),
                                ),
                              );
                            },
                      child: const Text(
                        'Play',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeckList() {
    final ungroupedDecks = deckService.getUngroupedDecks();
    final groups = deckService.groups;

    if (deckService.decks.isEmpty && groups.isEmpty) {
      return const Center(
        child: Text(
          'No decks yet. Create one!',
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        ...ungroupedDecks.map((deck) => _buildDeckCard(deck)),
        for (final group in groups) ...[
          _buildGroupHeader(group),
          if (_expandedGroups.contains(group.id))
            ...deckService
                .getGroupDecks(group.id)
                .map(
                  (deck) => Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: _buildDeckCard(deck),
                  ),
                ),
        ],
      ],
    );
  }

  Widget _buildGroupHeader(DeckGroup group) {
    final deckCount = deckService.getGroupDecks(group.id).length;
    final isExpanded = _expandedGroups.contains(group.id);

    return DragTarget<String>(
      onWillAccept: (deckId) {
        if (deckId != null) {
          final deck = deckService.getDeck(deckId);
          return deck.groupId != group.id;
        }
        return false;
      },
      onAccept: (deckId) {
        deckService.assignDeckToGroup(deckId, group.id);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(top: 16, bottom: 8),
          decoration: BoxDecoration(
            color: isHovering
                ? Colors.purple.shade100
                : Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: isHovering
                ? Border.all(color: Colors.purple.shade400, width: 2)
                : null,
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedGroups.remove(group.id);
                } else {
                  _expandedGroups.add(group.id);
                }
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    isExpanded ? Icons.expand_more : Icons.chevron_right,
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.folder, color: Colors.purple.shade400),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${group.name} ($deckCount)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      size: 20,
                      color: Colors.black54,
                    ),
                    onPressed: () => _renameGroup(group),
                    tooltip: 'Rename',
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.black54,
                    ),
                    onPressed: () => _deleteGroup(group),
                    tooltip: 'Delete',
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add,
                      size: 20,
                      color: Colors.black54,
                    ),
                    onPressed: () => _createDeck(groupId: group.id),
                    tooltip: 'Add deck to group',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeckCard(Deck deck) {
    final feedback = Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors
                  .primaries[deck.id.hashCode % Colors.primaries.length]
                  .shade100,
              Colors
                  .primaries[(deck.id.hashCode + 3) % Colors.primaries.length]
                  .shade200,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          deck.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );

    final childWhenDragging = Opacity(
      opacity: 0.5,
      child: _buildDeckCardContent(deck),
    );

    final child = _buildDeckCardContent(deck);

    final isDesktop =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.windows);

    if (isDesktop) {
      return Draggable<String>(
        data: deck.id,
        feedback: feedback,
        childWhenDragging: childWhenDragging,
        child: child,
      );
    } else {
      return LongPressDraggable<String>(
        data: deck.id,
        feedback: feedback,
        childWhenDragging: childWhenDragging,
        child: child,
      );
    }
  }

  Widget _buildDeckCardContent(Deck deck) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors
                .primaries[deck.id.hashCode % Colors.primaries.length]
                .shade100,
            Colors
                .primaries[(deck.id.hashCode + 3) % Colors.primaries.length]
                .shade200,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DeckEditor(deckId: deck.id)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deck.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${deck.words.length} cards',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DeckEditor(deckId: deck.id)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete deck?'),
                  content: Text(
                    'Are you sure you want to delete "${deck.name}"?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                deckService.removeDeck(deck.id);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<String?> _ask(
    BuildContext context,
    String prompt, {
    String? initialValue,
  }) async {
    final ctrl = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(prompt),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
