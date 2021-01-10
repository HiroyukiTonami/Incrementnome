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
      home: Home(title: 'メトロノームのオンオフとして動かす'),
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
  int _tempo = 120;
  bool _run = false;
  Soundpool pool = Soundpool(streamType: StreamType.alarm);

  void _toggleMetronome() {
    if (_run) {
      setState(() => _run = false);
    }
    else {
      setState(() => _run = true);
      _runMetronome(_tempo);
    }
  }

  /// 無限ループさせる
  Future<void> _runMetronome(int bpm) async {
    int soundId = await rootBundle.load('assets/sound/hammer.wav').then((ByteData soundData) {
      return pool.load(soundData);
    });
    var waitTime  = 60000 ~/ bpm;
    print(waitTime);

    while(_run) {
      await pool.play(soundId);
      await Future.delayed(Duration(milliseconds: waitTime));
    }
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
              'BPM: ',
            ),
            Text(
              '$_tempo',
              style: Theme.of(context).textTheme.headline4,
            ),
            FlatButton(
              child: const Text('ON / OFF'),
              color: Colors.orange,
              textColor: Colors.white,
              onPressed: _toggleMetronome,
            ),
          ],
        ),
      ),
    );
  }
}
