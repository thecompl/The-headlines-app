import 'package:blog_app/pages/ads.dart';
import 'package:blog_app/pages/home_page.dart';
import 'package:blog_app/pages/read_blog.dart';
import 'package:blog_app/pages/your_ads.dart';
import 'package:blog_app/pages/your_news.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'elements/drawer_builder.dart';

class AdvertiseFormPage extends StatefulWidget {
  AdvertiseFormPage({Key key, this.title}) : super(key: key);
  String title ;
  @override
  _AdvertiseFormPageState createState() => _AdvertiseFormPageState();
}

class _AdvertiseFormPageState extends State<AdvertiseFormPage> {
  TextEditingController nameController = TextEditingController();
  int _radioValue = 0;
  var error = 'Required';
  final _formKey = GlobalKey<FormState>();
  User user = new User();
  final _passwordFieldKey = GlobalKey<FormFieldState<String>>();
  void _handleRadioValueChange(int value) {
    setState(() {
      _radioValue = value;

      switch (_radioValue) {
        case 0:
          break;
        case 1:
          break;
      }
    });
  }
  File imageFile;



  _openGallary(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      imageFile = picture;
    });
    Navigator.of(context).pop();
  }

  _openCamera(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      imageFile = picture;
    });
    Navigator.of(context).pop();
  }


  Future<void> _showChoiceDialog(BuildContext context)
  {
    return showDialog(context: context, builder: (BuildContext context)
    {
      return AlertDialog(
        title: Text('Please Select !'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              GestureDetector(
                child: Text('Gallary'),
                onTap: (){
                  _openGallary(context);
                },
              ),
              Padding(padding: EdgeInsets.all(8.0)),
              GestureDetector(
                child: Text('Open Camera'),
                onTap: (){
                  _openCamera(context);
                },
              )
            ],
          ),
        ),
      );
    });
  }

  Widget _decideImageView(){
    if(imageFile == null){
      return Center(
          child: Text('No File Selected',
            style: TextStyle
              (color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold),
          )
      );
    }else
    {
      return Image.file
        (imageFile,
        width: MediaQuery.of(context).size.width*0.28,
        height: MediaQuery.of(context).size.height*0.26 ,);
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.deepOrange,
          title: Text
            ('Advertising Form ',
            style: TextStyle
              (fontFamily: 'Montserrat',letterSpacing: 1,
                fontSize: 18,fontWeight: FontWeight.bold),
          )
      ),
      body: Center(
          child: Card(
            child: Container(height: 600,width: 400,
              decoration: BoxDecoration(),
              child: Form(
                  autovalidateMode: AutovalidateMode.disabled,
                  key: _formKey,
                  child: new ListView(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 15),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 15,),
                        child: Text(
                          "Advertise Title",
                          style: TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        height: 60,
                        margin: EdgeInsets.all(10),
                        padding:EdgeInsets.symmetric(horizontal:12,vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color:Colors.deepOrange,width: 2),
                        ),
                        child: TextFormField(style: TextStyle(fontSize: 20),
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              icon: const Icon(Icons.album_rounded,color: Colors.deepOrange,size: 16,),
                              hintText: 'Enter Title',hintStyle: TextStyle(fontSize: 16)),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (!emailRegex.hasMatch(value)) {
                              return error;
                            }
                            return null;
                          },
                          onSaved: (value) {
                            user.email = value;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15,),
                        child: Text(
                          "Banner Image",
                          style: TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height*0.32,
                        margin: EdgeInsets.all(10),
                        padding:EdgeInsets.symmetric(horizontal:10,vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color:Colors.deepOrange,width: 2),
                        ),
                        child:
                        Row(
                          children: [

                            //     Text('Upload image',style:TextStyle(fontSize: 14,
                            // color: Colors.black,fontWeight: FontWeight.bold ,)),
                            Column(mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: MediaQuery.of(context).size.height*0.06,
                                  width: MediaQuery.of(context).size.width*0.26,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow:  [
                                      BoxShadow(
                                        color: Colors.deepOrange,
                                        blurRadius: 3,
                                        offset: Offset(1, 0), // Shadow position
                                      ),
                                    ],
                                    border: Border.all(color:Colors.deepOrange,width: 2),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      _showChoiceDialog(context);
                                    },
                                    child: Center(
                                        child: Text('Import Image',
                                          style: TextStyle(color: Colors.black,
                                            fontSize: 14,fontWeight: FontWeight.bold,),)),),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container( height:MediaQuery.of(context).size.height*0.27,
                                      width: MediaQuery.of(context).size.width*0.38,
                                      decoration: BoxDecoration(

                                        borderRadius: BorderRadius.circular(10),

                                        border: Border.all(color:Colors.deepOrange,width: 2),
                                      ),
                                      child: _decideImageView()),
                                ],
                              ),
                            ),
                          ],


                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15,),
                        child: Text(
                          "Button Type",
                          style: TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        height: 60,
                        margin: EdgeInsets.all(10),
                        padding:EdgeInsets.symmetric(horizontal:12,vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color:Colors.deepOrange,width: 2),
                        ),child: Row(
                        children: [
                          Radio(activeColor: Colors.green,
                            value: 0,
                            groupValue: _radioValue,
                            onChanged: _handleRadioValueChange,
                          ),
                          GestureDetector(onTap: (){
                            setState(() {
                              _radioValue = 0;

                              switch (_radioValue) {
                                case 0:
                                  break;
                                case 1:
                                  break;
                              }
                            });

                          },
                            child: Text(
                              'Link',
                              style: new TextStyle(fontSize: 16.0,color: Colors.black),
                            ),
                          ),
                          Radio(activeColor: Colors.green,
                            value: 1,
                            groupValue: _radioValue,
                            onChanged: _handleRadioValueChange,
                          ),
                          GestureDetector(onTap: (){
                            setState(() {
                            _radioValue = 1;

                            switch (_radioValue) {
                              case 0:
                                break;
                              case 1:
                                break;
                            }
                          });

                          },
                            child: Text(
                              'Enquiry Form',
                              style: new TextStyle(
                                  fontSize: 16.0,color: Colors.black
                              ),
                            ),
                          ),
                        ],
                      ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15,),
                        child: Text(
                          "Button Title",
                          style: TextStyle(fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        height: 60,
                        margin: EdgeInsets.all(10),
                        padding:EdgeInsets.symmetric(horizontal:12,vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color:Colors.deepOrange,width: 2),
                        ),
                        child: TextFormField(style: TextStyle(fontSize: 20),
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              icon: const Icon(Icons.album_rounded,color: Colors.deepOrange,size: 16,),
                              hintText: 'Button Title',
                              hintStyle: TextStyle(fontSize: 16)),
                          // keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*$')),
                            // WhitelistingTextInputFormatter(
                            //     RegExp(r'^[0-9]*$')),
                            LengthLimitingTextInputFormatter(10)
                          ],
                          validator: (value) {
                            if (!phoneRegex.hasMatch(value)) {
                              return error;
                            }
                            return null;
                          },
                          onSaved: (value) {
                            user.phoneNo = value;
                          },
                        ),
                      ),
                      _radioValue==0?
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15,),
                          child: Text(
                            "Link",
                            style: TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          height: 60,
                          margin: EdgeInsets.all(10),
                          padding:EdgeInsets.symmetric(horizontal:12,vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color:Colors.deepOrange,width: 2),
                          ),
                          child: TextFormField(style: TextStyle(fontSize: 20),
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                icon: const Icon(Icons.album_rounded,color: Colors.deepOrange,size: 16,),
                                hintText: 'Link',hintStyle: TextStyle(fontSize: 16)),
                            // keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*$')),
                              // WhitelistingTextInputFormatter(
                              //     RegExp(r'^[0-9]*$')),
                              LengthLimitingTextInputFormatter(10)
                            ],
                            validator: (value) {
                              if (!phoneRegex.hasMatch(value)) {
                                return error;
                              }
                              return null;
                            },
                            onSaved: (value) {
                              user.phoneNo = value;
                            },
                          ),
                        ),
                      ],):Container(),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Container(
                          height: 45,
                          margin: EdgeInsets.all(10),
                          // padding:EdgeInsets.symmetric(horizontal:100,vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.deepOrange,width: 2),
                            borderRadius: BorderRadius.circular(10),
                            // border: Border.all(color:Colors.black,width: 4),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              if (_formKey.currentState.validate()) {
                                print("Process data");
                                _formKey.currentState.save();
                                print('Name: ${user.name}');
                                print('Email: ${user.email}');
                                print('Phone No: ${user.phoneNo}');
                                print('Password: ${user.password}');
                              } else {
                                print('Error');
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) =>YourAds()));
                              }
                            },
                            child: Center(
                                child: Text('SAVE',
                                  style: TextStyle
                                    (fontWeight: FontWeight.bold,color: Colors.deepOrange,fontSize: 16,letterSpacing: 2),)),
                          ),
                        ),
                      )
                    ],
                  )),
            ),
          )),
    );

  }
  // Future capture(MediaSource source) async {
  //   final result = await
  //   Navigator.of(context).push(
  //     MaterialPageRoute(builder: (context) => Sourcepage(),
  //
  //     )
  //   );
  //
  // }


  final RegExp phoneRegex = new RegExp(r'^[6-9]\d{9}$');
  final RegExp emailRegex = new RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]"
      r"(?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?"
      r"(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");


}

class User {
  String name;
  String email;
  String phoneNo;
  String password;
}

