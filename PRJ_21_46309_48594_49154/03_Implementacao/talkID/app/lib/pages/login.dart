import 'package:flutter/material.dart';
import 'package:talk_id/responsive/pages/mobile_login.dart';
import 'package:talk_id/responsive/responsive_layout.dart';
import '../responsive/pages/tablet_login.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      body: ResponsiveLayout(
        mobileBody: MobileLoginPage(),
        tabletBody: TabletLoginPage(),
        desktopBody: Scaffold(),),
    );
  }

}