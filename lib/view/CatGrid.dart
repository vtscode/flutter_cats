import 'dart:math';

import 'package:after_layout/after_layout.dart';
import 'package:flutter_learn_architecture/model/glitch/NoInternetGlitch.dart';
import 'package:flutter_learn_architecture/provider/CatProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';

import '../getit.dart';

class CatGrid extends StatefulWidget {
  @override
  _CatGridState createState() => _CatGridState();
}

class _CatGridState extends State<CatGrid> with AfterLayoutMixin {
  final provider = getIt<CatProvider>();
  List<Widget> catPhotos = [];
  List<StaggeredTile> catPhotoTiles = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.pink[50],
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                catPhotoTiles.clear();
                catPhotos.clear();
                provider.refreshGird();
              },
            )
          ],
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            'Cute kitten',
            style: GoogleFonts.pacifico(),
          ),
        ),
        body: Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: catPhotos.length == 0
                ? Center(
              child: CircularProgressIndicator(),
            )
                : StaggeredGridView.countBuilder(
                crossAxisCount: 4,
                staggeredTileBuilder: (index) => catPhotoTiles[index],
                itemCount: catPhotos.length,
                itemBuilder: (context, index) {
                  return catPhotos[index];
                })));
  }

  @override
  void afterFirstLayout(BuildContext context) {
    provider.getTwentyRandomPhoto();

    provider.catPhotoStream.listen((snapshot) {
      snapshot.fold((l) {
        if (l is NoInternetGlitch) {
          Color randomColor = Color.fromRGBO(Random().nextInt(255),
              Random().nextInt(255), Random().nextInt(255), 1);
          catPhotos.add(CatPhotoErrorTile(randomColor, "Unable to Connect"));
        }
      },
              (r) => {
            catPhotos.add(CatPhotoTile(r.url)),
          });
      int count = Random().nextInt(4);
      catPhotoTiles.add(StaggeredTile.count(count, count));

      setState(() {});
    });
  }
}

class CatPhotoTile extends StatelessWidget {
  const CatPhotoTile(this.imageUrl);
  final String imageUrl;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Center(
          child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.all(Radius.circular(10.0)),
                  image: DecorationImage(
                      image: NetworkImage(imageUrl), fit: BoxFit.cover),
                ),
              ))),
    );
  }
}

class CatPhotoErrorTile extends StatelessWidget {
  const CatPhotoErrorTile(this.backgroundColor, this.errorMessage);
  final Color backgroundColor;
  final String errorMessage;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: InkWell(
        onTap: () {},
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: Text(errorMessage),
          ),
        ),
      ),
    );
  }
}
