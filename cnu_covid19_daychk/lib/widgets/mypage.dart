import 'package:cnu_covid19_daychk/widgets/recentChk.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:cp949/cp949.dart' as cp949;
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

class MyPage extends StatelessWidget {
  final String _storedId;
  final String _storedPw;
  final VoidCallback _resetLoginInfo;
  final Map<String, String> _headers;

  MyPage(this._storedId, this._storedPw, this._resetLoginInfo, this._headers);

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
              'idno': _storedId,
              // 'name': '',
              'q3': 'N', // 발열증상유무
              'q2': 'N', // 호흡기이상유무
              'memo': '', // 체온측정미실시사유
              'agree': 'Y', // 동의1
              'agree2': 'Y', // 동의2
            },
            headers: _headers, // Cookie 포함한 header
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
        content: Text(message),
        action: SnackBarAction(
            label: '확인', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('[로그인ID] ' + _storedId),
                FlatButton(
                  child: Text(
                    '변경',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: _resetLoginInfo,
                )
              ],
            ),
          ),
          RaisedButton(
            child: Text(
              '자가진단 제출',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            color: Theme.of(context).accentColor,
            textColor: Colors.black,
            onPressed: () => _submitForm(context),
          ),
          Container(
            child: RecentChk(_storedId, _storedPw, _headers),
          )
        ],
      ),
    );
  }
}
