import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:talk_id/responsive/pages/mobile_com_keyboard.dart';

class MobileTtsPopup {
  static void show(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.background,
            title: Text(
              AppLocalizations.of(context)?.textToSpeech ?? '',
              style: textTheme.displaySmall,
            ),
            content: const MobileComKeyboardPage(),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context)?.close ?? ''),
              ),
            ],
          ),
        );
      },
    );
  }
}
