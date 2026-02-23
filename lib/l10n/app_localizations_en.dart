// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kids Chinese Word Game';

  @override
  String get deckList_title => 'Your Decks';

  @override
  String get deckList_addDeck => 'Add Deck';

  @override
  String get deckList_addGroup => 'Add Group';

  @override
  String get deckList_goToGames => 'Go to Games';

  @override
  String get deckList_noDecks => 'No decks yet. Create one!';

  @override
  String deckList_cards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$_temp0';
  }

  @override
  String get deckList_dropToUngroup => 'Drop here to ungroup';

  @override
  String get dialog_deckName => 'Deck name?';

  @override
  String get dialog_groupName => 'Group name?';

  @override
  String get dialog_newName => 'New name?';

  @override
  String get dialog_cancel => 'Cancel';

  @override
  String get dialog_ok => 'OK';

  @override
  String get dialog_delete => 'Delete';

  @override
  String get dialog_rename => 'Rename';

  @override
  String get dialog_replace => 'Replace';

  @override
  String get dialog_skip => 'Skip';

  @override
  String get deleteGroup_title => 'Delete group?';

  @override
  String deleteGroup_message(String name) {
    return 'Delete \"$name\"? Decks in this group will become ungrouped.';
  }

  @override
  String get deleteDeck_title => 'Delete deck?';

  @override
  String deleteDeck_message(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get tooltip_rename => 'Rename';

  @override
  String get tooltip_delete => 'Delete';

  @override
  String get export_title => 'Export Decks';

  @override
  String get export_selectAll => 'Select All';

  @override
  String get export_button => 'Export';

  @override
  String export_success(int count) {
    return 'Exported $count deck(s)';
  }

  @override
  String get import_title => 'Import Collection';

  @override
  String import_failed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get import_processing => 'Processing...';

  @override
  String get conflict_title => 'Duplicate Deck Name';

  @override
  String conflict_messageGrouped(String name, String group) {
    return 'A deck named \"$name\" already exists in \"$group\".';
  }

  @override
  String conflict_messageUngrouped(String name) {
    return 'An ungrouped deck named \"$name\" already exists.';
  }

  @override
  String get conflict_whatToDo => 'What would you like to do?';

  @override
  String get conflict_applyToAll => 'Apply to all remaining conflicts';

  @override
  String importResult_imported(int count) {
    return '$count imported';
  }

  @override
  String importResult_replaced(int count) {
    return '$count replaced';
  }

  @override
  String importResult_renamed(int count) {
    return '$count renamed';
  }

  @override
  String importResult_skipped(int count) {
    return '$count skipped';
  }

  @override
  String importResult_groupsMerged(int count) {
    return '$count groups merged';
  }

  @override
  String get importResult_noChanges => 'No changes made';

  @override
  String importResult_complete(String details) {
    return 'Import complete: $details';
  }

  @override
  String get gameSelection_title => 'Games';

  @override
  String get gameSelection_selectMode => 'Select Game Mode';

  @override
  String gameSelection_playing(String name) {
    return 'Playing: $name';
  }

  @override
  String get game_recallFront_title => 'Recall: Front Only';

  @override
  String get game_recallFront_desc =>
      'Practice cards one at a time. Mark each as \"Good\" if you know it or \"Again\" to retry later. Cards you mark \"Again\" will reappear until cleared.';

  @override
  String get game_recallBoth_title => 'Recall: Front & Back';

  @override
  String get game_recallBoth_desc =>
      'See the front, then tap to flip and reveal the back. Great for vocabulary where you want to check your answer before rating.';

  @override
  String get game_randomMulti_title => 'Random: Multi Deck (Front only)';

  @override
  String get game_randomMulti_desc =>
      'Combine multiple decks into one session. Shows one random word from each selected deck simultaneously. Great for rapid review across subjects.';

  @override
  String get game_reverseRecall_title => 'Reverse Recall';

  @override
  String get game_reverseRecall_desc =>
      'Shows the back text first - tap to reveal the front. Tests reverse associations, like showing a definition to recall the word.';

  @override
  String get game_multipleChoice_title => 'Multiple Choice Quiz';

  @override
  String get game_multipleChoice_desc =>
      'See the front and pick the correct back from 4 options. Wrong answers come from other cards in the deck. Tracks your score.';

  @override
  String get game_memoryMatch_title => 'Memory Match';

  @override
  String get game_memoryMatch_desc =>
      'Classic memory game: flip two cards at a time to find matching front/back pairs. Tracks moves taken to complete.';

  @override
  String get game_noBackText => 'This deck has no cards with back text';

  @override
  String get chooseDeck_title => 'Choose deck';

  @override
  String get selectDecks_title => 'Select decks';

  @override
  String get repeatWords_title => 'Repeat words?';

  @override
  String get repeatWords_no => 'No';

  @override
  String get repeatWords_yes => 'Yes';

  @override
  String deckEditor_edit(String name) {
    return 'Edit: $name';
  }

  @override
  String get deckEditor_noGroup => 'No Group';

  @override
  String get deckEditor_selectGroup => 'Select Group';

  @override
  String get deckEditor_addFirst => 'Add your first card!';

  @override
  String get deckEditor_front => 'Front';

  @override
  String get deckEditor_back => 'Back (optional)';

  @override
  String get deckEditor_addCard => 'Add Card';

  @override
  String get deckEditor_editCard => 'Edit Card';

  @override
  String get deckEditor_save => 'Save';

  @override
  String game_cardsLeft(int remaining, int total) {
    return 'Cards left: $remaining / $total';
  }

  @override
  String get game_congratulations =>
      'Congratulations! You cleared all the cards!';

  @override
  String get game_again => 'Again';

  @override
  String get game_good => 'Good';

  @override
  String get game_finish => 'Finish';

  @override
  String get game_tapToFlip => 'Tap to flip';

  @override
  String get game_tapToReveal => 'Tap to reveal answer';

  @override
  String get game_allDone => 'All done!';

  @override
  String get game_next => 'Next';

  @override
  String game_multiDeck(int count) {
    return 'Multi Deck ($count)';
  }

  @override
  String get quiz_complete => 'Quiz Complete!';

  @override
  String quiz_correct(int correct, int total) {
    return '$correct / $total correct';
  }

  @override
  String quiz_question(int current, int total) {
    return 'Question $current / $total';
  }

  @override
  String get quiz_selectAnswer => 'Select the correct answer:';

  @override
  String get quiz_seeResults => 'See Results';

  @override
  String get memory_youWin => 'You Win!';

  @override
  String get memory_moves => 'Moves';

  @override
  String get memory_matches => 'Matches';

  @override
  String memory_completedMoves(int count) {
    return 'Completed in $count moves';
  }

  @override
  String get common_again => 'Again';

  @override
  String get common_good => 'Good';

  @override
  String get common_finish => 'Finish';

  @override
  String get common_next => 'Next';

  @override
  String get common_congratulations =>
      'Congratulations! You cleared all the cards!';

  @override
  String get common_tapToFlip => 'Tap to flip';

  @override
  String get common_tapToReveal => 'Tap to reveal answer';

  @override
  String get common_allDone => 'All done!';

  @override
  String get common_noBackText => 'This deck has no cards with back text';

  @override
  String editor_title(String name) {
    return 'Edit: $name';
  }

  @override
  String get editor_noGroup => 'No Group';

  @override
  String get editor_addFirstCard => 'Add your first card!';

  @override
  String get editor_front => 'Front';

  @override
  String get editor_back => 'Back (optional)';

  @override
  String get editor_addCard => 'Add Card';

  @override
  String get editor_editCard => 'Edit Card';

  @override
  String get editor_save => 'Save';

  @override
  String get editor_selectGroup => 'Select Group';

  @override
  String get lang_english => 'EN';

  @override
  String get lang_chinese => '中文';

  @override
  String get themes_title => 'Themes';

  @override
  String get theme_playful => 'Playful Theme';

  @override
  String get theme_modest => 'Modest Theme';

  @override
  String get theme_modern => 'Modern Theme';
}
