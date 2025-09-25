import 'dart:async';
import 'dart:convert';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:talk_id/pages/problems.dart';
import 'package:talk_id/utils/utils.dart';

class MobileItchPage extends StatefulWidget {
  const MobileItchPage({super.key});

  @override
  State<StatefulWidget> createState() => _MobileItchPageState();
}

class _MobileItchPageState extends State<MobileItchPage> {
  final GlobalKey _svgKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  Timer? _overlayTimer;
  List<CustomCircle> tapZones = [];

  Offset? _tapPosition;
  Color _circleColor = Colors.green;
  double _radius = 20.0;
  Offset? topLeft;
  double? svgWidth, svgHeight;

  @override
  Widget build(BuildContext context) {
    TextTheme _textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double appBarHeight = AppBar().preferredSize.height;
    final double bodyHeight = screenHeight - statusBarHeight - appBarHeight;

    const double scaleX = imgHeight / imgWidth;
    const double scaleY = imgWidth / imgHeight;
    double? newImgWidth, newImgHeight;
    newImgWidth = screenWidth;
    newImgHeight = scaleX * screenWidth;
    if (newImgHeight > screenHeight) {
      newImgHeight = bodyHeight;
      newImgWidth = scaleY * bodyHeight;
    }
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)?.itch ?? '',
          style: _textTheme.headlineMedium,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).iconTheme.color,
          onPressed: () => {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProblemsPage()),
            ),
          },
        ),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            newImgWidth = screenWidth;
            newImgHeight = imgHeight * screenWidth / imgWidth;
            return Column(
              children: [
                Container(
                  width: newImgWidth,
                  height: newImgHeight,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTapDown: (TapDownDetails details) {
                          _tapPosition = details.localPosition;
                          if (_tapPosition!.dx >= 0 &&
                              _tapPosition!.dy >= 0 &&
                              _tapPosition!.dx <= newImgWidth! &&
                              _tapPosition!.dy <= newImgHeight!) {
                            tapZones.add(CustomCircle(
                                _tapPosition!, _radius, _circleColor));
                            setState(() {});
                          } else {
                            setState(() {
                              _tapPosition = null;
                            });
                          }
                        },
                        child: SvgPicture.asset(
                          'assets/Muscles_front_and_back.svg',
                          semanticsLabel: 'Your SVG Image',
                          key: _svgKey,
                          width: newImgWidth,
                          height: newImgHeight,
                        ),
                      ),
                      if (tapZones.isNotEmpty)
                        ...tapZones.map((data) {
                          return Positioned(
                            top: data.pos.dy - data.radius,
                            left: data.pos.dx - data.radius,
                            child: CustomPaint(
                              size: Size(data.radius * 2, data.radius * 2),
                              painter: CirclePainter(color: _circleColor),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 60, left: 10, right: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              showColorPicker();
                            },
                            child: const Center(
                                child: Icon(
                              Icons.palette,
                              size: 28,
                            )),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '${AppLocalizations.of(context)?.radius ?? ''}: $_radius',
                                  style: _textTheme.titleSmall,
                                ),
                                Slider(
                                  value: _radius,
                                  min: 0,
                                  max: 100,
                                  divisions: 100,
                                  onChanged: (value) {
                                    setState(() {
                                      _radius = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (tapZones.isNotEmpty) {
                                tapZones.removeLast();
                              }
                              setState(() {});
                            },
                            icon: const Icon(Icons.remove_circle),
                            label: Text(
                                AppLocalizations.of(context)?.remove ?? ''),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (tapZones.isNotEmpty) {
                            var response =
                                await sendMessage(3, "I have itching", null);
                            if (response.statusCode == 201) {
                              var id = jsonDecode(response.body)["msgID"];
                              response = await sendMessageCoordinates(
                                  id, newImgWidth!, newImgHeight!, tapZones);
                              if (response.statusCode == 201) {
                                showOverlay(context);
                                tapZones.clear();
                              }
                            }
                          } else {
                            msgErrorPopUp(context, "comichão");
                          }
                          setState(() {});
                        },
                        icon: const Icon(Icons.send),
                        label: Text(AppLocalizations.of(context)?.send ?? ''),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            newImgHeight = bodyHeight;
            newImgWidth = imgWidth * bodyHeight / imgHeight;
            return Row(
              children: [
                Container(
                  width: newImgWidth,
                  height: newImgHeight,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTapDown: (TapDownDetails details) {
                          _tapPosition = details.localPosition;
                          if (_tapPosition!.dx >= 0 &&
                              _tapPosition!.dy >= 0 &&
                              _tapPosition!.dx <= newImgWidth! &&
                              _tapPosition!.dy <= newImgHeight!) {
                            tapZones.add(CustomCircle(
                                _tapPosition!, _radius, _circleColor));
                            setState(() {});
                          } else {
                            setState(() {
                              _tapPosition = null;
                            });
                          }
                        },
                        child: SvgPicture.asset(
                          'assets/Muscles_front_and_back.svg',
                          semanticsLabel: 'Your SVG Image',
                          key: _svgKey,
                          width: newImgWidth,
                          height: newImgHeight,
                        ),
                      ),
                      if (tapZones.isNotEmpty)
                        ...tapZones.map((data) {
                          return Positioned(
                            top: data.pos.dy - data.radius,
                            left: data.pos.dx - data.radius,
                            child: CustomPaint(
                              size: Size(data.radius * 2, data.radius * 2),
                              painter: CirclePainter(color: _circleColor),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            showColorPicker();
                          },
                          child: const Center(
                              child: Icon(
                            Icons.palette,
                            size: 28,
                          )),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${AppLocalizations.of(context)?.radius ?? ''}: $_radius',
                          style: _textTheme.titleSmall,
                        ),
                        Slider(
                          value: _radius,
                          min: 0,
                          max: 100,
                          divisions: 100,
                          onChanged: (value) {
                            setState(() {
                              _radius = value;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            tapZones.removeLast();
                            setState(() {});
                          },
                          icon: const Icon(Icons.remove_circle),
                          label:
                              Text(AppLocalizations.of(context)?.remove ?? ''),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (tapZones.isNotEmpty) {
                              var response =
                                  await sendMessage(3, "I have itching", null);
                              if (response.statusCode == 201) {
                                var id = jsonDecode(response.body)["msgID"];
                                response = await sendMessageCoordinates(
                                    id, newImgWidth!, newImgHeight!, tapZones);
                                if (response.statusCode == 201) {
                                  showOverlay(context);
                                  tapZones.clear();
                                }
                              }
                            } else {
                              msgErrorPopUp(context, "comichão");
                            }
                            setState(() {});
                          },
                          icon: const Icon(Icons.send),
                          label: Text(AppLocalizations.of(context)?.send ?? ''),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
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
      notificationSize = Size(screenSize.width / 3.2, bodyHeight / 12);
    } else {
      notificationSize =
          Size(screenSize.width / 5 + screenSize.width / 8, bodyHeight / 8);
    }
    final double rightPosition = screenSize.width - notificationSize.width;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top,
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
              style: textTheme.titleSmall,
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

  void showColorPicker() {
    TextTheme _textTheme = Theme.of(context).textTheme;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              AppLocalizations.of(context)?.pickColor ?? '',
              style: _textTheme.titleLarge,
            ),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickersEnabled: const <ColorPickerType, bool>{
                  ColorPickerType.wheel: true,
                },
                enableShadesSelection: true,
                borderColor: const Color(0xff443a49),
                onColorChangeStart: (value) => _circleColor,
                onColorChanged: (Color value) {
                  _circleColor = value;
                  setState(() {});
                },
              ),
            ),
          );
        });
  }
}
