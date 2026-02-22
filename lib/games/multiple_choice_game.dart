import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../theme/app_theme.dart';
import 'dart:math';

class MultipleChoiceGame extends StatefulWidget {
  final Deck deck;
  final AppTheme theme;
  const MultipleChoiceGame({
    super.key,
    required this.deck,
    required this.theme,
  });

  @override
  State<MultipleChoiceGame> createState() => _MultipleChoiceGameState();
}

class _MultipleChoiceGameState extends State<MultipleChoiceGame>
    with SingleTickerProviderStateMixin {
  late List<int> _cardIndices;
  int _currentIndex = 0;
  int _score = 0;
  bool _answered = false;
  int? _selectedAnswer;
  late List<String> _options;
  int _correctIndex = 0;
  bool finished = false;
  late AnimationController _animController;
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _cardIndices = List.generate(
      widget.deck.words.length,
      (i) => i,
    ).where((i) => widget.deck.hasBack(i)).toList();
    _cardIndices.shuffle(_rnd);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _setupQuestion();
    _animController.value = 1.0;
  }

  void _setupQuestion() {
    if (_currentIndex >= _cardIndices.length) {
      setState(() => finished = true);
      return;
    }

    final correctIdx = _cardIndices[_currentIndex];
    final correctAnswer = widget.deck.getBack(correctIdx)!;

    final wrongAnswers = <String>[];
    final otherIndices = _cardIndices.where((i) => i != correctIdx).toList();
    otherIndices.shuffle(_rnd);

    for (int i = 0; i < otherIndices.length && wrongAnswers.length < 3; i++) {
      final back = widget.deck.getBack(otherIndices[i]);
      if (back != null &&
          back != correctAnswer &&
          !wrongAnswers.contains(back)) {
        wrongAnswers.add(back);
      }
    }

    while (wrongAnswers.length < 3) {
      wrongAnswers.add('???');
    }

    _options = [...wrongAnswers.sublist(0, 3), correctAnswer];
    _options.shuffle(_rnd);
    _correctIndex = _options.indexOf(correctAnswer);

    _answered = false;
    _selectedAnswer = null;
  }

  void _selectAnswer(int index) {
    if (_answered) return;

    setState(() {
      _answered = true;
      _selectedAnswer = index;
      if (index == _correctIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _currentIndex++;
      _setupQuestion();
      _animController.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  double _getFontSize(String text) {
    if (text.length <= 10) return 22;
    if (text.length <= 20) return 18;
    return 14;
  }

  LinearGradient _randomGradient() {
    if (widget.theme.isModest) {
      return widget.theme.cardGradient;
    }
    final c1 = Colors.primaries[_rnd.nextInt(Colors.primaries.length)].shade200;
    final c2 = Colors.primaries[_rnd.nextInt(Colors.primaries.length)].shade400;
    return LinearGradient(
      colors: [c1, c2],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalQuestions = _cardIndices.length;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: widget.theme.primaryTextColor),
        title: Text(
          widget.deck.name,
          style: TextStyle(color: widget.theme.primaryTextColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: widget.theme.backgroundGradient),
        child: SafeArea(
          child: finished
              ? _buildFinishedScreen()
              : _buildQuestionScreen(totalQuestions),
        ),
      ),
    );
  }

  Widget _buildFinishedScreen() {
    final l10n = AppLocalizations.of(context)!;
    final totalQuestions = _cardIndices.length;
    final percentage = totalQuestions > 0
        ? (_score / totalQuestions * 100).round()
        : 0;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.quiz_complete,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: widget.theme.primaryTextColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.quiz_correct(_score, totalQuestions),
            style: TextStyle(
              fontSize: 28,
              color: widget.theme.primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              color: percentage >= 70
                  ? Colors.green.shade600
                  : Colors.orange.shade600,
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SizedBox(
              width: double.infinity,
              height: 70,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.theme.accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  l10n.common_finish,
                  style: TextStyle(
                    fontSize: 28,
                    color: widget.theme.buttonTextColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionScreen(int totalQuestions) {
    final l10n = AppLocalizations.of(context)!;
    final frontText = widget.deck.words[_cardIndices[_currentIndex]];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            l10n.quiz_question(_currentIndex + 1, totalQuestions),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: widget.theme.primaryTextColor,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _animController,
                curve: Curves.easeOut,
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: _randomGradient(),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  frontText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: widget.theme.isModest
                        ? widget.theme.primaryTextColor
                        : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            l10n.quiz_selectAnswer,
            style: TextStyle(
              fontSize: 18,
              color: widget.theme.secondaryTextColor,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) {
                final isSelected = _selectedAnswer == index;
                final isCorrect = index == _correctIndex;
                final showResult = _answered;

                Color bgColor;
                if (showResult && isCorrect) {
                  bgColor = Colors.green.shade400;
                } else if (showResult && isSelected && !isCorrect) {
                  bgColor = Colors.red.shade400;
                } else if (isSelected) {
                  bgColor = Colors.blue.shade300;
                } else {
                  bgColor = Colors.white.withOpacity(0.9);
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => _selectAnswer(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.blue.shade700
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        _options[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: _getFontSize(_options[index]),
                          fontWeight: FontWeight.w600,
                          color: showResult && (isCorrect || isSelected)
                              ? Colors.white
                              : widget.theme.primaryTextColor,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (_answered)
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.theme.buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  _currentIndex + 1 >= totalQuestions
                      ? l10n.quiz_seeResults
                      : l10n.common_next,
                  style: TextStyle(
                    fontSize: 24,
                    color: widget.theme.buttonTextColor,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
