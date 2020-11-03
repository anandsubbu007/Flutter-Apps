import 'dart:async';
import 'dart:convert';
import 'dart:math' show sqrt, max;
import 'dart:math';
import 'dart:ui' show lerpDouble;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeleton_text/skeleton_text.dart';

void main() {
  runApp(MyApp());
}

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

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    Timer(Duration(seconds: 2), navigate);
    super.initState();
  }

  void navigate() {
    Navigator.push(
      context,
      RevealRoute(
          page: ScreenOne(),
          maxRadius: 500,
          centerAlignment: Alignment.center,
          minRadius: 0),
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
          ],
        ),
      ),
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

  @override
  Duration get transitionDuration => Duration(seconds: 1, milliseconds: 800);
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

class ScreenOne extends StatefulWidget {
  ScreenOne({Key key}) : super(key: key);

  @override
  _ScreenOneState createState() => _ScreenOneState();
}

class _ScreenOneState extends State<ScreenOne> {
  int curentidx = 0;
  List<Model> model = [];
  List<Model> modelids = [];
  bool isloded = false;
  bool refresh;
  bool isfirst;
  bool isdone;
  @override
  void initState() {
    refresh = true;
    isfirst = true;
    super.initState();
  }

  Future getdata() async {
    if (refresh) {
      if (isloded) _refreshController.requestRefresh();
      if (curentidx == 0) {
        http.Response responce =
            await http.get('https://api2.funedulearn.com/init/demo-mails');
        Map<String, dynamic> map = json.decode(responce.body);
        List value = map['data'];
        model = [];
        value.forEach((e) {
          model.add(Model.fromMap(e));
        });
      }
      if (curentidx == 1) {
        http.Response responce =
            await http.get('https://api2.funedulearn.com/init/demo-profile');
        Map<String, dynamic> map = json.decode(responce.body);
        profname = map['profile']['name'];
        image = map['profile']['image'];
        print('Body :: $map');
      }
      if (isloded) _refreshController.refreshCompleted();
      isloded = false;
      refresh = !refresh;
    }
  }

  String profname;
  String image;
  ScrollController _cont = ScrollController();
  Widget get one {
    // print('MIN XT :: ${_cont.position.minScrollExtent}');
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListView.builder(
              controller: _cont,
              shrinkWrap: true,
              itemBuilder: (ctx, id) => Container(
                    padding: EdgeInsets.all(2),
                    child: Card(
                        margin: EdgeInsets.all(2),
                        elevation: 2,
                        child: Container(
                            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            child: Tile(
                              head: model[id],
                              isselected: modelids.contains(model[id]),
                              ontap: () {
                                if (!modelids.contains(model[id])) {
                                  modelids.add(model[id]);
                                } else {
                                  modelids.remove(model[id]);
                                }
                                setState(() {});
                              },
                            ))),
                  ),
              itemCount: model.length),
          caughtup
        ],
      ),
    );
  }

  Widget get caughtup {
    return Column(
      children: [
        SizedBox(height: 20),
        Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Divider(color: Colors.black45, thickness: 1.5)),
        Text('You\'re all caught Up!',
            style: TextStyle(color: Colors.black54),
            textAlign: TextAlign.center)
      ],
    );
  }

  Widget get two {
    print('image :: $image');
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 15),
          CircleAvatar(
            radius: 70,
            child: Image.network(
              image ?? '',
              loadingBuilder: (c, i, o) {
                return SkeletonAnimation(
                  child: CircleAvatar(
                    backgroundColor: Colors.purple[400],
                    radius: 75,
                    child: Icon(Icons.account_circle,
                        color: Colors.white, size: 70),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10),
          Text(profname ?? '', style: TextStyle(fontSize: 22)),
          Text('Mail.Box', style: TextStyle(fontSize: 16)),
          Container(
            padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
            child: ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: menus.length,
              separatorBuilder: (ctx, idx) => Divider(height: 2),
              itemBuilder: (ctx, idx) => ListTile(
                onTap: () {},
                title: Text(menus[idx]),
                leading: Icon(icons[idx]),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget get oneload {
    return ListView.builder(
        itemBuilder: (ctx, id) => Container(
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: SkeletonAnimation(
                child: Container(
                    height: 74,
                    width: double.infinity,
                    color: Colors.grey[300]),
              ),
            ),
        itemCount: 4);
  }

  Widget get twoload {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 15),
          SkeletonAnimation(
            child: CircleAvatar(
              backgroundColor: Colors.purple[400],
              radius: 75,
              child: Icon(Icons.account_circle, color: Colors.white, size: 70),
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
            child: SkeletonAnimation(
                child: Container(color: Colors.grey[300], height: 20)),
          ),
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
            child: SkeletonAnimation(
                child: Container(color: Colors.grey[300], height: 70)),
          ),
        ],
      ),
    );
  }

  List<String> menus = ['Setting', 'AboutUs', 'Rate Us', 'Log Out'];
  List<IconData> icons = [
    Icons.settings,
    Icons.info,
    Icons.star,
    Icons.exit_to_app_rounded
  ];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
            leading: SizedBox(),
            title: Text('All Emails'),
            centerTitle: true,
            backgroundColor: Colors.purple),
        body: SmartRefresher(
          enablePullDown: true,
          controller: _refreshController,
          onRefresh: () {
            isloded = true;
            refresh = true;
            setState(() {});
          },
          child: FutureBuilder(
            future: getdata(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (refresh) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return (curentidx == 0) ? one : two;
                } else {
                  return (curentidx == 0) ? oneload : twoload;
                }
              } else {
                return (curentidx == 0) ? one : two;
              }
            },
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: (id) {
            setState(() {
              refresh = true;
              curentidx = id;
            });
          },
          currentIndex: curentidx,
          items: [
            BottomNavigationBarItem(
                activeIcon: Icon(Icons.inbox_sharp, color: Colors.purple),
                icon: Icon(Icons.inbox_sharp),
                label: 'Inbox'),
            BottomNavigationBarItem(
                activeIcon: Icon(Icons.inbox_sharp, color: Colors.purple),
                icon: Icon(Icons.account_circle),
                label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class Tile extends StatelessWidget {
  final Model head;
  final bool isselected;
  final Function ontap;
  const Tile({Key key, this.head, this.isselected, this.ontap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.purple[100],
      onTap: ontap,
      child: Container(
        color: isselected ? Colors.grey[100] : null,
        padding: EdgeInsets.all(5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              fit: StackFit.loose,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.purple,
                  child: Text(
                    head.from.split('').first.toUpperCase(),
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                if (isselected)
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey[200].withOpacity(0.5),
                    child: Align(
                        alignment: Alignment.center,
                        child: Icon(Icons.check_sharp,
                            size: 40, color: Colors.blue)),
                  ),
              ],
            ),
            SizedBox(width: 5),
            Expanded(
                child: Column(
              children: [
                Row(
                  children: [
                    Text(head.subject ?? '',
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold)),
                    Spacer(),
                    Text(head.from ?? '',
                        style: TextStyle(color: Colors.purple)),
                  ],
                ),
                SizedBox(height: 5),
                Text(head.message ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black87))
              ],
            ))
          ],
        ),
      ),
    );
  }
}

class Model {
  String id;
  String from;
  String subject;
  dynamic body;
  String re;
  String message;
  Model({this.id, this.from, this.subject, this.body, this.re, this.message});
  factory Model.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Model(
      id: map['id'].toString(),
      from: map['from'],
      subject: map['subject'],
      body: map['body'],
      re: map['Re'],
      message: map['body']['message'],
    );
  }

  factory Model.fromJson(String source) => Model.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Model(id: $id, from: $from, subject: $subject,  Re: $re, message: $message , body: $body)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Model &&
        o.id == id &&
        o.from == from &&
        o.subject == subject &&
        o.body == body &&
        o.re == re &&
        o.message == message;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        from.hashCode ^
        subject.hashCode ^
        body.hashCode ^
        re.hashCode ^
        message.hashCode;
  }
}
