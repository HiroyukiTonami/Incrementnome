import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
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
      home: Home(title: '各パラメータを設定出来る'),
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
  int _stepSize = 5; // 何BPM加速するか
  int _bar = 4; // 何小節で1ループとするか
  int _startTempo = 120; // どこから始めるか
  int _maxTempo = 180; // どこまで加速するか
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

  /// 無限ループするメトロノーム
  Future<void> _runMetronome() async {
    int waitTime;
    int soundId = await rootBundle.load('assets/sound/hammer.wav').then((ByteData soundData) {
      return pool.load(soundData);
    });
    var count = 0; // 何拍打ったか数える
    while(_run) {
      waitTime  = 60000 ~/ _tempo;
      pool.play(soundId);
      await Future.delayed(Duration(milliseconds: waitTime));
      count++;
      // TODO: 4分の4拍子以外の対応
      if (_tempo < _maxTempo && count == _bar * 4) {
        setState(() => _tempo = _tempo + _stepSize);
        count = 0;
      }
    }
  }

  /// cupatinoPickerの子供として設定すると自然に見えるウィジェットを作る
  Widget cupatinoPickerChild(String text) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
      )
    );
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
                Container(
                  height: 70,
                  width: 50,
                  child: CupertinoPicker(
                    itemExtent: 40,
                    children: List.generate(10, (i)=> cupatinoPickerChild((i+1).toString())),
                    scrollController: FixedExtentScrollController(initialItem: _stepSize-1),
                    onSelectedItemChanged: (int value) {
                      setState(() {
                        _stepSize = value+1;
                      });
                    },
                  ),
                ),
                Text(
                  'BPM',
                  style: Theme.of(context).textTheme.headline5,
                ),
                Spacer(),
                Text(
                  '長さ: ',
                ),
                Container(
                  height: 70,
                  width: 50,
                  child: CupertinoPicker(
                    itemExtent: 40,
                    children: List.generate(20, (i)=> cupatinoPickerChild((i+1).toString())),
                    scrollController: FixedExtentScrollController(initialItem: _bar-1),
                    onSelectedItemChanged: (int value) {
                      setState(() {
                        _bar = value+1;
                      });
                    },
                  ),
                ),
                Text(
                  '小節',
                  style: Theme.of(context).textTheme.headline5,
                ),
                Spacer(),
              ],
            ),
            Container(height: 100,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Text(
                  'スタート: ',
                ),
                Container(
                  height: 70,
                  width: 50,
                  child: CupertinoPicker(
                    itemExtent: 40,
                    children: List.generate(200, (i)=> cupatinoPickerChild((i+1).toString())),
                    scrollController: FixedExtentScrollController(initialItem: _startTempo-1),
                    onSelectedItemChanged: (int value) {
                      setState(() {
                        _startTempo = value+1;
                      });
                    },
                  ),
                ),
                Text(
                  'BPM',
                  style: Theme.of(context).textTheme.headline5,
                ),
                Spacer(),
                Text(
                  'エンド: ',
                ),
                Container(
                  height: 70,
                  width: 50,
                  child: CupertinoPicker(
                    itemExtent: 40,
                    children: List.generate(200, (i)=> cupatinoPickerChild((i+1).toString())),
                    scrollController: FixedExtentScrollController(initialItem: _maxTempo-1),
                    onSelectedItemChanged: (int value) {
                      setState(() {
                        _maxTempo = value+1;
                      });
                    },
                  ),
                ),
                Text(
                  'BPM',
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
              min: 1,
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
