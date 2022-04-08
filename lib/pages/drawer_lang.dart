import 'dart:convert';
import 'package:blog_app/controllers/user_controller.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../appColors.dart';

class DrawerLanguage extends StatefulWidget {
  final isInHomePage;
  DrawerLanguage({this.isInHomePage = false});
  @override
  _DrawerLanguageState createState() => _DrawerLanguageState();
}

class _DrawerLanguageState extends State<DrawerLanguage> {
  bool _userLog = false;
  UserController userController = UserController();

  @override
  void initState() {
    super.initState();
    getAllAvialbleLanguages();
  }

  getAllAvialbleLanguages() async {
    print("allLanguageshello ${allLanguages.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/img/app_icon.png",
              width: 100,
              height: 100,
            ),
            SizedBox(
              height: 30,
            ),
        Container(
              height: 35,width: MediaQuery.of(context).size.width*0.6,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10) ,
              gradient: LinearGradient(
              begin: Alignment.topRight,end: Alignment.bottomLeft,colors: [Colors.deepOrange,Colors.purple]
            )),
              child: Card(
                child: Center(
                  child: Text(
                    "Choose your language",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
        Container(
              height: 35,width: MediaQuery.of(context).size.width*0.6,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10) ,
                  gradient: LinearGradient(
                  begin: Alignment.topRight,end: Alignment.bottomLeft,colors: [Colors.purple,Colors.deepOrange]
              )),
              child: Card(
                child: Center(
                  child: Text(
                    "भाषा का चयन कीजिये",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                    childAspectRatio: 3.3),
                itemCount: allLanguages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      BotToast.showLoading();
                      languageCode.value = allLanguages[index];
                      SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                      prefs.setString("defalut_language", json.encode(languageCode.value.toJson()));
                      prefs.setString("local_data",
                          json.encode(allMessages.value.toJson()));

                      await userController.getLanguageFromServer();

                      BotToast.cleanAll();

                      if (!widget.isInHomePage) {
                        Navigator.pushReplacementNamed(context, '/AuthPage');
                      } else {
                        if (currentUser.value.name != null) {
                          userController.updateLanguage();
                        }
                        Navigator.pop(context, false);
                        Navigator.pop(context, true);
                      }
                    },

                    child: Container(
                      margin: EdgeInsets.only(
                          top: 10,
                          left: index % 2 == 0 ? 30 : 5,
                          right: index % 2 != 0 ? 30 : 5),
                      padding: EdgeInsets.symmetric(
                        vertical: 0,
                      ),
                      decoration:allLanguages[index].language == languageCode.value.language?
                      BoxDecoration(
                        gradient: LinearGradient(
                        begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [Colors.deepOrange,Colors.purple]
                        ) ,
                        // border: Border.all(
                        //   color: Colors.grey[400],
                        // ),
                        borderRadius: BorderRadius.circular(10),
                      ):
                      BoxDecoration(
                        // border: Border.all(width: 5,
                        //   color: Colors.grey[400],
                        // ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Card(
                        child: Center(
                          child: Text(
                            allLanguages[index].name,
                            style: TextStyle(
                              color: appMainColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}













// import 'dart:convert';
// import 'package:blog_app/controllers/user_controller.dart';
// import 'package:blog_app/models/language.dart';
// import 'package:blog_app/repository/user_repository.dart';
// import 'package:bot_toast/bot_toast.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../appColors.dart';
//
// class DrawerLanguage extends StatefulWidget {
//   final isInHomePage;
//   DrawerLanguage({this.isInHomePage = false});
//   @override
//   _DrawerLanguageState createState() => _DrawerLanguageState();
// }
//
// class _DrawerLanguageState extends State<DrawerLanguage> {
//   bool _userLog = false;
//   UserController userController = UserController();
//
//   int selectedlang;
//
//   @override
//   void initState() {
//     super.initState();
//     print("selectlan"+languageCode.value.language.toString());
//     getAllAvialbleLanguages();
//   }
//
//   getAllAvialbleLanguages() async {
//
//     print("allLanguages ${allLanguages}");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Image.asset(
//               "assets/img/app_icon.png",
//               width: 100,
//               height: 100,
//             ),
//             SizedBox(
//               height: 30,
//             ),
//             Container(
//               height: 40,width: MediaQuery.of(context).size.width*0.6,
//               decoration: BoxDecoration(borderRadius: BorderRadius.circular(10) ,
//               gradient: LinearGradient(
//               begin: Alignment.topRight,end: Alignment.bottomLeft,colors: [Colors.deepOrange,Colors.purple]
//             )),
//               child: Card(
//                 child: Center(
//                   child: Text(
//                     "Choose your language",
//                     style: TextStyle(color: Colors.black, fontSize: 20),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             Container(
//               height: 40,width: MediaQuery.of(context).size.width*0.6,
//               decoration: BoxDecoration(borderRadius: BorderRadius.circular(10) ,
//                   gradient: LinearGradient(
//                   begin: Alignment.topRight,end: Alignment.bottomLeft,colors: [Colors.purple,Colors.deepOrange]
//               )),
//               child: Card(
//                 child: Center(
//                   child: Text(
//                     "भाषा का चयन कीजिये",
//                     style: TextStyle(color: Colors.black, fontSize: 20),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 30,
//             ),
//             MediaQuery.removePadding(
//               context: context,
//               removeTop: true,
//               child: GridView.builder(
//                 shrinkWrap: true,
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 4.0,
//                     mainAxisSpacing: 4.0,
//                     childAspectRatio: 3.3),
//                 itemCount: allLanguages.length,
//                 itemBuilder: (context, index) {
//                   return GestureDetector(
//                     onTap: () async {
//
//
//                       BotToast.showLoading();
//                       languageCode.value = allLanguages[index];
//
//                       SharedPreferences prefs =
//                           await SharedPreferences.getInstance();
//                       prefs.setString("defalut_language",
//                           json.encode(languageCode.value.toJson()));
//                       prefs.setString("local_data",
//                           json.encode(allMessages.value.toJson()));
//                       await userController.getLanguageFromServer();
//                       BotToast.cleanAll();
//                       if (!widget.isInHomePage) {
//                         Navigator.pushReplacementNamed(context, '/AuthPage');
//                       } else {
//                         if (currentUser.value.name != null) {
//                           userController.updateLanguage();
//                         }
//                         Navigator.pop(context, false);
//                         Navigator.pop(context, true);
//                       }
//                     },
//
//                     child: Container(
//                       margin: EdgeInsets.only(
//                           top: 10,
//                           left: index % 2 == 0 ? 30 : 5,
//                           right: index % 2 != 0 ? 30 : 5),
//                       padding: EdgeInsets.symmetric(
//                         vertical: 5,
//                       ),
//
//                       decoration:
//                       allLanguages[index].language == languageCode.value.language?
//                       BoxDecoration(
//                         color: Colors.blue,
//                           border: Border.all(
//
//                         )):
//                       BoxDecoration(
//                           border: Border.all(
//                             color: Colors.grey[400],
//                           )),
//
//
//                       child: Center(
//                         child: Text(
//                           allLanguages[index].name,
//                           style: TextStyle(
//                             color: appMainColor,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
