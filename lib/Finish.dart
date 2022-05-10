import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myfirsproje/menu.dart';

class FinishNormal extends StatefulWidget {
  String finishKullaniciAdi;
  int totalScore, kilitlevel;

  FinishNormal({this.finishKullaniciAdi, this.totalScore, this.kilitlevel});

  @override
  _FinishNormalState createState() => _FinishNormalState();
}

class _FinishNormalState extends State<FinishNormal> {
  int kontrol = 0;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Person")
              .doc(FirebaseAuth.instance.currentUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              var level = snapshot.data["level"];

              if (level <= widget.kilitlevel) {
                if (widget.totalScore > 7 && kontrol == 0) {
                  FirebaseFirestore.instance
                      .collection("Person")
                      .doc(FirebaseAuth.instance.currentUser.uid)
                      .update({"level": level + 1});
                  kontrol = 1;
                }
              }
              var resim = snapshot.data["resim"];

              return Scaffold(
                //backgroundColor: Color(0xFF006358),
                backgroundColor: Color(0xFF3C3E63),
                body: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          (widget.totalScore < 3)
                              ? "Bad"
                              : (widget.totalScore >= 3 &&
                                      widget.totalScore <= 5)
                                  ? "Not Bad"
                                  : (widget.totalScore >= 6 &&
                                          widget.totalScore <= 8)
                                      ? "Good"
                                      : (widget.totalScore > 8)
                                          ? "Legendary"
                                          : null,
                          style: TextStyle(
                            fontSize: 70,
                            fontFamily: "yazi",
                            color: Color(0xFFC7C768),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: size.height * .56,
                              width: size.width * .8,
                              decoration: BoxDecoration(
                                  color: Color(0xFF43456D).withOpacity(.85),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(28)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: (widget.totalScore <= 7)
                                            ? Color(0xE4FF0000).withOpacity(.5)
                                            : (widget.totalScore > 7)
                                                ? Color(0xE41FFF42)
                                                    .withOpacity(.6)
                                                : null,
                                        blurRadius: 50,
                                        spreadRadius: 2)
                                  ]),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        resim,
                                        height: 130,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Text(
                                    snapshot.data["nick"],
                                    style: TextStyle(
                                      color: Color(0xFFC7C768),
                                      fontSize: 24,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Text(
                                    "Score: " +
                                        widget.totalScore.toString() +
                                        "/10",
                                    style: TextStyle(
                                      fontSize: 28,
                                      color: Color(0xFFC7C768),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 60,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 27),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Menu(),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            "Quit",
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Color(0xFFC7C768),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 25),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChoiseLevel(
                                                  lKullanici:
                                                      snapshot.data["nick"],
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            (widget.totalScore < 8)
                                                ? "Play Again"
                                                : (widget.totalScore >= 8)
                                                    ? "Next Level"
                                                    : null,
                                            style: TextStyle(
                                              fontSize: 21,
                                              color: Color(0xFFC7C768),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 70,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }
}

//Ranked finish ekranı
class Finishh extends StatefulWidget {
  String finishKullaniciAdi;
  String kazan;
  int elo = 0;
  int totalScore;

  Finishh({this.elo, this.kazan, this.finishKullaniciAdi, this.totalScore});

  @override
  _FinishhState createState() => _FinishhState();
}

class _FinishhState extends State<Finishh> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    if (widget.kazan == "kazandı") {
      FirebaseFirestore.instance
          .collection("Person")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .update({"elo": widget.elo + 5});
      widget.elo = widget.elo + 5;
    }
    if (widget.kazan == "kaybetti") {
      FirebaseFirestore.instance
          .collection("Person")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .update({"elo": widget.elo - 5});
      widget.elo = widget.elo - 5;
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Person")
              .doc(FirebaseAuth.instance.currentUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              var resim = snapshot.data["resim"];

              return Scaffold(
                //backgroundColor: Color(0xFF006358),
                backgroundColor: Color(0xFF3C3E63),
                body: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          (widget.totalScore < 3)
                              ? "Bad"
                              : (widget.totalScore >= 3 &&
                                      widget.totalScore <= 5)
                                  ? "Not Bad"
                                  : (widget.totalScore >= 6 &&
                                          widget.totalScore <= 8)
                                      ? "Good"
                                      : (widget.totalScore > 8)
                                          ? "Legendary"
                                          : null,
                          style: TextStyle(
                            fontSize: 70,
                            fontFamily: "yazi",
                            color: Color(0xFFC7C768),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: size.height * .6,
                              width: size.width * .75,
                              decoration: BoxDecoration(
                                  color: Color(0xFF43456D).withOpacity(.85),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(28)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: (widget.kazan == "kaybetti")
                                            ? Color(0xE4FF0000).withOpacity(.5)
                                            : (widget.kazan == "kazandı")
                                                ? Color(0xE41FFF42)
                                                    .withOpacity(.6)
                                                : null,
                                        blurRadius: 50,
                                        spreadRadius: 2)
                                  ]),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        resim,
                                        height: 130,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Text(
                                    snapshot.data["nick"],
                                    style: TextStyle(
                                      color: Color(0xFFC7C768),
                                      fontSize: 22,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    (widget.kazan == "kaybetti")
                                        ? "-5"
                                        : (widget.kazan == "kazandı")
                                            ? "+5"
                                            : null,
                                    style: TextStyle(
                                      color: (widget.kazan == "kaybetti")
                                          ? Colors.red
                                          : (widget.kazan == "kazandı")
                                              ? Colors.green
                                              : null,
                                      fontSize: 60,
                                    ),
                                  ),
                                  Text(
                                    "Total Puan: " +
                                        snapshot.data["elo"].toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFFC7C768),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 40,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 23),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Menu(),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            "Quit",
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Color(0xFFC7D9D2),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 23),
                                        child: GestureDetector(
                                          onTap: () {
                                            var currentID = FirebaseAuth
                                                .instance.currentUser.uid;
                                            FirebaseFirestore.instance
                                                .collection("Games")
                                                .get()
                                                .then((data) {
                                              var readdata = data.docs;
                                              var odakurucuid;
                                              for (int i = 0;
                                                  i < readdata.length;
                                                  i++) {
                                                if (readdata[i]
                                                        ["odaVisiblity"] ==
                                                    true) {
                                                  odakurucuid =
                                                      readdata[i]["odaID"];
                                                  FirebaseFirestore.instance
                                                      .collection("Games")
                                                      .doc(odakurucuid)
                                                      .update({
                                                    "odaVisiblity": false,
                                                    "user2": widget
                                                        .finishKullaniciAdi,
                                                    "user2resim":
                                                        resim.toString(),
                                                    "user2totalScore": 0,
                                                    "user2time": 0,
                                                    "user2testDurum": "devam",
                                                  });
                                                  print(odakurucuid);
                                                  return Navigator
                                                      .pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  rankLaunchScreen(
                                                                    user:
                                                                        "user2",
                                                                    nick: widget
                                                                        .finishKullaniciAdi,
                                                                    odaID:
                                                                        odakurucuid,
                                                                  )));
                                                }
                                              }
                                              FirebaseFirestore.instance
                                                  .collection("Games")
                                                  .doc(currentID)
                                                  .set({
                                                "odaID": currentID,
                                                "odaVisiblity": true,
                                                "user1":
                                                    widget.finishKullaniciAdi,
                                                "user2": "Waiting",
                                                "user1resim": resim.toString(),
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
                                                            nick: widget
                                                                .finishKullaniciAdi,
                                                            odaID: currentID,
                                                          )));
                                            });
                                          },
                                          child: Text(
                                            "Play Again",
                                            style: TextStyle(
                                              fontSize: 21,
                                              color: Color(0xFFC7D9D2),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }
}

//Time trial finish ekranı

class FinishTime extends StatefulWidget {
  String finishKullaniciAdi;
  int totalScore, totalquestion;

  FinishTime({this.finishKullaniciAdi, this.totalScore, this.totalquestion});

  @override
  _FinishTimeState createState() => _FinishTimeState();
}

class _FinishTimeState extends State<FinishTime> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Person")
              .doc(FirebaseAuth.instance.currentUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              var resim = snapshot.data["resim"];

              return Scaffold(
                //backgroundColor: Color(0xFF006358),
                backgroundColor: Color(0xFF3C3E63),
                body: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          (widget.totalquestion / widget.totalScore <= 1.25)
                              ? "Legendary"
                              : (widget.totalquestion / widget.totalScore >
                                          1.25 &&
                                      widget.totalquestion / widget.totalScore <
                                          1.66)
                                  ? "Good"
                                  : (widget.totalquestion / widget.totalScore >=
                                              1.66 &&
                                          widget.totalquestion /
                                                  widget.totalScore <=
                                              3.3)
                                      ? "Not Bad"
                                      : (widget.totalquestion /
                                                  widget.totalScore >
                                              3.3)
                                          ? "Bad"
                                          : null,
                          style: TextStyle(
                            fontSize: 70,
                            fontFamily: "yazi",
                            color: Color(0xFFC7C768),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: size.height * .6,
                              width: size.width * .8,
                              decoration: BoxDecoration(
                                  color: Color(0xFF43456D).withOpacity(.85),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(28)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: (widget.totalquestion /
                                                    widget.totalScore >
                                                2.5)
                                            ? Color(0xE4FF0000).withOpacity(.5)
                                            : (widget.totalquestion /
                                                            widget.totalScore <=
                                                        2.5 &&
                                                    widget.totalquestion /
                                                            widget.totalScore >
                                                        1.3)
                                                ? Color(0xA8FFF200)
                                                    .withOpacity(.48)
                                                : (widget.totalquestion /
                                                            widget.totalScore <=
                                                        1.3)
                                                    ? Color(0xE41FFF42)
                                                        .withOpacity(.6)
                                                    : null,
                                        blurRadius: 50,
                                        spreadRadius: 2)
                                  ]),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        resim,
                                        height: 130,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Text(
                                    snapshot.data["nick"],
                                    style: TextStyle(
                                      color: Color(0xFFC7C768),
                                      fontSize: 24,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Icon(
                                    Icons.alarm,
                                    size: 40,
                                    color: Color(0xFFC7C768),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    "Score: " +
                                        widget.totalScore.toString() +
                                        "/" +
                                        (1 + widget.totalquestion).toString(),
                                    style: TextStyle(
                                      fontSize: 28,
                                      color: Color(0xFFC7C768),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 50,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 27),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Menu(),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            "Quit",
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Color(0xFFC7C768),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 25),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChoiseLevel(
                                                  lKullanici:
                                                      snapshot.data["nick"],
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            "Play Again",
                                            style: TextStyle(
                                              fontSize: 21,
                                              color: Color(0xFFC7C768),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 70,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }
}

class FinishFriend extends StatefulWidget {
  String finishKullaniciAdi, kazan;
  int totalScore;

  FinishFriend({this.finishKullaniciAdi, this.totalScore, this.kazan});

  @override
  _FinishFriendState createState() => _FinishFriendState();
}

class _FinishFriendState extends State<FinishFriend> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Person")
              .doc(FirebaseAuth.instance.currentUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              var resim = snapshot.data["resim"];

              return Scaffold(
                //backgroundColor: Color(0xFF006358),
                backgroundColor: Color(0xFF3C3E63),
                body: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          (widget.totalScore < 3)
                              ? "Bad"
                              : (widget.totalScore >= 3 &&
                                      widget.totalScore <= 5)
                                  ? "Not Bad"
                                  : (widget.totalScore >= 6 &&
                                          widget.totalScore <= 8)
                                      ? "Good"
                                      : (widget.totalScore > 8)
                                          ? "Legendary"
                                          : null,
                          style: TextStyle(
                            fontSize: 70,
                            fontFamily: "yazi",
                            color: Color(0xFFC7C768),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: size.height * .6,
                              width: size.width * .8,
                              decoration: BoxDecoration(
                                  color: Color(0xFF43456D).withOpacity(.85),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(28)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: (widget.kazan == "kaybetti")
                                            ? Color(0xE4FF0000).withOpacity(.5)
                                            : (widget.kazan == "kazandı")
                                                ? Color(0xE41FFF42)
                                                    .withOpacity(.6)
                                                : null,
                                        blurRadius: 50,
                                        spreadRadius: 2)
                                  ]),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        resim,
                                        height: 130,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Text(
                                    snapshot.data["nick"],
                                    style: TextStyle(
                                      color: Color(0xFFC7C768),
                                      fontSize: 24,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Color(0xFFC7C768),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    "Score: " +
                                        widget.totalScore.toString() +
                                        " / 10",
                                    style: TextStyle(
                                      fontSize: 28,
                                      color: Color(0xFFC7C768),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 50,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 27),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Menu(),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            "Quit",
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Color(0xFFC7C768),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 25),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChoiseLevel(
                                                  lKullanici:
                                                      snapshot.data["nick"],
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            "Play Again",
                                            style: TextStyle(
                                              fontSize: 21,
                                              color: Color(0xFFC7C768),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 70,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }
}
