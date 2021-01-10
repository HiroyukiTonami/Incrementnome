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
      home: Home(title: '規定数繰り返したら自動で加速する'),
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
  int _stepSize = 10; // 何BPM加速するか
  int _bar = 2; // 何小節で1ループとするか
  int _tempo = 120;
  bool _run = false;
  Soundpool pool = Soundpool(streamType: StreamType.alarm);

  void _toggleMetronome() {
    if (_run) {
      setState(() => _run = false);
    }
    else {
      setState(() => _run = true);
      _runMetronome();
    }
  }

  /// 無限ループさせる
  Future<void> _runMetronome() async {
    int waitTime;
    int soundId = await rootBundle.load('assets/sound/hammer.wav').then((ByteData soundData) {
      return pool.load(soundData);
    });
    var count = 0;
    while(_run) {
      waitTime  = 60000 ~/ _tempo;
      await pool.play(soundId);
      await Future.delayed(Duration(milliseconds: waitTime));
      count++;
      // TODO: 4分の4拍子以外の対応
      if (count == _bar * 4) {
        setState(() => _tempo = _tempo + _stepSize);
        count = 0;
      }
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Text(
                  'ステップ: ',
                ),
                Text(
                  '$_stepSize BPM',
                  style: Theme.of(context).textTheme.headline5,
                ),
                Spacer(),
                Text(
                  'メロディの長さ: ',
                ),
                Text(
                  '$_bar小節',
                  style: Theme.of(context).textTheme.headline5,
                ),
                Spacer(),
              ],
            ),
            Container(height: 100,),
            Text(
              'BPM: ',
            ),
            Text(
              '$_tempo',
              style: Theme.of(context).textTheme.headline4,
            ),
            Slider(
              value: _tempo.toDouble(),
              min: 10,
              max: 200,
              divisions: 200,
              label: _tempo.toString(),
              onChanged: (double value) {
                setState(() {
                  _tempo = value.toInt();
                });
              },
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
