import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(home: MyApp()));
  // runApp(MyApps());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    fetchdata(0);
    super.initState();
  }

  Map req = {
    "fld_action_type": 0,
    "fld_brand_id": "0",
    "cart_total": 0,
    "fld_cat_id": 216,
    "fld_search_txt": "",
    "fld_total_page": 0,
    "fld_user_id": "159",
    "grid_list_view": 0,
    "fld_max_price": 0,
    "fld_min_price": 0,
    "next_page": 0,
    "fld_page_no": 0,
    "fld_pincode": 0,
    "fld_spcl_price": 0,
    "fld_product_price": 0,
    "fld_product_qty": 0,
    "shipping_total": 0,
    "statusCode": 0,
    "total_seller_count": 0
  };
  List<Model> models = [];
  int totalpage = 100;
  int nextpg = 1;
  bool isended = false;
  Future<bool> fetchdata(int page) async {
    if ((totalpage ?? 2) > page) {
      req['next_page'] = page;
      curntpg = page;
      http.Response responce = await http.post(
        'https://phaukat.com/api/product',
        body: json.encode(req),
      );
      var map = json.decode(responce.body);
      if (responce.statusCode == 200) {
        List values = map['product_data'];
        totalpage = map['fld_total_page'];
        nextpg = map['next_page'];
        values.forEach((e) {
          models.add(Model.fromMap(e));
        });
        isloading = false;
        setState(() {});
        return true;
      } else {
        isloading = false;
        return false;
      }
    } else {
      isloading = false;
      isended = true;
      setState(() {});
      return false;
    }
  }

  int curntpg = 0;
  bool isloading = true;
  Widget card(Model model) {
    bool isfav = model.isinwish.toUpperCase() != 'FALSE';
    return Card(
        margin: EdgeInsets.all(3),
        child: Container(
          padding: EdgeInsets.all(7),
          child: Column(
            children: [
              Expanded(
                child: Image.network(
                  model.image,
                  width: double.infinity,
                ),
              ),
              Row(
                children: [
                  Expanded(child: Text(model.name)),
                  IconButton(
                      padding: EdgeInsets.all(5),
                      color: isfav ? Colors.red : Colors.grey,
                      icon:
                          Icon(isfav ? Icons.favorite : Icons.favorite_border),
                      onPressed: () {})
                ],
              ),
              Row(
                children: [
                  Text('₹${model.price}'),
                  Spacer(),
                  Text('₹${model.extraprice}',
                      style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          fontSize: 13)),
                  Spacer(),
                  Text('-${model.spclprice}% Off',
                      style: TextStyle(color: Colors.red)),
                ],
              ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DEMO')),
      body: isloading ? Center(child: CircularProgressIndicator()) : body(),
    );
  }

  Widget body() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: GridViewPagination(
        childAspectRatio: 3 / 5,
        itemBuilder: (c, i) {
          return card(models[i]);
        },
        itemCount: models.length,
        onNextPage: (pg) async {
          return fetchdata(pg);
        },
      ),
    );
  }
}

typedef Future<bool> OnNextPage(int nextPage);

class GridViewPagination extends StatefulWidget {
  final int itemCount;
  final double childAspectRatio;
  final OnNextPage onNextPage;
  final Function(BuildContext context, int position) itemBuilder;
  final Widget Function(BuildContext context) progressBuilder;

  GridViewPagination({
    this.itemCount,
    this.childAspectRatio,
    this.itemBuilder,
    this.onNextPage,
    this.progressBuilder,
  });

  @override
  _GridViewPaginationState createState() => _GridViewPaginationState();
}

class _GridViewPaginationState extends State<GridViewPagination> {
  int currentPage = 1;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification sn) {
        if (!isLoading &&
            sn is ScrollUpdateNotification &&
            sn.metrics.pixels == sn.metrics.maxScrollExtent) {
          setState(() {
            this.isLoading = true;
          });
          widget.onNextPage?.call(currentPage++)?.then((bool isLoaded) {
            setState(() {
              this.isLoading = false;
            });
          });
        }
        return true;
      },
      child: CustomScrollView(
        slivers: <Widget>[
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
              crossAxisCount: 2,
              childAspectRatio: widget.childAspectRatio,
            ),
            delegate: SliverChildBuilderDelegate(
              widget.itemBuilder,
              childCount: widget.itemCount,
              addAutomaticKeepAlives: true,
              addRepaintBoundaries: true,
              addSemanticIndexes: true,
            ),
          ),
          if (isLoading)
            SliverToBoxAdapter(
              child: widget.progressBuilder?.call(context) ?? _defaultLoading(),
            ),
        ],
      ),
    );
  }

  Widget _defaultLoading() {
    return Container(
      padding: EdgeInsets.all(15),
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    );
  }
}

class Model {
  String id;
  String catid;
  String sex;
  String color;
  String size;
  String extraprice;
  String name;
  String price;
  String spclprice;
  String image;
  String gif;
  String rat;
  String ratcount;
  String reviewcount;
  String isinwish;
  Model({
    this.id,
    this.catid,
    this.sex,
    this.color,
    this.size,
    this.extraprice,
    this.name,
    this.price,
    this.spclprice,
    this.image,
    this.gif,
    this.rat,
    this.ratcount,
    this.reviewcount,
    this.isinwish,
  });

  factory Model.fromMap(map) {
    if (map == null) return null;
    return Model(
      id: map['id'].toString(),
      catid: map['cat_id'].toString(),
      sex: map['unisex_type'].toString(),
      color: map['color_id'].toString(),
      size: map['size_id'].toString(),
      extraprice: map['extra_price'].toString(),
      name: map['name'].toString(),
      price: map['price'].toString(),
      spclprice: map['spcl_price'].toString(),
      image: map['default_image'].toString(),
      gif: map['gif_image'].toString(),
      rat: map['fld_total_rating'].toString(),
      ratcount: map['fld_rating_count'].toString(),
      reviewcount: map['fld_review_count'].toString(),
      isinwish: map['isInWishlist'].toString(),
    );
  }

  factory Model.fromJson(String source) => Model.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Model(id: $id, catid: $catid, sex: $sex, color: $color, size: $size, extraprice: $extraprice, name: $name, price: $price, spclprice: $spclprice, image: $image, gif: $gif, rat: $rat, ratcount: $ratcount, reviewcount: $reviewcount, isinwish: $isinwish)';
  }
}
