# Flashcard Games

A Flutter flashcard app for teachers to create decks and play learning games with kids.

## Features

### Deck Management
- Create, edit, and delete flashcard decks
- Cards support front text with optional back text
- Organize decks into groups for better structure
- Drag and drop decks between groups or to ungroup

### Games
- **Recall: Front Only** - Practice cards one at a time with Again/Good buttons
- **Recall: Front & Back** - Flip cards to reveal the back before rating
- **Random: Multi Deck** - Combine multiple decks into a randomized session

### Organization
- Group decks for subject-based organization
- Play all cards in a group as one combined deck
- Select entire groups when playing multi-deck games

### Data
- Import/Export collections as JSON files
- Handles duplicate deck names with rename/replace/skip options
- Data persists locally across app updates

## Getting Started

```bash
flutter pub get
flutter run
```

## Building

```bash
flutter build windows
flutter build web
flutter build apk
```
