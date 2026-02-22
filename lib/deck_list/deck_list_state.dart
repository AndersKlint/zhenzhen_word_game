import '../models.dart';

class DeckListState {
  final List<Deck> decks;
  final List<DeckGroup> groups;
  final Set<String> expandedGroupIds;

  const DeckListState({
    this.decks = const [],
    this.groups = const [],
    this.expandedGroupIds = const {},
  });

  DeckListState copyWith({
    List<Deck>? decks,
    List<DeckGroup>? groups,
    Set<String>? expandedGroupIds,
  }) {
    return DeckListState(
      decks: decks ?? this.decks,
      groups: groups ?? this.groups,
      expandedGroupIds: expandedGroupIds ?? this.expandedGroupIds,
    );
  }

  bool get isEmpty => decks.isEmpty && groups.isEmpty;

  bool isGroupExpanded(String groupId) => expandedGroupIds.contains(groupId);

  DeckListState toggleGroupExpanded(String groupId) {
    final newExpanded = Set<String>.from(expandedGroupIds);
    if (newExpanded.contains(groupId)) {
      newExpanded.remove(groupId);
    } else {
      newExpanded.add(groupId);
    }
    return copyWith(expandedGroupIds: newExpanded);
  }
}
