import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
class adsform extends StatefulWidget {
  final int id;
  final String title;

  const adsform({Key key,  this.title, this.id}) : super(key: key);
  @override
  _adsformState createState() => _adsformState();
}

class _adsformState extends State<adsform> {

  TextEditingController name = TextEditingController();
  TextEditingController mobile_no = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController desc = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: Container(
          height: size.height*0.8,
          width : size.width,

          padding: EdgeInsets.only(left: 15,right: 15),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 40),
                  Image.asset("assets/img/logo.png",height: 100,width: 120,),
                  textfield("name","Enter name",name,"please Enter name"),
                  SizedBox(height: 10,),
                  textfield("Mobile no","Enter mobile no",mobile_no,"please enter mobile no"),
                  SizedBox(height: 10,),
                  textfield("Email","Enter email",email ,"please enter email"),
                  SizedBox(height: 10,),
                  textfield("Description","Enter Description",desc,"please enter Description"),
                  SizedBox(height:20,),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red, // background
                        onPrimary: Colors.white, // foreground
                      ),
                      onPressed: () {

                        if (_formKey.currentState.validate()) {
                          postapi();

                        }
                      },
                      child: Text(widget.title,style: TextStyle(color: Colors.white),),
                    ),
                  )

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget textfield(lablename,hintname,con,validation) {
    return TextFormField(
      controller: con,
      autovalidateMode: AutovalidateMode.always,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: hintname,
        labelText: lablename,
      ),
      onSaved: (String value) {

      },
      validator: (value) {
     if(value .isEmpty) {
       return validation;
     }
     return null;
      },
    );
  }
  postapi() async {
    var dio = Dio();
    var Data = {
      "id": widget.id.toString(),
      "detail":{
        "name":name.text,
        "mobile_no":mobile_no.text,
        "email":email.text,
        "desc":desc.text
      }
    };
  print("suil"+ jsonEncode(Data));
    dio.post('http://theheadlines.co.in/api/addBlogads', data: jsonEncode(Data),options: Options(
      headers: {
        "Content-Type":"application/json"
      }
    )).then((value) {
      if(value.data['status'] == true){
        Fluttertoast.showToast(
            msg: "Thank you for "+widget.title,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
        Navigator.pop(context);
      }
    }
    );

  }

}
