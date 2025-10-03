import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:talk_id/provider/language_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MobileComKeyboardPage extends StatefulWidget {
  const MobileComKeyboardPage({super.key});

  @override
  State<StatefulWidget> createState() => MobileComKeyboardPageState();

  static void speak(String text, String language) {
    FlutterTts flutterTts = FlutterTts();
    flutterTts.setLanguage(language == 'en' ? 'en-Uk' : 'pt-PT');
    flutterTts.speak(text);
  }
}

enum TtsState { playing, stopped, paused, continued }

class MobileComKeyboardPageState extends State<MobileComKeyboardPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isFocused = false;
  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 1.0;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  String? _newVoiceText;
  int? _inputLength;

  TtsState ttsState = TtsState.stopped;

  bool get isPlaying => ttsState == TtsState.playing;
  bool get isStopped => ttsState == TtsState.stopped;
  bool get isPaused => ttsState == TtsState.paused;
  bool get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isWeb => kIsWeb;

  @override
  initState() {
    super.initState();
    initTts();
    _initializeLanguage();
  }

  void _initializeLanguage() {
    var provider = Provider.of<LanguageProvider>(context, listen: false);
    language = provider.locale.languageCode;
    flutterTts.setLanguage(language!);
    if (isAndroid) {
      flutterTts
          .isLanguageInstalled(language!)
          .then((value) => isCurrentLanguageInstalled = value);
    }
  }

  dynamic initTts() {
    flutterTts = FlutterTts();
    _setAwaitOptions();

    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setPauseHandler(() {
      setState(() {
        print("Paused");
        ttsState = TtsState.paused;
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
        print("Continued");
        ttsState = TtsState.continued;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future<dynamic> _getLanguages() async => await flutterTts.getLanguages;

  Future<dynamic> _getEngines() async => await flutterTts.getEngines;

  Future<void> _setSettings() async {
    Future<dynamic> engines = _getEngines();
  }

  Future<void> _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future<void> _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  Future<void> _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (language == 'pt') {
      await flutterTts.setLanguage('pt-PT');
    } else {
      await flutterTts.setLanguage(language!);
    }

    if (_newVoiceText != null) {
      // print("Text to speak: $_newVoiceText");
      if (_newVoiceText!.isNotEmpty) {
        // print("Speaking...");
        await flutterTts.speak(_newVoiceText!);
      }
    }
  }

  Future<void> _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future<void> _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems(
      List<Locale> locales) {
    var items = <DropdownMenuItem<String>>[];
    for (var locale in locales) {
      items.add(DropdownMenuItem(
        value: locale.languageCode,
        child: Text(locale.languageCode),
      ));
    }
    return items;
  }

  void changedLanguageDropDownItem(String? selectedType) {
    setState(() {
      language = selectedType;
      flutterTts.setLanguage(language!);
      if (isAndroid) {
        flutterTts
            .isLanguageInstalled(language!)
            .then((value) => isCurrentLanguageInstalled = value);
      }
    });
  }

  void _onChange(String text) {
    setState(() {
      _newVoiceText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextTheme _textTheme = Theme.of(context).textTheme;
    InputDecorationTheme _inputDecorationTheme =
        Theme.of(context).inputDecorationTheme;

    var provider = Provider.of<LanguageProvider>(context, listen: false);

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      right: 8,
                      left: 8,
                    ),
                    child: TextField(
                      minLines: 1,
                      maxLines: null,
                      controller: _controller,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 20.0),
                        labelStyle: _inputDecorationTheme.labelStyle,
                        icon: const Icon(
                          Icons.record_voice_over,
                          size: 36,
                        ),
                        hintText: AppLocalizations.of(context)
                            ?.hintKeyboardPageTextInput ??
                            '',
                      ),
                      onChanged: (String value) {
                        setState(() {
                          _onChange(value);
                        });
                      },
                      onTap: () {
                        setState(() {
                          _isFocused = true;
                        });
                      },
                      onSubmitted: (value) {
                        setState(() {
                          _isFocused = false;
                        });
                      },
                      onEditingComplete: () {
                        setState(() {
                          _isFocused = false;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _languageDropDownSection(provider.availableLocales),
            const SizedBox(height: 10),
            _btnSection(),
            const SizedBox(height: 10),
            _buildSliders(_textTheme),
          ],
        ),
      ),
    );
  }

  Widget _languageDropDownSection(List<Locale> languages) => Container(
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        DropdownButton(
          value: language,
          items: getLanguageDropDownMenuItems(languages),
          onChanged: changedLanguageDropDownItem,
        ),
      ]));

  Widget _btnSection() {
    return Container(
      padding: const EdgeInsets.only(top: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButtonColumn(Colors.green, Colors.greenAccent, Icons.play_arrow,
              AppLocalizations.of(context)?.play ?? '', _speak),
          _buildButtonColumn(Colors.red, Colors.redAccent, Icons.stop,
              AppLocalizations.of(context)?.stop ?? '', _stop),
          _buildButtonColumn(Colors.blue, Colors.blueAccent, Icons.pause,
              AppLocalizations.of(context)?.pause ?? '', _pause),
        ],
      ),
    );
  }

  Column _buildButtonColumn(Color color, Color splashColor, IconData icon,
      String label, Function func) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              icon: Icon(icon),
              iconSize: 42,
              color: color,
              splashColor: splashColor,
              onPressed: () => func()),
          Container(
              margin: const EdgeInsets.only(top: 8.0),
              child: Text(label,
                  style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w400,
                      color: color)))
        ]);
  }

  Widget _buildSliders(TextTheme _textTheme) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)?.pitch ?? '',
          style: _textTheme.titleLarge,
        ),
        _pitch(),
        Text(
          AppLocalizations.of(context)?.speed ?? '',
          style: _textTheme.titleLarge,
        ),
        _rate()
      ],
    );
  }

  Widget _volume() {
    return Slider(
        value: volume,
        onChanged: (newVolume) {
          setState(() => volume = newVolume);
        },
        min: 0.0,
        max: 1.0,
        divisions: 10,
        label: "${AppLocalizations.of(context)?.volume ?? ''}: $volume");
  }

  Widget _pitch() {
    return Slider(
      value: pitch,
      onChanged: (newPitch) {
        setState(() => pitch = newPitch);
      },
      min: 0.5,
      max: 2.0,
      divisions: 15,
      label: "${AppLocalizations.of(context)?.pitch ?? ''}: $pitch",
      activeColor: Colors.orange,
    );
  }

  Widget _rate() {
    return Slider(
      value: rate,
      onChanged: (newRate) {
        setState(() => rate = newRate);
      },
      min: 0.0,
      max: 1.0,
      divisions: 10,
      label: "${AppLocalizations.of(context)?.rate ?? ''}: $rate",
      activeColor: Colors.cyan,
    );
  }
}

