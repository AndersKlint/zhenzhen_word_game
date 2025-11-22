class Deck {
  String id;
  String name;
  List<String> words;

  Deck({required this.id, required this.name, List<String>? words})
      : words = words ?? [];

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'words': words};

  factory Deck.fromJson(Map<String, dynamic> json) => Deck(
        id: json['id'],
        name: json['name'],
        words: List<String>.from(json['words'] ?? []),
      );
}
