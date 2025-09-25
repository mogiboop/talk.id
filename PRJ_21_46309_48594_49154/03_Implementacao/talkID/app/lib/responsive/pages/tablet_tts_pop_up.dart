import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:talk_id/responsive/pages/tablet_com_keyboard.dart';

class TabletTtsPopup {
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
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.5,
              child: const TabletComKeyboardPage(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
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
