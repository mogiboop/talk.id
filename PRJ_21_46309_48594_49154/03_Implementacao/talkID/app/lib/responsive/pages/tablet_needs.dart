import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:talk_id/pages/home.dart';
import 'package:talk_id/responsive/pages/tablet_tts_pop_up.dart';
import 'package:talk_id/utils/boxdata.dart';
import 'package:talk_id/utils/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TabletNeedsPage extends StatefulWidget {
  const TabletNeedsPage({super.key});

  @override
  State<StatefulWidget> createState() => _TabletNeedsPageState();
}

class _TabletNeedsPageState extends State<TabletNeedsPage> {
  OverlayEntry? _overlayEntry;
  Timer? _overlayTimer;
  bool showTime = false;
  final Map<String, String> englishPositions = {
    'fowlerPosition': 'Fowler Position',
    'lateralPosition': 'Lateral Position',
    'pronePosition': 'Prone Position',
    'supinePosition': 'Supine Position',
  };

  @override
  Widget build(BuildContext context) {
    final List<BoxData> boxDataList = [
      BoxData(
          icon: Icons.access_time,
          text: AppLocalizations.of(context)?.time ?? ''),
      BoxData(
          icon: Icons.restaurant,
          text: AppLocalizations.of(context)?.hunger ?? ''),
      BoxData(
          icon: Icons.local_drink,
          text: AppLocalizations.of(context)?.thirst ?? ''),
      BoxData(icon: Icons.wc, text: AppLocalizations.of(context)?.toilet ?? ''),
      BoxData(
          icon: Icons.airline_seat_individual_suite,
          text: AppLocalizations.of(context)?.changePosition ?? ''),
      BoxData(
          icon: Icons.contacts,
          text: AppLocalizations.of(context)?.contactFamily ?? ''),
    ];
    final timeFormatter = DateFormat('HH:mm');
    TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)?.needs ?? '',
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
            crossAxisCount = 4;
            margin = const EdgeInsets.all(20);
            iconSize = 64;
          }
          return Center(
            child: GridView.count(
              shrinkWrap: true,
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
                    child: index == 0
                        ? showTime
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    timeFormatter.format(DateTime.now()),
                                    style: textTheme.displaySmall,
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    boxData.icon,
                                    size: iconSize,
                                    //color: Colors.blue,
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    boxData.text,
                                    textAlign: TextAlign.center,
                                    style: textTheme.displaySmall,
                                  ),
                                ],
                              )
                        : Column(
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
            right: 100.0,
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

  Future<void> _handleInkWellTap(BuildContext context, int index) async {
    switch (index) {
      case 0:
        showTime = !showTime;
        setState(() {});
        break;
      case 1:
        var response = await sendMessage(2, "I am hungry", null);
        if (response.statusCode == 201) {
          showOverlay(context);
        }
        break;
      case 2:
        var response = await sendMessage(2, "I am thirsty", null);
        if (response.statusCode == 201) {
          showOverlay(context);
        }
        break;
      case 3:
        var response = await sendMessage(2, "I need to go to the bathroom", null);
        if (response.statusCode == 201) {
          showOverlay(context);
        }
        break;
      case 4:
        _showBedPosDialog(context, (String selectedPosition) async {
          var response = await sendMessage(
              2, "I would like to change the position to:  $selectedPosition", null);
          if (response.statusCode == 201) {
            showOverlay(context);
          }
        });
        break;
      case 5:
        var response = await sendMessage(
            2, "I would like to contact my family", null);
        if (response.statusCode == 201) {
          showOverlay(context);
        }
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
            decoration: BoxDecoration(
              border: Border.all(
                  color: Theme.of(context).colorScheme.outline, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
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

  void _showBedPosDialog(BuildContext context, Function(String) onSelected) {
    List<Widget> childs = [
      buildBedPosItem(
          'assets/fowler.png',
          AppLocalizations.of(context)?.fowlerPosition ?? '',
          englishPositions['fowlerPosition']!,
          context,
          onSelected),
      buildBedPosItem(
          'assets/lateral.png',
          AppLocalizations.of(context)?.lateralPosition ?? '',
          englishPositions['lateralPosition']!,
          context,
          onSelected),
      buildBedPosItem(
          'assets/prone.png',
          AppLocalizations.of(context)?.pronePosition ?? '',
          englishPositions['pronePosition']!,
          context,
          onSelected),
      buildBedPosItem(
          'assets/supine.png',
          AppLocalizations.of(context)?.supinePosition ?? '',
          englishPositions['supinePosition']!,
          context,
          onSelected),
    ];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alertDialog(context,
            AppLocalizations.of(context)?.selectPosition ?? '', childs);
      },
    );
  }
}
