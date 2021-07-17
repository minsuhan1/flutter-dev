import 'dart:convert';
import 'package:cp949/cp949.dart' as cp949;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

void makeRequest() async {
  final response = await http.post(
    Uri.parse('https://dorm.cnu.ac.kr/intranet/login.php'),
    body: {
      'mode': 'login',
      'idno': '201902767',
      'pass': '990803',
    }, // 로그인 input
  ).timeout(Duration(seconds: 5));

  Map<String, String> headers = {};
  if (response.statusCode == 200) {
    // success
    print('데이터 수신 ' + response.contentLength.toString() + 'byte');
    //print(response.body); // 한글 깨짐
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

  // 자가진단 제출 테스트
  final chk_response = await http
      .post(
        Uri.parse(
            'https://dorm.cnu.ac.kr/intranet/user/corona19_daychkform.php'),
        body: {
          'mode': 'ins',
          // 'yy': '2021',
          // 'shtm': '3',
          'idno': '201902767',
          // 'name': '',
          'q3': 'N', // 발열증상유무
          'q2': 'N', // 호흡기이상유무
          'memo': '', // 체온측정미실시사유
          'agree': 'Y', // 동의1
          'agree2': 'Y', // 동의2
        },
        headers: headers, // Cookie 포함한 header
      )
      .timeout(Duration(seconds: 3));

  if (chk_response.statusCode == 200) {
    print('데이터 수신 ' + chk_response.contentLength.toString() + 'byte');
    //print(response.body); // 한글 깨짐
    print(chk_response.headers);
    print(cp949.decode(chk_response.bodyBytes)); // 한글이 깨지는 문제를 해결
  }
}


main() {
  makeRequest();
}
