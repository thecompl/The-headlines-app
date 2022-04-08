import 'package:blog_app/models/blog_category.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;

class ReadBlogScreenshot extends StatefulWidget {
  final Blog item;
  ReadBlogScreenshot(this.item);

  @override
  _ReadBlogScreenshotState createState() => _ReadBlogScreenshotState();
}

class _ReadBlogScreenshotState extends State<ReadBlogScreenshot> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Stack(
            children: [
              Image.network(
                widget.item.bannerImage[0],
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
              Container(
                padding: EdgeInsets.all(8),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Image.asset(
                    'assets/img/appicon.png',
                    height: 60,
                    width: 50,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.item.title ?? 'title',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: Text(
                      parse(widget.item.description ?? "desc").body.text ?? 'disc',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/img/google_play.png',
                        height: 50,
                        width: 75,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Image.asset(
                        'assets/img/appstore_icon.png',
                        height: 50,
                        width: 75,
                      ),
                      Spacer(),

                      SizedBox(
                        width: 5,
                      ),
                      Image.asset(
                        'assets/img/logo.png',
                        height: 50,
                        width: 100,
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
