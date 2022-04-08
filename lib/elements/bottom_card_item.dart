import 'package:blog_app/data/blog_list_holder.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/pages/SwipeablePage.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:mdi/mdi.dart';

import '../app_theme.dart';

//* <------- Bottom card of home page ------->

class BottomCard extends StatelessWidget {
  final Function ontap;
  final Blog item;
  final bool isTrending;
  final int index;
  final List<Blog> blogList;
  var height, width;
  BottomCard(this.item, this.index, this.blogList,
      {this.isTrending = false, this.ontap});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0, left: 2.0, right: 3.0),
      child: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)),
          elevation: 2,shadowColor: Colors.green,
          child: Container(
            width: 0.9 * width,
            height: 0.16 * height,
            decoration: BoxDecoration(
               // border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10.0),
              color: Theme.of(context).cardColor,
              // boxShadow: [
              //   BoxShadow(
              //       color: Colors.black38.withOpacity(0.1),
              //       blurRadius: 10.0,
              //       offset: Offset(0.0, 5.0),
              //       spreadRadius: 2.0)
              // ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                print("constraints ${constraints.maxWidth}");

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
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10.0),
                          onTap: () {
                            // Navigator.of(context)
                            // .pushNamed("/ReadBlog", arguments: item);
                            if(ontap!=null){
                            ontap();

                            }
                            blogListHolder.setList(blogList);
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SwipeablePage(index),
                            ));
                          },
                        ),
                      ),
                    ),
                    //Divider(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

//? Split the build method into smaller components for better reading

  _buildContents(BuildContext context, var height, var width) {
    //print(constraints);
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
              top: 0.0, left: 5.0, bottom: 0.0, right: 1.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
                height: 0.16 * height * 0.8,
                width: 0.2 * height * 0.8,
                // height: 0.2 * height,
                // width: 0.18 * height,
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
        ),
        _buildTextAndUserWidget(context, width)
      ],
    );
  }

  _buildTextAndUserWidget(BuildContext context, var width) {
    //print("Image Size ${0.2 * height * 0.85}");
    return Padding(
      padding: const EdgeInsets.only(top:3,bottom: 3,right: 0,left: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Spacer(),
          Padding(
            padding: const EdgeInsets.only(top: 12.0,left: 5),
            child: Container(
              width: 0.5 * width,
              child: Text(
                item.title,maxLines: 4,
                style: Theme.of(context).textTheme.bodyText1.merge(
                      TextStyle(letterSpacing: 1,
                          color: appThemeModel.value.isDarkModeEnabled.value
                              ? Colors.white
                              : Colors.black,
                          fontFamily: 'Montserrat',
                          fontSize: 13.0,
                          fontWeight: FontWeight.normal),
                    ),
                //style: TextStyle(fontSize: 18.0, color: Colors.black),
                //style: Theme.of(context).textTheme.subtitle1,
                //style: Theme.of(context).textTheme.headline6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // Spacer(),
          SizedBox(height: 8,),
          Container(
            // decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            width: width * 0.56,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0, ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 0.03 * width,
                          height: 0.03 * width,
                          decoration: new BoxDecoration(border: Border.all(color: Colors.white,width: 3),
                            color: Colors.green,
                            // color: HexColor(item.categoryColor.toString()),
                            //color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        Text(
                          item.categoryName,
                          style: Theme.of(context).textTheme.bodyText1.merge(
                                TextStyle(
                                    color: appThemeModel
                                            .value.isDarkModeEnabled.value
                                        ? Colors.white
                                        : Colors.black,
                                    fontFamily: 'Montserrat',letterSpacing: 1,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold),
                              ),
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(
                  //   width: 0.19 * width,
                  // ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: Icon(
                      Mdi.eye, size: 18,
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
                    //style: Theme.of(context).textTheme.subtitle1,
                  ),
                ],
              ),
            ),
          ),
          //Spacer()
        ],
      ),
    );
  }
}
