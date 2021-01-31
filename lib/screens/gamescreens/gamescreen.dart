import 'package:flutter/cupertino.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Play Game"),
      ),
      child: Center(
        child: Column(
          children: [
            Text("Center"),
          ],
        ),
      ),
    );
  }
}
