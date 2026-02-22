import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Kids Chinese Word Game'**
  String get appTitle;

  /// Title on the deck list screen
  ///
  /// In en, this message translates to:
  /// **'Your Decks'**
  String get deckList_title;

  /// Button to add a new deck
  ///
  /// In en, this message translates to:
  /// **'Add Deck'**
  String get deckList_addDeck;

  /// Button to add a new group
  ///
  /// In en, this message translates to:
  /// **'Add Group'**
  String get deckList_addGroup;

  /// Button to navigate to games screen
  ///
  /// In en, this message translates to:
  /// **'Go to Games'**
  String get deckList_goToGames;

  /// Message shown when there are no decks
  ///
  /// In en, this message translates to:
  /// **'No decks yet. Create one!'**
  String get deckList_noDecks;

  /// Card count display, e.g. '5 cards'
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 card} other{{count} cards}}'**
  String deckList_cards(int count);

  /// Drop zone hint for ungrouping decks
  ///
  /// In en, this message translates to:
  /// **'Drop here to ungroup'**
  String get deckList_dropToUngroup;

  /// Prompt for deck name input
  ///
  /// In en, this message translates to:
  /// **'Deck name?'**
  String get dialog_deckName;

  /// Prompt for group name input
  ///
  /// In en, this message translates to:
  /// **'Group name?'**
  String get dialog_groupName;

  /// Prompt for new name input
  ///
  /// In en, this message translates to:
  /// **'New name?'**
  String get dialog_newName;

  /// Cancel button in dialogs
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialog_cancel;

  /// OK button in dialogs
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get dialog_ok;

  /// Delete button in dialogs
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get dialog_delete;

  /// Rename button in dialogs
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get dialog_rename;

  /// Replace button in dialogs
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get dialog_replace;

  /// Skip button in dialogs
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get dialog_skip;

  /// Title of delete group confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete group?'**
  String get deleteGroup_title;

  /// Message in delete group confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? Decks in this group will become ungrouped.'**
  String deleteGroup_message(String name);

  /// Title of delete deck confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete deck?'**
  String get deleteDeck_title;

  /// Message in delete deck confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteDeck_message(String name);

  /// Tooltip for rename button
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get tooltip_rename;

  /// Tooltip for delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get tooltip_delete;

  /// Title of export dialog
  ///
  /// In en, this message translates to:
  /// **'Export Decks'**
  String get export_title;

  /// Select all checkbox label
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get export_selectAll;

  /// Export button
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export_button;

  /// Success message after export
  ///
  /// In en, this message translates to:
  /// **'Exported {count} deck(s)'**
  String export_success(int count);

  /// Title for import dialog
  ///
  /// In en, this message translates to:
  /// **'Import Collection'**
  String get import_title;

  /// Error message for failed import
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String import_failed(String error);

  /// Processing message during import
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get import_processing;

  /// Title for conflict resolution dialog
  ///
  /// In en, this message translates to:
  /// **'Duplicate Deck Name'**
  String get conflict_title;

  /// Conflict message for deck in a group
  ///
  /// In en, this message translates to:
  /// **'A deck named \"{name}\" already exists in \"{group}\".'**
  String conflict_messageGrouped(String name, String group);

  /// Conflict message for ungrouped deck
  ///
  /// In en, this message translates to:
  /// **'An ungrouped deck named \"{name}\" already exists.'**
  String conflict_messageUngrouped(String name);

  /// Prompt in conflict dialog
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get conflict_whatToDo;

  /// Checkbox to apply resolution to all conflicts
  ///
  /// In en, this message translates to:
  /// **'Apply to all remaining conflicts'**
  String get conflict_applyToAll;

  /// Import result: count imported
  ///
  /// In en, this message translates to:
  /// **'{count} imported'**
  String importResult_imported(int count);

  /// Import result: count replaced
  ///
  /// In en, this message translates to:
  /// **'{count} replaced'**
  String importResult_replaced(int count);

  /// Import result: count renamed
  ///
  /// In en, this message translates to:
  /// **'{count} renamed'**
  String importResult_renamed(int count);

  /// Import result: count skipped
  ///
  /// In en, this message translates to:
  /// **'{count} skipped'**
  String importResult_skipped(int count);

  /// Import result: count groups merged
  ///
  /// In en, this message translates to:
  /// **'{count} groups merged'**
  String importResult_groupsMerged(int count);

  /// Import result when nothing changed
  ///
  /// In en, this message translates to:
  /// **'No changes made'**
  String get importResult_noChanges;

  /// Import complete message with details
  ///
  /// In en, this message translates to:
  /// **'Import complete: {details}'**
  String importResult_complete(String details);

  /// Title on game selection screen
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get gameSelection_title;

  /// Prompt to select a game mode
  ///
  /// In en, this message translates to:
  /// **'Select Game Mode'**
  String get gameSelection_selectMode;

  /// Shows which deck is being played
  ///
  /// In en, this message translates to:
  /// **'Playing: {name}'**
  String gameSelection_playing(String name);

  /// Title for Recall Front Only game
  ///
  /// In en, this message translates to:
  /// **'Recall: Front Only'**
  String get game_recallFront_title;

  /// Description for Recall Front Only game
  ///
  /// In en, this message translates to:
  /// **'Practice cards one at a time. Mark each as \"Good\" if you know it or \"Again\" to retry later. Cards you mark \"Again\" will reappear until cleared.'**
  String get game_recallFront_desc;

  /// Title for Recall Front & Back game
  ///
  /// In en, this message translates to:
  /// **'Recall: Front & Back'**
  String get game_recallBoth_title;

  /// Description for Recall Front & Back game
  ///
  /// In en, this message translates to:
  /// **'See the front, then tap to flip and reveal the back. Great for vocabulary where you want to check your answer before rating.'**
  String get game_recallBoth_desc;

  /// Title for Random Multi Deck game
  ///
  /// In en, this message translates to:
  /// **'Random: Multi Deck (Front only)'**
  String get game_randomMulti_title;

  /// Description for Random Multi Deck game
  ///
  /// In en, this message translates to:
  /// **'Combine multiple decks into one session. Shows one random word from each selected deck simultaneously. Great for rapid review across subjects.'**
  String get game_randomMulti_desc;

  /// Title for Reverse Recall game
  ///
  /// In en, this message translates to:
  /// **'Reverse Recall'**
  String get game_reverseRecall_title;

  /// Description for Reverse Recall game
  ///
  /// In en, this message translates to:
  /// **'Shows the back text first - tap to reveal the front. Tests reverse associations, like showing a definition to recall the word.'**
  String get game_reverseRecall_desc;

  /// Title for Multiple Choice game
  ///
  /// In en, this message translates to:
  /// **'Multiple Choice Quiz'**
  String get game_multipleChoice_title;

  /// Description for Multiple Choice game
  ///
  /// In en, this message translates to:
  /// **'See the front and pick the correct back from 4 options. Wrong answers come from other cards in the deck. Tracks your score.'**
  String get game_multipleChoice_desc;

  /// Title for Memory Match game
  ///
  /// In en, this message translates to:
  /// **'Memory Match'**
  String get game_memoryMatch_title;

  /// Description for Memory Match game
  ///
  /// In en, this message translates to:
  /// **'Classic memory game: flip two cards at a time to find matching front/back pairs. Tracks moves taken to complete.'**
  String get game_memoryMatch_desc;

  /// Error when deck has no back text for games that need it
  ///
  /// In en, this message translates to:
  /// **'This deck has no cards with back text'**
  String get game_noBackText;

  /// Title for deck selection dialog
  ///
  /// In en, this message translates to:
  /// **'Choose deck'**
  String get chooseDeck_title;

  /// Title for multiple deck selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select decks'**
  String get selectDecks_title;

  /// Title for repeat words dialog
  ///
  /// In en, this message translates to:
  /// **'Repeat words?'**
  String get repeatWords_title;

  /// No option for repeat words
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get repeatWords_no;

  /// Yes option for repeat words
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get repeatWords_yes;

  /// Title for deck editor screen
  ///
  /// In en, this message translates to:
  /// **'Edit: {name}'**
  String deckEditor_edit(String name);

  /// Label when deck has no group
  ///
  /// In en, this message translates to:
  /// **'No Group'**
  String get deckEditor_noGroup;

  /// Title for group selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select Group'**
  String get deckEditor_selectGroup;

  /// Prompt when deck is empty
  ///
  /// In en, this message translates to:
  /// **'Add your first card!'**
  String get deckEditor_addFirst;

  /// Label for front text input
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get deckEditor_front;

  /// Label for back text input
  ///
  /// In en, this message translates to:
  /// **'Back (optional)'**
  String get deckEditor_back;

  /// Button to add a card
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get deckEditor_addCard;

  /// Title for edit card dialog
  ///
  /// In en, this message translates to:
  /// **'Edit Card'**
  String get deckEditor_editCard;

  /// Save button in edit card dialog
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get deckEditor_save;

  /// Progress indicator in card games
  ///
  /// In en, this message translates to:
  /// **'Cards left: {remaining} / {total}'**
  String game_cardsLeft(int remaining, int total);

  /// Message when all cards are cleared
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You cleared all the cards!'**
  String get game_congratulations;

  /// Button to retry a card
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get game_again;

  /// Button to mark card as known
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get game_good;

  /// Button to finish/exit game
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get game_finish;

  /// Hint to tap card to flip
  ///
  /// In en, this message translates to:
  /// **'Tap to flip'**
  String get game_tapToFlip;

  /// Hint to tap card to reveal answer
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal answer'**
  String get game_tapToReveal;

  /// Message when game is complete
  ///
  /// In en, this message translates to:
  /// **'All done!'**
  String get game_allDone;

  /// Button for next card
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get game_next;

  /// Title for multi deck game
  ///
  /// In en, this message translates to:
  /// **'Multi Deck ({count})'**
  String game_multiDeck(int count);

  /// Title when quiz finishes
  ///
  /// In en, this message translates to:
  /// **'Quiz Complete!'**
  String get quiz_complete;

  /// Score display after quiz
  ///
  /// In en, this message translates to:
  /// **'{correct} / {total} correct'**
  String quiz_correct(int correct, int total);

  /// Question progress indicator
  ///
  /// In en, this message translates to:
  /// **'Question {current} / {total}'**
  String quiz_question(int current, int total);

  /// Prompt to select an answer
  ///
  /// In en, this message translates to:
  /// **'Select the correct answer:'**
  String get quiz_selectAnswer;

  /// Button to see quiz results
  ///
  /// In en, this message translates to:
  /// **'See Results'**
  String get quiz_seeResults;

  /// Win message for memory game
  ///
  /// In en, this message translates to:
  /// **'You Win!'**
  String get memory_youWin;

  /// Label for move count
  ///
  /// In en, this message translates to:
  /// **'Moves'**
  String get memory_moves;

  /// Label for match count
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get memory_matches;

  /// Completion message with move count
  ///
  /// In en, this message translates to:
  /// **'Completed in {count} moves'**
  String memory_completedMoves(int count);

  /// Button to mark card for retry
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get common_again;

  /// Button to mark card as known
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get common_good;

  /// Finish button
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get common_finish;

  /// Next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get common_next;

  /// Congratulations message after completing a game
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You cleared all the cards!'**
  String get common_congratulations;

  /// Hint to tap card to flip
  ///
  /// In en, this message translates to:
  /// **'Tap to flip'**
  String get common_tapToFlip;

  /// Hint to tap card to reveal answer
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal answer'**
  String get common_tapToReveal;

  /// Completion message
  ///
  /// In en, this message translates to:
  /// **'All done!'**
  String get common_allDone;

  /// Error when deck has no back text
  ///
  /// In en, this message translates to:
  /// **'This deck has no cards with back text'**
  String get common_noBackText;

  /// Title for deck editor screen
  ///
  /// In en, this message translates to:
  /// **'Edit: {name}'**
  String editor_title(String name);

  /// Label for ungrouped deck
  ///
  /// In en, this message translates to:
  /// **'No Group'**
  String get editor_noGroup;

  /// Prompt when deck is empty
  ///
  /// In en, this message translates to:
  /// **'Add your first card!'**
  String get editor_addFirstCard;

  /// Label for front side of card
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get editor_front;

  /// Label for back side of card
  ///
  /// In en, this message translates to:
  /// **'Back (optional)'**
  String get editor_back;

  /// Button to add a card
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get editor_addCard;

  /// Title for edit card dialog
  ///
  /// In en, this message translates to:
  /// **'Edit Card'**
  String get editor_editCard;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get editor_save;

  /// Title for group selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select Group'**
  String get editor_selectGroup;

  /// Short label for English language
  ///
  /// In en, this message translates to:
  /// **'EN'**
  String get lang_english;

  /// Short label for Chinese language
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get lang_chinese;

  /// Menu item to switch to playful theme
  ///
  /// In en, this message translates to:
  /// **'Playful Theme'**
  String get theme_playful;

  /// Menu item to switch to modest theme
  ///
  /// In en, this message translates to:
  /// **'Modest Theme'**
  String get theme_modest;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
