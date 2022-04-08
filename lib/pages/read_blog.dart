import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:blog_app/elements/video_player.dart';
import 'package:blog_app/helpers/helper.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/pages/adsform.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_text_to_speech/flutter_text_to_speech.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mdi/mdi.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../app_theme.dart';
import 'read_blog_screenshot.dart';
import 'web_view.dart';
import 'package:get/get.dart';

class ReadBlog extends StatefulWidget {
  final Blog item;

  ReadBlog(this.item);

  @override
  _ReadBlogState createState() => _ReadBlogState();
}

enum TtsState { playing, stopped, paused, continued }

class _ReadBlogState extends State<ReadBlog> {

  bool _isLoading = false;
  bool display = false;
  var height, width;
  int _current = 0;
  bool isVolume = false;
  bool isWebOpened = false;
  bool isVolumeOn = false;
  bool isOpeningWebPage = false;
  bool isBookmark = false;
  bool isBookmarkdislike = false;
  bool showadd = false;
  bool like_count = false;
  bool isNew = false;
  VoiceController _voiceController;
  bool linkOpen = false;
  List<Blog> blogList = [];
  List blogs_comment = [];

  // text to speech
  FlutterTts flutterTts = FlutterTts();
  TtsState ttsState = TtsState.stopped;
  GlobalKey<CustomVideoPlayerState> videoPlayeState =
  GlobalKey<CustomVideoPlayerState>();

  bool userlogin = false;

  TextEditingController commentcon = TextEditingController();

  List comment_lenght = [];

  int i = 0;

  get index => 0;
  GlobalKey globalKey = GlobalKey();

  Future<void> init(String text) async {
    bool isLanguageFound = false;
    flutterTts.getLanguages.then((value) {
      Iterable it = value;

      it.forEach((element) {
        if (element.toString().contains(getCurrentItem().blogAccentCode)) {
          flutterTts.setLanguage(element);
          initTTS(text);
          isLanguageFound = true;
        }
      });
    });

    if (!isLanguageFound) initTTS(text);
  }

  Future<void> initTTS(String text) async {
    flutterTts.setStartHandler(() {
      setState(() {
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      stop();
    });

    flutterTts.setPauseHandler(() {
      setState(() {
        ttsState = TtsState.paused;
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
        ttsState = TtsState.continued;
      });
    });

    await Future.delayed(Duration(milliseconds: 100));
    speak(text);
  }

  Future speak(String text) async {
    var result = await flutterTts.speak(text);
    if (result == 1) setState(() => ttsState = TtsState.playing);
  }

  Future stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Blog getCurrentItem() {
    return widget.item;
  }

  var scr = new GlobalKey();
  double fontSize = 16;
  int _counter = 0;
  Position _currentPosition;
  String _currentAddress;


  _getCurrentLocation() {
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition.latitude,
        _currentPosition.longitude,
      );
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
        "${place.locality}, ${place.postalCode}, ${place.country}";
        print(_currentAddress);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    print("adds show"+ getCurrentItem().ads_show.toString());
    print("adds data"+ getCurrentItem().ads_data.toString());


    _getCurrentLocation();
    print("this is like count" + getCurrentItem().like_count.toString());

    getCurrentItem().blog_comment;
    getcomment();
    super.initState();
    //initializeLoggedInUser();
    print("Current Data ${currentUser.value.isNewUser}");
    if (currentUser.value.id != null) {
      setState(() {
        userlogin = true;
      });
    }
    if (currentUser != null) {
      if (currentUser?.value?.isNewUser == null) {
        currentUser.value.isNewUser = false;
        isNew = false;
      } else {
        isNew = currentUser.value.isNewUser;
      }
    }

    //getProfile();
    _voiceController = FlutterTextToSpeech.instance.voiceController();
    if (getCurrentItem().isBookmarked == 1) {
      isBookmark = true;
    } else {
      isBookmark = false;
    }
    _viewPost();
  }

  _likePost(){
    // like_count!=like_count;
    if (getCurrentItem().like_count == 1)
    {
      like_count = true;
     }else{
      like_count = false;
    }
    _viewPost();
  }

  bool isReadBlogAvailable = true;

  @override
  void dispose() {
    super.dispose();
    flutterTts?.stop();
    if (_voiceController != null) {
      _voiceController?.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery
        .of(context)
        .size
        .height;
    print(
        "top MediaQuery.of(context).size. ${MediaQuery
            .of(context)
            .padding
            .top} $kToolbarHeight}");
    width = MediaQuery
        .of(context)
        .size
        .width;
    return ValueListenableBuilder(
        valueListenable: currentUser,
        builder: (BuildContext context, value, Widget child) {
          // print('veelue'+ jsonDecode(value.toString()));
          return LoadingOverlay(
            isLoading: _isLoading,
            color: Colors.grey,
            child: Scaffold(
              backgroundColor: Theme
                  .of(context)
                  .cardColor,
              body: GestureDetector(
                onHorizontalDragEnd: (DragEndDetails dragDetail) {
                  isReadBlogAvailable = true;
                },
                onHorizontalDragUpdate: (DragUpdateDetails details) async {
                  print("details.delta.xd ${details.delta.dx}");
                  if (details.delta.dx < 0) {
                    print("left isReadBlogAvailable $isReadBlogAvailable");

                    if (widget.item.url != null && isReadBlogAvailable) {
                      isReadBlogAvailable = false;
                      // await Helper.launchURL(widget.item.url);
                      print("getCurrentItem().url, ${getCurrentItem().url}");
                      /* try {
                        videoPlayeState.currentState.vidoPlayPauseTogal(true);
                      } catch (e) {
                        print("error while pause $e");
                      }*/
                      setState(() {
                        linkOpen = true;
                      });
                      /*    await Get.to(CustomWebView(
                        url: getCurrentItem().url,
                      ));*/
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CustomWebView(
                                url: getCurrentItem().url,
                              ),
                        ),
                      );

                      setState(() {
                        linkOpen = false;
                      });
                      print(
                          " MediaQuery.of(context).padding.top ${MediaQuery
                              .of(context)
                              .padding
                              .top}");
                      /*  try {
                        videoPlayeState.currentState.vidoPlayPauseTogal(true);
                      } catch (e) {}
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext ctn) {
                          return SafeArea(
                            child: Container(
                              color: Colors.transparent,
                              margin: EdgeInsets.only(
                                top: MediaQuery.of(context).padding.top,
                              ),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: new BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: new BorderRadius.only(
                                        topLeft: const Radius.circular(30.0),
                                        topRight: const Radius.circular(30.0),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 15, top: 5),
                                            child: Icon(
                                              Icons.close,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: WebView(
                                      initialUrl: widget.item.url,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                      try {
                        videoPlayeState.currentState.vidoPlayPauseTogal(false);
                      } catch (e) {}
*/
                      // await launch(widget.item.url).then((value) {});

                    }
                  } else if (details.delta.dx > 0) {
                    print("right");
                    Navigator.pop(context);
                  }
                },
                child: SafeArea(
                  child: Padding(
                   padding: EdgeInsets.only(left:5,right:5),
                   child: Container(

                     height: MediaQuery.of(context).size.height,
                     child: Stack(
                       children: [
                         Column(
                           children: [
                             !(currentUser.value.isNewUser ?? false)
                               ? Container()
                               : Positioned.fill(
                                 child: GestureDetector(
                               onTap: () async {
                                 setState(() {
                                   // intializeshared();
                                   isNew = false;
                                   // currentUser.value = Users.fromJSON(
                                   //     json.decode(prefs.get('current_user')));
                                   currentUser.value.isNewUser = false;
                                   //intializeshared();
                                   print(
                                       "Current Data ontap ${currentUser.value
                                           .isNewUser}");
                                   print("isNew ontap $isNew");
                                 });
                               },
                               child: Image.asset(
                                 'assets/img/screen.png',
                                 fit: BoxFit.cover,
                               ),
                             ),
                           ),

                               //   Container(
                               //   // decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                               //   child: _buildBlogNameAndDetails(context),
                               // ),
                             // SizedBox(
                             //   height:MediaQuery.of(context).size.height*0.0 ,),
                             // Container(
                             //     //height:MediaQuery.of(context).size.height*0.2,
                             //     width:MediaQuery.of(context).size.width*0.95,
                             //   decoration: BoxDecoration(
                             //      ),
                             //   padding: EdgeInsets.only(left: 1,right: 5,top: 0,bottom: 3),
                             //   // decoration: BoxDecoration(border: Border.all(color:Colors.white)),
                             //   child: Text(
                             //     getCurrentItem().title,maxLines: 3,
                             //     style: Theme
                             //         .of(context)
                             //         .textTheme
                             //         .bodyText1
                             //         .merge(
                             //       TextStyle(
                             //           color: Colors.black,
                             //           fontFamily: 'Montserrat',letterSpacing: 1,wordSpacing: 1,
                             //           fontSize: 18,
                             //           overflow: TextOverflow.ellipsis,
                             //           fontWeight: FontWeight.bold),
                             //     ),
                             //   ),
                             // ),
                             // Container(
                             //   //decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                             //   width: MediaQuery.of(context).size.width,
                             //   height: MediaQuery.of(context).size.height*0.02,
                             //  // color: Colors.white,
                             // ),
                             // Stack(
                             //   children: <Widget>[

                             Container(

                               //decoration: BoxDecoration( border: Border.all(color: Colors.red)),
                               height: MediaQuery.of(context).size.height*0.95,
                               child: _buildPage(),
                             ),
                             // getCurrentItem().ads_show == 1 && showadd == false ?
                             // Center(
                             //   child: SafeArea(
                             //     child: Container(decoration: BoxDecoration(
                             //         // border: Border.all(color: Colors.black)
                             //       ),
                             //       height: height*0.99,
                             //       child:  _buildAdvertise(),
                             //     ),
                             //   ),
                             // ):Container(),
                             // !(currentUser.value.isNewUser ?? false)
                             //     ? Container()
                             //     : Positioned.fill(
                             //   child: GestureDetector(
                             //     onTap: () async {
                             //       setState(() {
                             //         // intializeshared();
                             //         isNew = false;
                             //         // currentUser.value = Users.fromJSON(
                             //         //     json.decode(prefs.get('current_user')));
                             //         currentUser.value.isNewUser = false;
                             //         //intializeshared();
                             //         print(
                             //             "Current Data ontap ${currentUser.value
                             //                 .isNewUser}");
                             //         print("isNew ontap $isNew");
                             //       });
                             //     },
                             //     child: Image.asset(
                             //       'assets/img/screen.png',
                             //       fit: BoxFit.cover,
                             //     ),
                             //   ),
                             // ),
                         //  ],
                         // ),
                          ],
                        ),
                         getCurrentItem().ads_show == 1 && showadd == false ?
                         _buildAdvertise():Container(),
                       ],
                     ),
                   ),
                   ),
              ),
            ),
          )
          );
        });
  }

  _buildPage() {
    return Stack(
      children: <Widget>[
        RepaintBoundary(
          key: scr,
          child: ReadBlogScreenshot(
            getCurrentItem(),
          ),
        ),
        Positioned.fill(

          child: _buildBlog(
            context,
          ),
        ),
        display==true?
       _buildTopBackButton(context):
        Container(),
      ],
    );
  }

  _buildBlog(BuildContext context) {
    var widthTop = 0.035 * width - 5;
    return
      GestureDetector( onTap: () {
      setState(() {
        display=!display;
      });
    },
      child: Container(
        decoration: BoxDecoration(

            color:appThemeModel.value.isDarkModeEnabled.value ?
            Colors.black  :Colors.white,
        ),
        child: Column(
          children: <Widget>[
             //     Expanded(
        //       flex: 1,
        //       child: Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       children: [
        //         display==true?
        //         Container(): IconButton(
        //           icon: Icon(Icons.arrow_back_ios_sharp,color: Colors.black,),
        //           onPressed: (){
        //             Navigator.pop(context);
        //           },
        //         ),
        //         Container(
        //         child: _buildBlogNameAndDetails(context),
        //       ),
        //       // Container(
        // //   child: Image.asset("assets/img/logo.png"),
        // //   height: 18,),
        //       GestureDetector(
        //   onTap: () async{
        //       shareImage();
        //   },
        //   child: Container(
        //       padding: EdgeInsets.only(right: 10),
        //       //padding: EdgeInsets.all(5),
        //       // decoration: BoxDecoration(
        //       //   borderRadius: BorderRadius.circular(5.0),
        //       //   border: Border.all(
        //       //     color: Colors.black,
        //       //   ),
        //       //   color: Colors.white,
        //       // ),
        //       child:
        //       Image.asset(
        //         'assets/img/white/share.png',
        //         height: 22,
        //         width: 25,
        //         color: Colors.black,
        //       ),
        //   ),
        // ),
        // ]),
        //     ),

            // SizedBox(height:10),


            // SizedBox(height:10),

            Container(
              height: 0.5 * height,
              width: double.infinity,
              color: Colors.white,
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: _buildOverlayImage(),
                  ),
                 Container(
                   child:_buildBlogNameAndDetails(context),
                 ),
                  SafeArea(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 12,top: 10),
                        child: Card(color: Colors.white,
                            child: Container(height: 40,width: 40,
                                decoration: BoxDecoration(
                                image:  DecorationImage(
                                  image:  AssetImage("assets/img/app_icon.png"),

                                )
                            )),
                      ),
                      )
                    ],
                  )
                  ),
                ],
              ),
            ),
            // Expanded(
            //   child: Container(
            //     // height:MediaQuery.of(context).size.height*0.1,
            //     color: Theme
            //         .of(context)
            //         .cardColor,
            //     child: SingleChildScrollView(
            //       child: Column(
            //         children: [
            //           // ClipRRect(
            //           //   child: Container(
            //           //     width: double.infinity,
            //           //     height: 0.055 * height,
            //           //     decoration: BoxDecoration(
            //           //       borderRadius: BorderRadius.only(
            //           //         topLeft: Radius.circular(15.0),
            //           //         topRight: Radius.circular(15.0),
            //           //       ),
            //           //       color: HexColor("#F9F9F9"),
            //           //     ),
            //           //     child: Padding(
            //           //       padding: const EdgeInsets.only(
            //           //           left: 10.0, top: 8.0, bottom: 10.0),
            //           //       child: Row(
            //           //         children: <Widget>[
            //           //           Container(
            //           //             width: 0.035 * width,
            //           //             height: 0.035 * width,
            //           //             decoration: new BoxDecoration(
            //           //               color: HexColor(
            //           //                   widget.item.categoryColor.toString()),
            //           //               //color: Colors.orange,
            //           //               shape: BoxShape.circle,
            //           //             ),
            //           //           ),
            //           //           SizedBox(
            //           //             width: 5,
            //           //           ),
            //           //           Text(
            //           //             getCurrentItem().authorName != ''
            //           //                 ? getCurrentItem().authorName
            //           //                 : "By Admin",
            //           //             style: Theme.of(context)
            //           //                 .textTheme
            //           //                 .bodyText1
            //           //                 .merge(
            //           //                   TextStyle(
            //           //                       color: Colors.black,
            //           //                       fontFamily: 'Montserrat',
            //           //                       fontSize: 13.0,
            //           //                       fontWeight: FontWeight.normal),
            //           //                 ),
            //           //           ),
            //           //           SizedBox(
            //           //             width: 10,
            //           //           ),
            //           //           Text(
            //           //             "Publish On ",
            //           //             style: Theme.of(context)
            //           //                 .textTheme
            //           //                 .bodyText1
            //           //                 .merge(
            //           //                   TextStyle(
            //           //                       color: appThemeModel.value
            //           //                               .isDarkModeEnabled.value
            //           //                           ? Colors.white
            //           //                           : Colors.black,
            //           //                       fontFamily: 'Montserrat',
            //           //                       fontSize: 12.0,
            //           //                       fontWeight: FontWeight.normal),
            //           //                 ),
            //           //             textAlign: TextAlign.left,
            //           //           ),
            //           //           Text(
            //           //             getCurrentItem().createDate.toString(),
            //           //             style: Theme.of(context)
            //           //                 .textTheme
            //           //                 .bodyText1
            //           //                 .merge(
            //           //                   TextStyle(
            //           //                       color: appThemeModel.value
            //           //                               .isDarkModeEnabled.value
            //           //                           ? Colors.white
            //           //                           : Colors.black,
            //           //                       fontFamily: 'Montserrat',
            //           //                       fontSize: 12.0,
            //           //                       fontWeight: FontWeight.normal),
            //           //                 ),
            //           //             textAlign: TextAlign.left,
            //           //           ),
            //           //           isVolumeOn
            //           //               ? SizedBox(
            //           //                   width: widthTop,
            //           //                 )
            //           //               : Container(),
            //           //           isVolumeOn
            //           //               ? Container(
            //           //                   width: widthTop * 0.04 * width,
            //           //                   alignment: Alignment.center,
            //           //                   child: Text(
            //           //                     allMessages
            //           //                         .value.toStopPlayingTapAgain,
            //           //                     style: Theme.of(context)
            //           //                         .textTheme
            //           //                         .bodyText1
            //           //                         .merge(
            //           //                           TextStyle(
            //           //                               color: Colors.black,
            //           //                               fontFamily: 'Montserrat',
            //           //                               fontSize: 10.0,
            //           //                               fontWeight:
            //           //                                   FontWeight.normal),
            //           //                         ),
            //           //                     textAlign: TextAlign.left,
            //           //                   ),
            //           //                 )
            //           //               : Container(),
            //           //         ],
            //           //       ),
            //           //     ),
            //           //   ),
            //           // ),
            //           Container(
            //             alignment: Alignment.topLeft,
            //             decoration: BoxDecoration(
            //               color: Theme
            //                   .of(context)
            //                   .cardColor,
            //             ),
            //             child: Column(
            //               // alignment: Alignment.topLeft,
            //               children: [
            //                 // Padding(
            //                 //   padding: const EdgeInsets.only(
            //                 //     top: 0.0,
            //                 //     left: 0.0,
            //                 //     right: 0.0,
            //                 //   ),
            //                 //   //created date
            //                 //   child:Container(color: Colors.white,
            //                 //     padding: EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
            //                 //     // decoration: BoxDecoration(border: Border.all(color:Colors.white)),
            //                 //     child:Container()//title commented
            //                 //     // Text(
            //                 //     //  getCurrentItem().title,
            //                 //     //   style: Theme
            //                 //     //       .of(context)
            //                 //     //       .textTheme
            //                 //     //       .bodyText1
            //                 //     //       .merge(
            //                 //     //     TextStyle(
            //                 //     //         color: Colors.red,
            //                 //     //         fontFamily: 'Montserrat',letterSpacing: 1,
            //                 //     //         fontSize: 16.0,
            //                 //     //         fontWeight: FontWeight.bold),
            //                 //     //   ),
            //                 //     // ),
            //                 //   ),
            //                 // ),
            //                 // Divider(),
            //                 // Container(decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            //                 //   width: double.infinity,
            //                 //   /* height: getCurrentItem().isVotingEnabled ==
            //                 //               1 &&
            //                 //           currentUser.value.id != null
            //                 //       ? 0.34 * height
            //                 //       : height *
            //                 //           (0.425 +
            //                 //               (getCurrentItem().url == null
            //                 //                   ? 0.06
            //                 //                   : 0)),
            //                 //                   */
            //                 //   child: Padding(
            //                 //     padding: const EdgeInsets.only(
            //                 //       left: 10.0,
            //                 //       right: 10.0,
            //                 //       top: 10.0,
            //                 //       bottom: 10.0,
            //                 //     ),
            //                 //     child: Builder(
            //                 //       builder: (context) {
            //                 //
            //                 //         String text =getCurrentItem().description!=''?
            //                 //             parse(getCurrentItem().description).body.text:'';
            //                 //
            //                 //         return Column(
            //                 //           crossAxisAlignment:
            //                 //           CrossAxisAlignment.start,
            //                 //           children: [
            //                 //             Padding(
            //                 //               padding: const EdgeInsets.only(
            //                 //                   top: 10.0),
            //                 //               child: Text(
            //                 //                 text,
            //                 //                 //overflow: TextOverflow.ellipsis,
            //                 //                 maxLines: getCurrentItem()
            //                 //                     .isVotingEnabled ==
            //                 //                     1 &&
            //                 //                     currentUser.value.id !=
            //                 //                         null
            //                 //                     ? (height / 70).toInt()
            //                 //                     : (height / 50).toInt(),
            //                 //                 overflow: TextOverflow.ellipsis,
            //                 //                 style: TextStyle(
            //                 //                   color: appThemeModel.value
            //                 //                       .isDarkModeEnabled.value
            //                 //                       ? Colors.white
            //                 //                       : Colors.black,letterSpacing: 1,
            //                 //                   fontFamily: 'Montserrat',
            //                 //                   fontSize:
            //                 //                   defaultFontSize.value !=
            //                 //                       null
            //                 //                       ? defaultFontSize.value
            //                 //                       .toDouble()
            //                 //                       : 16,
            //                 //                 ),
            //                 //               ),
            //                 //             ),
            //                 //           ],
            //                 //         );
            //                 //       },
            //                 //     ),
            //                 //   ),
            //                 // ),
            //               ],
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
           // Divider(height: 12,),
           //  display == true?
           //  ClipRRect(
           //    child: Container(
           //      width: double.infinity,
           //      height: 0.03 * height,
           //      decoration: BoxDecoration(
           //        border: Border.all(color: Colors.red),
           //        borderRadius: BorderRadius.only(
           //          topLeft: Radius.circular(15.0),
           //          topRight: Radius.circular(15.0),
           //        ),
           //        color: Colors.white,
           //      ),
           //      child: Padding(
           //        padding: const EdgeInsets.only(
           //            left: 1.0, top: 10.0, bottom: 0.0),
           //        child: Row(
           //          children: <Widget>[
           //            Container(
           //              width: 0.03 * width,
           //              height: 0.038 * width,
           //              // decoration: new BoxDecoration(
           //              //   color: HexColor(
           //              //       widget.item.categoryColor.toString()),
           //              //   //color: Colors.orange,
           //              //   shape: BoxShape.circle,
           //              // ),
           //            ),
           //            SizedBox(
           //              width: 0,
           //            ),
           //            Text(
           //              getCurrentItem().authorName != ''
           //                  ? getCurrentItem().authorName
           //                  : "By Admin",
           //              style: Theme
           //                  .of(context)
           //                  .textTheme
           //                  .bodyText1
           //                  .merge(
           //                TextStyle(
           //                    color: Colors.black,
           //                    fontFamily: 'Montserrat',
           //                    fontSize: 10.0,
           //                    fontWeight: FontWeight.bold),
           //              ),
           //            ),
           //            SizedBox(
           //              width: 5,
           //            ),
           //            Text(
           //              "Publish On ",
           //              style: Theme
           //                  .of(context)
           //                  .textTheme
           //                  .bodyText1
           //                  .merge(
           //                TextStyle(
           //                    color: appThemeModel.value
           //                        .isDarkModeEnabled.value
           //                        ? Colors.white
           //                        : Colors.black,
           //                    fontFamily: 'Montserrat',
           //                    fontSize: 10.0,
           //                    fontWeight: FontWeight.bold),
           //              ),
           //              textAlign: TextAlign.left,
           //            ),
           //            Text(
           //              getCurrentItem().createDate.toString(),
           //              style: Theme
           //                  .of(context)
           //                  .textTheme
           //                  .bodyText1
           //                  .merge(
           //                TextStyle(
           //                    color: appThemeModel.value
           //                        .isDarkModeEnabled.value
           //                        ? Colors.white
           //                        : Colors.black,
           //                    fontFamily: 'Montserrat',
           //                    fontSize: 10.0,
           //                    fontWeight: FontWeight.bold),
           //              ),
           //              textAlign: TextAlign.left,
           //            ),
           //            // isVolumeOn
           //            //     ? SizedBox(
           //            //   width: widthTop,
           //            // )
           //            //     : Container(),
           //            // isVolumeOn
           //            //     ? Container(
           //            //   width: widthTop * 0.035 * width,
           //            //   alignment: Alignment.center,
           //            //   child: Text(
           //            //     allMessages
           //            //         .value.toStopPlayingTapAgain,
           //            //     style: Theme
           //            //         .of(context)
           //            //         .textTheme
           //            //         .bodyText1
           //            //         .merge(
           //            //       TextStyle(
           //            //           color: Colors.blue,
           //            //           fontFamily: 'Montserrat',
           //            //           fontSize: 10.0,
           //            //           fontWeight:
           //            //           FontWeight.bold),
           //            //     ),
           //            //     textAlign: TextAlign.left,
           //            //   ),
           //            // )
           //            //     : Container(),
           //          ],
           //        ),
           //      ),
           //    ),
           //  ):
           //  Container(
           //    //  decoration: BoxDecoration(border: Border.all(color: Colors.black)),
           //  //    height: MediaQuery.of(context).size.height*0.035
           //  ),
            SizedBox(height:10),
            Container(

              height:MediaQuery.of(context).size.height*0.1,
              width:MediaQuery.of(context).size.width*0.95,
              decoration: BoxDecoration(

              ),
              padding: EdgeInsets.only(left: 1,right: 5,top: 0,bottom: 3),
              // decoration: BoxDecoration(border: Border.all(color:Colors.white)),
              child: Text(
                getCurrentItem().title,maxLines: 3,
                style: Theme.of(context).textTheme.bodyText1.merge(
                  TextStyle(
                      color: Colors.red,
                      fontFamily: 'Montserrat',letterSpacing: 1,wordSpacing: 1,
                      fontSize: defaultFontSize.value.toDouble()+3,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                height:MediaQuery.of(context).size.height*0.2,
                width:MediaQuery.of(context).size.width*0.95,
                decoration: BoxDecoration(
                ),
                padding: EdgeInsets.only(left: 1,right: 5,top: 0,bottom: 3),
                // decoration: BoxDecoration(border: Border.all(color:Colors.white)),
                child: Text(
                  parse(getCurrentItem().description).body.text,
                  style: Theme.of(context).textTheme.bodyText1.merge(
                    TextStyle(
                        color: appThemeModel.value.isDarkModeEnabled.value ?
                        Colors.white  :Colors.black,
                        fontFamily: 'Montserrat',letterSpacing: 1,wordSpacing: 1,
                        fontSize: defaultFontSize.value.toDouble(),
                        // overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ),
            ),

            getCurrentItem().url != null
                ? Container(
                height: 0.14 * height,
                  width: width,
                  color: Theme
                    .of(context)
                    .cardColor,
              child:display == true?
                  Card(
                    color: appThemeModel.value.isDarkModeEnabled.value ?Colors.black:Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ClipRRect(
                          child: Container(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 1.0, top: 10.0, bottom: 0.0),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    getCurrentItem().authorName != ''
                                        ? getCurrentItem().authorName
                                        : "By Admin",
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .bodyText1
                                        .merge(
                                      TextStyle(
                                          color: appThemeModel.value.isDarkModeEnabled.value ?Colors.white:Colors.black,
                                          fontFamily: 'Montserrat',
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "Publish On ",
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .bodyText1
                                        .merge(
                                      TextStyle(
                                          color: appThemeModel.value
                                              .isDarkModeEnabled.value
                                              ? Colors.white
                                              : Colors.black,
                                          fontFamily: 'Montserrat',
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  Text(
                                    getCurrentItem().createDate.toString(),
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .bodyText1
                                        .merge(
                                      TextStyle(
                                          color: appThemeModel.value
                                              .isDarkModeEnabled.value
                                              ? Colors.white
                                              : Colors.black,
                                          fontFamily: 'Montserrat',
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  isVolumeOn
                                      ? SizedBox(
                                    width: widthTop,
                                  )
                                      : Container(),
                                  isVolumeOn
                                      ? Container(
                                    width: widthTop * 0.03 * width,
                                    alignment: Alignment.center,
                                    child: Text(
                                      allMessages
                                          .value.toStopPlayingTapAgain,
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .bodyText1
                                          .merge(
                                        TextStyle(
                                            color: Colors.blue,
                                            fontFamily: 'Montserrat',
                                            fontSize: 10.0,
                                            fontWeight:
                                            FontWeight.bold),
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  )
                                      : Container(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Container(
                          height: 0.05*height,
                          decoration: BoxDecoration(
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  currentUser.value.id != null
                                      ? GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (like_count == false && isBookmarkdislike == false) {
                                          _likePost();
                                          like_count = true;
                                        } else {
                                          like_count = false;
                                        }
                                      });
                                    },
                                    child: Card(
                                      color: Colors.grey[100],elevation: 5,
                                      child: Container(padding: EdgeInsets.all(2),
                                        // decoration: BoxDecoration(
                                        //   borderRadius:
                                        //       BorderRadius.circular(5.0),
                                        //   border: Border.all(
                                        //     color: Colors.black,
                                        //   ),
                                        //   color: Colors.white,
                                        // ),
                                        child: like_count == true
                                            ? Icon(
                                          Icons.favorite_border,
                                          color: Colors.black,
                                          size: 22,
                                        )
                                            : Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  )
                                      : Container(),
                                  // getCurrentItem().url != null
                                  //     ?
                                  //  Text(
                                  //         "Swipe",
                                  //         style: TextStyle(
                                  //           color: appThemeModel
                                  //                   .value.isDarkModeEnabled.value
                                  //               ? Colors.white
                                  //               : Colors.black,
                                  //           fontSize: 15,
                                  //         ),
                                  //       )
                                  //     : Container(),
                                  // getCurrentItem().url != null
                                  //   ? Icon(Mdi.arrowLeftBoldBoxOutline)
                                  // : Container(),
                                  // getCurrentItem().url != null
                                  //     ? Text(
                                  //         " For More ",
                                  //         style: TextStyle(
                                  //           color: appThemeModel
                                  //                   .value.isDarkModeEnabled.value
                                  //               ? Colors.white
                                  //               : Colors.black,
                                  //           fontSize: 15,
                                  //         ),
                                  //       )
                                  //     : Container(),
                                  SizedBox(
                                    width: 7,
                                  ),
                                  currentUser.value.id != null
                                      ? GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isBookmark == false
                                            && isBookmarkdislike == false
                                        ) {
                                          Fluttertoast.showToast(
                                              msg: "Bookmark Successfully",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.TOP,
                                              backgroundColor: Colors.green,
                                              textColor: Colors.white);
                                          _savePost();
                                          isBookmark = true;
                                        } else {
                                          Fluttertoast.showToast(
                                              msg: "Un-Bookmarked",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.TOP,
                                              backgroundColor: Colors.green,
                                              textColor: Colors.white);
                                          isBookmark = false;
                                        }
                                      });
                                    },
                                    child: Card(color: Colors.grey[100],elevation: 5,

                                      child: Container(

                                        child: isBookmark == true
                                            ? Icon(
                                          Icons.bookmark,
                                          color: Colors.blue,
                                          size: 25,
                                        )
                                            : Icon(
                                          Icons.bookmark_border,
                                          color: Colors.black,
                                          size: 25,
                                        ),
                                      ),
                                    ),
                                  )
                                      : Container(),

                                  SizedBox(width:5),



                                  // currentUser.value.id != null
                                  //     ? GestureDetector(
                                  //   onTap: () {
                                  //     setState(() {
                                  //       if (isBookmarkdislike == false &&  like_count == false ) {
                                  //         //_savePost();
                                  //         isBookmarkdislike = true;
                                  //       } else {
                                  //         isBookmarkdislike = false;
                                  //       }
                                  //     });
                                  //   },
                                  //   child: Card(color: Colors.grey[100],elevation: 5,
                                  //     child: Container(padding: EdgeInsets.all(2),
                                  //       child: isBookmarkdislike == true
                                  //           ? Icon(
                                  //         Icons.thumb_down_alt_sharp,
                                  //         color: Colors.blue,
                                  //         size: 22,
                                  //       )
                                  //           : Icon(
                                  //         Icons.thumb_down_outlined,
                                  //         color: Colors.black,
                                  //         size: 22,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // )
                                  //     : Container(),

                                  SizedBox(
                                      width:5
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      comment();
                                    },
                                    child: Card(elevation: 5,color: Colors.grey[100],
                                      child: Container(
                                          padding: EdgeInsets.all(2),
                                          // decoration: BoxDecoration(
                                          //   borderRadius: BorderRadius.circular(5.0),
                                          //   border: Border.all(
                                          //     color: Colors.black,
                                          //   ),
                                          //   color: Colors.white,
                                          // ),
                                          child: Icon(
                                            Icons.comment_bank_outlined, size: 22,
                                            color: Colors.black,
                                          )
                                        // Image.asset(
                                        //   'assets/img/white/share.png',
                                        //   height: 20,
                                        //   width: 20,
                                        //   color: Color(0xff48D1CC),
                                        // ),
                                      ),
                                    ),
                                  ),
                                  // SizedBox(
                                  //   width: 10,
                                  // ),

                                  // SizedBox(
                                  //   width: 10,
                                  // ),
                                  SizedBox(
                                    width: currentUser.value.id != null ? 5 : 0,
                                  ),
                                  // for volume sound

                                  languageCode.value.language!='gj'?
                                  Card(
                                  color: Colors.grey[100],
                                    shape:StadiumBorder(
                                      side: BorderSide(
                                        color: Colors.white,
                                        width: 2.0,
                                      ),
                                    ),
                                   elevation: 5,
                                    child: Container(
                                      padding: EdgeInsets.all(2),
                                      // decoration: BoxDecoration(
                                      //   borderRadius: BorderRadius.circular(5.0),
                                      //   border: Border.all(
                                      //     color: Colors.black,
                                      //   ),
                                      //   color: Colors.white,
                                      // ),
                                      child:
                                      VisibilityDetector(
                                        key: Key(getCurrentItem().title),
                                        onVisibilityChanged:
                                            (visibilityInfo) async {
                                          var visiblePercentage =
                                              visibilityInfo.visibleFraction *
                                                  100.0;
                                          if (visiblePercentage != 100.0) {
                                            if (isVolume) {
                                              stop();
                                            }
                                            isVolume = false;
                                          }
                                        },
                                        child: GestureDetector(
                                          child:Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Image.asset(
                                              isVolume
                                                  ? 'assets/img/white/pause.png'
                                                  : 'assets/img/white/play.png',
                                              //play.png
                                              height: 20,
                                              width: 20,
                                              fit: BoxFit.cover,
                                              color: Colors.black,
                                            ),
                                          ),

                                          onTap: () {
                                            setState(() {
                                              if (isVolume == false) {
                                                init(getCurrentItem()
                                                    .trimedDescription);
                                                isVolume = true;
                                                isVolumeOn = true;
                                                Future.delayed(
                                                    const Duration(
                                                        milliseconds: 700), () {
                                                  isVolumeOn = false;
                                                });
                                              } else {
                                                stop();
                                                isVolume = false;
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ):Container(),
                                  // languageCode.value.language!='gj'?
                                  // Card(color: Colors.grey[100],elevation: 5,
                                  //   child: Container(
                                  //     padding: EdgeInsets.all(2),
                                  //     // decoration: BoxDecoration(
                                  //     //   borderRadius: BorderRadius.circular(5.0),
                                  //     //   border: Border.all(
                                  //     //     color: Colors.black,
                                  //     //   ),
                                  //     //   color: Colors.white,
                                  //     // ),
                                  //
                                  //     child:
                                  //     VisibilityDetector(
                                  //       key: Key(getCurrentItem().title),
                                  //       onVisibilityChanged:
                                  //           (visibilityInfo) async {
                                  //         var visiblePercentage =
                                  //             visibilityInfo.visibleFraction *
                                  //                 100.0;
                                  //         if (visiblePercentage != 100.0) {
                                  //           if (isVolume) {
                                  //             stop();
                                  //           }
                                  //           isVolume = false;
                                  //         }
                                  //       },
                                  //       child: GestureDetector(
                                  //         child: Image.asset(
                                  //           isVolume
                                  //               ? 'assets/img/white/pause.png'
                                  //               : 'assets/img/white/play.png',
                                  //           //play.png
                                  //           height: 21,
                                  //           width: 21,
                                  //           fit: BoxFit.cover,
                                  //           color: Colors.black,
                                  //         ),
                                  //         onTap: () {
                                  //           setState(() {
                                  //             if (isVolume == false) {
                                  //               init(getCurrentItem()
                                  //                   .trimedDescription);
                                  //               isVolume = true;
                                  //               isVolumeOn = true;
                                  //               Future.delayed(
                                  //                   const Duration(
                                  //                       milliseconds: 700), () {
                                  //                 isVolumeOn = false;
                                  //               });
                                  //             } else {
                                  //               stop();
                                  //               isVolume = false;
                                  //             }
                                  //           });
                                  //         },
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ):Container(),
                                  // pause play button
                                ],
                              ),
                              GestureDetector(
                                onTap: () async {
                                  shareImage();
                                },
                                child: Card( color: Colors.white,elevation: 5,
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    // decoration: BoxDecoration(
                                    //   borderRadius: BorderRadius.circular(5.0),
                                    //   border: Border.all(
                                    //     color: Colors.black,
                                    //   ),
                                    //   color: Colors.white,
                                    // ),
                                    child:
                                    Image.asset(
                                      'assets/img/white/share.png',
                                      height: 21,
                                      width: 21,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ) :
                  Container(
              //  decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                padding:EdgeInsets.only(left: 2,right: 2,bottom: 3),
                height: MediaQuery.of(context).size.height*0.08,
                width: MediaQuery.of(context).size.width,
                child: Card(
                  color: appThemeModel.value.isDarkModeEnabled.value?
                  Colors.black:Colors.grey[100],
                    // padding:EdgeInsets.only(left: 10,right: 5,bottom: 10),
                  // height: MediaQuery.of(context).size.height*0.0752,
                  //   width: MediaQuery.of(context).size.width,
                  child: GestureDetector(
                        onTap: () { if (index == 0)
                          _openLink();
                        },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: Text(
                                parse(getCurrentItem().title ?? "desc").body.text ?? 'disc',
                                maxLines: 2,
                                style: Theme.of(context).textTheme.bodyText1.merge(TextStyle(
                                    color:appThemeModel.value.isDarkModeEnabled.value? Colors.white:Colors.black,
                                    fontFamily: 'Montserrat',letterSpacing: 1,
                                    fontSize: 13.0,
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: FontWeight.bold)),
                              ),
                            ) ,

                            Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                               borderRadius: BorderRadius.circular(5),
                               border: Border.all(color:Colors.black)
                             ),
                              child: Text('Tap For More ...',textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,letterSpacing: 1),),
                            )
                          ],
                        ),
                      ),

                  ),
              ),
            )
                :Container(),
            // currentUser.value.id != null &&
            //     getCurrentItem().isVotingEnabled == 1
            //     ? _buildVotingCard()
            //     : Container(),
          ],
        ),
      ),
    );
  }

  _buildVotingCard() {
    return Container(
      width: double.infinity,
      height: 0.09 * height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0),
      ),
      child: getCurrentItem().isVote == 0
          ? _buildVotingMech()
          : _buildIsParticipated(),
    );
  }

  _buildVotingMech() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: ShapePainter(),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    "${allMessages.value.doYouAgree}",
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodyText1
                        .merge(
                      TextStyle(
                          color: appThemeModel.value.isDarkModeEnabled.value
                              ? Colors.white
                              : Colors.black,
                          fontFamily: 'Montserrat',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    ButtonTheme(
                      minWidth: 0.25 * width,
                      child: RaisedButton(
                        onPressed: () {
                          setState(() {
                            _saveVoting(1);
                          });
                        },
                        color: HexColor("#016300"),
                        child: Text(
                          allMessages.value.yes,
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyText1
                              .merge(
                            TextStyle(
                                color: Colors.white,
                                fontFamily: 'Montserrat',
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    ButtonTheme(
                      minWidth: 0.25 * width,
                      child: RaisedButton(
                        onPressed: () {
                          setState(() {
                            _saveVoting(0);
                          });
                        },
                        color: HexColor("#C62226"),
                        child: Text(
                          allMessages.value.no,
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyText1
                              .merge(
                            TextStyle(
                                color: Colors.white,
                                fontFamily: 'Montserrat',
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _buildIsParticipated() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: ShapePainter(),
          child: Column(
            children: [
              Spacer(),
              Container(
                child: Center(
                  child: Text(
                    allMessages.value.thankYouForParticipating,
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodyText1
                        .merge(
                      TextStyle(
                          color: appThemeModel.value.isDarkModeEnabled.value
                              ? Colors.white
                              : Colors.black,
                          fontFamily: 'Montserrat',
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
              Spacer(),
              SizedBox(
                height: 0.5 * constraints.maxHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    getCurrentItem().yesPercent > 0
                        ? ButtonTheme(
                      minWidth: widget.item.yesPercent /
                          100 *
                          constraints.maxWidth -
                          2,
                      height: constraints.maxHeight * 0.5,
                      child: RaisedButton(
                        onPressed: () {},
                        color: HexColor("#016300"),
                        child: Text(
                          getCurrentItem().yesPercent.toString() +
                              "% ${allMessages.value.yes}",
                          style:
                          Theme
                              .of(context)
                              .textTheme
                              .bodyText1
                              .merge(
                            TextStyle(
                                color: Colors.white,
                                fontFamily: 'Montserrat',
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                    )
                        : Container(),
                    getCurrentItem().noPercent > 0 &&
                        getCurrentItem().yesPercent > 0
                        ? Container(
                      color: HexColor("#000000"),
                      height: 55,
                      width: 3,
                    )
                        : Container(),
                    getCurrentItem().noPercent > 0
                        ? Center(
                      child: ButtonTheme(
                        minWidth: widget.item.noPercent /
                            100 *
                            constraints.maxWidth -
                            1,
                        height: constraints.maxHeight * 0.5,
                        child: RaisedButton(
                          onPressed: () {},
                          color: HexColor("#C62226"),
                          child: Text(
                            getCurrentItem().noPercent.toString() +
                                "% ${allMessages.value.no}",
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodyText1
                                .merge(
                              TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Montserrat',
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                      ),
                    )
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _buildBookmark() {
    return currentUser.value.id != null
        ? Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 5.0),
      child: GestureDetector(
        child: !isBookmark
            ? Icon(
          Icons.bookmark_border,
          color: Colors.black,
          size: 25,
        )
            : Icon(
          Icons.bookmark,
          color: Colors.black,
          size: 25,
        ),
        onTap: () {
          setState(() {
            if (isBookmark == false) {
              _savePost();
              isBookmark = true;
            } else {}
          });
        },
      ),
    )
        : IconButton(
      icon: Icon(Icons.aspect_ratio, color: Colors.black),
      onPressed: () {},
    );
  }

  Path _buildBoatPath() {
    return Path()
      ..moveTo(15, 120)
      ..lineTo(0, 85)..lineTo(50, 85)..lineTo(60, 80)..lineTo(60, 85)..lineTo(
          120, 85)..lineTo(
          105, 120) //and back to the origin, could not be necessary #1
      ..close();
  }

  _buildOverlayImage() {
    return Stack(
      children: <Widget>[
        widget.item.contentType == "video"
            ? linkOpen
            ? SizedBox.shrink()
            : CustomVideoPlayer(
          blog: getCurrentItem(),
          key: videoPlayeState,
        )
            : getCurrentItem().bannerImage.length > 1
            ? Positioned(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        height: height * 0.6,
                        viewportFraction: 1.0,
                        enlargeCenterPage: false,
                        autoPlay: true,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _current = index;
                          });
                        },
                      ),
                      items: getCurrentItem()
                          .bannerImage
                          .map<Widget>((item) =>
                          Container(
                            child: Center(
                                child: CachedNetworkImage(
                                  imageUrl: item,
                                  fit: BoxFit.cover,
                                  cacheKey: item,
                                )),
                          ))
                          .toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                      getCurrentItem().bannerImage.map<Widget>((url) {
                        int index =
                        getCurrentItem().bannerImage.indexOf(url);
                        return Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: Container(
                            width: 10.0,
                            height: 10.0,
                            margin: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 2.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _current == index
                                  ? Color.fromRGBO(0, 0, 0, 0.9)
                                  : Color.fromRGBO(0, 0, 0, 0.4),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                )
              ],
            ))
            : Positioned.fill(
            child: Image.network(
              getCurrentItem().bannerImage[0],
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
      ],
    );
  }

  _buildBlogNameAndDetails(BuildContext context) {
    _viewPost();
    return Container(
      alignment: Alignment.bottomLeft,
     
      padding: EdgeInsets.only(left: 10,bottom: 10),
      child: Card(
        color: Colors.black,
          shape:StadiumBorder(
            side: BorderSide(
              color: Colors.white,
              width: 2.0,
            ),
          ),
        child: Container(
          height: MediaQuery.of(context).size.height*0.035,
          width: MediaQuery.of(context).size.width*0.4,
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(4.0),
          alignment: Alignment.topLeft,
          child: Center(
            child: Text(
              getCurrentItem().categoryName.toUpperCase(),
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyText1
                  .merge(
                TextStyle(
                    backgroundColor: Colors.transparent,
                    color: Colors.white,
                    fontFamily: 'Montserrat',letterSpacing: 1,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildVoting(BuildContext context) {
    return Positioned(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff7c94b6),
          image: const DecorationImage(
            image: NetworkImage(
                'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg'),
            fit: BoxFit.cover,
          ),
          border: Border.all(
            color: Colors.black,
            width: 8,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  _buildTopBackButton(BuildContext context) {
    return Positioned(
      top: 30.0,
      left: 15.0,
      child: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black54,
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back,color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _viewPost() async {
    print("getCurrentItem().id ${getCurrentItem().id}");
    print("currentUser.value.id ${currentUser.value.id}");
    final msg = jsonEncode(
        {"blog_id": getCurrentItem().id, "user_id": currentUser.value.id});
    final String url =
        '${GlobalConfiguration().getValue(
        'api_base_url')}increaseBlogViewCount';
    final client = new http.Client();
    final response = await client.post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        "lang-code": languageCode.value?.language ?? null
      },
      body: msg,
    );
    print("response.body ${response.body}");
    Map dataNew = json.decode(response.body);
  }

  void _savePost() async {

    print("call save post");

    print("current value" + currentUser.value.id.toString());
    if (currentUser.value.id == null) {
      const snackBar = SnackBar(
        content: Text('User not login please login'),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    else {
      final msg = jsonEncode(

          {"blog_id": getCurrentItem().id, "user_id": currentUser.value.id}

      );

      final String url = '${GlobalConfiguration().getValue(
          'api_base_url')}bookmarkPost';
      final client = new http.Client();
      final response = await client.post(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          "lang-code": languageCode.value?.language ?? null,
        },
        body: msg,
      );
      print("response ${response.statusCode}");
      Map data = json.decode(response.body);
      print("response $data");
      isBookmark = true;

      getCurrentItem().isBookmarked = data['data']['is_bookmark'];
      Fluttertoast.showToast(
          msg: data['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.green,
          textColor: Colors.white);
      getBlogVotes();
    }
  }

  void _savecomment(text) async {
    if (currentUser.value.id == null) {
      print("current value" + currentUser.value.id.toString());
      const snackBar = SnackBar(
        content: Text('User not login please login'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    else {
      final msg = jsonEncode({
        "blog_id": getCurrentItem().id.toString(),
        "user_id": currentUser.value.id.toString(),
        "comment": text.toString()
      });

      final String url =
          '${GlobalConfiguration().getValue('api_base_url')}commentPost';
      print('url' + url.toString());
      final client = new http.Client();
      final response = await client.post(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          "lang-code": languageCode.value?.language ?? null,
        },
        body: msg,
      );

      Map data = json.decode(response.body);
      print("response $data");
      // isBookmark = true;
      // getCurrentItem().isBookmarked = data['data']['is_bookmark'];
      // Fluttertoast.showToast(
      //     msg: data['message'],
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.TOP,
      //
      //     backgroundColor: Colors.green,
      //     textColor: Colors.white);
      getBlogVotes();
      setState(() {
        getcomment();
      });

      // Navigator.pop(context);
    }
  }

  _deletecomment(id, commneteduser_id) async {
    if (currentUser.value.id.toString() == commneteduser_id.toString()) {
      print("this is delete");
      final msg = jsonEncode({

        "id": id,
      });
      final String url =
          '${GlobalConfiguration().getValue('api_base_url')}commentDelete';
      print('url' + url.toString());
      final client = new http.Client();
      final response = await client.post(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          "lang-code": languageCode.value?.language ?? null,
        },
        body: msg,
      );
      print(response.body);


      Fluttertoast.showToast(
          msg: "Comment deleted successfully",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 12
      );
      setState(() {
        getcomment();
      });
    }
    else {
      Fluttertoast.showToast(
          msg: "Not Authorized to Delete !!..",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 12
      );
    }
  }

  void _swipetoBlogs(type, context) async {
    final msg = jsonEncode({"blog_id": getCurrentItem().id, "type": type});
    final String url =
        '${GlobalConfiguration().getValue('api_base_url')}nextPreviousBlog';
    final client = new http.Client();
    final response = await client.post(
      url,
      headers: {
        "Content-Type": "application/json",
        'userData': currentUser.value.id,
        "lang-code": languageCode.value?.language ?? null
      },
      body: msg,
    );
    print("swipe blog data ${response.body}");
    Map data = json.decode(response.body);
    final list =
    (data['data'] as List).map((i) => new Blog.fromMap(i)).toList();
    setState(() {
      blogList = list;
      Navigator.of(context).pushNamed("/ReadBlog", arguments: blogList[0]);
    });
  }

  void _openLink() async {
    try {
      Fluttertoast.showToast(msg: "Opening News in Web");
      Helper.launchURL(getCurrentItem().url);
    } catch (e) {
      Fluttertoast.showToast(msg: "Invalid Link");
    }

    setState(() {
      isOpeningWebPage = false;
    });
  }

  void _saveVoting(vote) async {
    _isLoading = true;
    final msg = jsonEncode({
      "vote": vote,
      "user_id": currentUser.value.id,
      'blog_id': getCurrentItem().id
    });
    print("msg $msg");
    final String url =
        '${GlobalConfiguration().getValue('api_base_url')}addBlogVote';
    final client = new http.Client();
    final response = await client.post(
      url,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: msg,
    );
    print("_saveVoting response $response");
    Map data = json.decode(response.body);
    getBlogVotes();
  }

  void getBlogVotes() async {
    print(
        "getBlogVotes currentUser.value.id ${currentUser.value
            .id} ${languageCode.value?.language}");

    final msg = jsonEncode({"blog_id": getCurrentItem().id});
    final String url =
        '${GlobalConfiguration().getValue('api_base_url')}getBlogVote';
    final client = new http.Client();
    final response = await client.post(
      url,
      headers: {
        "Content-Type": "application/json",
        'userData': currentUser.value.id,
        "lang-code": languageCode.value?.language ?? null
      },
      body: msg,
    );
    Map data = json.decode(response.body);
    setState(() {
      getCurrentItem().isVote = data['data']['is_vote'];
      getCurrentItem().yesPercent = data['data']['yes_percent'];
      getCurrentItem().noPercent = data['data']['no_percent'];
      getCurrentItem().isBookmarked = data['data']['is_bookmark'];
      getCurrentItem().like_count = data['data']['like_count'];
      _isLoading = false;
    });
  }

  getcomment() async {
    final String url = '${GlobalConfiguration().getValue(
        'api_base_url')}commentList';
    print("url" + url.toString());

    final client = new http.Client();
    final response = await client.post(
      url,
      body: {"blog_id": getCurrentItem().id.toString()},
    );
    setState(() {
      var alldata = json.decode(response.body);
      print(alldata['data']['comment']);
      blogs_comment = alldata['data']['comment'];

      //  print("data" + alldata["data"].toString());
      // List commentlist = alldata["data"];

      // for (var i = 0; i < commentlist.length; i++) {
      //   List blog = commentlist[i]['blog'];
      //   print("comment length" + blog.length.toString());
      //
      //   for (var j = 0; j < blog.length; j++) {
      //
      //    List  comment_lenght = blog[j]['blog_comment'];
      //    print( "comment_length"+comment_lenght.length.toString());
      //
      //     for (var g = 0; g < comment_lenght.length; g++) {
      //       setState(() {
      //         blogs_comment.add(comment_lenght[g]);
      //         print("allcommet"+ blogs_comment.toString());
      //       });
      //     }
      //   }
      // }
    });
    // print("blog"+ commentlist.toString());
    //  print("all data="+response.body.toString());
  }

  Future<void> _shareText() async {
    try {
      var request =
      await HttpClient().getUrl(Uri.parse(getCurrentItem().bannerImage[0]));
      var response = await request.close();
      Uint8List bytes = await consolidateHttpClientResponseBytes(response);
      await Share.file('ESYS AMLOG', 'amlog.jpg', bytes, 'image/jpg',
          text: getCurrentItem().title);
    } catch (e) {}
  }

  Future<Uint8List> _capturePng() async {
    RenderRepaintBoundary boundary;
    try {
      boundary = scr.currentContext.findRenderObject();
    } catch (e) {}

    if (boundary == null) {
      print("Waiting for boundary to be painted.");
      await Future.delayed(const Duration(milliseconds: 20));
      return _capturePng();
    }
    try {
      var image = await boundary.toImage(pixelRatio: 3.0);
      var byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData.buffer.asUint8List();
    } catch (e) {}

    return null;
  }
  // Future<void> _capturePng() async {
  //   final RenderRepaintBoundary boundary = globalKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  //   final Image image = (await boundary.toImage(pixelRatio: 3.0)) as Image;
  //   final  byteData = await image.toByteData(format: ImageByteFormat.png);
  //   final Uint8List pngBytes = byteData.buffer.asUint8List();
  //   print(pngBytes);
  // }
  shareImage() async {
    BotToast.showLoading();
    var pngBytes = await _capturePng();
    print("pngBytes $pngBytes");

    try {
      await Share.file(
        'esys image',
        'esys.png',
        pngBytes,
        'image/png',
         text: "Save time.Download TheHeadlines,india's highest rated news app,to read news in 40 words. \n" + getCurrentItem().url
        // text: "https://theheadlines.co.in",
      );
    } catch (e) {
      BotToast.showText(text: "shareImage $e");
    }
    BotToast.cleanAll();
  }

  comment() async {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      backgroundColor: Colors.white,
      // context and builder are
      // required properties in this widget
      context: context,
      builder: (BuildContext context) {
        // we set up a container inside which
        // we create center column and display text
        return Container(
          padding:
          EdgeInsets.only(bottom: MediaQuery
              .of(context)
              .viewInsets
              .bottom),
          // padding: EdgeInsets.only(top: 15),
          //  height: MediaQuery.of(context).size.height*0.8,
          child: RefreshIndicator(onRefresh:_refresh ,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //   Text('data',style: TextStyle(color: Colors.black),),
                  // Text('data'),
                  //   getCurrentItem().blog_comment.length > 0 ?
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: blogs_comment.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                          leading: Icon(
                            Icons.comment_outlined,
                            color: Colors.blue,
                          ),
                          // trailing: Text('$index',style: TextStyle(
                          //   color:Colors.blue,fontSize: 14
                          // ),
                          // ),
                          title: Text(
                            blogs_comment[index]['comment'].toString(),
                            maxLines: 5,
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                letterSpacing: 1),
                          ),

                          trailing: GestureDetector(
                              onTap: () {
                                Widget cancelButton = TextButton(
                                  child: Text("No"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                );
                                Widget continueButton = TextButton(
                                  child: Text("Yes"),
                                  onPressed: () {
                                    _deletecomment(blogs_comment[index]['id'],
                                        blogs_comment[index]['user_id']);
                                    Navigator.pop(context);
                                  },
                                );
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Delete Comment"),
                                      content: Text("Are you sure to delete the Comment"),
                                      actions: [
                                        cancelButton,
                                        continueButton,
                                      ],
                                    );
                                  },
                                );
                                print("id" + blogs_comment[index]['id'].toString());
                              },
                              child: Icon(Icons.more_horiz, color: Colors
                                  .blue,)) //$index
                      );
                    },
                  ),
                  // Container(
                  // padding: EdgeInsets.only(left: 10),
                  // child: Text ("Be the first to the comment",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 13,letterSpacing: 1,color: Colors.black),)),

                  userlogin == true
                      ? Center(
                    child: Container(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      // decoration: BoxDecoration(border: Border.all(color: Colors.black),
                      //     borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Row(
                            children: [
                              Text(
                                'Comments...',
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          TextField(
                            controller: commentcon,
                            keyboardType: TextInputType.multiline,
                            // autofocus: true,
                            style: TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                                suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _savecomment(commentcon.text);
                                        commentcon.text = '';
                                      });
                                    },
                                    child: Icon(
                                      Icons.send_sharp,
                                      color: Colors.blue,
                                    )),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                hintText: 'Please Do Your Comment Here',
                                hintStyle: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400)),
                          ),
                          //   const Text('Please Comment Here',style: TextStyle(color: Colors.deepOrange),),
                        ],
                      ),
                    ),
                  )
                      : Container(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        "Please Login First",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            letterSpacing: 1,
                            color: Colors.black),
                      )),
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _buildAdvertise() {
    return  Stack(
      children: [
        Container(
          height:MediaQuery.of(context).size.height,
          width:MediaQuery.of(context).size.width,
          child: GestureDetector(
              onTap: () {
                if(getCurrentItem().ads_data['ads_type'] == 1  ) {
                  postapiincresevlog(getCurrentItem().ads_data['id'],"http://theheadlines.co.in/api/increaseBlogLinkAds");
                  postapiincresevlog(getCurrentItem().ads_data['id'],"http://theheadlines.co.in/api/increaseBlogViewads");
                  launch(getCurrentItem().ads_data['url']);
                }
                else{
                  postapiincresevlog(getCurrentItem().ads_data['id'],"http://theheadlines.co.in/api/increaseBlogLinkAds");
                  postapiincresevlog(getCurrentItem().ads_data['id'],"http://theheadlines.co.in/api/increaseBlogViewads");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => adsform(title:getCurrentItem().ads_data['title'],id:getCurrentItem().ads_data['id'])),
                  );
                }
              },
              child: Image.network(getCurrentItem().ads_data['image'],fit:BoxFit.fill,)),),
        GestureDetector(
          onTap: (){
            setState(() {
              postapiincresevlog(getCurrentItem().ads_data['id'],"http://theheadlines.co.in/api/increaseBlogViewads");
              showadd = true;
            });
          },
          child: Positioned(
              top:40,
              left:40,
              child: Container()
              // Icon(Icons.cancel_sharp,color: Colors.black,size: 30,)
          ),
        ),
      ],
    );
  }

  postapiincresevlog(id,api) async {
    var dio = Dio();
    var Data = {
      "id":id.toString(),
    };
    print("suil"+ jsonEncode(Data));
    dio.post(api, data: Data,options: Options(
        headers: {
          "Content-Type":"application/json"
        }
    )).then((value) {
      if(value.data['status'] == true){


      }
    }
    );

  }

  Future<void> _refresh() async {
    _viewPost();
    return await Future.delayed(Duration(seconds: 2));
  }
}


class CustomClipPath extends CustomClipper<Path> {
  var radius = 0.0;
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(radius, 0.0);
    path.arcToPoint(Offset(0.0, radius),
        clockwise: true, radius: Radius.circular(radius));
    path.lineTo(0.0, size.height - radius);
    path.lineTo(size.width - 0.58 * size.width, size.height);
    path.lineTo(size.width - 0.45 * size.width, radius);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class ShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var path1 = Path();
    path1.moveTo(0, size.height);
    path1.quadraticBezierTo(
        size.width / 2.5, size.height, size.width / 3, size.height);
    path1.lineTo(size.width / 2, 0);
    path1.lineTo(0, 0);
    Path path2 = Path();
    path2.moveTo(size.width / 3, size.height);
    path2.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height);
    path2.lineTo(size.width, 0);
    path2.lineTo(size.width / 2, 0);

    Paint paint1 = Paint()..color = HexColor("#FFAF7E");
    Paint paint2 = Paint()..color = HexColor("#AA83F8");

    canvas.drawPath(path1, paint1);

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class BlogNameAndDetails extends StatelessWidget {
  final Blog blog;

  BlogNameAndDetails({this.blog});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.85 * MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: 30.0, right: 30.0, bottom: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              blog.title,
              style: Theme.of(context).textTheme.bodyText1.merge(
                    TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontSize: 25.0,
                        fontWeight: FontWeight.normal),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class OverlayImage extends StatelessWidget {
  final Blog item;
  final Function onCaresoulChange;
  final int currentIndex;

  OverlayImage({this.item, this.onCaresoulChange, this.currentIndex});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Stack(
      children: <Widget>[
        item.contentType == "video"
            ? CustomVideoPlayer(
                blog: item,
              )
            : item.bannerImage.length > 1
                ? Positioned(
                    child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          CarouselSlider(
                            options: CarouselOptions(
                              height: height * 0.6,
                              viewportFraction: 1.0,
                              enlargeCenterPage: false,
                              autoPlay: true,
                              onPageChanged: (index, reason) {
                                onCaresoulChange(index);
                              },
                            ),
                            items: item.bannerImage
                                .map<Widget>((item) => Container(
                                      child: Center(
                                          child: Image.network(
                                        item,
                                        fit: BoxFit.cover,
                                        height: height,
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes
                                                  : null,
                                            ),
                                          );
                                        },
                                      )),
                                    ))
                                .toList(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: item.bannerImage.map<Widget>((url) {
                              int index = item.bannerImage.indexOf(url);
                              return Padding(
                                padding: const EdgeInsets.only(top: 30.0),
                                child: Container(
                                  width: 10.0,
                                  height: 10.0,
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 2.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: currentIndex == index
                                        ? Color.fromRGBO(0, 0, 0, 0.9)
                                        : Color.fromRGBO(0, 0, 0, 0.4),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      )
                    ],
                  ))
                : Positioned.fill(
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
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.transparent,
                Colors.transparent,
                Colors.black
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            ),
          ),
        ),
        Container(
          alignment: Alignment.topRight,
          padding: EdgeInsets.only(top: 33.0, right: 16.0),
          child: Opacity(
            opacity: 0.6,
            child: ButtonTheme(
              minWidth: 0.07 * width,
              height: 0.04 * height,
              child: RaisedButton(
                padding: EdgeInsets.only(
                  right: 9,
                  left: 9,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                onPressed: () {
                  Navigator.of(context)
                      .pushReplacementNamed('/HomeClonePage', arguments: false);
                },
                color: Colors.black,
                child: Wrap(
                  children: [
                    Icon(
                      Mdi.eye,
                      color: Colors.white,
                      size: 18.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 0.0),
                      child: Text(
                        " " + item.viewCount.toString(),
                        style: Theme.of(context).textTheme.bodyText1.merge(
                              TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Montserrat',
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.normal),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
