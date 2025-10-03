import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talk_id/pages/questions_answers.dart';
import 'package:talk_id/responsive/pages/tablet_com_keyboard.dart';
import 'package:talk_id/responsive/pages/tablet_tts_pop_up.dart';
import 'package:talk_id/utils/boxdata.dart';
import 'package:talk_id/utils/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TabletQuickChatPage extends StatefulWidget {
  const TabletQuickChatPage({super.key});

  @override
  State<StatefulWidget> createState() => _TabletQuickChatPageState();
}

class _TabletQuickChatPageState extends State<TabletQuickChatPage> {
  List<String> customGreetings = [];
  List<String> customAnswers = [];
  List<String> customQuestions = [];
  List<Map<String, dynamic>> customCategories = [];
  final secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadGreetings();
    _loadAnswers();
    _loadQuestions();
    _loadCustomCategories();
  }

  Future<void> _saveCustomCategories() async {
    String? token = await getToken();
    if (token == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String customCategoriesString = json.encode(customCategories);
    await prefs.setString('${token}_customCategories', customCategoriesString);
  }

  Future<void> _saveGreetings() async {
    String? token = await getToken();
    if (token == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('${token}_customGreetings', customGreetings);
  }

  Future<void> _saveAnswers() async {
    String? token = await getToken();
    if (token == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('${token}_customAnswers', customAnswers);
  }

  Future<void> _saveQuestions() async {
    String? token = await getToken();
    if (token == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('${token}_customQuestions', customQuestions);
  }

  Future<void> _loadCustomCategories() async {
    String? token = await getToken();
    if (token == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? customCategoriesString =
    prefs.getString('${token}_customCategories');
    if (customCategoriesString != null) {
      setState(() {
        customCategories = (json.decode(customCategoriesString) as List)
            .map((e) => (e as Map<String, dynamic>).map(
                (k, v) => MapEntry(k, v is List ? List<String>.from(v) : v)))
            .toList();
      });
    }
  }

  Future<void> _loadGreetings() async {
    String? token = await getToken();
    if (token == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      customGreetings = prefs.getStringList('${token}_customGreetings') ?? [];
    });
  }

  Future<void> _loadAnswers() async {
    String? token = await getToken();
    if (token == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      customAnswers = prefs.getStringList('${token}_customAnswers') ?? [];
    });
  }

  Future<void> _loadQuestions() async {
    String? token = await getToken();
    if (token == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      customQuestions = prefs.getStringList('${token}_customQuestions') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<BoxData> boxDataList = [
      BoxData(
          icon: Icons.emoji_people,
          text: AppLocalizations.of(context)?.greetings ?? ''),
      BoxData(
          icon: Icons.chat_rounded,
          text: AppLocalizations.of(context)?.answers ?? ''),
      BoxData(
          icon: Icons.question_mark_outlined,
          text: AppLocalizations.of(context)?.questions ?? ''),
      BoxData(
          icon: Icons.add,
          text: AppLocalizations.of(context)?.addNewCategory ?? ''),
    ];

    for (var category in customCategories) {
      boxDataList.add(
          BoxData(icon: Icons.category, text: category['title'] as String));
    }

    TextTheme _textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.background,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)?.quickChat ?? '',
          style: _textTheme.displayMedium,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).iconTheme.color,
          onPressed: () => {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QAPage()),
            ),
          },
        ),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          int crossAxisCount = orientation == Orientation.portrait ? 2 : 4;
          EdgeInsetsGeometry margin = orientation == Orientation.portrait
              ? const EdgeInsets.all(30)
              : const EdgeInsets.all(20);
          double iconSize = orientation == Orientation.portrait ? 80 : 64;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100.0),
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: crossAxisCount,
                children: List.generate(boxDataList.length, (index) {
                  BoxData boxData = boxDataList[index];
                  return InkWell(
                    onTap: () {
                      _handleInkWellTap(index);
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
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          );
        },
      ),
      floatingActionButton: Stack(
        children: [
          const Positioned(
            bottom: 0.0,
            left: 40.0,
            child: FloatingActionButton(
              heroTag: 'SOS',
              onPressed: sendSOS,
              child: Icon(Icons.sos),
            ),
          ),
          Positioned(
            bottom: 0.0,
            right: 10.0,
            child: FloatingActionButton(
              heroTag: 'TTS',
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

  Future<void> _handleInkWellTap(int index) async {
    if (index < 4) {
      switch (index) {
        case 0:
          _showGreetsDialog();
          break;
        case 1:
          _showAnswersDialog();
          break;
        case 2:
          _showQuestionsDialog();
          break;
        case 3:
          _showAddCategoryDialog();
          break;
        default:
          print('InkWell at index $index tapped');
      }
    } else {
      _showCustomCategoryDialog(customCategories[index - 4]);
    }
  }

  void _speakOption(String text) {
    final languageCode = Localizations.localeOf(context).languageCode;
    TabletComKeyboardPage.speak(text, languageCode);
  }

  Widget buildAddOptionItem(
      BuildContext context, Map<String, dynamic> category) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Center(
      child: ListTile(
        title: Text(
          AppLocalizations.of(context)?.addOption ?? 'Add Option',
          style: textTheme.titleLarge?.copyWith(color: Colors.blue),
        ),
        onTap: () {
          Navigator.of(context).pop();
          _showAddOptionDialog(context, category);
        },
      ),
    );
  }

  void _showAddOptionDialog(
      BuildContext context, Map<String, dynamic> category) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.addOption ?? 'Add Option'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText:
              AppLocalizations.of(context)?.enterOption ?? 'Enter option',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  (category['options'] as List<String>).add(controller.text);
                  _saveCustomCategories();
                });
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)?.add ?? 'Add'),
            ),
          ],
        );
      },
    );
  }

  void _showGreetsDialog() {
    List<Widget> childs = [
      buildItem(AppLocalizations.of(context)?.hello ?? '', context, () {
        setState(() {
          customGreetings.remove(AppLocalizations.of(context)?.hello ?? '');
          _saveGreetings();
        });
      }),
      buildItem(AppLocalizations.of(context)?.hi ?? '', context, () {
        setState(() {
          customGreetings.remove(AppLocalizations.of(context)?.hi ?? '');
          _saveGreetings();
        });
      }),
      buildItem(AppLocalizations.of(context)?.greetings ?? '', context, () {
        setState(() {
          customGreetings.remove(AppLocalizations.of(context)?.greetings ?? '');
          _saveGreetings();
        });
      }),
      ...customGreetings
          .map((greeting) => buildItem(greeting, context, () {
        setState(() {
          customGreetings.remove(greeting);
          _saveGreetings();
        });
      }))
          .toList(),
      buildAddItem(context),
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alertDialog(
            context, AppLocalizations.of(context)?.selectOption ?? '', childs);
      },
    );
  }

  Widget buildAddItem(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Center(
      child: ListTile(
        title: Text(
          AppLocalizations.of(context)?.addGreeting ?? 'Add Greeting',
          style: textTheme.titleLarge?.copyWith(color: Colors.blue),
        ),
        onTap: () {
          Navigator.of(context).pop();
          _showAddGreetingDialog(context);
        },
      ),
    );
  }

  void _showAddGreetingDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
          Text(AppLocalizations.of(context)?.addGreeting ?? 'Add Greeting'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)?.enterGreeting ??
                  'Enter greeting',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  customGreetings.add(controller.text);
                  _saveGreetings();
                });
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)?.add ?? 'Add'),
            ),
          ],
        );
      },
    );
  }

  void _showAnswersDialog() {
    List<Widget> childs = [
      buildItem(AppLocalizations.of(context)?.cool ?? '', context, () {
        setState(() {
          customAnswers.remove(AppLocalizations.of(context)?.cool ?? '');
          _saveAnswers();
        });
      }),
      buildItem(AppLocalizations.of(context)?.ok ?? '', context, () {
        setState(() {
          customAnswers.remove(AppLocalizations.of(context)?.ok ?? '');
          _saveAnswers();
        });
      }),
      buildItem(AppLocalizations.of(context)?.maybe ?? '', context, () {
        setState(() {
          customAnswers.remove(AppLocalizations.of(context)?.maybe ?? '');
          _saveAnswers();
        });
      }),
      ...customAnswers
          .map((answer) => buildItem(answer, context, () {
        setState(() {
          customAnswers.remove(answer);
          _saveAnswers();
        });
      }))
          .toList(),
      buildAddAnswerItem(context),
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alertDialog(
            context, AppLocalizations.of(context)?.selectOption ?? '', childs);
      },
    );
  }

  Widget buildAddAnswerItem(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Center(
      child: ListTile(
        title: Text(
          AppLocalizations.of(context)?.addAnswer ?? 'Add Answer',
          style: textTheme.titleLarge?.copyWith(color: Colors.blue),
        ),
        onTap: () {
          Navigator.of(context).pop();
          _showAddAnswerDialog(context);
        },
      ),
    );
  }

  void _showAddAnswerDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.addAnswer ?? 'Add Answer'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText:
              AppLocalizations.of(context)?.enterAnswer ?? 'Enter answer',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  customAnswers.add(controller.text);
                  _saveAnswers();
                });
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)?.add ?? 'Add'),
            ),
          ],
        );
      },
    );
  }

  Widget buildItem(String text, BuildContext context, Function onDelete) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Center(
      child: ListTile(
        title: Text(
          text,
          style: textTheme.titleLarge,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            onDelete();
            Navigator.of(context).pop();
          },
        ),
        onTap: () {
          Navigator.of(context).pop();
          _speakOption(text);
        },
      ),
    );
  }

  void _showQuestionsDialog() {
    List<Widget> childs = [
      buildItem(AppLocalizations.of(context)?.howAreYou ?? '', context, () {
        setState(() {
          customQuestions.remove(AppLocalizations.of(context)?.howAreYou ?? '');
          _saveQuestions();
        });
      }),
      buildItem(AppLocalizations.of(context)?.why ?? '', context, () {
        setState(() {
          customQuestions.remove(AppLocalizations.of(context)?.why ?? '');
          _saveQuestions();
        });
      }),
      buildItem(AppLocalizations.of(context)?.what ?? '', context, () {
        setState(() {
          customQuestions.remove(AppLocalizations.of(context)?.what ?? '');
          _saveQuestions();
        });
      }),
      ...customQuestions
          .map((question) => buildItem(question, context, () {
        setState(() {
          customQuestions.remove(question);
          _saveQuestions();
        });
      }))
          .toList(),
      buildAddQuestionItem(context),
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alertDialog(
            context, AppLocalizations.of(context)?.selectOption ?? '', childs);
      },
    );
  }

  Widget buildAddQuestionItem(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Center(
      child: ListTile(
        title: Text(
          AppLocalizations.of(context)?.addQuestion ?? 'Add Question',
          style: textTheme.titleLarge?.copyWith(color: Colors.blue),
        ),
        onTap: () {
          Navigator.of(context).pop();
          _showAddQuestionDialog(context);
        },
      ),
    );
  }

  void _showAddQuestionDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
          Text(AppLocalizations.of(context)?.addQuestion ?? 'Add Question'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)?.enterQuestion ??
                  'Enter question',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  customQuestions.add(controller.text);
                  _saveQuestions();
                });
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)?.add ?? 'Add'),
            ),
          ],
        );
      },
    );
  }

  void _showCustomCategoryDialog(Map<String, dynamic> category) {
    List<Widget> childs = (category['options'] as List<dynamic>).map<Widget>((option) {
      if (option is String) {
        return buildItem(option, context, () {
          setState(() {
            (category['options'] as List<dynamic>).removeWhere((item) => item == option);
            _saveCustomCategories();
          });
        });
      } else {
        print('Warning: Unexpected non-string type encountered: $option');
        return SizedBox.shrink();
      }
    }).toList();

    childs.add(buildAddOptionItem(context, category));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              AppLocalizations.of(context)?.selectOption ?? 'Select Option'),
          content: SingleChildScrollView(
            child: ListBody(
              children: childs,
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddCategoryDialog() async {
    TextEditingController categoryController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
          Text(AppLocalizations.of(context)?.addCategory ?? 'Add Category'),
          content: TextField(
            controller: categoryController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)?.enterCategory ??
                  'Enter category',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  customCategories
                      .add({'title': categoryController.text, 'options': []});
                  _saveCustomCategories();
                });
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)?.add ?? 'Add'),
            ),
          ],
        );
      },
    );
  }
}