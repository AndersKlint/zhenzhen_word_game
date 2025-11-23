import 'package:flutter/material.dart';

PreferredSizeWidget buildAppBar(BuildContext context, String title) {
  return AppBar(
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
    surfaceTintColor: Colors.transparent, // removes Material blur overlay
    centerTitle: true,
    leading: Navigator.canPop(context)
        ? IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          )
        : null,
  );
}
