import 'dart:convert';
import 'dart:io';
import 'package:cnu_covid19_daychk/main.dart';
import 'package:cnu_covid19_daychk/widgets/mypage.dart';
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
  Map<String, String> _headers = {}; // Client header

  void _resetLoginInfo() {
    setState(() {
      _storedId = null;
      _storedPw = null;
    });
  }

  void _loginRequest() async {

    try {
      final response = await http.post(
        Uri.parse('https://dorm.cnu.ac.kr/intranet/login.php'),
        body: {
          'mode': 'login',
          'idno': _idController.text,
          'pass': _pwController.text,
        }, // 로그인 input
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) { // 연결됨
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
          _headers['Cookie'] =
              rawCookie.substring(0, idx); // PHPSESSID 추출 후 클라이언트 헤더 Cookie에 저장
        }
        print(_headers['Cookie']); // print PHPSESSID
        print(response.body); // 한글이 깨지는 문제를 해결

      }
    } on SocketException catch (e) {
      _showToast(context, '인터넷 연결을 확인해 주세요');
    }
  }


  @override
  Widget build(BuildContext context) {
    return _storedId != null && _storedPw != null
        ? MyPage(_storedId, _storedPw, _resetLoginInfo, _headers)
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
