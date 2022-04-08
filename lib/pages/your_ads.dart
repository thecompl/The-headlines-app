import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../advertise_page.dart';
import 'create_post.dart';

class YourAds extends StatefulWidget {
  const YourAds({Key key}) : super(key: key);
  @override
  _YourAdsState createState() => _YourAdsState();

}

class _YourAdsState extends State<YourAds> {

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SafeArea(
        child:
        Scaffold(appBar: AppBar(backgroundColor: Colors.deepOrange,
            title: Text('Active Advertising',style: TextStyle
              (fontFamily: 'Montserrat',wordSpacing: 1,letterSpacing: 1,
                fontSize: 18,fontWeight: FontWeight.bold),)),
          body:
          Container(
              height: size.height*0.2,
              width: size.width*1,
              child: Padding(
                padding: const EdgeInsets.only(left:5,right:5,top: 3),
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreatePost()),
                    );
                  },
                  child: Container(
                      height: size.height*0.2,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                            padding: EdgeInsets.only(top: 5,bottom: 5,left: 5,),
                            child: Row(
                                children: [
                                  Container(
                                      height: size.height*0.2,
                                      width: size.width*0.32,
                                      child: Image.asset("assets/img/img.png",),
                                      decoration: BoxDecoration(

                                        borderRadius: BorderRadius.circular(10),
                                      )
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(left:10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            // Icon(Icons.circle,size:10,color: Colors.green,),
                                            Container(
                                                padding: EdgeInsets.only(),
                                                child: Text("Advertise Title",
                                                  style:TextStyle( fontWeight: FontWeight.w500,
                                                      color:Colors.black,fontSize: 16),)
                                            ),
                                            SizedBox(width:20),
                                            Padding(
                                              padding:  EdgeInsets.only(left: 30,right: 5),
                                              child: Container(
                                                // padding: EdgeInsets.only(),
                                                height: size.height*0.025,
                                                width: size.width*0.1,
                                                decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius: BorderRadius.all(Radius.circular(3))
                                                ),

                                                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text("20".toUpperCase(),
                                                        style: TextStyle( fontWeight: FontWeight.w500,
                                                            color:Colors.white,fontSize: 14)),
                                                    Icon(Icons.star_border_outlined,size: 13,color: Colors.white,)
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 7,),
                                        Row(
                                          children: [
                                            SizedBox(height: 1,),
                                            Container(
                                                child: Text("Italian,",
                                                  style:TextStyle( fontWeight: FontWeight.w600,
                                                      color:Colors.black,fontSize: 10),)),
                                            Container(
                                                child: Text(" North Indian,",
                                                    style:TextStyle( fontWeight: FontWeight.w600,
                                                        color:Colors.black,fontSize: 10))),
                                            Container(
                                                child: Text("South Indian",
                                                    style:TextStyle( fontWeight: FontWeight.w600,
                                                        color:Colors.black,fontSize: 10))),
                                          ],
                                        ),
                                        SizedBox(height: 0  ),
                                        Padding(
                                          padding: const EdgeInsets.only(left:0),
                                          child: Container  (
                                              child:Row(
                                                children: [
                                                  Container(height:MediaQuery.of(context).size.height*0.08 ,
                                                      width:MediaQuery.of(context).size.width*0.58 ,
                                                      padding: EdgeInsets.only(left: 0,right: 5),
                                                      child: Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. "
                                                          "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s,"
                                                          " when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
                                                        maxLines: 5,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle( fontWeight: FontWeight.w400,
                                                            color:Colors.grey,fontSize: 10),)),
                                                ],
                                              )

                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                          children: [
                                            Icon(Icons.wifi_protected_setup,size: 17,color: Colors.blue,),
                                            // Image.asset("assets/img/img.png",height:15,width: 15,),
                                            SizedBox(width: 3,),
                                            Text("Re-Active".toUpperCase(),style:TextStyle( fontWeight: FontWeight.w400, color:Colors.blue,fontSize: 12),),
                                            SizedBox(width:MediaQuery.of(context).size.width*0.16,),
                                            btn("Delete".toUpperCase(), 0.03,YourAds())
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ]
                            )
                        ),
                      )),
                ),
              )


          ),
          floatingActionButton: FloatingActionButton(
            onPressed: (){
              print('Add Advertise');
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdvertiseFormPage()));
            },
            backgroundColor: Colors.deepOrange,
            child:
            Icon(Icons.add,color: Colors.white,size: 25,),elevation: 10,
          ),

        )
    );
  }
  btn(String btnTitle,h,route){
    return Container(
      height:MediaQuery.of(context).size.height*h,

      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          primary: Colors.blue, // background
          onPrimary: Colors.white, // foreground
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => route),
          );
        },
        child: Text(btnTitle.toUpperCase(),style: TextStyle( fontWeight: FontWeight.w400, color:Colors.white,),),
      ),
    );
  }
}


