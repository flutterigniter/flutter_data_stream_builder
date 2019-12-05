import 'package:flutter/material.dart';
import 'package:flutter_data_stream_builder/flutter_data_stream_builder.dart';

final Color darkBlue = Color.fromARGB(255, 18, 32, 47);

Stream<List<int>> _timedCounter() async* {
  int _i = 10;
  while (true) {
    if (_i < 0) break;
    await Future.delayed(Duration(seconds: 1));
    yield List<int>.generate(_i--, (i) => i + 1);
  }
  throw Exception('Mission aborted');
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: darkBlue),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: DataStreamBuilder<List<int>>(
            stream: _timedCounter(),
            builder: (context, List<int> numbers) => ListView(
              children: numbers.map((n) => ListTile(
                title: Center(child: Text(n.toString())))
              ).toList(),
            )
          ),
        ),
      ),
    );
  }
}