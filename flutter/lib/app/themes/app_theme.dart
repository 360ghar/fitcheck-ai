import 'package:flutter/material.dart';

import '../../core/theme/paper_theme.dart';
import '../../core/theme/paper_tokens.dart';

/// App-level themes. Screens re-theme to their feature's paper stock with
/// `PaperStockScope`; the root uses stone.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme =>
      paperTheme(Brightness.light, PaperStockId.stone);

  static ThemeData get darkTheme =>
      paperTheme(Brightness.dark, PaperStockId.stone);
}
