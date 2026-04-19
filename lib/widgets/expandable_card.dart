import 'package:flutter/material.dart';

class ExpandableCard extends StatelessWidget {
  final String text;
  final LinearGradient gradient;
  final Color textColor;
  final double maxWidth;
  final double maxHeight;

  const ExpandableCard({
    super.key,
    required this.text,
    required this.gradient,
    required this.textColor,
    this.maxWidth = 600,
    this.maxHeight = 400,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth > 0
            ? constraints.maxWidth.clamp(120.0, maxWidth)
            : maxWidth;
        final availableHeight = constraints.maxHeight > 0
            ? constraints.maxHeight.clamp(80.0, maxHeight)
            : maxHeight;

        return _SizedCard(
          text: text,
          gradient: gradient,
          textColor: textColor,
          maxWidth: availableWidth,
          maxHeight: availableHeight,
        );
      },
    );
  }
}

class _SizedCard extends StatefulWidget {
  final String text;
  final LinearGradient gradient;
  final Color textColor;
  final double maxWidth;
  final double maxHeight;

  const _SizedCard({
    required this.text,
    required this.gradient,
    required this.textColor,
    required this.maxWidth,
    required this.maxHeight,
  });

  @override
  State<_SizedCard> createState() => _SizedCardState();
}

class _SizedCardState extends State<_SizedCard> {
  late double _fontSize;

  @override
  void initState() {
    super.initState();
    _fontSize = _calculateInitialFontSize(widget.text, widget.maxWidth);
  }

  double _calculateInitialFontSize(String text, double cardWidth) {
    if (text.length <= 5) return 50;
    if (text.length <= 10) return 40;
    if (text.length <= 15) return 30;
    if (text.length <= 25) return 26;
    return 22;
  }

  bool _doesTextFit(String text, double fontSize, double width, double height) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
      ),
      maxLines: null,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: width - 32);
    return textPainter.height <= height - 32 && textPainter.width <= width - 32;
  }

  double _shrinkFontSize(double current, double width, double height) {
    double newSize = current;
    while (newSize > 12 && !_doesTextFit(widget.text, newSize, width, height)) {
      newSize -= 2;
    }
    return newSize;
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.maxWidth;
    final height = widget.maxHeight;

    final finalFontSize = _shrinkFontSize(_fontSize, width, height);
    final needsScroll = finalFontSize <= 12;

    return Container(
      constraints: BoxConstraints(
        minWidth: 100,
        minHeight: 60,
        maxWidth: width,
        maxHeight: height,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: widget.gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: needsScroll
          ? SingleChildScrollView(
              child: Text(
                widget.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: finalFontSize,
                  fontWeight: FontWeight.bold,
                  color: widget.textColor,
                ),
              ),
            )
          : Center(
              child: Text(
                widget.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: finalFontSize,
                  fontWeight: FontWeight.bold,
                  color: widget.textColor,
                ),
              ),
            ),
    );
  }
}
