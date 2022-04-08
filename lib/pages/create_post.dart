import 'package:blog_app/pages/your_news.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreatePost extends StatefulWidget {
  CreatePost({Key key, this.title}) : super(key: key);
   String title ;
  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  TextEditingController nameController = TextEditingController();
  int _radioValue = 0;
  var error = 'Required';
  final items = ['Sports','Political','Bollywood','Recruitments','Disasters'];
  String value = 'Sports';
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
        case 2:
          break;
      }
    });
  }
  File imageFile;
  File videoFile;



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
  _Gallary(BuildContext context) async {
    File video = await ImagePicker.pickVideo(source: ImageSource.gallery);
    print('video path'+video.path);
    this.setState(() {
      videoFile = video;
      print('path'+video.path.toString());
    });
    Navigator.of(context).pop();
  }

  _Camera(BuildContext context) async {
    var video = await ImagePicker.pickVideo(source: ImageSource.camera);
    this.setState(() {
      videoFile = video;
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

  Future<void> _showDialog(BuildContext context)
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
                  _Gallary(context);
                },
              ),
              Padding(padding: EdgeInsets.all(8.0)),
              GestureDetector(
                child: Text('Open Camera'),
                onTap: (){
                  _Camera(context);
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

  Widget _decideVideoView(){
    if(videoFile == null){
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
      return Center(child: Text('Video Uploaded',
        style: TextStyle(
            color: Colors.black,
            fontSize: 16,fontWeight: FontWeight.bold),));
      // return Image.file
      //   (videoFile,
      //   width: MediaQuery.of(context).size.width*0.35,
      //   height: MediaQuery.of(context).size.height*0.26 ,);
    }
  }



  @override
  Widget build(BuildContext context) {
    DropdownMenuItem<String> buildMenuItem(String item) =>
        DropdownMenuItem(value: item,
          child: Text(
            item,
            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
          ),
        );
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.deepOrange,
        title: Text
          ('Upload News',
          style: TextStyle
            (fontFamily: 'Montserrat',
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
                          "News Category",
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
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: value,
                                iconSize: 36,
                                icon:Icon(Icons.arrow_drop_down,color:Colors.deepOrange),
                                isExpanded: true,
                                items: items.map(buildMenuItem).toList(),
                                onChanged: (value)
                                =>setState(() => this.value = value),
                              ),
                            ),
                          ),

                      // TextFormField(
                      //   decoration: const InputDecoration(
                      //       icon: const Icon(Icons.person),
                      //       hintText: 'News Category',
                      //       labelText: 'Category'),
                      //   inputFormatters: [new LengthLimitingTextInputFormatter(10)],
                      //   validator: (value) {
                      //     if (value.isEmpty) {
                      //       return 'Please Enter Category';
                      //     }
                      //     return null;
                      //   },
                      //   onSaved: (value) {
                      //     user.name = value;
                      //   },
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15,),
                        child: Text(
                          "News Title",
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
                              icon: const Icon(Icons.arrow_right),
                              hintText: 'Enter News Title',hintStyle: TextStyle(fontSize: 15)),
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
                          "Description",
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
                              icon: const Icon(Icons.arrow_right),
                              hintText: 'Enter Description',hintStyle: TextStyle(fontSize: 15)),
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
                      Padding(
                        padding: const EdgeInsets.only(left: 15,),
                        child: Text(
                          "Do You Want Show Name",
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
                            Radio(
                              value: 0,
                              groupValue: _radioValue,
                              onChanged: _handleRadioValueChange,
                            ),
                            Text(
                              'YES',
                              style: new TextStyle(fontSize: 16.0,color: Colors.black),
                            ),
                            Radio(
                              value: 1,
                              groupValue: _radioValue,
                              onChanged: _handleRadioValueChange,
                            ),
                            Text(
                              'NO',
                              style: new TextStyle(
                                fontSize: 16.0,color: Colors.black
                              ),
                            ),
                          ],
                        ),
                      ),
                        // child: TextFormField(
                        //
                        //     style: TextStyle(fontSize: 20),
                        //   key: _passwordFieldKey,
                        //   obscureText: true,
                        //   decoration: const InputDecoration(
                        //     border: InputBorder.none,
                        //     icon: const Icon(Icons.arrow_right),
                        //     hintText: 'Show name Yes/No',hintStyle: TextStyle(fontSize: 15)
                        //   ),
                        //   validator: (value) {
                        //     if (value.isEmpty) {
                        //       return error;
                        //     }
                        //     return null;
                        //   },
                        //     onSaved: (value) {
                        //     user.email = value;}
                        //     )
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



                        // child: TextFormField(style: TextStyle(fontSize: 20),
                        //   obscureText: true,
                        //   decoration: const InputDecoration(
                        //     border: InputBorder.none,
                        //       icon: const Icon(Icons.arrow_right),
                        //       hintText: 'Upload Banner Image',hintStyle: TextStyle(fontSize: 15)),
                        //   validator: (value) {
                        //     if (value.isEmpty) {
                        //       return 'banner image';
                        //     }
                        //     if (value != _passwordFieldKey.currentState.value) {
                        //       return 'banner image';
                        //     }
                        //     return null;
                        //   },
                        //   onSaved: (value) {
                        //     user.password = value;
                        //   },
                        // ),

                      Padding(
                        padding: const EdgeInsets.only(left: 15,),
                        child: Text(
                          "Upload Video",
                          style: TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height*0.13,
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
                                  height: MediaQuery.of(context).size.height*0.065,
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
                                        _showDialog(context);
                                      },

                                    child: Center(
                                        child: Text('Import Video',
                                          style: TextStyle(color: Colors.black,
                                              fontSize: 14,fontWeight: FontWeight.bold),)),),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container( height:MediaQuery.of(context).size.height*0.07,
                                      width: MediaQuery.of(context).size.width*0.35,
                                      decoration: BoxDecoration(

                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color:Colors.deepOrange,width: 2),
                                      ),
                                      child: _decideVideoView()),
                                ],
                              ),
                            ),
                          ],


                        ),
                      ),
                      // Container(
                      //   height: 60,
                      //   margin: EdgeInsets.all(10),
                      //   padding:EdgeInsets.symmetric(horizontal:12,vertical: 4),
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(10),
                      //     border: Border.all(color:Colors.deepOrange,width: 2),
                      //   ),
                      //   child: TextFormField(style: TextStyle(fontSize: 20),
                      //     decoration: const InputDecoration(
                      //       border: InputBorder.none,
                      //         icon: const Icon(Icons.arrow_right),
                      //         hintText: 'Upload Video',hintStyle: TextStyle(fontSize: 15)),
                      //     keyboardType: TextInputType.phone,
                      //     inputFormatters: [
                      //       FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*$')),
                      //       // WhitelistingTextInputFormatter(
                      //       //     RegExp(r'^[0-9]*$')),
                      //       LengthLimitingTextInputFormatter(10)
                      //     ],
                      //     validator: (value) {
                      //       if (!phoneRegex.hasMatch(value)) {
                      //         return error;
                      //       }
                      //       return null;
                      //     },
                      //     onSaved: (value) {
                      //       user.phoneNo = value;
                      //     },
                      //   ),
                      // ),  //ajsgj
                      Padding(
                        padding: const EdgeInsets.only(left: 15,),
                        child: Text(
                          "News Tags",
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
                              icon: const Icon(Icons.arrow_right),
                              hintText: 'News Tag',
                              hintStyle: TextStyle(fontSize: 15)),
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
                      Padding(
                        padding: const EdgeInsets.only(left: 15,),
                        child: Text(
                          "News Url",
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
                              icon: const Icon(Icons.arrow_right),
                              hintText: 'News Url',hintStyle: TextStyle(fontSize: 15)),
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
                                    MaterialPageRoute(builder: (context) => YourNews()));
                              }
                            },
                            child: Center(
                                child: Text('Create',
                                  style: TextStyle
                                    (fontWeight: FontWeight.bold,color: Colors.deepOrange),)),
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

