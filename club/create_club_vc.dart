import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:club/config/app_conf.dart';
import 'package:club/controller/club/create_first_post_vc.dart';
import 'package:club/controller/club/club_set_rules_vc.dart';
import 'package:club/controller/main_navigation_vc.dart';
import 'package:club/domain/nft.dart';
import 'package:club/domain/user_profile.dart';
import 'package:club/service/auth_service.dart';
import 'package:club/util/show_dialog_mixin.dart';
import 'package:club/view/clubs_main_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CreateclubVc extends StatefulWidget {

  const CreateclubVc({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CreateclubVcState();
  }

}

class _CreateclubVcState extends State<CreateclubVc>{
  
  bool isClickNext = false; 
  //Agreeable
  bool _isAgree = false;
  UserProfile _userProfile = UserProfile.from("uid", "token", "name", "email", "avatar", "gender", "region", "phone", "passwd", false,null);
  //imageGroup
  ImageProvider _imageProvider;
  //name
  TextEditingController _clubNameController = TextEditingController();
  //description
  TextEditingController _introController = TextEditingController();
  //follower name
  TextEditingController _followerNameController = TextEditingController();
  //origin
  TextEditingController _originController = TextEditingController();
  //chosenCategory
  int _categoryIndex = 0;

  bool isContractGated = false; 

  //nftList
  List<NftSelect> _nftList = [];
  int _maxSelectNum = 3;
  int _selectedCount = 0;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  //initiateFunction
  _initData(){
    AuthService authService = Provider.of<AuthService>(context,listen: false);
    _userProfile = authService.userProfile;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create a Club"),
        centerTitle: true,
        elevation: 0,
        flexibleSpace:Container(
          height: 105,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0,1],
              colors: [Color.fromRGBO(239, 141, 72, 1),Color.fromRGBO(239, 201, 107, 1)]
            )
          ),
        )
      ),
      body: Listener(
        onPointerMove: (move){
            //retractKeyboard
            FocusScope.of(context).requestFocus(FocusNode());
        },
        child: ListView(
            children: [
              Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(20,20,20,0),
                child: Column(
                  children: [
                    //logo
                    Padding(padding: EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 120,
                            child: Text("Club Photo",style: TextStyle(fontSize: 15,color: Colors.black,fontFamily: "SourceSansPro_clubs"),)
                          ),
                          GestureDetector(
                                  onTap: ()=>_clickChangePhoto(),
                                  child: _imageProvider == null
                                    ?Container(
                                                width: 80,
                                                height: 80,
                                                color: Colors.grey[200],
                                                padding: EdgeInsets.fromLTRB(26, 8, 0, 0),
                                                child: Text("+",style: TextStyle(fontSize: 52,fontWeight: FontWeight.w200,color: Colors.white),),
                                              )
                                    :Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: _imageProvider,
                                          fit: BoxFit.cover
                                        ) 
                                      )
                                    )
                            )
                        ],
                      )
                    ),
                    //name
                    Padding(padding: EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            child: Text("Name",style: TextStyle(fontSize: 15,color: Colors.black,fontFamily: "SourceSansPro_clubs"),)
                          ),
                          Expanded(
                            child: Container(
                              height: 35,
                              decoration: BoxDecoration(
                                  color: Colors.grey[200], borderRadius: BorderRadius.circular(5)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: TextFormField(
                                          controller: _clubNameController,
                                          maxLines: 2,
                                          cursorColor: Colors.orange,
                                          decoration: InputDecoration(
                                            // hintText: "Search here",
                                            // hintStyle:
                                            //     TextStyle(fontSize: 13, color: Colors.black54),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 15),
                                          ),
                                          // onEditingComplete: _inputSearchDone
                                          validator: (value) {
                                            if (value == null||value.trim()=="") {
                                              return 'Required';
                                            }
                                            return null;
                                          }
                                        )),
                                        //XXOO
                                        // Icon(Icons.cancel_outlined, color: Colors.black54),
                                        
                                ],
                              ),
                            )
                          )
                        ],
                      )
                    ),
                    //pass rule
                    Padding(padding: EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            child: Text("Is Contract-Gated",style: TextStyle(fontSize: 15,color: Colors.black,fontFamily: "SourceSansPro_clubs"),)
                          ),
                          Expanded(
                            child: Container(
                              height: 30,
                              decoration: BoxDecoration(
                                  color: Colors.white, borderRadius: BorderRadius.circular(5)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: 
                                      ElevatedButton(
                                        onPressed: ()=>_setPassRules(),
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all(Colors.black87),
                                        ), 
                                        child: Text("Set Pass Rules",style: TextStyle(fontSize: 13,color: Colors.white,fontWeight: FontWeight.w600,fontFamily: "SourceSansPro_clubs")
                                      ))),
                                      //勾勾叉叉
                                      Padding(padding: EdgeInsets.only(left: 10),child: Icon(Icons.cancel_outlined, color: Colors.black54),)      
                                ],
                              ),
                            )
                          )
                        ],
                      )
                    ),
                    //intro
                    Padding(padding: EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 120,
                            child: Text("Intro",style: TextStyle(fontSize: 15,color: Colors.black,fontFamily: "SourceSansPro_clubs"),)
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[200], borderRadius: BorderRadius.circular(5)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: TextFormField(
                                          controller: _introController,
                                          maxLines: 8,
                                          cursorColor: Colors.orange,
                                          decoration: InputDecoration(
                                            // hintText: "Search here",
                                            hintStyle:
                                                TextStyle(fontSize: 13, color: Colors.black54),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 15),
                                          ),
                                          // onEditingComplete: _inputSearchDone
                                          validator: (value) {
                                            if (value == null||value.trim()=="") {
                                              return 'Required';
                                            }
                                            return null;
                                          },
                                        )),
                                ],
                              ),
                            )
                          )
                        ],
                      )
                    ),
                    //follower name
                    Padding(padding: EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            child: Text("Follower Name",style: TextStyle(fontSize: 15,color: Colors.black,fontFamily: "SourceSansPro_clubs"),)
                          ),
                          Expanded(
                            child: Container(
                              height: 35,
                              decoration: BoxDecoration(
                                  color: Colors.grey[200], borderRadius: BorderRadius.circular(5)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: TextFormField(
                                          controller: _followerNameController,
                                          maxLines: 1,
                                          cursorColor: Colors.orange,
                                          decoration: InputDecoration(
                                            hintText: "default: Follwer",
                                            hintStyle:
                                                TextStyle(fontSize: 13, color: Colors.black54),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 15),
                                          ),
                                          // onEditingComplete: _inputSearchDone
                                        )),   
                                ],
                              ),
                            )
                          )
                        ],
                      )
                    ),
                    //origin
                    Padding(padding: EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Club Origin",style: TextStyle(fontSize: 15,color: Colors.black,fontFamily: "SourceSansPro_clubs"),),
                                Text("Paste your domain",style: TextStyle(fontSize: 12,color: Colors.black54,fontFamily: "SourceSansPro_clubs"),)
                              ]
                            )
                          ),
                          Expanded(
                            child: Container(
                              height: 35,
                              decoration: BoxDecoration(
                                  color: Colors.grey[200], borderRadius: BorderRadius.circular(5)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: TextFormField(
                                          controller: _originController,
                                          maxLines: 1,
                                          cursorColor: Colors.orange,
                                          decoration: InputDecoration(
                                            // hintText: "Search here",
                                            hintStyle:
                                                TextStyle(fontSize: 13, color: Colors.black54),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 15),
                                          ),
                                          // onEditingComplete: _inputSearchDone
                                          validator: (value) {
                                            if (value == null||value.trim()=="") {
                                              return 'Required';
                                            }
                                            return null;
                                          },
                                        )),   
                                ],
                              ),
                            )
                          )
                        ],
                      )
                    ),
                    //category
                    Padding(padding: EdgeInsets.only(bottom: 20),
                      child: Column(children: [
                        Row(children: [
                          Text("Category",style: TextStyle(fontSize: 15,color: Colors.black,fontFamily: "SourceSansPro_clubs")),
                          SizedBox(width: 10,),
                          Text("select one",style: TextStyle(fontSize: 12,color: Colors.black54,fontFamily: "SourceSansPro_clubs"))
                        ]),
                        _getAllCategroy()
                      ])
                    ),
                    //agree
                    Padding(padding: EdgeInsets.only(bottom: 20),
                      child: Row(children: [
                          CupertinoSwitch(
                            activeColor: Color.fromRGBO(255, 142, 93, 1),
                            value: _isAgree, 
                            onChanged: (value){
                              setState(() {
                                _isAgree = !_isAgree;
                              });
                            }
                          ),
                          SizedBox(width: 15),
                          Text("Agree",style: TextStyle(fontSize: 15,color: Colors.black,fontFamily: "SourceSansPro_clubs")),
                          SizedBox(width: 10,),
                          GestureDetector(
                            onTap: (){
                              launch("http://about.club-s.asia/Content_Policy.html");
                            },
                            child:Text("Community Guidelines",style: TextStyle(fontSize: 15,color: Colors.orange,fontFamily: "SourceSansPro_clubs")),
                          ),
                      ])
                    ),
                  ]
                )
              ),
              Padding(padding: EdgeInsets.all(20),child: ClubsMainButton(btnTextString: "Next",btnClick: (){
                _clickNext();
              },borderRadius: BorderRadius.circular(10),))
            ],
          )
        )
      
    );
  }




    //categoryWidget
    Widget _getAllCategroy() {
    List<OutlinedButton> list = [];
    for (int i=0;i<categoryList.length;i++) {
      String item = categoryList[i];
      list.add(OutlinedButton(
          onPressed: () => _clickCategory(i),
          style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
            padding: MaterialStateProperty.all(EdgeInsets.all(8)),
            side: i==_categoryIndex
              ?MaterialStateProperty.all(BorderSide(color: Colors.orange))
              :MaterialStateProperty.all(BorderSide(color: Colors.black45))
          ),
          child: Text(
            item,
            style: i==_categoryIndex
              ?TextStyle(color: Colors.orange, fontSize: 12,fontWeight: FontWeight.w600)
              :TextStyle(color: Colors.black45, fontSize: 12)
          )));
    }
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 15),
        child: Wrap(
          spacing: 10,
          children: list,
        ),
    );
  }






//-----------Data-----------

void _loadNft(){
  _nftList.clear();
  _selectedCount = 0;
  _nftList.add(NftSelect(Nft("id", "Dogs", "assets/club/dog.png"),false));
  _nftList.add(NftSelect(Nft("id", "Dogs", "assets/club/dog.png"),false));
  _nftList.add(NftSelect(Nft("id", "Dogs", "assets/club/dog.png"),false));
  _nftList.add(NftSelect(Nft("id", "Dogs", "assets/club/dog.png"),false));
  _nftList.add(NftSelect(Nft("id", "Dogs", "assets/club/dog.png"),false));
  _nftList.add(NftSelect(Nft("id", "Dogs", "assets/club/dog.png"),false));
  _nftList.add(NftSelect(Nft("id", "Dogs", "assets/club/dog.png"),false));
}






  //----------Events-----------

  Future<void> _clickChangePhoto() async {
    try{
      final XFile pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        print('No image selected');
        return;
      }
      setState(() {
       _imageProvider = FileImage(File(pickedFile.path));
      });
    }on PlatformException catch (e){
      //权限问题
      print(e.message);
      var status = await Permission.photos.request();
      if(!status.isGranted){
        ShowDialogUtil.showErrorDialog(context, "Please grant the permission of photo library to App.");
      }
    }
  }


  //Clickpassrule
  void _setPassRules(){
    //Loadingnft
    _loadNft();
    //Modal
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context_x,setState_x){
            return Container(
              width: double.infinity,
              height:MediaQuery.of(context).size.height-80,
              padding: EdgeInsets.fromLTRB(0,20,0,20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                color: Colors.white),
              child: Padding(
                padding: EdgeInsets.all(0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(
                      width: 50,
                      height: 6,
                      margin:EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(3)
                      ),
                    )),
                    Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child:Text("Select NFTs you owned and set the gated rule",textAlign: TextAlign.left,style: TextStyle(fontSize: 16,color: Colors.black,fontFamily: "SourceSansPro_clubs")),
                          ),
                    Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("Your NFT Found:   ",textAlign: TextAlign.left,style: TextStyle(fontSize: 14,color: Colors.black54,fontFamily: "SourceSansPro_clubs")),
                                Text(_nftList.length.toString(),textAlign: TextAlign.left,style: TextStyle(fontSize: 28,color: Colors.orange[900],fontFamily: "SourceSansPro_clubs",fontWeight: FontWeight.bold)),
                                SizedBox(width: MediaQuery.of(context).size.width*0.1),
                                Text("Max Choices:   ",textAlign: TextAlign.left,style: TextStyle(fontSize: 14,color: Colors.black54,fontFamily: "SourceSansPro_clubs")),
                                Text(_maxSelectNum.toString(),textAlign: TextAlign.left,style: TextStyle(fontSize: 28,color: Colors.black,fontFamily: "SourceSansPro_clubs",fontWeight: FontWeight.bold)),
                              ],
                            ),
                    ),
                    //nft列表
                    Expanded(child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 30,
                          crossAxisSpacing: 20,
                          childAspectRatio: 0.9
                        ),
                        itemCount: _nftList.length,
                        itemBuilder:  (context,index){
                          return GestureDetector(
                            onTap: (){
                              setState_x(() {
                                  if(_nftList[index].isSelected == true){//cancel
                                    _nftList[index].isSelected = false;
                                    _selectedCount--;
                                  }else{//select
                                    if(_selectedCount < _maxSelectNum){
                                      _nftList[index].isSelected = true;
                                      _selectedCount++;
                                    }
                                  }
                                });
                            },
                            child:  Card(
                              elevation: 10,
                              shadowColor: Colors.black45,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: _nftList[index].isSelected?BorderSide(
                                  color: Colors.orange[900],
                                  width: 5
                                ):BorderSide(width: 0,color: Colors.transparent)
                              ),
                              // borderOnForeground: false,
                              child:Container(
                                width: (MediaQuery.of(context).size.width-40)/3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),
                                      child:  Container(
                                        width: double.infinity,
                                        height: 70,
                                        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                        color: Color.fromRGBO(227, 237, 251, 1),
                                        child: Image.asset(_nftList[index].nft.imageUrl),
                                      )
                                    ),
                                    Text("Dogs",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold, color: Colors.black,fontFamily: "SourceSansPro_clubs")),
                                  ],
                                ),      
                              )
                          ));
                        }
                      )
                    )),
                    //Button
                    ClubsMainButton(
                      margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
                      btnTextString: "Confirm Rules",btnClick: _clickConfirm,)
                  ],
                )
              )
            );
          });
        });
  
  }



  //ClickCategory
  void _clickCategory(int index) {
    setState(() {
      _categoryIndex = index;
    });
  }

  //clickNext
  void _clickNext(){
     //retractKeyboard
    FocusScope.of(context).requestFocus(FocusNode());
    

    // if (_formKey.currentState.validate()) {
    //   Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateFirstPostVc()));
    // }
  }

 

  //confirm
  void _clickConfirm(){
    Navigator.pop(context);
  }

}


class NftSelect{
  Nft nft;
  bool isSelected;
  NftSelect(this.nft,this.isSelected){}
}