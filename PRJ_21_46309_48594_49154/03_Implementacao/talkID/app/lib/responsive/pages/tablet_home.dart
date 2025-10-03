import 'dart:async';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:talk_id/pages/gallery.dart';
import 'package:talk_id/pages/needs.dart';
import 'package:talk_id/pages/problems.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:talk_id/pages/questions_answers.dart';
import 'package:talk_id/responsive/pages/tablet_tts_pop_up.dart';
import 'package:talk_id/theme/theme_constants.dart';
import 'package:talk_id/utils/boxdata.dart';
import 'package:talk_id/theme/theme_manager.dart';
import 'package:talk_id/widgets/languages_picker_widget.dart';

import '../../pages/login.dart';
import '../../utils/utils.dart';

class TabletHomePage extends StatefulWidget {
  const TabletHomePage({super.key});

  @override
  State<StatefulWidget> createState() => _TabletHomePageState();
}

class _TabletHomePageState extends State<TabletHomePage> {
  OverlayEntry? _overlayEntry;
  Timer? _overlayTimer;
  late int _selectedIndex;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      if (index == 1) {
        PhotoManager.requestPermissionExtend()
            .then((PermissionState state) async {
          if (state.isAuth) {
            _selectedIndex = await Navigator.push(context,
                MaterialPageRoute(builder: (context) => const GalleryPage()));
            setState(() {});
          }
        });
      } else if (index == 2) {
        TabletTtsPopup.show(context);
        _selectedIndex = 0;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<BoxData> boxDataList = [
      BoxData(
          icon: Icons.sos_rounded,
          text: AppLocalizations.of(context)?.sos ?? ''),
      BoxData(icon: Icons.help, text: AppLocalizations.of(context)?.qA ?? ''),
      BoxData(
          icon: Icons.accessibility_new,
          text: AppLocalizations.of(context)?.needs ?? ''),
      BoxData(
          icon: Icons.notification_important,
          text: AppLocalizations.of(context)?.problems ?? ''),
    ];

    TextTheme _textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.background,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)?.title ?? '',
          style: _textTheme.displayMedium,
        ),
        leading: IconButton(
          icon: const Icon(Icons.logout),
          color: Theme.of(context).iconTheme.color,
          onPressed: () => {
            logout(),
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            ),
          },
        ),
        actions: [
          const Icon(Icons.light_mode),
          const SizedBox(
            width: 10,
          ),
          Switch(
              value: Provider.of<ThemeManager>(context).themeData == darkTheme,
              onChanged: (newValue) {
                Provider.of<ThemeManager>(context, listen: false).toggleTheme();
                setState(() {});
              }),
          const SizedBox(
            width: 20,
          ),
          const LanguagePickerWidget()
        ],
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
              physics:
                  const NeverScrollableScrollPhysics(), // Make GridView non-scrollable
              shrinkWrap: true,
              crossAxisCount: crossAxisCount,
              children: List.generate(boxDataList.length, (index) {
                // Access individual box data from the list
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
                      borderRadius: BorderRadius.circular(8.0),
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
                          style: _textTheme.displaySmall,
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
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppLocalizations.of(context)?.homePageName ?? '',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.photo_library),
            label: AppLocalizations.of(context)?.gallery ?? '',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.record_voice_over),
            label: AppLocalizations.of(context)?.comKeyboard ?? '',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
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

  Future<void> _handleInkWellTap(BuildContext context, int index) async {
    switch (index) {
      case 0:
        var response = await sendSOS();
        if (response.statusCode == 201) {
          showOverlay(context);
        }
        break;
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const QAPage()));
        break;
      case 2:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const NeedsPage()));
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProblemsPage()),
        );
        break;
      default:
        print('InkWell at index $index tapped');
    }
  }
}
