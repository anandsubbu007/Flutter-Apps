import 'dart:async';
import 'package:flutter/material.dart';
import 'ScreenOne.dart';
// import 'package:route_transitions/route_transitions.dart';
// import 'package:circular_reveal_animation/circular_reveal_animation.dart';
import 'dart:math' show sqrt, max;
import 'dart:ui' show lerpDouble;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Demo App',
        theme: ThemeData(primarySwatch: Colors.purple),
        home: MyHomePage(),
        debugShowCheckedModeBanner: false);
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  // AnimationController animationController;
  // Animation<double> animation;
  @override
  void initState() {
    // animationController = AnimationController(
    //   vsync: this,
    //   duration: Duration(milliseconds: 1000),
    // );
    // animation = CurvedAnimation(
    //   parent: animationController,
    //   curve: Curves.easeIn,
    // );
    super.initState();
    // Timer(Duration(seconds: 2), navigate);
    // () => Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(builder: (context) => ScreenOne()),
    //     ));
  }

  void navigate() {
    // Navigator.of(context).pushReplacement(RevealRoute(
    //   page: ScreenOne(),
    //   maxRadius: 720,
    //   centerAlignment: Alignment.center,
    // ));
    Navigator.push(
      context,
      RevealRoute(
        page: ScreenOne(),
        maxRadius: 800,
        centerAlignment: Alignment.center,
        minRadius: 10,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[400],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('Images/mail.png'),
            SizedBox(height: 10),
            Text('Mail.Box',
                style: TextStyle(color: Colors.white, fontSize: 25)),
            // RaisedButton(
            //     child: Text('Tap'),
            //     onPressed: () {
            //       navigate();
            //     })
          ],
        ),
      ),
      floatingActionButton:
          FloatingActionButton(child: Icon(Icons.ac_unit), onPressed: navigate),
    );
  }
}

class RevealRoute extends PageRouteBuilder {
  final Widget page;
  final AlignmentGeometry centerAlignment;
  final Offset centerOffset;
  final double minRadius;
  final double maxRadius;
  RevealRoute(
      {@required this.page,
      this.minRadius = 0,
      @required this.maxRadius,
      this.centerAlignment,
      this.centerOffset})
      : assert(centerOffset != null || centerAlignment != null),
        super(pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return page;
        });

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return ClipPath(
        clipper: CircularRevealClipper(
            fraction: animation.value,
            centerAlignment: centerAlignment,
            centerOffset: centerOffset,
            minRadius: minRadius,
            maxRadius: maxRadius),
        child: child);
  }
}

@immutable
class CircularRevealClipper extends CustomClipper<Path> {
  final double fraction;
  final Alignment centerAlignment;
  final Offset centerOffset;
  final double minRadius;
  final double maxRadius;

  CircularRevealClipper(
      {@required this.fraction,
      this.centerAlignment,
      this.centerOffset,
      this.minRadius,
      this.maxRadius});

  @override
  Path getClip(Size size) {
    final Offset center = this.centerAlignment?.alongSize(size) ??
        this.centerOffset ??
        Offset(size.width / 2, size.height / 2);
    final minRadius = this.minRadius ?? 0;
    final maxRadius = this.maxRadius ?? calcMaxRadius(size, center);

    return Path()
      ..addOval(
        Rect.fromCircle(
          center: center,
          radius: lerpDouble(minRadius, maxRadius, fraction),
        ),
      );
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;

  static double calcMaxRadius(Size size, Offset center) {
    final w = max(center.dx, size.width - center.dx);
    final h = max(center.dy, size.height - center.dy);
    return sqrt(w * w + h * h);
  }
}