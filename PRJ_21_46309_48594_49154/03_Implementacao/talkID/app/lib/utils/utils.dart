import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const mobileWidth = 500;
const tabletWidth = 1100;

const int imgWidth = 1442;
const int imgHeight = 1256;

const secureStorage = FlutterSecureStorage();

//const String base_url = '10.0.2.2:8000';
const String base_url = 'talkid.onrender.com';

class CirclePainter extends CustomPainter {
  final Color color;

  CirclePainter({super.repaint, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class CustomCircle {
  Offset pos;
  double radius;
  Color color;

  CustomCircle(this.pos, this.radius, this.color);

  Map<String, dynamic> toJson() => {
        'x': pos.dx.toStringAsFixed(6),
        'y': pos.dy.toStringAsFixed(6),
        'radius': radius,
        'color': "#${color.value.toRadixString(16)}",
      };
}

Future<http.Response> sendMessage(
    int msgType, String msgInfo, double? level) async {
  String? token = await getToken();
  if (level != null) {
    return http.post(Uri.https(base_url, '/app_comm_api/addMsgs/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $token',
        },
        body: jsonEncode(<String, dynamic>{
          "message_type": msgType,
          "message_info": msgInfo,
          "level": level,
        }));
  } else {
    return http.post(Uri.https(base_url, '/app_comm_api/addMsgs/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $token',
        },
        body: jsonEncode(<String, dynamic>{
          "message_type": msgType,
          "message_info": msgInfo,
        }));
  }
}

Future<http.Response> sendMessageCoordinates(int msgID, double imgWidth,
    double imgHeight, List<CustomCircle> circles) async {
  String? token = await getToken();
  List<Map<String, dynamic>> circlesJsonList =
      circles.map((circle) => circle.toJson()).toList();

  Map<String, dynamic> body = {
    "message_id": msgID,
    "imageWidth": imgWidth.toStringAsFixed(6),
    "imageHeight": imgHeight.toStringAsFixed(6),
    "coordinates": circlesJsonList
  };
  String jsonBody = jsonEncode(body);
  return http.post(Uri.https(base_url, '/app_comm_api/addMsgsCoord/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $token',
      },
      body: jsonBody);
}

Future<http.Response> createAccount(String username, String password,
    String email, String firstName, String lastName) {
  return http.post(Uri.https(base_url, '/app_comm_api/createAccount/2/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "username": username,
        "password": password,
        "email": email,
        "first_name": firstName,
        "last_name": lastName,
      }));
}

Future<http.Response> login(String username, String password) {
  return http.post(
    Uri.https(base_url, '/app_comm_api-token-auth/'),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(<String, dynamic>{
      'username': username,
      'password': password,
    }),
  );
}

void logout() async {
  const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  await secureStorage.deleteAll();
}

Future<String?> getToken() async {
  const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  return await secureStorage.read(key: 'auth_token');
}

Future<http.Response> sendSOS() async {
  return await sendMessage(1, "SOS Emergency", null);
}

double calculateMargin(double width) {
  return width > 900 ? width * 0.02 : width * 0.05;
}

double calculateIconSize(double width) {
  return width > 900 ? 64.0 : 80.0;
}

Widget buildGreetItem(IconData icon, String text, BuildContext context) {
  TextTheme textTheme = Theme.of(context).textTheme;
  return Center(
    child: ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).iconTheme.color,
      ),
      title: Text(
        text,
        style: textTheme.titleLarge,
      ),
      onTap: () {
        Navigator.of(context).pop();
      },
    ),
  );
}

Widget buildBedPosItem(String path, String text, String englishText,
    BuildContext context, Function(String) onSelected) {
  TextTheme textTheme = Theme.of(context).textTheme;
  return Center(
    child: ListTile(
      leading: ImageIcon(
        AssetImage(path),
        size: 50,
      ),
      title: Text(
        text,
        style: textTheme.titleLarge,
      ),
      onTap: () {
        Navigator.of(context).pop();
        onSelected(englishText);
      },
    ),
  );
}

Widget buildDifficultyBreathingItem(String text, String englishText,
    BuildContext context, Function(String) onSelected) {
  TextTheme textTheme = Theme.of(context).textTheme;
  return Center(
    child: ListTile(
      title: Text(
        text,
        style: textTheme.titleLarge,
      ),
      onTap: () {
        Navigator.of(context).pop();
        onSelected(englishText);
      },
    ),
  );
}

AlertDialog alertDialog(
    BuildContext context, String title, List<Widget> childs) {
  TextTheme textTheme = Theme.of(context).textTheme;
  return AlertDialog(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    title: Text(
      title,
      style: textTheme.displaySmall,
    ),
    content: SingleChildScrollView(
      child: ListBody(
        children: childs,
      ),
    ),
  );
}

void msgErrorPopUp(BuildContext context, String msg) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Erro'),
        content: Text(AppLocalizations.of(context)!.errorMsgPt1 +
            msg +
            AppLocalizations.of(context)!.errorMsgPt2 +
            msg +
            AppLocalizations.of(context)!.errorMsgPt3),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
