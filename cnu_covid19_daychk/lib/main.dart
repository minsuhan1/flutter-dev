import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './widgets/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

main() async {
  // 가로모드 비활성화
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitUp,
  ]);
  _initNotiSetting();

  runApp(MaterialApp(home: MyApp()));
}

void _initNotiSetting() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  final initSettingsIOS = IOSInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: false,
    requestAlertPermission: false,
  );
  final initSettings = InitializationSettings(
    android: initSettingsAndroid,
    iOS: initSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AgreeDialog();
  }

  void AgreeDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('agree') != true || prefs.getBool('agree') == null) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('주의', style: TextStyle(fontWeight: FontWeight.bold),),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('이 앱을 사용함으로써 발생하는 모든 민,형사상 책임은 앱 사용자에게 있습니다.'),
                  Text('코로나19 의심 증상이 있으면 반드시 정보시스템에 접속하여 자가진단 재제출을 하시기 바랍니다.'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                textColor: Colors.amber,
                child: Text('동의', style: TextStyle(fontWeight: FontWeight.bold),),
                onPressed: () {
                  prefs.setBool('agree', true);
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                textColor: Colors.amber,
                child: Text('앱 종료', style: TextStyle(fontWeight: FontWeight.bold),),
                onPressed: () {
                  exit(0);
                },
              ),
            ],
          );
        },
      );
    } else {
      return;
    }

  }
  void InfoDialog() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;


    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          // 둥근 모서리
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          // Dialog Main Title
          title: Column(
            children: [
              new Text(
                "앱 및 개발자 정보",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("앱 버전: $version"),
              Text(" "),
              Text("[Contact]"),
              Text("Email: msh050533@gmail.com"),
            ],
          ),
          actions: [
            new FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                textColor: Colors.purple,
                child: new Text(
                  "확인",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ))
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CNU Dorm 자가진단',
      theme: ThemeData(primarySwatch: Colors.purple, accentColor: Colors.amber),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CNU Dorm 자가진단'),
          actions: [
            IconButton(
                onPressed: () => InfoDialog(),
                icon: Icon(Icons.info_outline))
          ],
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Login(),
        ),
      ),
    );
  }
}
