import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Incrementnome());
}

class Incrementnome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Incrementnome',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home(title: 'とりあえず音を出す'),
    );
  }
}

/// アプリ起動時に表示する画面
class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ByteData sound;
  int _counter = 0;
  Soundpool pool = Soundpool(streamType: StreamType.alarm);

  /// 無限ループさせる
  Future<void> runMetronome(int bpm) async {
    int soundId = await rootBundle.load('assets/sound/hammer.wav').then((ByteData soundData) {
      return pool.load(soundData);
    });
    var waitTime  = 60000 ~/ bpm;
    print(waitTime);

    for (int i = 0; i < 100; i++) {
      await pool.play(soundId);
      await Future.delayed(Duration(milliseconds: waitTime));
    }
  }

  void _incrementCounter()  {
    runMetronome(200);
    setState(() {
      _counter++;
    });
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
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            FlatButton(
              child: const Text('Button'),
              color: Colors.orange,
              textColor: Colors.white,
              onPressed: _incrementCounter,
            ),
          ],
        ),
      ),
    );
  }
}
