import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RedBalls',
      home: MyHomePage(title: 'RedBalls'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool started = false;
  List<Ball> balls = [];
  String message = "";
  List<Image> myHand = [];
  List<Image> pcHand = [];
  List<int> removedIndices = [];

  @override
  void initState() {
    super.initState();
    print("this is running");
    reset();
  }

  void reset() {
    message = "Press start to begin";
    started = false;
    balls = [];
    removedIndices = [];
    myHand = [];
    pcHand = [];

    for (int i = 0; i < 9; i++) {
      balls.add(Ball(
        index: i,
        grabbed: false,
      ));
    }
  }

  void pcMove(List<int> indices) {
    if (indices.isEmpty) {
      setState(() {   
        started = true;
        message = "Grab 1 or 2 adjacent balls";
        print("PC is gonna remove at 4");
        balls.removeAt(4);
        balls.insert(4, Ball(index: 4, grabbed: true));
        removedIndices.add(4);
        pcHand.add(Image.asset('lib/assets/ball.png', width: 50, height: 50));
      });
    }
    for (int index in indices) {
      setState(() {
        int remove = 8 - index;
        while (removedIndices.contains(remove)) {
          remove = Random().nextInt(9);
        }
        print("PC is gonna remove at $remove");
        balls.removeAt(remove);
        balls.insert(remove, Ball(index: remove, grabbed: true));
        removedIndices.add(remove);
        pcHand.add(Image.asset('lib/assets/ball.png', width: 50, height: 50));
      });
    }

    if (removedIndices.length == 9) {
      if (pcHand.length % 2 == 1) {
        setState(() {
          message = "You lost(( Press reset to play again";
        });
      }
    }
  }

  void grab() {
    List<int> indices = [];
    for (Ball ball in balls) {
      if (ball.selected) {
        indices.add(ball.index);
      }
    }

    if (indices.length > 2) {
      setState(() {
        message = "You can not grab more than 2 balls";
      });
      return;
    } else if (indices.length == 2) {
      if (indices[0] % 3 == 2) {
        if (indices[0] != indices[1] - 3) {
          setState(() {
            message = "You can only grab 2 adjacent balls";
          });
          return;
        }
      } else {
        if (indices[0] != indices[1] - 1 && indices[0] != indices[1] - 3) {
          setState(() {
            message = "You can only grab 2 adjacent balls";
          });
          return;
        }
      }
    }

    for (int i in indices) {
      setState(() {
        myHand.add(Image.asset('lib/assets/ball.png', width: 50, height: 50));
        print("I am gonna remove at $i");
        removedIndices.add(i);
        balls.removeAt(i);
        balls.insert(i, Ball(index: i, grabbed: true));
      });
    }

    pcMove(indices);
  }

  @override
  Widget build(BuildContext context) {
    print(balls.length);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.red,
      ),
      body: Stack(children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                message,
                style: TextStyle(fontSize: 26),
              ),
              SizedBox(height: 32),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                height: MediaQuery.of(context).size.width,
                child: GridView.builder(
                    padding: EdgeInsets.zero,
                    primary: false,
                    itemCount: balls.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return Container(child: balls[index]);
                    }),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(0, 0),
                          blurRadius: 4.0,
                        )
                      ],
                    ),
                    child: FlatButton(
                      child: Text(
                        started ? "Grab" : "Start",
                        style: TextStyle(fontSize: 22, color: Colors.white),
                      ),
                      onPressed: () => started ? grab() : pcMove([]),
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Container(
                    width: 120,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(0, 0),
                          blurRadius: 4.0,
                        )
                      ],
                    ),
                    child: FlatButton(
                      child: Text(
                        "Reset",
                        style: TextStyle(fontSize: 22, color: Colors.white),
                      ),
                      onPressed: () {
                        setState(() {
                          reset();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 40,
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: myHand,
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
        Positioned(
          top: 40,
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: pcHand,
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
      ]),
    );
  }
}


class Ball extends StatefulWidget {
  Ball({@required this.index, @required this.grabbed});
  final int index;
  bool selected = false;
  final bool grabbed;

  @override
  _BallState createState() => _BallState();
}

class _BallState extends State<Ball> {
  BoxDecoration decoration() {
    if (widget.selected) {
      return BoxDecoration(
        border: Border.all(
          width: 2,
          color: Colors.red,
        ),
      );
    } else {
      return BoxDecoration();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.grabbed) {
      return GestureDetector(
          child: Container(
            decoration: decoration(),
            child: Image.asset(
              'lib/assets/ball.png',
            ),
          ),
          onTap: () {
            setState(() {
              widget.selected = !widget.selected;
            });
            print('Tapped at ${widget.index}');
          });
    } else {
      return Container();
    }
  }
}
