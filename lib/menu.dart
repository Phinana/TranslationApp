import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:myfirsproje/friendScreen.dart';
import 'package:myfirsproje/home.dart';
import 'package:myfirsproje/main.dart';
import 'package:myfirsproje/rankedQueue.dart';
import 'package:myfirsproje/service/authoje/soruEkleme.dart';
import 'package:myfirsproje/timeTrial.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'Finish.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  AuthService _authService = AuthService();

  var user = FirebaseAuth.instance.currentUser;
  var fireStore = FirebaseFirestore.instance;
  String infoGenel = "Translation Battle";
  String infoGenel2 =
      "Translation Battle is a translation game. It has 4 different game modes (Normal Game, Ranked Game,"
      " Time Trial, Pass & Play) Play now to join the fun and competitive adventure that educates you while getting fun."
      " Get more points to take higher place in the overall ranking.";
  String infoNormal = "Normal Game";
  String infoNormal2 =
      "In Normal Game mode, You don't lose or gain any points. Main goal of this gamemode, getting more points than 8 in levels "
      "that becomes more difficult each time. You level up for each lock you unlock.";
  String infoRank = "Ranked Game";
  String infoRank2 =
      "Your goal in this game mode is to answer more questions than your opponent correctly. If both sides score equal points, "
      "the winner will be the one who answers the question faster. "
      "If both players answered the questions in equal time, it's a draw."
      " Depending on the result of the game, you gain or lose elo points. Elo score determines your level."
      "Play now and get points to take higher place in "
      "Top List"
      ".";
  String infoTime = "Time Trial";
  String infoTime2 =
      "The goal of this game mode is to solve the maximum number of questions in the given time. answer random and increasingly difficult"
      " questions as fast as possible.";
  String infoPassPlay = "Pass & Play";
  String infoPassPlay2 =
      "You can challenge your friends in this game mode. Your scores are not affected in this mode. With your friends "
      "in fun mode” "
      "match and enjoy the game while you learn.";

  var usersRef = FirebaseFirestore.instance.collection("Person");
  var onlineRef = FirebaseDatabase.instance.ref('.info/connected');

  @override
  void initState() {
    // TODO: implement initState

    FirebaseDatabase.instance
        .ref('status/${user.uid}')
        .onDisconnect()
        .set('offline')
        .then((value) => {
              fireStore
                  .collection("Person")
                  .doc(user.uid)
                  .update({'durum': true}),
            });

    FirebaseDatabase.instance.ref('status/${user.uid}').set('online');

    super.initState();
  }

  infoDialog(BuildContext context) {
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Stack(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height / 3 * 2,
                padding:
                    EdgeInsets.only(top: 50, bottom: 16, left: 16, right: 16),
                margin: EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        offset: Offset(0.0, 10.0),
                      ),
                    ]),
                child: SingleChildScrollView(
                  child: Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          infoGenel,
                          style: TextStyle(
                              fontSize: 24.0, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          infoGenel2,
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Text(
                          infoNormal,
                          style: TextStyle(
                              fontSize: 24.0, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          infoNormal2,
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Text(
                          infoTime,
                          style: TextStyle(
                              fontSize: 24.0, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          infoTime2,
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Text(
                          infoRank,
                          style: TextStyle(
                              fontSize: 24.0, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          infoRank2,
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Text(
                          infoPassPlay,
                          style: TextStyle(
                              fontSize: 24.0, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          infoPassPlay2,
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 60;
    return Scaffold(
      body: Container(
        color: Color(0xFF272837),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Listener")
              .doc()
              .snapshots(),
          builder: (context, listener) {
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("Person")
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    listener.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  var dinleyici = listener.data;
                  if (dinleyici.data() != null) {
                    if (dinleyici["arkIstek"] == "gonderildi") {
                      Fluttertoast.showToast(msg: "Ark isteği alındı");
                    }
                  }
                  var alinanVeri = snapshot.data["nick"];
                  var urlTutucu = snapshot.data["resim"];
                  var alinanLevel = snapshot.data["level"];

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 6, left: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  KullaniciGecmis(
                                                    aranacakuid: FirebaseAuth
                                                        .instance
                                                        .currentUser
                                                        .uid,
                                                    mnick: alinanVeri,
                                                    mresim: urlTutucu,
                                                  )));
                                    },
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          urlTutucu,
                                          height: 50,
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF2952BF),
                                            border: Border.all(width: 1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            alinanVeri,
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                fontFamily: 'İtalic',
                                                decoration: TextDecoration.none,
                                                fontSize: 12,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  CircularPercentIndicator(
                                    radius: 45.0,
                                    animation: true,
                                    lineWidth: 5.0,
                                    percent: ((100 / 30) * alinanLevel) / 100,
                                    center: Text(
                                      alinanLevel.toString(),
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                    backgroundColor: Color(0xFF2952BF),
                                    progressColor:
                                        Theme.of(context).accentColor,
                                  ),
                                ],
                              ),
                            ),
                            Image.asset(
                              "images/logo2.png",
                              width: 180.0,
                              height: 180.0,
                            ),
                            Text(
                              'Translation Battle',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'yazi',
                                  decoration: TextDecoration.none,
                                  fontSize: 50,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: RawMaterialButton(
                                onPressed: () {
                                  infoDialog(context);
                                },
                                fillColor: Colors.white,
                                shape: CircleBorder(),
                                constraints:
                                    BoxConstraints(minHeight: 35, minWidth: 35),
                                child: FaIcon(FontAwesomeIcons.info,
                                    size: 22, color: Color(0xFF2F3041)),
                              ),
                            ),
                            circButton(
                                FontAwesomeIcons.medal,
                                achievementScreen(
                                  nick: alinanVeri,
                                )),
                            circButton(
                                FontAwesomeIcons.lightbulb,
                                Finishh(
                                  elo: 150,
                                  finishKullaniciAdi: "cengiz",
                                  kazan: "kazandı",
                                  totalScore: 7,
                                )),
                            circButton(FontAwesomeIcons.cog, profileScreen()),
                            circButton(
                                FontAwesomeIcons.userFriends,
                                OnlineUser(
                                  nick: alinanVeri,
                                  url: urlTutucu,
                                ))
                          ],
                        ),
                        Wrap(
                          runSpacing: 8,
                          children: [
                            GestureDetector(
                              onTap: () {
                                final list = nextNumbers(10, min: 0, max: 29);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChoiseLevel(
                                      lKullanici: alinanVeri,
                                      list: list,
                                      url: urlTutucu,
                                    ),
                                  ),
                                );
                              },
                              child: modeButton(
                                  'Play',
                                  'Play o normal game',
                                  FontAwesomeIcons.trophy,
                                  Color(0xFF2F80ED),
                                  width),
                            ),
                            GestureDetector(
                              onTap: () {
                                final list = nextNumbers(29, min: 0, max: 29);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => timeTrial(
                                      list: list,
                                      homekullaniciAdi: alinanVeri,
                                      url: urlTutucu,
                                    ),
                                  ),
                                );
                              },
                              child: modeButton(
                                  'Time Trial',
                                  'Race against the clock',
                                  FontAwesomeIcons.userClock,
                                  Color(0xFFDF1D5A),
                                  width),
                            ),
                            GestureDetector(
                              onTap: () {
                                final list = nextNumbers(10, min: 0, max: 29);
                                var currentID =
                                    FirebaseAuth.instance.currentUser.uid;
                                FirebaseFirestore.instance
                                    .collection("Games")
                                    .get()
                                    .then((data) {
                                  var readdata = data.docs;
                                  var odakurucuid;
                                  for (int i = 0; i < readdata.length; i++) {
                                    if (readdata[i]["odaVisiblity"] == true) {
                                      odakurucuid = readdata[i]["odaID"];
                                      FirebaseFirestore.instance
                                          .collection("Games")
                                          .doc(odakurucuid)
                                          .update({
                                        "odaVisiblity": false,
                                        "user2": alinanVeri,
                                        "user2resim": urlTutucu.toString(),
                                        "user2totalScore": 0,
                                        "user2time": 0,
                                        "user2testDurum": "devam",
                                      });

                                      return Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  rankLaunchScreen(
                                                    user: "user2",
                                                    nick: alinanVeri,
                                                    odaID: odakurucuid,
                                                    list: list,
                                                  )));
                                    }
                                  }
                                  FirebaseFirestore.instance
                                      .collection("Games")
                                      .doc(currentID)
                                      .set({
                                    "odaID": currentID,
                                    "odaVisiblity": true,
                                    "user1": alinanVeri,
                                    "user2": "Waiting",
                                    "user1resim": urlTutucu.toString(),
                                    "user2resim": "bekle",
                                    "user1totalScore": 0,
                                    "user2totalScore": 0,
                                    "user1time": 0,
                                    "user2time": 0,
                                    "user1testDurum": "devam",
                                    "user2testDurum": "baslamadi",
                                    "silmeDurumu": false
                                  });
                                  return Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              rankLaunchScreen(
                                                user: "user1",
                                                nick: alinanVeri,
                                                odaID: currentID,
                                                list: list,
                                              )));
                                });
                              },
                              child: modeButton(
                                  'Ranks',
                                  'Show ranks',
                                  FontAwesomeIcons.couch,
                                  Color(0xFF45D280),
                                  width),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => friendScreen()));
                              },
                              child: modeButton(
                                  'Pass & Play',
                                  'Challenge your friends',
                                  FontAwesomeIcons.userFriends,
                                  Color(0xFFFF8306),
                                  width),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  int nextNumber({int min, int max}) => min + Random().nextInt(max - min + 1);

  List<int> nextNumbers(int length, {int min, int max}) {
    final numbers = Set<int>();
    while (numbers.length < length) {
      final number = nextNumber(min: min, max: max);
      numbers.add(number);
    }
    return List.of(numbers);
  }

  Padding circButton(IconData icon, Widget page) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: RawMaterialButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => page));
        },
        fillColor: Colors.white,
        shape: CircleBorder(),
        constraints: BoxConstraints(minHeight: 35, minWidth: 35),
        child: FaIcon(icon, size: 22, color: Color(0xFF2F3041)),
      ),
    );
  }

  GestureDetector modeButton(
      String title, String subtitle, IconData icon, Color color, double width) {
    return GestureDetector(
      child: Container(
        width: width,
        height: 80,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 17, 0, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                      fontFamily: 'Manrope',
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                        fontFamily: 'Manrope',
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 17, 25, 20),
              child: FaIcon(
                icon,
                size: 35,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}

//kullanıcı adına tıklanınca sayfa
class KullaniciGecmis extends StatefulWidget {
  String aranacakuid, mnick, mresim;
  KullaniciGecmis({this.aranacakuid, this.mnick, this.mresim});
  @override
  _KullaniciGecmisState createState() => _KullaniciGecmisState();
}

class _KullaniciGecmisState extends State<KullaniciGecmis> {
  showEkleDialog(BuildContext context, String clickknick, String clickkresim,
      String mynick, String myresim) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(
        "Quit",
        style: TextStyle(
            color: Colors.red, fontSize: 17, fontWeight: FontWeight.bold),
      ),
      onPressed: () => Navigator.pop(context, false),
    );
    Widget continueButton = TextButton(
      child: Text(
        "Ekle",
        style: TextStyle(
            color: Colors.green, fontSize: 17, fontWeight: FontWeight.bold),
      ),
      onPressed: () => FirebaseFirestore.instance
          .collection("Listener")
          .doc(clickknick)
          .collection("istek")
          .doc(mynick)
          .set({
        "id": FirebaseAuth.instance.currentUser.uid,
        "nick": mynick,
        "resim": myresim,
        "friendsId": "yok",
        "friendsNick": clickknick,
        "friendsResim": clickkresim,
        "arkIstek": "gonderildi",
        "oyunIstek": "yok"
      }).then(
        (value) => Navigator.pop(context, false),
      ),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      content: Text(
        "Arkadaş eklemek istediğinize emin misiniz?",
        style: TextStyle(
            color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showCikarDialog(BuildContext context, String friendsNick) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(
        "Quit",
        style: TextStyle(
            color: Colors.red, fontSize: 17, fontWeight: FontWeight.bold),
      ),
      onPressed: () => Navigator.pop(context, false),
    );
    Widget continueButton = TextButton(
      child: Text(
        "Çıkar",
        style: TextStyle(
            color: Colors.green, fontSize: 17, fontWeight: FontWeight.bold),
      ),
      onPressed: () => FirebaseFirestore.instance
          .collection("Person")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection("friends")
          .doc(friendsNick)
          .delete()
          .then(
            (value) => Navigator.pop(context, false),
          ),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      content: Text(
        "Arkadaşlar listenizden çıkarmak istediğinize emin misiniz?",
        style: TextStyle(
            color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  String clickresim, clicknick;
  String arkadas = "degil";

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Person")
            .doc(FirebaseAuth.instance.currentUser.uid)
            .collection("friends")
            .snapshots(),
        builder: (context, friendsVeri) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("Users")
                .doc("rankedGame")
                .collection(widget.aranacakuid)
                .orderBy("tarih", descending: true)
                .snapshots(),
            builder: (context, veriAl) {
              if (veriAl.connectionState == ConnectionState.waiting ||
                  friendsVeri.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                var friend = friendsVeri.data.docs;
                var veri = veriAl.data.docs;
                print(friend.isEmpty.toString());
                print(widget.aranacakuid);
                print(friend.length);
                if (!friend.isEmpty) {
                  print(friend.length);
                  for (int i = 0; i < friend.length; i++) {
                    print(friend[i]["friendsId"]);
                    if (widget.aranacakuid == friend[i]["friendsId"]) {
                      arkadas = "arkadas";
                    }
                  }
                }

                if (veri.isEmpty) {
                  return Scaffold(
                    appBar: AppBar(
                      backgroundColor: Color(0xFFD7D6D6),
                      centerTitle: true,
                      title: Text(
                        'Profiles Details',
                        style: TextStyle(
                            fontSize: 35,
                            fontFamily: "yazi",
                            fontWeight: FontWeight.normal,
                            color: Colors.black),
                      ),
                      iconTheme: IconThemeData(color: Colors.black),
                    ),
                    body: Center(
                      child: Text("Kullanıcı hiç maç oynamadı!"),
                    ),
                  );
                }

                clicknick = veri[veri.length - 1]["nick"];
                clickresim = veri[veri.length - 1]["user1resim"];

                return Scaffold(
                  appBar: AppBar(
                    backgroundColor: Color(0xFFD7D6D6),
                    centerTitle: true,
                    title: Text(
                      'Profiles Details',
                      style: TextStyle(
                          fontSize: 35,
                          fontFamily: "yazi",
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                    ),
                    iconTheme: IconThemeData(color: Colors.black),
                  ),
                  body: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30)),
                        gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Colors.black54,
                              Color.fromRGBO(0, 41, 102, 1)
                            ])),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 15, 0, 20),
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "Nick :  " + veri[0]["nick"],
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    "Elo :  " + veri[0]["elo"].toString(),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    "Match :  " + veri.length.toString(),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  (widget.aranacakuid ==
                                          FirebaseAuth.instance.currentUser.uid)
                                      ? SizedBox()
                                      : FloatingActionButton(
                                          onPressed: () {
                                            (arkadas == "arkadas")
                                                ? showCikarDialog(
                                                    context, clicknick)
                                                : showEkleDialog(
                                                    context,
                                                    clicknick,
                                                    clickresim,
                                                    widget.mnick,
                                                    widget.mresim);
                                          },
                                          mini: true,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              side: BorderSide(
                                                  color: Colors.black,
                                                  width: 1.4)),
                                          backgroundColor: Colors.white,
                                          child: Image.asset(
                                            (arkadas == "arkadas")
                                                ? "images/deleteUser.png"
                                                : "images/useradd.png",
                                            height: 20,
                                          ),
                                        )
                                ],
                              ),
                              Image.asset(
                                veri[0]["user1resim"],
                                height: 150,
                                width: 150,
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          child: Scrollbar(
                            showTrackOnHover: true,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Container(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.all(8.0),
                                  itemCount: veri.length,
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot ver = veri[index];
                                    return Container(
                                      margin:
                                          const EdgeInsets.fromLTRB(9, 9, 9, 1),
                                      height: 75,
                                      decoration: BoxDecoration(
                                        color:
                                            (ver["kazanmmDurumu"] == "kazandı")
                                                ? Colors.green
                                                : Colors.red,
                                        border: Border.all(
                                          width: 1,
                                          color: Colors.white,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Image.asset(
                                                    ver["user1resim"],
                                                    height: 50,
                                                  ),
                                                  Text(
                                                    ver["nick"],
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Text(
                                                    ver["user1totalscore"]
                                                            .toString() +
                                                        " doğru",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  Text(
                                                    ver["user1time"]
                                                            .toString() +
                                                        " saniye",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )
                                                ],
                                              ),
                                              Text(
                                                "vs",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              Column(
                                                children: [
                                                  Text(
                                                    ver["user2totalscore"]
                                                            .toString() +
                                                        " doğru",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  Text(
                                                    ver["user2time"]
                                                            .toString() +
                                                        " saniye",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )
                                                ],
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Image.asset(
                                                    ver["user2resim"],
                                                    height: 50,
                                                  ),
                                                  Text(
                                                    ver["rakip"],
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          );
        });
  }
}

// Level seçme ekranı
class ChoiseLevel extends StatefulWidget {
  String lKullanici, url;
  List<int> list;

  ChoiseLevel({this.lKullanici, this.list, this.url});

  @override
  _ChoiseLevelState createState() => _ChoiseLevelState();
}

class _ChoiseLevelState extends State<ChoiseLevel> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Person")
            .doc(FirebaseAuth.instance.currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              color: Colors.deepOrange,
            ));
          } else {
            var veri = snapshot.data;
            var levels = veri["level"];
            List<String> levelNumber = [
              "images/levels/1.png",
              "images/levels/2.png",
              "images/levels/3.png",
              "images/levels/4.png",
              "images/levels/5.png",
              "images/levels/6.png",
              "images/levels/7.png",
              "images/levels/8.png",
              "images/levels/9.png",
              "images/levels/10.png",
              "images/levels/11.png",
              "images/levels/12.png",
              "images/levels/13.png",
              "images/levels/14.png",
              "images/levels/15.png",
              "images/levels/16.png",
              "images/levels/17.png",
              "images/levels/18.png",
              "images/levels/19.png",
              "images/levels/20.png",
              "images/levels/21.png",
              "images/levels/22.png",
              "images/levels/23.png",
              "images/levels/24.png",
              "images/levels/25.png",
              "images/levels/26.png",
              "images/levels/27.png",
              "images/levels/28.png",
              "images/levels/29.png",
              "images/levels/30.png",
              "images/levels/31.png",
              "images/levels/32.png",
              "images/levels/33.png",
              "images/levels/34.png",
              "images/levels/35.png",
              "images/levels/36.png",
              "images/levels/37.png",
              "images/levels/38.png",
              "images/levels/39.png",
            ];
            return Scaffold(
              backgroundColor: Color(0xFF303247),
              body: Scrollbar(
                showTrackOnHover: true,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Levels",
                        style: TextStyle(
                          fontFamily: "yazi",
                          fontSize: 45,
                          color: Color(0xFFC9F3F3),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                        child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                            ),
                            shrinkWrap: true,
                            itemCount: levelNumber.length,
                            itemBuilder: (context, levelindex) {
                              return levelButton(levelNumber[levelindex],
                                  levelindex + 1, levels);
                            }),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        });
  }

  Padding levelButton(String url, int level, int kilit) {
    var kilitKontrol = false;

    if (kilit < level) {
      url = "images/unlock.png";
      kilitKontrol = true;
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
            color: Color(0xFF00FFFA).withOpacity(.7),
            borderRadius: BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                  color: Color(0xE404805A).withOpacity(.35),
                  blurRadius: 40,
                  spreadRadius: 2)
            ]),
        child: ElevatedButton(
          onPressed: () {
            if (kilitKontrol == false) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Home(
                            homekullaniciAdi: widget.lKullanici,
                            list: widget.list,
                            url: widget.url,
                            kilitlevel: level,
                          )));
            } else {
              Fluttertoast.showToast(msg: "Bu seviye kilitlidir!");
            }
          },
          style: ElevatedButton.styleFrom(
            primary: Color(0xFF1A8B8B),
            fixedSize: (Size(75, 75)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(43),
            ),
          ),
          child: Image.asset(
            url,
            height: 120,
          ),
        ),
      ),
    );
  }
}

// Ödül ekranı
class achievementScreen extends StatefulWidget {
  String nick;

  achievementScreen({this.nick});

  @override
  _achievementScreenState createState() => _achievementScreenState();
}

class _achievementScreenState extends State<achievementScreen> {
  var user = FirebaseAuth.instance.currentUser;
  var fireStore = FirebaseFirestore.instance;

  var kendiresmi;
  var kontrol = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Person")
          .orderBy("elo", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          var veriler = snapshot.data.docs;
          for (int i = 0; i < veriler.length; i++) {
            if (veriler[i]["elo"] == -100 &&
                veriler[i]["currentId"].toString() ==
                    FirebaseAuth.instance.currentUser.uid.toString()) {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: Color(0xFFD7D6D6),
                  centerTitle: true,
                  title: Text(
                    'Top List',
                    style: TextStyle(
                        fontSize: 40,
                        fontFamily: "yazi",
                        fontWeight: FontWeight.normal,
                        color: Colors.black),
                  ),
                  iconTheme: IconThemeData(color: Colors.black),
                ),
                body: Center(
                  child: Text("Kullanıcı hiç maç oynamadı!"),
                ),
              );
            }
          }
          return Scaffold(
            backgroundColor: Color(0xFF272837),
            appBar: AppBar(
              title: Text(
                "Top List",
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontFamily: "yazi",
                ),
              ),
              centerTitle: true,
              backgroundColor: Color(0xFF2B2B44),
            ),
            body: ListView.builder(
              shrinkWrap: true,
              itemCount: veriler.length,
              itemBuilder: (BuildContext context, int index) {
                if (veriler[index]["elo"] == -100) {
                  return SizedBox();
                }
                DocumentSnapshot satirVerisi = veriler[index];

                if (widget.nick == satirVerisi["nick"]) {
                  kendiresmi = satirVerisi["resim"].toString();
                }

                return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: BorderSide(
                            color: (widget.nick == satirVerisi["nick"])
                                ? Colors.green
                                : Colors.red,
                            width: 2.0)),
                    color: Color(0xFFAEB0BD),
                    elevation: 5,
                    margin: EdgeInsets.fromLTRB(5, 8, 5, 1),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: GestureDetector(
                        onTap: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 60,
                              width: 60,
                              child: Image.asset(satirVerisi["resim"]),
                            ),
                            Text(
                              satirVerisi["nick"],
                              textAlign: TextAlign.left,
                            ),
                            (index == 0)
                                ? Image.asset(
                                    "images/goldcup.png",
                                    height: 50,
                                  )
                                : (index == 1)
                                    ? Image.asset(
                                        "images/silvercup.png",
                                        height: 50,
                                      )
                                    : (index == 2)
                                        ? Image.asset(
                                            "images/bronzecup.png",
                                            height: 50,
                                          )
                                        : Image.asset(
                                            "images/medal.png",
                                            height: 50,
                                          ),
                            Text(
                              satirVerisi["elo"].toString(),
                              textAlign: TextAlign.right,
                            ),
                            (satirVerisi["nick"] == widget.nick)
                                ? SizedBox(
                                    width: 36,
                                  )
                                : FloatingActionButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  KullaniciGecmis(
                                                    aranacakuid: satirVerisi[
                                                        "currentId"],
                                                    mnick: widget.nick,
                                                    mresim: kendiresmi,
                                                  )));
                                    },
                                    mini: true,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        side: BorderSide(
                                            color: Colors.black, width: 1.4)),
                                    backgroundColor: Color(0xFFAEB0BD),
                                    child: Image.asset(
                                      "images/user.png",
                                      height: 20,
                                    ),
                                  )
                          ],
                        ),
                      ),
                    ));
              },
            ),
          );
        }
      },
    );
  }
}

// Online arkadaşlar listesi
class OnlineUser extends StatefulWidget {
  String nick, url;

  OnlineUser({this.nick, this.url});

  @override
  _OnlineUserState createState() => _OnlineUserState();
}

class _OnlineUserState extends State<OnlineUser> {
  int nextNumber({int min, int max}) => min + Random().nextInt(max - min + 1);

  List<int> nextNumbers(int length, {int min, int max}) {
    final numbers = Set<int>();
    while (numbers.length < length) {
      final number = nextNumber(min: min, max: max);
      numbers.add(number);
    }
    return List.of(numbers);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Listener")
            .doc(widget.nick)
            .collection("istek")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var veriler = snapshot.data.docs;
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  "Friends",
                  style: TextStyle(fontSize: 40, fontFamily: "yazi"),
                ),
                centerTitle: true,
                backgroundColor: Color(0xFF2B2B44),
              ),
              backgroundColor: Color(0xFF2F3041),
              body: Column(
                children: [
                  Text(
                    "Oyun istekleri...",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                    textAlign: TextAlign.left,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Flexible(
                      child: Scrollbar(
                        showTrackOnHover: true,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: veriler.length,
                          itemBuilder: (BuildContext context, int index) {
                            DocumentSnapshot veri = veriler[index];
                            if (veri["oyunIstek"] == "oyunistek") {
                              return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: BorderSide(
                                        color: Colors.black, width: 3.0),
                                  ),
                                  color: Color(0xFFAEB0BD),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 10, 10, 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          height: 50,
                                          child: Image.asset(veri["resim"]),
                                        ),
                                        Text(
                                          veri["nick"],
                                          textAlign: TextAlign.left,
                                        ),
                                        Row(
                                          children: [
                                            FloatingActionButton(
                                              onPressed: () {
                                                FirebaseFirestore.instance
                                                    .collection("Listener")
                                                    .doc(veri["friendsNick"])
                                                    .collection("istek")
                                                    .doc(veri["nick"])
                                                    .update({
                                                  "oyunIstek": "red",
                                                  veri["friendsNick"] +
                                                      "testDurum": "red",
                                                  veri["nick"] + "testDurum":
                                                      "red"
                                                });
                                              },
                                              mini: true,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  side: BorderSide(
                                                      color: Colors.black,
                                                      width: 1.2)),
                                              backgroundColor: Colors.red,
                                              child: Image.asset(
                                                "images/minus.png",
                                                height: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                            FloatingActionButton(
                                              onPressed: () {
                                                FirebaseFirestore.instance
                                                    .collection("Listener")
                                                    .doc(veri["friendsNick"])
                                                    .collection("istek")
                                                    .doc(veri["nick"])
                                                    .update({
                                                  "oyunIstek": "kabul",
                                                  veri["friendsNick"] +
                                                      "testDurum": "hazir"
                                                });
                                                final list = nextNumbers(10,
                                                    min: 0, max: 29);
                                                var evsahibi = veri["nick"];
                                                var kabuleden =
                                                    veri["friendsNick"];

                                                Future.delayed(
                                                  Duration(milliseconds: 2500),
                                                  () {
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            FriendsQueue(
                                                          user: "user2",
                                                          homekullaniciAdi:
                                                              widget.nick,
                                                          user1: evsahibi,
                                                          user2: kabuleden,
                                                          user1url:
                                                              veri["resim"],
                                                          user2url: veri[
                                                              "friendsResim"],
                                                          list: list,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              mini: true,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  side: BorderSide(
                                                      color: Colors.black,
                                                      width: 1.2)),
                                              backgroundColor: Colors.green,
                                              child: Image.asset(
                                                "images/plus.png",
                                                height: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ));
                            } else {
                              return SizedBox();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Text(
                    "Arkadaşlık istekleri...",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                    textAlign: TextAlign.left,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Flexible(
                      child: Scrollbar(
                        showTrackOnHover: true,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: veriler.length,
                          itemBuilder: (BuildContext context, int index) {
                            DocumentSnapshot veri = veriler[index];
                            if (veri["arkIstek"] == "gonderildi") {
                              return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: BorderSide(
                                        color: Colors.black, width: 3.0),
                                  ),
                                  color: Color(0xFFAEB0BD),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 10, 10, 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          height: 50,
                                          child: Image.asset(veri["resim"]),
                                        ),
                                        Text(
                                          veri["nick"],
                                          textAlign: TextAlign.left,
                                        ),
                                        Row(
                                          children: [
                                            FloatingActionButton(
                                              onPressed: () {
                                                FirebaseFirestore.instance
                                                    .collection("Listener")
                                                    .doc(widget.nick)
                                                    .collection("istek")
                                                    .doc(veri["nick"])
                                                    .update(
                                                        {"arkIstek": "red"});
                                              },
                                              mini: true,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  side: BorderSide(
                                                      color: Colors.black,
                                                      width: 1.2)),
                                              backgroundColor: Colors.red,
                                              child: Image.asset(
                                                "images/minus.png",
                                                height: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                            FloatingActionButton(
                                              onPressed: () {
                                                FirebaseFirestore.instance
                                                    .collection("Person")
                                                    .doc(FirebaseAuth.instance
                                                        .currentUser.uid)
                                                    .collection("friends")
                                                    .doc(veri["nick"])
                                                    .set({
                                                  "nick": veri["friendsNick"],
                                                  "friendsNick": veri["nick"],
                                                  "id": FirebaseAuth
                                                      .instance.currentUser.uid,
                                                  "friendsId": veri["id"],
                                                  "resim": veri["friendsResim"],
                                                  "friendsResim": veri["resim"]
                                                });

                                                FirebaseFirestore.instance
                                                    .collection("Person")
                                                    .doc(veri["id"])
                                                    .collection("friends")
                                                    .doc(veri["friendsNick"])
                                                    .set({
                                                  "nick": veri["nick"],
                                                  "friendsNick":
                                                      veri["friendsNick"],
                                                  "id": veri["id"],
                                                  "friendsId": FirebaseAuth
                                                      .instance.currentUser.uid,
                                                  "resim": veri["resim"],
                                                  "friendsResim":
                                                      veri["friendsResim"]
                                                });
                                                print(veri["nick"] +
                                                    veri["friendsNick"]);
                                                FirebaseFirestore.instance
                                                    .collection("Listener")
                                                    .doc(veri["friendsNick"])
                                                    .collection("istek")
                                                    .doc(veri["nick"])
                                                    .set({
                                                  "id": veri["id"],
                                                  "nick": veri["friendsNick"],
                                                  "resim": veri["friendsResim"],
                                                  "friendsId": FirebaseAuth
                                                      .instance.currentUser.uid,
                                                  "friendsNick": veri["nick"],
                                                  "friendsResim": veri["resim"],
                                                  "arkIstek": "kabul",
                                                  "oyunIstek": "yok"
                                                });
                                              },
                                              mini: true,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  side: BorderSide(
                                                      color: Colors.black,
                                                      width: 1.2)),
                                              backgroundColor: Colors.green,
                                              child: Image.asset(
                                                "images/plus.png",
                                                height: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ));
                            } else {
                              return SizedBox(
                                height: 0,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }
}

// İpucu ekranı
class hintScreen extends StatefulWidget {
  @override
  _hintScreenState createState() => _hintScreenState();
}

class _hintScreenState extends State<hintScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

class InfoScreen extends StatefulWidget {
  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  bool gameControl = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          child: Stack(
            overflow: Overflow.visible,
            alignment: Alignment.topCenter,
            children: [
              Container(
                height: 250,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 70, 10, 10),
                  child: Column(
                    children: [
                      Text("oyunIstek"),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'Challenge your',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Text("Oyun birazdan başlayacak."),
                      SizedBox(
                        height: 5,
                      ),
                      RaisedButton(
                        onPressed: () {},
                        color: Colors.redAccent,
                        child: Text(
                          gameControl == false ? 'Play' : "Cancel",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: -50,
                  child: Row(
                    children: [
                      // CircleAvatar(
                      //   backgroundColor: Colors.redAccent,
                      //   radius: 52,
                      //   child: Image.asset( ),
                      // ),
                      Image.asset(
                        "images/levels/VS.png",
                        height: 40,
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      // CircleAvatar(
                      //   backgroundColor: Colors.redAccent,
                      //   radius: 52,
                      //   child: Image.asset(
                      //     widget.friendUrl,
                      //     height: 70,
                      //   ),
                      // ),
                    ],
                  )),
            ],
          )),
    );
  }
}

// Profil ekranı
class profileScreen extends StatefulWidget {
  @override
  _profileScreenState createState() => _profileScreenState();
}

class _profileScreenState extends State<profileScreen> {
  final TextEditingController sifrec = TextEditingController();
  final TextEditingController nickc = TextEditingController();
  final TextEditingController adc = TextEditingController();
  AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Person")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
            color: Colors.deepOrange,
          ));
        } else {
          var urlTutucu = snapshot.data["resim"];
          var nick = snapshot.data["nick"];
          var userName = snapshot.data["userName"];
          return Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(color: Color(0xE4D0C5C5)),
              title: Text(
                "Settings",
                style: TextStyle(
                    fontSize: 40, fontFamily: "yazi", color: Color(0xE4D0C5C5)),
              ),
              centerTitle: true,
              backgroundColor: Color(0xE2013865),
              actions: [
                IconButton(
                  onPressed: () {
                    _authService.signOut();
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => GirisEkrani()));
                  },
                  icon: Icon(
                    Icons.exit_to_app,
                    color: Color(0xE4D0C5C5),
                    size: 25,
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xE2013865),
            body: SingleChildScrollView(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 25, 0, 30),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Avatar()));
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xff055884),
                            fixedSize: Size(95, 95),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(60),
                            ),
                          ),
                          child: Image.asset(
                            urlTutucu,
                            height: 95,
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Container(
                            height: size.height * .55,
                            width: size.width,
                            decoration: BoxDecoration(
                                color: Color(0xFF105A58).withOpacity(.75),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(28)),
                                boxShadow: [
                                  BoxShadow(
                                      color: Color(0xE4928686).withOpacity(.6),
                                      blurRadius: 50,
                                      spreadRadius: 2)
                                ]),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(15, 12, 15, 0),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      child: TextFormField(
                                        controller: adc,
                                        style: TextStyle(color: Colors.white),
                                        decoration: const InputDecoration(
                                          prefixIcon: Icon(
                                            Icons.person,
                                            color: Color(0xFFD1D9DC),
                                          ),
                                          hintText: "Yeni kullanıcı adı",
                                          prefixText: " ",
                                          hintStyle:
                                              TextStyle(color: Colors.grey),
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                            color: Colors.white,
                                          )),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      child: TextFormField(
                                        controller: nickc,
                                        style: TextStyle(color: Colors.white),
                                        decoration: const InputDecoration(
                                          prefixIcon: Icon(
                                            Icons.sports_esports,
                                            color: Color(0xFFD1D9DC),
                                          ),
                                          hintText: "Yeni nick",
                                          prefixText: " ",
                                          hintStyle:
                                              TextStyle(color: Colors.grey),
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                            color: Colors.white,
                                          )),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      child: TextFormField(
                                        obscureText: true,
                                        controller: sifrec,
                                        validator: (_passwordController) {
                                          return _passwordController.length >= 6
                                              ? null
                                              : "Şifre 6 karakterden az olamaz";
                                        },
                                        style: TextStyle(color: Colors.white),
                                        decoration: const InputDecoration(
                                          prefixIcon: Icon(
                                            Icons.vpn_key,
                                            color: Color(0xFFD1D9DC),
                                          ),
                                          hintText: "Yeni şifre",
                                          prefixText: " ",
                                          hintStyle:
                                              TextStyle(color: Colors.grey),
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                            color: Colors.white,
                                          )),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 40,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        {
                                          if (sifrec.text == "") {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Şifre kısmı boş bırakılamaz!");
                                            return;
                                          }
                                          _authService.guncelle(
                                            sifrec.text,
                                            (nickc.text == ""
                                                ? nickc.text = nick
                                                : nickc.text),
                                            (adc.text == ""
                                                ? adc.text = userName
                                                : adc.text),
                                          );
                                        }
                                        adc.clear();
                                        sifrec.clear();
                                        nickc.clear();
                                      },
                                      style: ElevatedButton.styleFrom(
                                          primary: Color(0xff055884),
                                          fixedSize: Size(250, 55),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25))),
                                      child: Text(
                                        'Güncelle',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                            color: Colors.white,
                                            fontFamily: 'Manrope',
                                            decoration: TextDecoration.none),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

class rankLaunchScreen extends StatefulWidget {
  String user, nick, odaID;
  List<int> list;

  rankLaunchScreen({this.user, this.nick, this.odaID, this.list});

  @override
  _rankLaunchScreenState createState() => _rankLaunchScreenState();
}

class _rankLaunchScreenState extends State<rankLaunchScreen> {
  var odaDurum;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Games")
            .doc(widget.odaID)
            .snapshots(),
        builder: (context, veri) {
          if (veri.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              color: Colors.deepOrange,
            ));
          } else {
            odaDurum = veri.data["odaVisiblity"].toString();
            var user1 = veri.data["user1"].toString();
            var user2 = veri.data["user2"].toString();
            var user1resim = veri.data["user1resim"].toString();
            var user2resim = veri.data["user2resim"].toString();

            if (odaDurum == "false") {
              Future.delayed(
                Duration(milliseconds: 2500),
                () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => rankedQueue(
                        user: widget.user,
                        homekullaniciAdi: widget.nick,
                        user1: user1,
                        user2: user2,
                        user1url: user1resim,
                        user2url: user2resim,
                        odaID: widget.odaID,
                        list: widget.list,
                      ),
                    ),
                  );
                },
              );
            }

            return Scaffold(
              backgroundColor: Color(0xE2013865),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Column(
                          children: [
                            Image.asset(
                              (user1resim == "bekle")
                                  ? "images/avatar1.png"
                                  : user1resim,
                              height: 150,
                              width: 150,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              user1,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Column(
                          children: [
                            (user2resim == "bekle")
                                ? Padding(
                                    padding: const EdgeInsets.all(20 + .0),
                                    child: Container(
                                      height: 100,
                                      width: 100,
                                      child: CircularProgressIndicator(
                                        color: Colors.deepOrange,
                                        strokeWidth: 4,
                                      ),
                                    ),
                                  )
                                : Image.asset(
                                    user2resim,
                                    height: 150,
                                    width: 150,
                                  ),
                            SizedBox(
                              height: 23,
                            ),
                            Text(
                              user2,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    (odaDurum == "true")
                        ? "Kullanıcı Bekleniyor"
                        : "Oyun birazdan başlayacak",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection("Games")
                          .doc(widget.odaID)
                          .delete()
                          .then((value) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Menu(),
                          ),
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.deepOrange,
                        fixedSize: Size(250, 55),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25))),
                    child: Text(
                      'İptal',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Colors.white,
                          fontFamily: 'Manrope',
                          decoration: TextDecoration.none),
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }
}

//Avatar seçim ekranı
class Avatar extends StatefulWidget {
  @override
  _AvatarState createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  var user = FirebaseAuth.instance.currentUser;
  var firebase = FirebaseFirestore.instance;

  AuthService authService = AuthService();

  Padding elevatedButton(String avatar) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 0),
      child: ElevatedButton(
        onPressed: () {
          authService.resimAl(avatar).then((value) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => profileScreen()));
          });
        },
        child: Image(
          image: AssetImage(avatar),
          height: 130,
        ),
        style: ElevatedButton.styleFrom(
          primary: Colors.transparent,
          fixedSize: Size(130, 130),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(65),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> avatarList = [
      "images/avatar1.png",
      "images/avatar2.png",
      "images/avatar3.png",
      "images/avatar4.png",
      "images/avatar5.png",
      "images/avatar6.png",
      "images/avatar7.png",
      "images/avatar8.png",
      "images/avatar9.png",
      "images/avatar10.png",
      "images/avatar11.png",
      "images/avatar12.png",
      "images/avatar13.png",
      "images/avatar14.png",
      "images/avatar15.png",
      "images/avatar16.png",
      "images/avatar17.png",
      "images/avatar18.png",
      "images/avatar19.png",
      "images/avatar20.png",
      "images/avatar21.png",
      "images/avatar22.png",
      "images/avatar23.png",
      "images/avatar24.png",
      "images/avatar25.png",
      "images/avatar26.png",
      "images/avatar27.png",
      "images/avatar28.png",
      "images/avatar29.png",
      "images/avatar30.png",
      "images/avatar31.png",
      "images/avatar33.png",
      "images/avatar34.png",
      "images/avatar35.png",
      "images/avatar36.png",
      "images/avatar37.png",
      "images/avatar38.png",
      "images/avatar39.png",
      "images/avatar40.png",
      "images/avatar41.png",
      "images/avatar42.png",
      "images/avatar43.png",
      "images/avatar44.png",
      "images/avatar45.png",
      "images/avatar46.png",
      "images/avatar47.png",
      "images/avatar48.png",
      "images/avatar49.png",
      "images/avatar50.png",
      "images/avatar51.png",
      "images/avatar52.png",
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF043933),
        centerTitle: true,
        title: Text(
          'Avatars',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.teal,
      body: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          shrinkWrap: true,
          itemCount: avatarList.length,
          itemBuilder: (context, avatarIndex) {
            return elevatedButton(avatarList[avatarIndex]);
          }),
    );
  }
}
