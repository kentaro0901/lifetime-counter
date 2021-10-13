import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lifetime Counter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Lifetime Counter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _ChangeFormState();
}

class _ChangeFormState extends State<MyHomePage> {

  DateTime _date = DateTime.now(); //目標
  String _dateString = DateFormat('yyyy-MM-dd').format(DateTime.now()); //表示用
  Duration _duration = const Duration(); //目標との差分

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(milliseconds: 50), _onTimer);
    _getPrefItems();
  }

  _getPrefItems() async { // ロード
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int timestamp = prefs.getInt('dateTimestamp') ?? DateTime.now().millisecondsSinceEpoch;
    setState(() {
      _date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      _dateString = DateFormat('yyyy-MM-dd').format(_date);
    });
  }

  void _onTimer(Timer timer) {
    var _now = DateTime.now();
    setState(() => { // 更新を伝える
      _duration = _now.isBefore(_date) ? _date.difference(_now): const Duration()
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime.now(),
        lastDate: _date.add(const Duration(days: 80*366))
    );
    if(picked != null) {
      setState(() => {
        _date = picked,
        _dateString = DateFormat('yyyy-MM-dd').format(picked),
      });
    }
    prefs.setInt('dateTimestamp', picked!.millisecondsSinceEpoch); // セーブ
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
                child:Text(
                  "$_dateStringまであと",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                )
            ),
            Center(
                child:Text(
                  "$_duration",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Theme.of(context).primaryColor,
                  ),
                )
            ),
            Container(
              padding: const EdgeInsets.only(top:100.0),
              child: ElevatedButton(
                onPressed: () => _selectDate(context),
                child: Text(
                  '命日選択',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 20,
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}
