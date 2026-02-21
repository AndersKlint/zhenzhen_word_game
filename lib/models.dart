class DeckGroup {
  String id;
  String name;

  DeckGroup({required this.id, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory DeckGroup.fromJson(Map<String, dynamic> json) =>
      DeckGroup(id: json['id'], name: json['name']);
}

class Deck {
  String id;
  String name;
  List<String> words;
  Map<int, String> backs;
  String? groupId;

  Deck({
    required this.id,
    required this.name,
    List<String>? words,
    Map<int, String>? backs,
    this.groupId,
  }) : words = words ?? [],
       backs = backs ?? {};

  String? getBack(int index) => backs[index];

  void setBack(int index, String? value) {
    if (value == null || value.isEmpty) {
      backs.remove(index);
    } else {
      backs[index] = value;
    }
  }

  bool hasBack(int index) =>
      backs.containsKey(index) && backs[index]!.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'words': words,
    'backs': backs.map((k, v) => MapEntry(k.toString(), v)),
    'groupId': groupId,
  };

  factory Deck.fromJson(Map<String, dynamic> json) => Deck(
    id: json['id'],
    name: json['name'],
    words: List<String>.from(json['words'] ?? []),
    backs: json['backs'] != null
        ? Map<int, String>.from(
            (json['backs'] as Map).map((k, v) => MapEntry(int.parse(k), v)),
          )
        : {},
    groupId: json['groupId'],
  );
}
