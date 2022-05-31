import 'dart:convert';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uxcam/flutter_uxcam.dart';
import 'package:club/controller/auth/login_with_account_vc.dart';
import 'package:club/controller/auth/register_email_vc.dart';
import 'package:club/view/clubs_main_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class clubSetRulesVc extends StatefulWidget {
  @override
  _clubSetRulesVcState createState() => _clubSetRulesVcState();
}

class _clubSetRulesVcState extends State<clubSetRulesVc> {
  bool isPassWordInputVisibal = false;

  TextEditingController _userNameController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  //elements
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [
                0,
                1
              ],
                      colors: [
                Color.fromRGBO(239, 141, 72, 1),
                Color.fromRGBO(239, 201, 107, 1)
              ]))),
        ),
        body: Stack(children: [
          Container(
            margin: EdgeInsets.fromLTRB(20, 50, 20, 0),
            // color: Colors.black12,
            height: 420,
            child: ListView(
              children: [
                Container(
                    margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                    child: Text(
                      "New Hear?",
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.black87,
                          fontFamily: "SourceSansPro_clubs"),
                    )),
                Container(
                  margin: EdgeInsets.only(top: 60),
                  height: 55,
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.1), blurRadius: 2)
                  ]),
                  child: TextField(
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      hintText: "Username(optional)",
                      hintStyle: TextStyle(
                          fontSize: 15,
                          color: Color.fromRGBO(142, 136, 149, 1)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.grey,
                          )),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Color.fromRGBO(239, 141, 72, 1),
                          )),
                    ),
                    controller: _userNameController,
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 20, 0, 50),
                  child: Text("Set your Username and click Next",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontFamily: "SourceSansPro_clubs")),
                ),
                ClubsMainButton(btnTextString: "Next", btnClick: _clickNext)
              ],
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
                height: 100,
                // color: Colors.black45,
                child: Column(children: [
                  Container(
                      margin: EdgeInsets.only(top: 35),
                      child: RichText(
                          text: TextSpan(
                              text: "Log in ",
                              style: TextStyle(
                                  color: Color.fromRGBO(255, 116, 23, 1),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  fontFamily: "SourceSansPro_clubs"),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  //clickEvents
                                  _clickLoginAnother();
                                },
                              children: [
                            TextSpan(
                              text: "to Another Account ",
                              style: TextStyle(
                                  color: Color.fromRGBO(155, 157, 163, 1),
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: "SourceSansPro_clubs"),
                            )
                          ])))
                ]),
              ))
        ]));
  }

  //-------------------OtherEvents-------------------

  //-------------------clickEvents-------------------

  //click
  Future<void> _clickLoginAnother() async {
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (context) => LoginWithAccountVc()));
  }

  //click
  void _clickNext() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RegisterEmailVc(
                  userName: _userNameController.text,
                )));
  }

  //functions

}
