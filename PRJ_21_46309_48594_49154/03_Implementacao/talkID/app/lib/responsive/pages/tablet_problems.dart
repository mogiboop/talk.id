import 'dart:async';
import 'package:flutter/material.dart';
import 'package:talk_id/pages/home.dart';
import 'package:talk_id/pages/itch.dart';
import 'package:talk_id/pages/pain.dart';
import 'package:talk_id/responsive/pages/tablet_tts_pop_up.dart';
import 'package:talk_id/utils/boxdata.dart';
import 'package:talk_id/utils/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TabletProblemsPage extends StatefulWidget {
  const TabletProblemsPage({super.key});

  @override
  State<StatefulWidget> createState() => _TabletProblemsPageState();
}

class _TabletProblemsPageState extends State<TabletProblemsPage> {
  OverlayEntry? _overlayEntry;
  Timer? _overlayTimer;
  bool showTime = false;
  final Map<String, String> englishBreathing = {
    'aspirate': 'Nasal aspirator',
    'cannula': 'Clean the cannula',
  };

  @override
  Widget build(BuildContext context) {
    final List<BoxData> boxDataList = [
      BoxData(
          icon: Icons.air,
          text: AppLocalizations.of(context)?.difficultyBreathing ?? ''),
      BoxData(
          icon: Icons.mood_bad, text: AppLocalizations.of(context)?.pain ?? ''),
      BoxData(icon: Icons.spa, text: AppLocalizations.of(context)?.itch ?? ''),
    ];
    TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)?.problems ?? '',
          style: textTheme.displayMedium,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).iconTheme.color,
          onPressed: () => {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            ),
          },
        ),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          int crossAxisCount = 0;
          EdgeInsetsGeometry margin = const EdgeInsets.all(0);
          double iconSize = 0;
          if (orientation == Orientation.portrait) {
            crossAxisCount = 2;
            margin = const EdgeInsets.all(30);
            iconSize = 80;
          } else {
            crossAxisCount = 3;
            margin = const EdgeInsets.all(20);
            iconSize = 64;
          }
          crossAxisCount = crossAxisCount > boxDataList.length
              ? boxDataList.length
              : crossAxisCount;
          return Center(
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              children: List.generate(boxDataList.length, (index) {
                BoxData boxData = boxDataList[index];
                return InkWell(
                  onTap: () {
                    _handleInkWellTap(context, index);
                  },
                  child: Container(
                    margin: margin,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.shadow,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          boxData.icon,
                          size: iconSize,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          boxData.text,
                          textAlign: TextAlign.center,
                          style: textTheme.displaySmall,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
      floatingActionButton: Stack(
        children: [
          const Positioned(
            bottom: 10.0,
            left: 40.0,
            child: FloatingActionButton(
              heroTag: "SOS",
              onPressed: sendSOS,
              child: Icon(Icons.sos),
            ),
          ),
          Positioned(
            bottom: 10.0,
            right: 10.0,
            child: FloatingActionButton(
              heroTag: "TTS",
              onPressed: () {
                TabletTtsPopup.show(context);
              },
              child: const Icon(Icons.record_voice_over),
            ),
          ),
        ],
      ),
    );
  }

  void _handleInkWellTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        _showBreathingDialog((String selectedOption) async {
          var response = await sendMessage(
              3, "Difficulties in breathing: $selectedOption", null);
          if (response.statusCode == 201) {
            showOverlay(context);
          }
        });
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PainPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ItchPage()),
        );
        break;
    }
  }

  void showOverlay(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _overlayTimer?.cancel();
    }
    final screenSize = MediaQuery.of(context).size;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double? appBarHeight = Scaffold.of(context).appBarMaxHeight;
    final double bodyStartHeight = statusBarHeight + appBarHeight!;
    final bodyHeight = screenSize.height - bodyStartHeight;
    Size notificationSize = Size.zero;
    if (screenSize.width < bodyHeight) {
      notificationSize = Size(screenSize.width / 3, bodyHeight / 20);
    } else {
      notificationSize =
          Size(screenSize.width / 5 + screenSize.width / 8, bodyHeight / 13);
    }
    final double topPosition = bodyStartHeight;
    final double rightPosition = screenSize.width - notificationSize.width;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: topPosition,
        left: rightPosition,
        child: Material(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: notificationSize.width,
            height: notificationSize.height,
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: Text(
              AppLocalizations.of(context)?.messageSent ?? '',
              style: textTheme.titleLarge,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    _overlayTimer = Timer(const Duration(seconds: 3), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  void _showBreathingDialog(Function(String) onSelected) {
    List<Widget> childs = [
      buildDifficultyBreathingItem(
          AppLocalizations.of(context)?.aspirate ?? '', englishBreathing['aspirate']!, context, onSelected),
      buildDifficultyBreathingItem(
          AppLocalizations.of(context)?.cannula ?? '', englishBreathing['cannula']!, context, onSelected)
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alertDialog(
            context, AppLocalizations.of(context)?.selectOption ?? '', childs);
      },
    );
  }
}
