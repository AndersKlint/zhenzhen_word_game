import 'package:flutter_test/flutter_test.dart';
import 'package:zhenzhen_word_game/deck_service.dart';

void main() {
  group('parseLaoziCsv', () {
    test('parses basic CSV correctly', () {
      const csv = '''hanzi	meaning	pinyin	description	examples	tags
你好	hello	nǐ hǎo	test desc	examples here	deck:testdeck group:testgroup''';

      final result = DeckService().parseLaoziCsv(csv, 'testfile');

      expect(result.decks.length, 1);
      expect(result.decks[0].name, 'testdeck');
      expect(result.decks[0].words, ['你好']);
      expect(result.decks[0].getBack(0), 'nǐ hǎo\nhello');
    });

    test('creates groups from CSV', () {
      const csv = '''hanzi	meaning	pinyin	description	examples	tags
你好	hello	nǐ hǎo	test desc	examples here	deck:testdeck group:testgroup''';

      final result = DeckService().parseLaoziCsv(csv, 'testfile');

      expect(result.groups.length, 1);
      expect(result.groups[0].name, 'testgroup');
    });

    test('groups cards by (deck, group) pair', () {
      const csv = '''hanzi	meaning	pinyin	description	examples	tags
你好	hello	nǐ hǎo	test desc	examples here	deck:deck1 group:g1
世界	world	shìjiè	test desc	examples here	deck:deck1 group:g1
谢谢	thanks	xièxie	test desc	examples here	deck:deck2 group:g1''';

      final result = DeckService().parseLaoziCsv(csv, 'testfile');

      expect(result.decks.length, 2);
      expect(result.decks[0].name, 'deck1');
      expect(result.decks[0].words, ['你好', '世界']);
      expect(result.decks[1].name, 'deck2');
      expect(result.decks[1].words, ['谢谢']);
    });

    test('handles ungrouped cards', () {
      const csv = '''hanzi	meaning	pinyin	description	examples	tags
你好	hello	nǐ hǎo	test desc	examples here	deck:testdeck
谢谢	thanks	xièxie	test desc	examples here	deck:testdeck''';

      final result = DeckService().parseLaoziCsv(csv, 'testfile');

      expect(result.groups.length, 0);
      expect(result.decks.length, 1);
      expect(result.decks[0].groupId, isNull);
      expect(result.decks[0].words, ['你好', '谢谢']);
    });

    test('uses filename as deck name when no deck tag', () {
      const csv = '''hanzi	meaning	pinyin	description	examples	tags
你好	hello	nǐ hǎo	test desc	examples here	''';

      final result = DeckService().parseLaoziCsv(csv, 'mylanfile');

      expect(result.decks[0].name, 'mylanfile');
    });

    test('URL decodes spaces in tags', () {
      const csv = '''hanzi	meaning	pinyin	description	examples	tags
你好	hello	nǐ hǎo	test desc	examples here	deck:My%20Deck group:My%20Group''';

      final result = DeckService().parseLaoziCsv(csv, 'testfile');

      expect(result.decks[0].name, 'My Deck');
      expect(result.groups[0].name, 'My Group');
    });

    test('handles missing meaning gracefully', () {
      const csv = '''hanzi	meaning	pinyin	description	examples	tags
你好		nǐ hǎo	test desc	examples here	deck:testdeck''';

      final result = DeckService().parseLaoziCsv(csv, 'testfile');

      expect(result.decks[0].getBack(0), 'nǐ hǎo\n');
    });

    test('handles empty lines', () {
      const csv = '''hanzi	meaning	pinyin	description	examples	tags
你好	hello	nǐ hǎo	test desc	examples here	deck:testdeck

谢谢	thanks	xièxie	test desc	examples here	deck:testdeck''';

      final result = DeckService().parseLaoziCsv(csv, 'testfile');

      expect(result.decks[0].words, ['你好', '谢谢']);
    });

    test('skips lines without hanzi', () {
      const csv = '''hanzi	meaning	pinyin	description	examples	tags
你好	hello	nǐ hǎo	test desc	examples here	deck:testdeck
		shìjiè	test desc	examples here	deck:testdeck
世界	world	shìjiè	test desc	examples here	deck:testdeck''';

      final result = DeckService().parseLaoziCsv(csv, 'testfile');

      expect(result.decks[0].words, ['你好', '世界']);
    });

    test('keeps all duplicates', () {
      const csv = '''hanzi	meaning	pinyin	description	examples	tags
你好	hello	nǐ hǎo	test desc	examples here	deck:testdeck
你好	hello2	nǐ hǎo2	test desc	examples here	deck:testdeck''';

      final result = DeckService().parseLaoziCsv(csv, 'testfile');

      expect(result.decks[0].words, ['你好', '你好']);
      expect(result.decks[0].getBack(0), 'nǐ hǎo\nhello');
      expect(result.decks[0].getBack(1), 'nǐ hǎo2\nhello2');
    });

    test('throws on missing required columns', () {
      const csv = '''hanzi	description	examples	tags
你好	test desc	examples here	deck:testdeck''';

      expect(
        () => DeckService().parseLaoziCsv(csv, 'testfile'),
        throwsFormatException,
      );
    });

    test('handles multiline quoted fields without creating duplicates', () {
      const csv = '''hanzi	meaning	pinyin	description	examples	tags
谢谢	Thank you	xièxie	A common way to express gratitude.	"谢谢你的帮助。
Thank you for your help.

非常感谢！
Thank you very much!"	deck:tefre
你好	hello	nǐ hǎo	test desc	examples here	deck:tefre2''';

      final result = DeckService().parseLaoziCsv(csv, 'testfile');

      expect(result.decks.length, 2);
      expect(result.decks[0].words, ['谢谢']);
      expect(result.decks[1].words, ['你好']);
    });

    test('handles escaped quotes in quoted fields', () {
      const csv = '''hanzi	meaning	pinyin	description	examples	tags
你好	"hello ""world"""	nǐ hǎo	test desc	examples here	deck:testdeck''';

      final result = DeckService().parseLaoziCsv(csv, 'testfile');

      expect(result.decks[0].getBack(0), 'nǐ hǎo\nhello "world"');
    });
  });
}
