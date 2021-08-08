import 'package:cnu_covid19_daychk/widgets/recentChk.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cp949/cp949.dart' as cp949;
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class MyPage extends StatefulWidget {
  final String _storedId;
  final String _storedPw;
  final VoidCallback _resetLoginInfo;
  final Map<String, String> _headers;


  MyPage(this._storedId, this._storedPw, this._resetLoginInfo, this._headers);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  bool _notification = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadStoredNotiValue();
  }

  void _loadStoredNotiValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getBool('noti') == null || prefs.getBool('noti') == false) {
      setState(() {
        _notification = false;
      });
    } else if (prefs.getBool('noti') == true) {
      setState(() {
        _notification = true;
      });
    }
  }

  void _setStoredNotiValue(bool val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('noti', val);
  }

  void _submitForm(BuildContext context) async {
    // 자가진단 제출
    try {
      final chk_response = await http
          .post(
            Uri.parse(
                'https://dorm.cnu.ac.kr/intranet/user/corona19_daychkform.php'),
            body: {
              'mode': 'ins',
              // 'yy': '2021',
              // 'shtm': '3',
              'idno': widget._storedId,
              // 'name': '',
              'q3': 'N', // 발열증상유무
              'q2': 'N', // 호흡기이상유무
              'memo': '', // 체온측정미실시사유
              'agree': 'Y', // 동의1
              'agree2': 'Y', // 동의2
            },
            headers: widget._headers, // Cookie 포함한 header
          )
          .timeout(Duration(seconds: 5));

      if (chk_response.statusCode == 200) {
        print('데이터 수신 ' + chk_response.contentLength.toString() + 'byte');
        //print(response.body); // 한글 깨짐
        print(chk_response.headers);
        print(cp949.decode(chk_response.bodyBytes)); // 한글이 깨지는 문제를 해결
        if (!cp949.decode(chk_response.bodyBytes).contains('로그인')) {
          _showToast(context, '제출 완료');
        } else {
          _showToast(context, '제출 실패');
        }
      }
    } on SocketException catch (e) {
      print('d');
      _showToast(context, '인터넷 연결을 확인해 주세요');
    }
  }

  void _showToast(BuildContext context, String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        duration: Duration(seconds: 1),
        content: Text(message),
        action: SnackBarAction(
            label: '확인', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  Future _scheduledAtTimeNotification() async {
    print('noti scheduling function called');
    final notiTitle = '자가진단 제출 알림';
    final notiDesc = '앱에서 자가진단 결과를 제출해주세요';

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // 아래는 iOS 알림 수신 권한 요청
    // final result = await flutterLocalNotificationsPlugin
    //     .resolvePlatformSpecificImplementation<
    //     IOSFlutterLocalNotificationsPlugin>()
    //     ?.requestPermissions(
    //   alert: true,
    //   badge: true,
    //   sound: true,
    // );

    var android = AndroidNotificationDetails('id', notiTitle, notiDesc,
        importance: Importance.max, priority: Priority.max);
    var ios = IOSNotificationDetails();
    var detail = NotificationDetails(android: android, iOS: ios);


    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.deleteNotificationChannelGroup('id');

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      notiTitle,
      notiDesc,
      _setNotiTime(),
      detail,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

  }

  tz.TZDateTime _setNotiTime() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day,
        13, 0);
    if(scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    print('schedule set');
    return scheduledDate;
  }

  @override
  Widget build(BuildContext context) {
    //print(_headers['Cookie']);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) => Column(
          children: [
            Container(
              height: constraints.maxHeight * 0.07,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('[로그인ID] ' + widget._storedId),
                  FlatButton(
                    child: Text(
                      '변경',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: widget._resetLoginInfo,
                  )
                ],
              ),
            ),
            Container(
              height: constraints.maxHeight * 0.07,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '매일 오후 1시에 제출 알림 수신하기',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Switch.adaptive(
                    activeColor: Theme.of(context).primaryColor,
                    value: _notification,
                    onChanged: (val) {
                      setState(() {
                        _notification = val;
                      });
                      _setStoredNotiValue(val);
                      if (val == true) {
                        _showToast(context, "매일 오후 1시에 자가진단 제출 알림을 수신합니다.");
                        _scheduledAtTimeNotification();
                      }
                    },
                  ),
                ],
              ),
            ),
            Container(
              height: constraints.maxHeight * 0.06,
              child: RaisedButton(
                child: Text(
                  '자가진단 제출',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                color: Theme.of(context).accentColor,
                textColor: Colors.black,
                onPressed: () => _submitForm(context),
              ),
            ),
            Container(
              height: constraints.maxHeight * 0.80,
              child: RecentChk(widget._storedId, widget._storedPw, widget._headers),
            )
          ],
        ),
      ),
    );
  }
}
