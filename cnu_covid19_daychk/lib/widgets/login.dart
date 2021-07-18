import 'dart:convert';
import 'package:cnu_covid19_daychk/main.dart';
import 'package:cp949/cp949.dart' as cp949;
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  void _showToast(BuildContext context, String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
            label: '확인', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  var _storedId;
  var _storedPw;
  final _idController = TextEditingController();
  final _pwController = TextEditingController();

  void _loginRequest() async {
    Map<String, String> headers = {};

    final response = await http.post(
      Uri.parse('https://dorm.cnu.ac.kr/intranet/login.php'),
      body: {
        'mode': 'login',
        'idno': _idController.text,
        'pass': _pwController.text,
      }, // 로그인 input
    ).timeout(Duration(seconds: 5));

    if (response.statusCode == 200) {
      print('데이터 수신 ' + response.contentLength.toString() + 'byte');
      if (response.body.contains('failed')) {
        // 로그인 성공여부 확인
        print('login failed');
        _showToast(context, '로그인 실패. ID/PW를 확인해주세요');
      } else {
        _showToast(context, '로그인 성공');
        setState(() {
          _storedId = _idController.text;
          _storedPw = _pwController.text;
        });
      }

      String rawCookie = response.headers['set-cookie'].toString();
      if (rawCookie != null) {
        // 웹서버로부터 받은 set-cookie
        int idx = rawCookie.indexOf(';');
        headers['Cookie'] =
            rawCookie.substring(0, idx); // PHPSESSID 추출 후 클라이언트 헤더 Cookie에 저장
      }
      print(headers['Cookie']); // print PHPSESSID
      print(response.body); // 한글이 깨지는 문제를 해결
    }
  }

  // void makeRequest() async {
  //   // 자가진단 제출 테스트
  //   final chk_response = await http
  //       .post(
  //     Uri.parse(
  //         'https://dorm.cnu.ac.kr/intranet/user/corona19_daychkform.php'),
  //     body: {
  //       'mode': 'ins',
  //       // 'yy': '2021',
  //       // 'shtm': '3',
  //       'idno': '201902767',
  //       // 'name': '',
  //       'q3': 'N', // 발열증상유무
  //       'q2': 'N', // 호흡기이상유무
  //       'memo': '', // 체온측정미실시사유
  //       'agree': 'Y', // 동의1
  //       'agree2': 'Y', // 동의2
  //     },
  //     headers: headers, // Cookie 포함한 header
  //   )
  //       .timeout(Duration(seconds: 3));
  //
  //   if (chk_response.statusCode == 200) {
  //     print('데이터 수신 ' + chk_response.contentLength.toString() + 'byte');
  //     //print(response.body); // 한글 깨짐
  //     print(chk_response.headers);
  //     print(cp949.decode(chk_response.bodyBytes)); // 한글이 깨지는 문제를 해결
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return _storedId != null && _storedPw != null
        ? Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('로그인ID: ' + _storedId),
                FlatButton(
                  child: Text(
                    '변경',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _storedId = null;
                      _storedPw = null;
                    });
                  },
                )
              ],
            ),
          )
        : Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          hintText: '정보시스템 ID',
                        ),
                        controller: _idController,
                      ),
                      TextField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          hintText: 'Password',
                        ),
                        obscureText: true,
                        controller: _pwController,
                      ),
                    ],
                  ),
                ),
                FlatButton(
                  // 로그인 버튼
                  color: Colors.purple,
                  textColor: Colors.white,
                  onPressed: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    _loginRequest();
                  },
                  child: Text(
                    '로그인',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
