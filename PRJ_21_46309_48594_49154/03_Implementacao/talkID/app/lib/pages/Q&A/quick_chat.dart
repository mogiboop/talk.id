import 'package:flutter/material.dart';
import 'package:talk_id/responsive/pages/mobile_quick_chat.dart';
import 'package:talk_id/responsive/pages/tablet_quick_chat.dart';
import 'package:talk_id/responsive/responsive_layout.dart';

class QuickChatPage extends StatefulWidget {
  const QuickChatPage({super.key});

  @override
  State<StatefulWidget> createState() => _QuickChatPageState();
}

class _QuickChatPageState extends State<QuickChatPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      body: ResponsiveLayout(
        mobileBody: MobileQuickChatPage(),
        tabletBody: TabletQuickChatPage(),
        desktopBody: Scaffold(),
      ),
    );
  }
}
