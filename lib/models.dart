class DeckGroup {
  String id;
  String name;

  DeckGroup({required this.id, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory DeckGroup.fromJson(Map<String, dynamic> json) =>
      DeckGroup(id: json['id'] as String, name: json['name'] as String);
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

  bool get hasBackText => backs.values.any((value) => value.isNotEmpty);

  void setBack(int index, String? value) {
    if (value == null || value.isEmpty) {
      backs.remove(index);
    } else {
      backs[index] = value;
    }
  }

  bool hasBack(int index) => backs[index]?.isNotEmpty ?? false;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'words': words,
    'backs': backs.map((k, v) => MapEntry(k.toString(), v)),
    'groupId': groupId,
  };

  factory Deck.fromJson(Map<String, dynamic> json) => Deck(
    id: json['id'] as String,
    name: json['name'] as String,
    words: List<String>.from(json['words'] as List? ?? const <String>[]),
    backs: json['backs'] != null
        ? Map<int, String>.from(
            (json['backs'] as Map).map(
              (key, value) =>
                  MapEntry(int.parse(key as String), value as String),
            ),
          )
        : {},
    groupId: json['groupId'] as String?,
  );
}
