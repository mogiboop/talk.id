import 'package:flutter/material.dart';
import 'package:talk_id/l10n/l10n.dart';
import 'package:talk_id/provider/language_provider.dart';
import 'package:provider/provider.dart';

class LanguagePickerWidget extends StatefulWidget {
  const LanguagePickerWidget({super.key});

  @override
  State<StatefulWidget> createState() => _LanguagePickerWidgetState();
}

class _LanguagePickerWidgetState extends State<LanguagePickerWidget> {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<LanguageProvider>(context, listen: false);
    TextTheme textTheme = Theme.of(context).textTheme;
    return PopupMenuButton<String>(
        initialValue: provider.locale.countryCode,
        padding: const EdgeInsets.only(right: 20),
        onSelected: (countryCode) {
          provider.updateLanguage(Locale(countryCode));
          setState(() {});
        },
        itemBuilder: (context) {
          return L10n.all.map((locale) {
            String countryName = L10n.getCountryName(locale.languageCode);
            String countryFlag = L10n.getFlag(locale.languageCode);
            return PopupMenuItem<String>(
                value: locale.languageCode,
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(countryName, style: textTheme.titleLarge),
                      Text(
                        countryFlag,
                        style: const TextStyle(fontSize: 24.0),
                      ),
                    ],
                  ),
                ));
          }).toList();
        },
        child: Center(
          child: Text(
            L10n.getFlag(provider.locale.languageCode),
            style: const TextStyle(fontSize: 36.0),
          ),
        ));
  }
}
