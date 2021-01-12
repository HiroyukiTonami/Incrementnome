import 'dart:math';
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
      home: Home(title: 'Incrementnome'),
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
  int _remainBeat = 16; // あと何拍で次のテンポに移るか
  int _startTempo = 120; // どこから始めるか
  int _maxTempo = 180; // どこまで加速するか
  int _tempo = 120;
  bool _run = false;
  Soundpool beatPool = Soundpool(streamType: StreamType.alarm);
  Soundpool finishPool = Soundpool(streamType: StreamType.alarm);
  Soundpool clickPool = Soundpool(streamType: StreamType.alarm);


  void _toggleMetronome() {
    if (_run) {
      setState(() => _run = false);
    }
    else {
      setState(() => _run = true);
      _runMetronome();
    }
  }

  /// 何拍でループが終わるかを計算する。
  ///
  /// TODO: 4分の4拍子以外の対応
  int calcBeatPerLoop() {
    return _bar * 4;
  }

  ///音を再生し、再生にかかった時間をmillisecで返す。
  Future<int> playSound(Soundpool pool, int soundId) async {
    final lastTime = DateTime.now();
    await pool.play(soundId);
    return DateTime.now().difference(lastTime).inMilliseconds;
  }

  /// 無限ループするメトロノーム
  Future<void> _runMetronome() async {
    int beat = await rootBundle.load('assets/sound/hammer.wav').then((ByteData soundData) {
      return beatPool.load(soundData);
    });
    int finish = await rootBundle.load('assets/sound/finish.wav').then((ByteData soundData) {
      return finishPool.load(soundData);
    });
    int click = await rootBundle.load('assets/sound/click.wav').then((ByteData soundData) {
      return clickPool.load(soundData);
    });

    int soundLength;
    while(_run) {
      soundLength = await playSound(beatPool, beat);
      setState(() => _remainBeat = max(_remainBeat - 1, 0));
      await Future.delayed(Duration(milliseconds: (60000 ~/ _tempo) - soundLength));
      if (_tempo < _maxTempo && _remainBeat == 0) {
        soundLength = await playSound(finishPool, finish);
        setState(() {
          _tempo = _tempo + _stepSize;
          _remainBeat = calcBeatPerLoop();
        });
        // その時のテンポに合わせてインターバルを設定しないと違和感が出る
        await Future.delayed(Duration(milliseconds: (60000 * 4 ~/ _tempo) - soundLength));
        // 入の4カウント
        for(int i = 0; i < 4; i++) {
          soundLength = await playSound(clickPool, click);
          await Future.delayed(Duration(milliseconds: (60000 ~/ _tempo) - soundLength));
        }
      }
    }
  }

  /// cupertinoPickerの子供として設定すると自然に見えるウィジェットを作る
  Widget cupertinoPickerChild(String text) {
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
                    children: List.generate(10, (i)=> cupertinoPickerChild((i+1).toString())),
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
                    children: List.generate(20, (i)=> cupertinoPickerChild((i+1).toString())),
                    scrollController: FixedExtentScrollController(initialItem: _bar-1),
                    onSelectedItemChanged: (int value) {
                      setState(() {
                        _bar = value+1;
                        _remainBeat = calcBeatPerLoop();
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
                    children: List.generate(200, (i)=> cupertinoPickerChild((i+1).toString())),
                    scrollController: FixedExtentScrollController(initialItem: _startTempo-1),
                    onSelectedItemChanged: (int value) {
                      setState(() {
                        _startTempo = value+1;
                        _tempo = _startTempo;
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
                    children: List.generate(200, (i)=> cupertinoPickerChild((i+1).toString())),
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
            Container(height: 90),
            Row(
              children: [
                Spacer(),
                Text(
                  '残り$_remainBeat拍',
                  style: TextStyle(fontSize: 30),
                ),
                Spacer(),
              ],
            ),
            Container(height: 10),
            Text(
              'now BPM',
            ),
            Text(
              '$_tempo',
              style: Theme.of(context).textTheme.headline3,
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
            Row(
              children: [
                Spacer(),
                FlatButton(
                  child: Text('RESET'),
                  color: Colors.green,
                  textColor: Colors.white,
                  onPressed: () {
                    setState(() {
                      _tempo = _startTempo;
                      _remainBeat = calcBeatPerLoop();
                    });
                  },
                ),
                Spacer(),
                FlatButton(
                  child: Text(_run ? 'STOP' : 'GO'),
                  color: _run ? Colors.blue : Colors.orange,
                  textColor: Colors.white,
                  onPressed: _toggleMetronome,
                ),
                Spacer(),
              ],
            )
          ],
        ),
      ),
    );
  }
}
