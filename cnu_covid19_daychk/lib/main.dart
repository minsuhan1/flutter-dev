import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
//...
//Here comes code of Flutter
//...
//Now I define the async function to make the request
void makeRequest() async{
  final response = await http
      .post(Uri.parse('https://dorm.cnu.ac.kr/intranet/login.php'), body: {'mode': 'login', 'idno' : '201902767', 'pass' : '990803'})
      .timeout(Duration(seconds: 3));

  if (response.statusCode == 200) {
    print('데이터 수신 ' + response.contentLength.toString() + 'byte');
    //print(response.body); // 한글 깨짐
    print(response.headers);
    print(response.body); // 한글이 깨지는 문제를 해결
  }
}
//...
//Here comes more Flutter code
//...
main(){
  makeRequest();
}