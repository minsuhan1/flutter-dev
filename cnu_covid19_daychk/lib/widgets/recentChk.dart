import 'package:html/parser.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:cp949/cp949.dart' as cp949;
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

class RecentChk extends StatefulWidget {
  final String _storedId;
  final String _storedPw;
  final Map<String, String> _headers;

  RecentChk(this._storedId, this._storedPw, this._headers);

  @override
  _RecentChkState createState() => _RecentChkState();
}

class _RecentChkState extends State<RecentChk> {
  List<List<String>> _data = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshRecentChecks();
  }

  Future<void> _refreshRecentChecks() =>
      Future.delayed(Duration(seconds: 1), () async {
        var _tmp = await _loadRecentChecks(context);
        print(_tmp);
        setState(() => _data = _tmp);
      });

  Future<List<List<String>>> _loadRecentChecks(context) async {
    // 최근 자가진단 목록 불러오기
    try {
      final chk_response = await http
          .post(
            Uri.parse(
                'https://dorm.cnu.ac.kr/intranet/user/corona19_daychk.php'),
            headers: widget._headers, // Cookie 포함한 header
          )
          .timeout(Duration(seconds: 5));

      if (chk_response.statusCode == 200) {
        var document = parse(cp949.decode(chk_response.bodyBytes));
        var table_rows = document
            .getElementsByClassName('tab_color')[0]
            .getElementsByTagName('td');
        List<List<String>> ret_data = [];
        for (int i = 6; i < table_rows.length; i++) {
          List<String> row_data = [];
          row_data.add(table_rows[i].innerHtml);
          row_data.add(table_rows[i + 1].innerHtml);
          row_data.add(table_rows[i + 2].innerHtml);
          row_data.add(table_rows[i + 3].innerHtml);
          i += 5;
          ret_data.add(row_data);
        }
        // table_rows.map((e) => e.innerHtml).forEach((element) {
        //   data.add(element);
        // });
        print(ret_data);
        return ret_data;
        // print(cp949.decode(chk_response.bodyBytes)); // 한글이 깨지는 문제를 해결
      }
      return [];
    } on SocketException catch (e) {
      _showToast(context, '인터넷 연결을 확인해 주세요');
      return [];
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          child: Text(
            '제출현황(아래로 당겨서 새로고침)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          padding: EdgeInsets.only(top: 30),
        ),
        Container(
          padding: EdgeInsets.all(2),
          height: 550,
          child: RefreshIndicator(
            onRefresh: _refreshRecentChecks,
            child: ListView.builder(
              itemCount: _data.length,
              itemBuilder: (ctx, index) => Card(
                elevation: 5,
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 15,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: FittedBox(
                        child: Text(_data[index][0]),
                      ),
                    ),
                  ),
                  title: Text(
                    _data[index][1],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '발열증상 유무: ${_data[index][2]}, 이상증상 유무: ${_data[index][3]}',
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}