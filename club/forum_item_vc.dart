import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_uxcam/flutter_uxcam.dart';
import 'package:club/config/app_conf.dart';
import 'package:club/controller/account/join/joined_clubs.dart';
import 'package:club/controller/auth/login_with_account_vc.dart';
import 'package:club/controller/auth/login_with_choice_vc.dart';
import 'package:club/controller/club/create_club_vc.dart';
import 'package:club/controller/club/club_content_vc.dart';
import 'package:club/controller/main_item_type.dart';
import 'package:club/controller/main_navigation_vc.dart';
import 'package:club/domain/followed_club_summary.dart';
import 'package:club/domain/club_summary.dart';
import 'package:club/domain/popular_club_summary.dart';
import 'package:club/domain/user_profile.dart';
import 'package:club/service/auth_service.dart';
import 'package:club/service/club_service.dart';
import 'package:club/util/clubs_show_dialog_util.dart';
import 'package:club/util/image_resize.dart';
import 'package:club/util/show_dialog_mixin.dart';
import 'package:club/view/clubs_main_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:http/browser_client.dart';

class clubItemVc extends StatefulWidget implements MainItemVc {
  @override
  _clubItemVcState createState() => _clubItemVcState();

  @override
  MainItemType getMainItemType() {
    return MainItemType.club;
  }

  @override
  MainNavigationVc navigationVc;
}

class _clubItemVcState extends State<clubItemVc>
    with AutomaticKeepAliveClientMixin<clubItemVc> {
  List<PopularclubSummary> _popularclubs = [];
  List<FollowedclubSummary> _followedclubs = [];
  List<clubSummary> _clubs = [];

  clubService _clubService = clubService();
  bool _error;
  bool _loading;


  bool _isSearchState = false;

  bool _isSwitchAllCategories = false;


  final TextEditingController _contentController = TextEditingController();

  String selectedclubId;

  final TextEditingController _searchController = TextEditingController();

  List<String> _categoryList = categoryList;

  UserProfile _userProfile = UserProfile();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    AuthService authService = Provider.of<AuthService>(context, listen: false);
    _userProfile = authService.userProfile;
    _refreshPopularList();
    _fetchFollowedclubs();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            toolbarHeight: 70,
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
            title: Container(
              height: 35,
              padding: EdgeInsets.only(right: 5),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(18)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset("assets/club/club_Search_Icon.png", height: 30),
                  Expanded(
                      child: TextFormField(
                          controller: _searchController,
                          maxLines: 1,
                          cursorColor: Colors.orange,
                          decoration: InputDecoration(
                            hintText: "Search here",
                            hintStyle:
                                TextStyle(fontSize: 13, color: Colors.black54,fontFamily: "SourceSansPro_clubs"),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 15),
                          ),
                          onEditingComplete: _inputSearchDone)),
                  _isSearchState
                      ? GestureDetector(
                          onTap: _cancelSearch,
                          child:
                              Icon(Icons.cancel_rounded, color: Colors.black54),
                        )
                      : Container()
                ],
              ),
            )),
        body: Stack(
          alignment: Alignment.center,
          children: [
            Container(
                color: Colors.grey[200],
                width: double.infinity,
                child: _isSearchState
                    ? _getSearchResultListView()
                    : _isSwitchAllCategories
                        ? _getAllCategroy()
                        : _getListView())
          ],
        ));
  }

  Widget _getListView() {
    return RefreshIndicator(
        child: ListView.builder(
            itemCount: _popularclubs.length + 2,
            itemBuilder: (context, index) {
              if (index == 0) {
                if (_userProfile.token != null && _userProfile.token != "") {
                  return _getFollowed();
                } else {
                  return Container();
                }
              }
              if (index == 1) {
                return _getCategroy();
              }
              // if (index == _popularclubs.length - _nextPageThreshold +2 && _hasMore) {
              //   _fetchPopularclubs();
              // }
              if (index == _popularclubs.length + 2) {
                if (_error) {
                  return _errorView();
                } else {
                  return _loadingView();
                }
              }
              return _popularView(index - 2);
            }),
        onRefresh: _initData);
  }

  Widget _getSearchResultListView() {
    return ListView.builder(
        itemCount: _clubs.length,
        itemBuilder: (context, index) {
          if (index == _clubs.length) {
            if (_error) {
              return _errorView();
            } else {
              return _loadingView();
            }
          }
          return _clubView(index);
        });
  }

  Widget _getFollowed() {
    List<Widget> list = [];
    for (var i = 0; i < _followedclubs.length; i++) {
      FollowedclubSummary club = _followedclubs[i];
      list.add(GestureDetector(
          onTap: () => _clickclub(club.clubId),
          child: Container(
              width: (MediaQuery.of(context).size.width - 70) / 4,
              margin: EdgeInsets.only(right: 10),
              child: Column(children: [
                ClipOval(
                    child: (club.clubImageUrl == null ||
                            club.clubImageUrl.isEmpty)
                        ? Image.asset("assets/club/Followed_club-pic1.png",
                            width: 50, height: 50, fit: BoxFit.cover)
                        : Image.network(club.clubImageUrl,
                            width: 50, height: 50, fit: BoxFit.cover)),
                SizedBox(height: 5),
                Text(club.clubName,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.black,fontFamily: "SourceSansPro_clubs"),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis)
              ]))));

      if (i == 2 && _followedclubs.length >= 4) {
        list.add(GestureDetector(
            onTap: _clickMore,
            child: Container(
                width: (MediaQuery.of(context).size.width - 70) / 4,
                child: Column(children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(25)),
                    child: Icon(Icons.more_horiz),
                  ),
                  SizedBox(height: 5),
                  Text("More",
                      style: TextStyle(fontSize: 12, color: Colors.black,fontFamily: "SourceSansPro_clubs"),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis)
                ]))));
        break;
      }
    }
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(children: [
            Container(
                width: 5,
                height: 5,
                color: Colors.orange,
                margin: EdgeInsets.only(right: 5)),
            Text("Followed club",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,fontFamily: "SourceSansPro_clubs"))
          ]),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: list.length > 0
                ? list
                : [
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "You have no followed clubs~",
                      style: TextStyle(fontSize: 13, color: Colors.black38,fontFamily: "SourceSansPro_clubs"),
                    )
                  ],
          )
        ],
      ),
    );
  }

  Widget _getCategroy() {
    List<OutlinedButton> list = [];
    for (var i = 0; i < _categoryList.length; i++) {
      var item = _categoryList[i];
      list.add(OutlinedButton(
          onPressed: () => _clickCategory(item),
          style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
            padding: MaterialStateProperty.all(EdgeInsets.all(8)),
          ),
          child: Text(
            item,
            style: TextStyle(color: Colors.black54, fontSize: 12,fontFamily: "SourceSansPro_clubs"),
          )));
      if (i == 9) {
        //max9
        break;
      }
    }
    return Container(
        color: Colors.white,
        width: double.infinity,
        margin: EdgeInsets.only(top: 1),
        padding: EdgeInsets.all(20),
        child: Column(children: [
          Row(children: [
            Container(
                width: 5,
                height: 5,
                color: Colors.orange,
                margin: EdgeInsets.only(right: 5)),
            Expanded(
                child: Text("By Category",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,fontFamily: "SourceSansPro_clubs"))),
            Container(
                width: 90,
                child: GestureDetector(
                  child: Text("All Categories >",
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          decoration: TextDecoration.underline,fontFamily: "SourceSansPro_clubs")),
                  onTap: _switchCategory,
                ))
          ]),
          Container(
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: Wrap(
              spacing: 10,
              children: list,
            ),
          ),
          Row(children: [
            Container(
                width: 5,
                height: 5,
                color: Colors.orange,
                margin: EdgeInsets.only(right: 5)),
            Text("Popular",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,fontFamily: "SourceSansPro_clubs")),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ClubsMainButton(
                    width: 110,
                    height: 35,
                    borderRadius: BorderRadius.circular(10),
                    btnClick: ()=>_clickCreateClub(),
                    btnTextString: "Create a Club",
                    btnTextStyle: TextStyle(
                      fontSize: 13,
                      fontFamily: "SourceSansPro_clubs",
                      fontWeight: FontWeight.bold
                    ),
                  )
                ],
              )
            )
          ]),
        ]));
  }

  Widget _getAllCategroy() {
    List<OutlinedButton> list = [];
    for (var item in _categoryList) {
      list.add(OutlinedButton(
          onPressed: () => _clickCategory(item),
          style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
            padding: MaterialStateProperty.all(EdgeInsets.all(8)),
          ),
          child: Text(
            item,
            style: TextStyle(color: Colors.black54, fontSize: 12,fontFamily: "SourceSansPro_clubs"),
          )));
    }
    return Column(children: [
      Container(
          color: Colors.white,
          width: double.infinity,
          margin: EdgeInsets.only(top: 1),
          padding: EdgeInsets.all(20),
          child: Column(children: [
            Row(children: [
              Container(
                  width: 5,
                  height: 5,
                  color: Colors.orange,
                  margin: EdgeInsets.only(right: 5)),
              Text("By Category",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,fontFamily: "SourceSansPro_clubs"))
            ]),
            Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: Wrap(
                spacing: 10,
                children: list,
              ),
            ),
            Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                child: GestureDetector(
                    child: Text("< Back to club ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            decoration: TextDecoration.underline,fontFamily: "SourceSansPro_clubs")),
                    onTap: _switchCategory)),
          ]))
    ]);
  }

  Widget _popularView(int index) {
    PopularclubSummary club = _popularclubs[index];
    return GestureDetector(
        onTap: () => _clickclub(club.id),
        child: Container(
            color: Colors.white,
            width: double.infinity,
            margin: EdgeInsets.only(top: 1),
            padding: EdgeInsets.all(20),
            child: Column(children: [
              //club info
              Row(children: [
                Container(
                    width: 25,
                    height: 25,
                    padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.orange)),
                    child: Text(
                      (index + 1).toString(),
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,),
                      textAlign: TextAlign.center,
                    )),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.all(8),
                  width: 55,
                  height: 55,
                  child: ClipOval(
                      child: (club.imageUrl == null || club.imageUrl.isEmpty)
                          ? Image.asset(
                              "assets/club/Followed_club-pic1.png",
                              fit: BoxFit.cover,
                            )
                          : ResizeImageUtil.resizedImage(
                              context, club.imageUrl,
                              width: 55, height: 55)),
                ),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(club.name,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold,fontFamily: "SourceSansPro_clubs")),
                        Text(
                            "${club.followerCount}  Followers   ${club.postCount} Posts",
                            style:
                                TextStyle(fontSize: 12, color: Colors.black54,fontFamily: "SourceSansPro_clubs")),
                      ]),
                ),
                GestureDetector(
                  onTap: () => club.followedByMe
                      ? _clickUnfollow(club.id)
                      : _clickFollow(club.id),
                  child: Container(
                    width: 70,
                    height: 30,
                    padding: EdgeInsets.only(top: 6),
                    decoration: club.followedByMe
                        ? BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color.fromRGBO(218, 218, 218, 1),
                          )
                        : BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.orange),
                          ),
                    child: club.followedByMe
                        ? Text("Followed",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 13,fontFamily: "SourceSansPro_clubs"))
                        : Text("Follow",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: Colors.orange, fontSize: 13,fontFamily: "SourceSansPro_clubs")),
                  ),
                )
              ]),
              //3HotTopic
              (club.postItems != null && club.postItems.length >= 1)
                  ? Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Row(
                        children: [
                          Image.asset("assets/topic/hot_icon.png", width: 10),
                          SizedBox(width: 10),
                          Expanded(
                              child: Text(
                            club.postItems[0].title,
                            style:
                                TextStyle(color: Colors.black, fontSize: 12,fontFamily: "SourceSansPro_clubs"),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ))
                        ],
                      ),
                    )
                  : Row(),
              (club.postItems != null && club.postItems.length >= 2)
                  ? Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Row(
                        children: [
                          Image.asset("assets/topic/hot_icon.png", width: 10),
                          SizedBox(width: 10),
                          Expanded(
                              child: Text(
                            club.postItems[1].title,
                            style:
                                TextStyle(color: Colors.black, fontSize: 12,fontFamily: "SourceSansPro_clubs"),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ))
                        ],
                      ),
                    )
                  : Row(),
              (club.postItems != null && club.postItems.length >= 3)
                  ? Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Row(
                        children: [
                          Image.asset("assets/topic/hot_icon.png", width: 10),
                          SizedBox(width: 10),
                          Expanded(
                              child: Text(
                            club.postItems[2].title,
                            style:
                                TextStyle(color: Colors.black, fontSize: 12,fontFamily: "SourceSansPro_clubs"),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ))
                        ],
                      ),
                    )
                  : Row(),
            ])));
  }

  Widget _clubView(int index) {
    clubSummary club = _clubs[index];
    return GestureDetector(
        onTap: () => _clickclub(club.id),
        child: Container(
            color: Colors.white,
            width: double.infinity,
            margin: EdgeInsets.only(top: 1),
            padding: EdgeInsets.all(20),
            child: Column(children: [
              //club info
              Row(children: [
                Container(
                    width: 25,
                    height: 25,
                    padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.orange)),
                    child: Text(
                      (index + 1).toString(),
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    )),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.all(8),
                  width: 55,
                  height: 55,
                  child: ClipOval(
                      child: (club.imageUrl == null || club.imageUrl.isEmpty)
                          ? Image.asset(
                              "assets/club/Followed_club-pic1.png",
                              fit: BoxFit.cover,
                            )
                          : Image.network(club.imageUrl, fit: BoxFit.cover)),
                ),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(club.name,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        Text(
                            "${club.followerCount}  Followers   ${club.postCount} Posts",
                            style:
                                TextStyle(fontSize: 12, color: Colors.black54,fontFamily: "SourceSansPro_clubs")),
                      ]),
                ),
                GestureDetector(
                  onTap: () => club.followedByMe
                      ? _clickUnfollow(club.id)
                      : _clickFollow(club.id),
                  child: Container(
                    width: 70,
                    height: 30,
                    padding: EdgeInsets.only(top: 6),
                    decoration: club.followedByMe
                        ? BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color.fromRGBO(218, 218, 218, 1),
                          )
                        : BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.orange),
                          ),
                    child: club.followedByMe
                        ? Text("Followed",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 13,fontFamily: "SourceSansPro_clubs"))
                        : Text("Follow",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: Colors.orange, fontSize: 13,fontFamily: "SourceSansPro_clubs")),
                  ),
                )
              ]),
            ])));
  }

  Widget _loadingView() {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(8),
      child: CircularProgressIndicator(),
    ));
  }

  Widget _errorView() {
    return Center(
        child: InkWell(
      onTap: () {
        setState(() {
          _loading = true;
          _error = false;
          _initData();
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text("Error loading posts. Tap to retry"),
      ),
    ));
  }

  Widget applyFollowView() {
    //msgLayer
    return Container(
      width: double.infinity,
      height: 280,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          color: Colors.white),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          TextButton(
              onPressed: _closeApply,
              child: Text(
                "Exit",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,fontFamily: "SourceSansPro_clubs"),
              )),
          TextButton(
              onPressed: _clickApplyFollow,
              child: Text(
                "Apply",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.orange,
                    fontWeight: FontWeight.w400,fontFamily: "SourceSansPro_clubs"),
              ))
        ]),
        //textBox
        Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color.fromRGBO(244, 244, 244, 1),
            ),
            padding: EdgeInsets.all(5),
            child: TextFormField(
              cursorColor: Colors.orange,
              controller: _contentController,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: 'Please write down the reasons. ',
                labelStyle: TextStyle(color: Colors.black12, fontSize: 14,fontFamily: "SourceSansPro_clubs"),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                return null;
              },
              maxLines: 5,
            )),
        SizedBox(height: 15),
        Text(
          "We will respond you later.",
          style: TextStyle(fontSize: 14, color: Colors.black54,fontFamily: "SourceSansPro_clubs"),
        )
      ]),
    );
  }

//------Data---------

  void _resetFetchStates() {
    _error = false;
    _loading = true;
    _popularclubs = [];
  }

  Future<void> _refreshPopularList() async {
    _resetFetchStates();
    _fetchPopularclubs();
  }

  Future<void> _fetchPopularclubs() async {
    try {
      final clubs = await _clubService.fetchPopularclubs(_userProfile.uid);
      setState(() {
        _loading = false;
        _popularclubs.addAll(clubs);
      });
    } catch (e) {
      print(e);
      setState(() {
        _loading = false;
        _error = true;
        _popularclubs = [];
      });
    }
  }

  Future<void> _fetchFollowedclubs() async {
    try {
      final clubs = await _clubService.fetchFollowedclubs(10, null);
      setState(() {
        _followedclubs.clear();
        _followedclubs.addAll(clubs);
      });
    } catch (e) {
      print(e);
      setState(() {
        _loading = false;
        _error = true;
        _popularclubs = [];
      });
    }
  }

  Future<void> _fetchAllclubs(String category) async {
    _error = false;
    _loading = true;
    _clubs = [];
    try {
      final clubs = await _clubService.fetchAllclubs(category);
      setState(() {
        _loading = false;
        _clubs.addAll(clubs);
      });
    } catch (e) {
      print(e);
      setState(() {
        _loading = false;
        _error = true;
        _clubs = [];
      });
    }
  }

  //--------Event-------
  void _switchCategory() {
    setState(() {
      _isSwitchAllCategories = !_isSwitchAllCategories;
    });
  }

  void _clickMore() {
    Joinedclubs.startJoinedclubsPage(context);
  }

  //createClub
  void _clickCreateClub() {


    //goCreate
    ClubsShowDialogUtil.showTipDialog(context,
        mainTitle: "Too Early",
        miniTitle: "Need to meet the requirements:",
        content:
            "· Account created more than 7 days\n· No disciplinary action\n· Haven’t created a club in 7 days",
        callback: () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateclubVc()));
    });
  }


  void _clickclub(String clubId) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => clubContentVc(clubId: clubId)));
  }

  Future<void> _clickFollow(String clubId) async {
    if (_userProfile == null || _userProfile.name == null) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userProfileStr = preferences.getString("user");
      if (userProfileStr == null) {
        
        Navigator.of(context, rootNavigator: true)
            .push(MaterialPageRoute(builder: (context) => LoginWithAccountVc()))
            .then((v) => {
                  userProfileStr = preferences.getString("user"),
                  if (userProfileStr != null)
                    {
                      Future.delayed(Duration(milliseconds: 800), () {
                        _initData();
                      })
                    }
                });
      } else {
        UserProfile userProfile =
            UserProfile.fromJson(jsonDecode(userProfileStr));
        if (!userProfile.isLogin) {
     
          Navigator.of(context, rootNavigator: true)
              .push(
                  MaterialPageRoute(builder: (context) => LoginWithChoiceVc()))
              .then((v) => {
                    userProfileStr = preferences.getString("user"),
                    userProfile =
                        UserProfile.fromJson(jsonDecode(userProfileStr)),
                    if (userProfile.isLogin)
                      {
                        Future.delayed(Duration(milliseconds: 800), () {
                          _initData();
                        })
                      }
                  });
        }
      }
      return;
    } else {
      selectedclubId = clubId;
      print("选中了club:$clubId");
      showModalBottomSheet(
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          context: context,
          builder: (BuildContext context) {
            return AnimatedPadding(
              padding: MediaQuery.of(context).viewInsets,
              duration: const Duration(milliseconds: 100),
              child: applyFollowView()
            );
          });
    }
  }

  Future<void> _clickUnfollow(String clubId) async {
    selectedclubId = clubId;
    print("选中了club:$clubId");
    ShowDialogUtil.showLoading(context);
    try {
      await _clubService.unFollow(selectedclubId).then((value) => {
            _initData(),
            Navigator.pop(context),
          });
    } catch (e) {
      print(e);
      Navigator.pop(context);
      ShowDialogUtil.showErrorDialog(context, "Failed to unfollow,try again");
    }
  }

  void _closeApply() {
    // retractKeyboard
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      selectedclubId = null;
      _contentController.clear();
    });
    Navigator.pop(context);
  }

  Future<void> _clickApplyFollow() async {
    print("发起申请");
    if (_contentController.text.trim().isEmpty) {
      ShowDialogUtil.showErrorDialog(context, "Please input your reason");
      return;
    }
    ShowDialogUtil.showLoading(context);
    try {
      await _clubService
          .followApply(selectedclubId, _contentController.text)
          .then((value) => {
                _initData(),
                Navigator.pop(context),
                _closeApply(),
            
                FlutterUxcam.setUserIdentity(_userProfile.uid),
                FlutterUxcam.setUserProperty("userName", _userProfile.name),
                FlutterUxcam.logEventWithProperties(
                    "clubItem-follow-followApply", {
                  "clubId": selectedclubId,
                  "followReason": _contentController.text
                })
              });
    } catch (e) {
      print(e);
      Navigator.pop(context);
      ShowDialogUtil.showErrorDialog(context, "Failed to apply,try again");
    }
  }

  void _clickCategory(String categoryName) {

    _searchController.text = categoryName;

    _inputSearchDone();
  }

  void _inputSearchDone() {
    // retractKeyboard
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {

      if (_searchController.text.isEmpty) {
        _isSearchState = false;
      } else {

        _doSearch();
      }
    });
  }

  void _cancelSearch() {
    setState(() {
      _searchController.clear();
      _isSearchState = false;
    });
  }