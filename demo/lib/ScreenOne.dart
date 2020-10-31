import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ScreenOne extends StatefulWidget {
  ScreenOne({Key key}) : super(key: key);

  @override
  _ScreenOneState createState() => _ScreenOneState();
}

class _ScreenOneState extends State<ScreenOne> {
  int curentidx = 0;
  List<Model> model = [];
  bool isloded = false;
  Future getdata() async {
    if (isloded) {
      _refreshController.requestRefresh();
    }
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
    if (isloded) {
      _refreshController.refreshCompleted();
      isloded = false;
    }
  }

  String profname;
  String image;
  Widget get one {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ListView.builder(
            shrinkWrap: true,
            itemBuilder: (ctx, id) => Container(
                  padding: EdgeInsets.all(2),
                  child: Card(
                      margin: EdgeInsets.all(2),
                      elevation: 2,
                      child: Container(
                          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          child: Tile(head: model[id]))),
                ),
            itemCount: model.length),
        SizedBox(height: 20),
        Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Divider(color: Colors.black45, thickness: 1.5)),
        Text('You\'re all caught Up!', style: TextStyle(color: Colors.black54))
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
                    color: Colors.grey[200]),
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
                child: Container(color: Colors.grey[200], height: 20)),
          ),
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
            child: SkeletonAnimation(
                child: Container(color: Colors.grey[200], height: 70)),
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
    getdata();
    return Scaffold(
      appBar: AppBar(title: Text('All Emails'), centerTitle: true),
      body: SmartRefresher(
        enablePullDown: true,
        controller: _refreshController,
        onRefresh: () {
          isloded = true;
          setState(() {});
        },
        child: FutureBuilder(
          future: getdata(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return (curentidx == 0) ? one : two;
            } else {
              return (curentidx == 0) ? oneload : twoload;
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (id) {
          setState(() {
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
    );
  }
}

class Tile extends StatelessWidget {
  final Model head;
  const Tile({Key key, this.head}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.purple[100],
      onTap: () {},
      child: Container(
        padding: EdgeInsets.all(5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.purple,
              child: Text(
                head.from.split('').first,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
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
  int id;
  String from;
  String subject;
  dynamic body;
  String re;
  String message;
  Model({this.id, this.from, this.subject, this.body, this.re, this.message});
  factory Model.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Model(
      id: map['id'],
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
}
