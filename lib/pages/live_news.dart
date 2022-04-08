import 'package:blog_app/controllers/e_live_new_controller.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as convert;

import '../app_theme.dart';

class LiveNews extends StatefulWidget {
  @override
  _LiveNewsState createState() => _LiveNewsState();
}

class _LiveNewsState extends StateMVC {
  ELiveNewsController eLiveNewsController;

  _LiveNewsState() : super(ELiveNewsController()) {
    eLiveNewsController = ELiveNewsController();
  }
  int selectedVideo;
  convert.YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    print("LiveNews");
    eLiveNewsController.getLiveNews().then((_) {
      setState(() {});
    });
  }

  setVideo() {
    final videoId = convert.YoutubePlayer.convertUrlToId(
      eLiveNewsController.liveNewsModel[selectedVideo].url,
    );
    _controller = convert.YoutubePlayerController(
      initialVideoId: videoId,
      flags: convert.YoutubePlayerFlags(autoPlay: true),
    );
    _controller.load(videoId);

    // _controller.addListener((event) {
    //   if (event.isReady) {
    //     _controller.play();
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        backgroundColor: Theme.of(context).canvasColor,
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back,color: Colors.black,)),
        title: Text(
          allMessages.value.liveNews,
          style: TextStyle(
            color: appThemeModel.value.isDarkModeEnabled.value
                ? Colors.white
                : Colors.black,
          ),
        ),
      ),
      body: eLiveNewsController.liveNewsModel == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                //video player

                selectedVideo == null
                    ? Container()
                    : VisibilityDetector(
                        key: Key(
                            "${eLiveNewsController.liveNewsModel[selectedVideo].image}"),
                        onVisibilityChanged: (visibilityInfo) async {
                          var visiblePercentage =
                              visibilityInfo.visibleFraction * 100.0;
                          print(
                              'Widget ${visibilityInfo.key} is $visiblePercentage% visible');
                          if (visiblePercentage == 100.0) {
                            await Future.delayed(Duration(seconds: 1));
                            if (_controller != null) {
                              _controller.play();
                            }
                          } else {
                            if (_controller != null) {
                              _controller.pause();
                            }
                          }
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.4,
                          width: MediaQuery.of(context).size.width,
                          child: convert.YoutubePlayer(
                            controller: _controller,
                            aspectRatio: 16 / 9,
                          ),
                        ),
                      ),
                selectedVideo == null
                    ? Container()
                    : Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Image.network(
                              '${GlobalConfiguration().getValue('image_url')}upload/company-logo/original/' +
                                  eLiveNewsController
                                      .liveNewsModel[selectedVideo].image,
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              eLiveNewsController
                                  .liveNewsModel[selectedVideo].companyName,
                              style: TextStyle(
                                  color: appThemeModel
                                          .value.isDarkModeEnabled.value
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                Expanded(
                  child: ListView.separated(
                    itemCount: eLiveNewsController.liveNewsModel.length,
                    separatorBuilder: (context, _) {
                      return Divider(
                        indent: 2,
                        thickness: 2,
                      );
                    },
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedVideo = index;
                            setVideo();
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Image.network(
                                '${GlobalConfiguration().getValue('image_url')}upload/company-logo/original/' +
                                    eLiveNewsController
                                        .liveNewsModel[index].image,
                                height: 75,
                                width: 75,
                                fit: BoxFit.cover,
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    eLiveNewsController
                                        .liveNewsModel[index].companyName,
                                    style: TextStyle(
                                        color: appThemeModel
                                                .value.isDarkModeEnabled.value
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }
}
