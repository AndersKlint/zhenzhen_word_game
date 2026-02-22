import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

PreferredSizeWidget buildAppBar(
  BuildContext context,
  String title, {
  AppTheme? theme,
}) {
  final textColor = theme?.primaryTextColor ?? const Color(0xDD000000);
  return AppBar(
    title: Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    centerTitle: true,
    leading: Navigator.canPop(context)
        ? IconButton(
            icon: Icon(Icons.arrow_back, color: textColor),
            onPressed: () => Navigator.pop(context),
          )
        : null,
  );
}
