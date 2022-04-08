import 'dart:convert';
import 'dart:io';

import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:mdi/mdi.dart';
import 'package:http/http.dart' as http;

import '../app_theme.dart';

//* <------- Bottom card of home page ------->

class BottomCardSaved extends StatelessWidget {
  final Blog item;
  final bool isTrending;
  var height, width;
  BottomCardSaved(this.item, {this.isTrending = false});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0, left: 1.0, right: 3.0),
      child: Center(
       child: Card(
         shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(10.0)),
         elevation: 2,
         shadowColor: Colors.green,
         child: Container(
           width: 0.95 * width,
           height: 0.15 * height,
           decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(10.0),
             color: Theme.of(context).cardColor,
           ),
           child: LayoutBuilder(
             builder: (context, constraints) {
               return Stack(
                 children: <Widget>[
                   _buildContents(context, height, constraints.maxWidth),
                   Positioned(
                     bottom: 0.03 * height,
                     right: 0.03 * width,
                     child: isTrending
                         ? Image.asset(
                             "assets/img/trending.png",
                             height: 20,
                             width: 20,
                           )
                         : Container(),
                   ),
                 ],
               );
             },
           ),
         ),
       ),
        ),
    );
  }

  _buildContents(BuildContext context, var height, var width) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
              top: 0.0, left: 3.0, bottom: 0.0, right: 0.0),
          child: GestureDetector(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Container(
                  height: 0.14 * height * 0.9,
                  width: 0.22 * height * 0.8,
                  child: Image.network(
                    item.bannerImage[0],
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes
                              : null,
                        ),
                      );
                    },
                  )),
            ),
            onTap: () {
              Navigator.of(context).pushNamed("/ReadBlog", arguments: item);
            },
          ),
        ),
        _buildTextAndUserWidget(context, width),
      ],
    );
  }

  _buildTextAndUserWidget(BuildContext context, var width) {
    return Padding(
      padding: const EdgeInsets.only(left: 10,top: 2,right: 2,bottom: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: GestureDetector(
                  child: Container(
                    width: 0.45 * width,
                    child: Text(
                      item.title,maxLines: 4,
                      style: Theme.of(context).textTheme.bodyText1.merge(
                            TextStyle(
                                color:
                                    appThemeModel.value.isDarkModeEnabled.value
                                        ? Colors.white
                                        : Colors.black,
                                fontFamily: 'Montserrat',
                                fontSize: 12.0 ,wordSpacing: 1,letterSpacing: 1,
                                fontWeight: FontWeight.w500),
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed("/ReadBlog", arguments: item);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 25,left: 8),
                child: InkWell(
                  child: Image.asset(
                    "assets/img/delete.png",
                    width: 0.06 * width,
                  ),
                  onTap: () async {
                    Fluttertoast.showToast(
                        msg: "Story remove from bookmark",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.TOP,

                        backgroundColor: Colors.green,
                        textColor: Colors.white);
                    _deleteSavedPost(context);
                  },
                ),
              ),
            ],
          ),
          Spacer(),
          //SizedBox(height: 12,),
          Container(
           // decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            width: width * 0.54,height: 22,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 3.0),
              child: Row(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 0.03 * width,
                        height: 0.03 * width,
                        decoration: new BoxDecoration(border: Border.all(color: Colors.white,width: 3),
                        color: Colors.green,
                          shape: BoxShape.circle,
                        )
                        // decoration: new BoxDecoration(
                        //   color: HexColor(item.categoryColor.toString()),
                        //   shape: BoxShape.circle,
                        // ),
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Text(
                        item.categoryName.toUpperCase(),
                        style: Theme.of(context).textTheme.bodyText1.merge(
                              TextStyle(
                                color: appThemeModel
                                        .value.isDarkModeEnabled.value
                                    ? Colors.white
                                    : Colors.black,
                                fontFamily: 'Montserrat',
                                fontSize: 12.0,letterSpacing: 1,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      ),
                    ],
                  ),
                   Spacer(),
                  //SizedBox(width: MediaQuery.of(context).size.width*0.13,),
                  Padding(
                    padding: const EdgeInsets.only(right: 3),
                    child: Icon(
                      Mdi.eye,size: 18,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    item.viewCount.toString(),
                    style: Theme.of(context).textTheme.bodyText1.merge(
                          TextStyle(
                              color: appThemeModel.value.isDarkModeEnabled.value
                                  ? Colors.white
                                  : Colors.black,
                              fontFamily: 'Montserrat',
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteSavedPost(context) async {
    final msg =
        jsonEncode({"blog_id": item.id, "user_id": currentUser.value.id});
    final String url = '${GlobalConfiguration().getValue('api_base_url')}deleteBookmarkPost';
    final client = new http.Client();
    final response = await client.post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        "lang-code": languageCode.value?.language ?? null
      },
      body: msg,
    );
    Map data = json.decode(response.body);
    Navigator.of(context).pushNamed("/SavedPage");
  }
}
