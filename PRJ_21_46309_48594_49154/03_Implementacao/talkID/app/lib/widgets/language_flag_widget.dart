import 'package:flutter/material.dart';
import 'package:talk_id/l10n/l10n.dart';
import 'package:talk_id/provider/language_provider.dart';
import 'package:provider/provider.dart';

class LanguageFlagWidget extends StatelessWidget {
  const LanguageFlagWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, value, child) => Center(
        child: Text(
          L10n.getFlag(value.locale.languageCode),
          style: const TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
