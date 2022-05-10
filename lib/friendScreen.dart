import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myfirsproje/service/auth.dart';

import 'Finish.dart';

class friendScreen extends StatefulWidget {
  @override
  _friendScreenState createState() => _friendScreenState();
}

class _friendScreenState extends State<friendScreen> {
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Person")
            .doc(FirebaseAuth.instance.currentUser.uid)
            .collection("friends")
            .snapshots(),
        builder: (context, friendsVeri) {
          if (friendsVeri.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var friend = friendsVeri.data.docs;

            return Scaffold(
              appBar: AppBar(
                backgroundColor: Color(0xFF043933),
                centerTitle: true,
                title: Text(
                  'Friends',
                  style: TextStyle(
                      fontSize: 35,
                      fontFamily: "yazi",
                      fontWeight: FontWeight.normal,
                      color: Colors.white),
                ),
                iconTheme: IconThemeData(color: Colors.white),
              ),
              backgroundColor: Colors.teal,
              body: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  shrinkWrap: true,
                  itemCount: friend.length,
                  itemBuilder: (context, index) {
                    return elevatedButton(
                        friend[index]["friendsResim"],
                        friend[index]["friendsNick"],
                        friend[index]["nick"],
                        friend[index]["friendsId"],
                        friend[index]["resim"]);
                  }),
            );
          }
        });
  }

  Container elevatedButton(String friendUrl, String friendName, String mynick,
      String friendsUid, String myUrl) {
    return Container(
      margin: EdgeInsets.all(10),
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
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => friendAlertDialog(
                    friendName, friendUrl, mynick, friendsUid, myUrl)),
          );
        },
        style: ElevatedButton.styleFrom(
          primary: Color(0xFF1A8B8B),
          fixedSize: (Size(75, 75)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(52),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              friendUrl,
              height: 120,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              friendName,
              style: TextStyle(
                fontSize: 17,
              ),
            ),
            SizedBox(
              height: 6,
            ),
          ],
        ),
      ),
    );
  }
}

class friendAlertDialog extends StatefulWidget {
  String friendUrl, friendNick, mynick, myurl, friendUid;
  friendAlertDialog(
      [this.friendNick,
      this.friendUrl,
      this.mynick,
      this.friendUid,
      this.myurl]);
  @override
  State<friendAlertDialog> createState() => _friendAlertDialogState();
}

class _friendAlertDialogState extends State<friendAlertDialog> {
  bool gameControl = false;
  @override
  void gameCont() {
    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Listener")
            .doc(widget.friendNick)
            .collection("istek")
            .doc(widget.mynick)
            .snapshots(),
        builder: (context, listenFriend) {
          if (listenFriend.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Colors.lightBlue,
              body: Center(
                child: CircularProgressIndicator(
                  color: Colors.deepOrange,
                ),
              ),
            );
          } else {
            var friend = listenFriend.data;

            if (friend["oyunIstek"] == "kabul") {
              Future.delayed(
                Duration(milliseconds: 2500),
                () {
                  final list = nextNumbers(10, min: 0, max: 29);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FriendsQueue(
                        user: "user1",
                        homekullaniciAdi: widget.mynick,
                        user1: widget.mynick,
                        user2: widget.friendNick,
                        user1url: widget.myurl,
                        user2url: widget.friendUrl,
                        list: list,
                      ),
                    ),
                  );
                },
              );
            }
            return Scaffold(
              backgroundColor: Colors.lightBlueAccent,
              body: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0)),
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
                              Text(gameControl == true
                                  ? friend["oyunIstek"]
                                  : ""),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                'Challenge your ${widget.friendNick}',
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              Text(gameControl == true
                                  ? friend["oyunIstek"] != "kabul"
                                      ? "Waiting..."
                                      : "Oyun birazdan başlayacak."
                                  : ""),
                              SizedBox(
                                height: 5,
                              ),
                              friend["oyunIstek"] != "kabul"
                                  ? RaisedButton(
                                      onPressed: () {
                                        if (gameControl == false) {
                                          FirebaseFirestore.instance
                                              .collection("Listener")
                                              .doc(widget.friendNick)
                                              .collection("istek")
                                              .doc(widget.mynick)
                                              .set({
                                            widget.mynick + "testDurum":
                                                "hazir",
                                            widget.friendNick + "testDurum":
                                                "bekliyor",
                                            widget.mynick + "totalScore": 0,
                                            widget.friendNick + "totalScore": 0,
                                            widget.mynick + "time": 0,
                                            widget.friendNick + "time": 0,
                                            "arkIstek": "arkadas",
                                            "oyunIstek": "oyunistek",
                                            "nick": widget.mynick,
                                            "friendsNick": widget.friendNick,
                                            "id": FirebaseAuth
                                                .instance.currentUser.uid,
                                            "friendsId": widget.friendUid,
                                            "resim": widget.myurl,
                                            "friendsResim": widget.friendUrl
                                          });
                                          gameControl = true;
                                          gameCont();
                                        } else {
                                          FirebaseFirestore.instance
                                              .collection("Listener")
                                              .doc(widget.friendNick)
                                              .collection("istek")
                                              .doc(widget.mynick)
                                              .update({"oyunIstek": "yok"});
                                          gameControl = false;
                                          gameCont();
                                        }
                                      },
                                      color: Colors.redAccent,
                                      child: Text(
                                        gameControl == false
                                            ? 'Play'
                                            : "Cancel",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  : Container(
                                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                      child: CircularProgressIndicator(
                                        color: Colors.redAccent,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                          top: -50,
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.redAccent,
                                radius: 52,
                                child: Image.asset(
                                  widget.myurl,
                                  height: 70,
                                ),
                              ),
                              Image.asset(
                                "images/levels/VS.png",
                                height: 40,
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              CircleAvatar(
                                backgroundColor: Colors.redAccent,
                                radius: 52,
                                child: Image.asset(
                                  widget.friendUrl,
                                  height: 70,
                                ),
                              ),
                            ],
                          )),
                    ],
                  )),
            );
          }
        });
  }
}

class FriendsQueue extends StatefulWidget {
  String user, homekullaniciAdi, user1url, user2url, user1, user2;
  List<int> list;

  FriendsQueue(
      {this.user,
      this.homekullaniciAdi,
      this.list,
      this.user1,
      this.user2,
      this.user1url,
      this.user2url});
  @override
  _FriendsQueueState createState() => _FriendsQueueState();
}

class _FriendsQueueState extends State<FriendsQueue> {
  List<Icon> _scoreTracker = [];
  int _questionIndex = 0;
  int _totalScore = 0;
  int selectedans = 0;
  String cevap1 = "";
  String cevap2 = "";
  List<int> cevaplar = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  int userElo = 0;
  String cevap3 = "";
  int dogrucevap = 0;
  bool answerWasSelected = false;
  bool endOfQuiz = false;
  bool isitcorrect = false;
  bool correctAnswerSelected = false;

  void _questionAnswered(bool isitcorrect) {
    setState(() {
      cevaplar[_questionIndex] = selectedans;
      print(widget.user +
          widget.homekullaniciAdi +
          widget.user1url +
          widget.user2url +
          widget.user1 +
          widget.user2);
      // answer was selected
      answerWasSelected = true;
      // check if answer was correct
      if (isitcorrect) {
        _totalScore++;
        correctAnswerSelected = true;
      }
      //adding to the score tracker on top
      _scoreTracker.add(
        isitcorrect
            ? Icon(
                Icons.check_circle,
                color: Colors.green,
              )
            : Icon(
                Icons.clear,
                color: Colors.red,
              ),
      );
      //  when the quiz ends
      if (_questionIndex + 1 == 10) {
        endOfQuiz = true;
        finish();
      }
    });
  }

  void finish() {
    // Süreyi durdurup geçen süreyi tutar
    bitisSuresi = 100 - timer.tick;
    timer.cancel();
    _counter = bitisSuresi;

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm:ss \n EEE d MMM').format(now);

    //  Testin bittiğini firebase e bildiriyoruz ve sonucları kaydediyoruz
    print("burası verileri kaydediyor");
    print(widget.user2 + widget.user1);
    FirebaseFirestore.instance
        .collection("Listener")
        .doc(widget.user2)
        .collection("istek")
        .doc(widget.user1)
        .update({
      widget.homekullaniciAdi + "testDurum": "bitti",
      widget.homekullaniciAdi + "totalScore": _totalScore,
      widget.homekullaniciAdi + "time": timer.tick
    });

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => friendSonucHesaplama(
                  user: widget.user,
                  nick: widget.homekullaniciAdi,
                  tarih: formattedDate,
                  user1: widget.user1,
                  user2: widget.user2,
                )));
  }

  void _nextQuestion() {
    setState(() {
      selectedans = 0;
      _questionIndex++;
      answerWasSelected = false;
      correctAnswerSelected = false;
      isitcorrect = false;
    });
  }

  double value = 0;
  int _counter;
  int bitisSuresi;
  Timer timer;

  @override
  void initState() {
    // TODO: implement initState
    value = 0;
    zamanlayici();
    super.initState();
  }

  //Zamanlayıcı ayarı
  void zamanlayici() {
    _counter = 100;
    timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (timer.tick == 101) {
          timer.cancel();

          finish();
        } else {
          value = value + 0.01;
          _counter--;
        }
      });
    });
  }

  // showAlertDialog(BuildContext context) {
  //   // set up the buttons
  //   Widget cancelButton = TextButton(
  //     child: Text(
  //       "Quit",
  //       style: TextStyle(
  //           color: Colors.red, fontSize: 17, fontWeight: FontWeight.bold),
  //     ),
  //     onPressed: () {
  //       FirebaseFirestore.instance
  //           .collection("Games")
  //           .doc()
  //           .update({
  //         "silmeDurumu": true,
  //         widget.user.toString() + "testDurum": "bitti",
  //       });
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => Menu(),
  //         ),
  //       );
  //     },
  //   );
  //   Widget continueButton = TextButton(
  //     child: Text(
  //       "Continue",
  //       style: TextStyle(
  //           color: Colors.green, fontSize: 17, fontWeight: FontWeight.bold),
  //     ),
  //     onPressed: () => Navigator.pop(context, false),
  //   );
  //
  //   // set up the AlertDialog
  //   AlertDialog alert = AlertDialog(
  //     backgroundColor: Colors.white,
  //     content: Text(
  //       "Are you sure you want to quit?",
  //       style: TextStyle(
  //           color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
  //     ),
  //     actions: [
  //       cancelButton,
  //       continueButton,
  //     ],
  //   );
  //
  //   // show the dialog
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return alert;
  //     },
  //   );
  // }

  var kont = 0;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        //showAlertDialog(context);
      },
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Question")
            .orderBy("istatistik")
            .snapshots(),
        builder: (context, veriAl) {
          if (veriAl.connectionState == ConnectionState.waiting && kont == 0) {
            kont++;
            return Center(
                child: CircularProgressIndicator(
              color: Colors.deepOrange,
            ));
          } else {
            var alinanVeri = veriAl.data.docs;
            dogrucevap = alinanVeri[widget.list[_questionIndex]]["dogrucevap"];
            return Scaffold(
              backgroundColor: Color(0xFF373855),
              body: Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1.5, color: Colors.deepOrange),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              widget.user1url.toString(),
                              height: 50,
                            ),
                            Text(
                              widget.user1,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                        Image.asset(
                          "images/vs1.png",
                          height: 40,
                        ),
                        Row(
                          children: [
                            Text(
                              widget.user2,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            Image.asset(
                              widget.user2url.toString(),
                              height: 50,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 6, 0, 0),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(left: 8, bottom: 3),
                                  child: Icon(
                                    Icons.timer,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(right: 15),
                                  child: Text(
                                    '$_counter',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
                              //margin: EdgeInsets.all(20),
                              // padding: EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2,
                                  color: Colors.lightGreen,
                                  style: BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: LinearProgressIndicator(
                                backgroundColor: Color(0xA8632626),
                                color: Colors.green,
                                minHeight: 7,
                                value: value,
                              ),
                            ),
                            Row(
                              children: [
                                if (_scoreTracker.length == 0)
                                  SizedBox(
                                    height: 25.0,
                                  ),
                                if (_scoreTracker.length > 0) ..._scoreTracker
                              ],
                            ),
                            Container(
                              width: double.infinity,
                              height: 130.0,
                              margin: EdgeInsets.only(
                                  bottom: 10.0, left: 30.0, right: 30.0),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 50.0, vertical: 20.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Center(
                                child: Text(
                                  alinanVeri[widget.list[_questionIndex]]
                                          ["soru"]
                                      .toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (answerWasSelected) {
                                  return;
                                }
                                selectedans = 1;
                                if (answerWasSelected) {
                                  return;
                                }
                                if (dogrucevap == 1) {
                                  isitcorrect = true;
                                }
                                _questionAnswered(isitcorrect);
                              },
                              child: Container(
                                padding: EdgeInsets.all(15.0),
                                margin: EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 30.0),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: (answerWasSelected)
                                      ? (dogrucevap != 1)
                                          ? (selectedans == 1)
                                              ? Colors.red
                                              : Colors.white
                                          : Colors.green
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Text(
                                  alinanVeri[widget.list[_questionIndex]]["1"],
                                  style: TextStyle(
                                    fontSize: 15.0,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (answerWasSelected) {
                                  return;
                                }
                                selectedans = 2;
                                if (answerWasSelected) {
                                  return;
                                }
                                if (dogrucevap == 2) {
                                  isitcorrect = true;
                                }
                                _questionAnswered(isitcorrect);
                              },
                              child: Container(
                                padding: EdgeInsets.all(15.0),
                                margin: EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 30.0),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: (answerWasSelected)
                                      ? (dogrucevap != 2)
                                          ? (selectedans == 2)
                                              ? Colors.red
                                              : Colors.white
                                          : Colors.green
                                      : Colors.white,
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Text(
                                  alinanVeri[widget.list[_questionIndex]]["2"],
                                  style: TextStyle(
                                    fontSize: 15.0,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (answerWasSelected) {
                                  return;
                                }
                                selectedans = 3;
                                if (answerWasSelected) {
                                  return;
                                }
                                if (dogrucevap == 3) {
                                  isitcorrect = true;
                                }
                                _questionAnswered(isitcorrect);
                              },
                              child: Container(
                                padding: EdgeInsets.all(15.0),
                                margin: EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 30.0),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: (answerWasSelected)
                                      ? (dogrucevap != 3)
                                          ? (selectedans == 3)
                                              ? Colors.red
                                              : Colors.white
                                          : Colors.green
                                      : Colors.white,
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Text(
                                  alinanVeri[widget.list[_questionIndex]]["3"],
                                  style: TextStyle(
                                    fontSize: 15.0,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 15.0),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    minimumSize: Size(double.infinity, 45.0),
                                    primary: Colors.deepOrange,
                                    elevation: 20,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    )),
                                onPressed: () {
                                  if (!answerWasSelected) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                          'Please select an answer before going to the next question'),
                                    ));
                                    return;
                                  }
                                  _nextQuestion();
                                },
                                child: Text(
                                  endOfQuiz ? 'Restart Quiz' : 'Next Question',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(18.0),
                              child: Text(
                                '${(_questionIndex + 1).toString()}',
                                style: TextStyle(
                                    fontSize: 35.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            if (answerWasSelected && !endOfQuiz)
                              Container(
                                height: 30,
                                width: double.infinity,
                                color: correctAnswerSelected
                                    ? Colors.green
                                    : Colors.red,
                                child: Center(
                                  child: Text(
                                    correctAnswerSelected
                                        ? 'Well done, you got it right!'
                                        : 'Wrong :/',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class friendSonucHesaplama extends StatefulWidget {
  String user, nick, tarih, user1, user2;

  friendSonucHesaplama(
      {this.user, this.nick, this.tarih, this.user1, this.user2});

  @override
  _friendSonucHesaplamaState createState() => _friendSonucHesaplamaState();
}

class _friendSonucHesaplamaState extends State<friendSonucHesaplama> {
  String bitisDurumu1 = "devam";
  int kontrol = 0;
  String bitisDurumu2 = "devam";
  String u1Kazanma = "kaybetti";
  String u2Kazanma = "kaybetti";
  String user1resim, user2resim;
  int user1score, user2score, user1time, user2time;

  @override
  Widget build(BuildContext context) {
    print(widget.user2 + widget.user1);
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Listener")
          .doc(widget.user2)
          .collection("istek")
          .doc(widget.user1)
          .snapshots(),
      builder: (context, veri) {
        if (veri.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.teal,
            child: Center(
                child: CircularProgressIndicator(
              color: Colors.deepOrange,
            )),
          );
        } else {
          var alinan = veri.data;
          bitisDurumu1 = alinan["${widget.user1}testDurum"].toString();
          bitisDurumu2 = alinan["${widget.user2}testDurum"].toString();

          user1resim = alinan["resim"];
          user2resim = alinan["friendsResim"];

          // İki kullanıcının testtinin bitip bitmediği kontrol ediliyor.
          // Daha sonra kimin kazanıldığı total skor ve ssüreye göre belirleniyor
          if (bitisDurumu1 == "bitti") {
            user1score = alinan["${widget.user1}totalScore"];
            user1time = alinan["${widget.user1}time"];
          }
          if (bitisDurumu2 == "bitti") {
            user2score = alinan["${widget.user2}totalScore"];
            user2time = alinan["${widget.user2}time"];
          }

          if (bitisDurumu1 == "bitti" && bitisDurumu2 == "bitti") {
            if (alinan["${widget.user1}totalScore"] >
                alinan["${widget.user2}totalScore"]) {
              u1Kazanma = "kazandı";
            }
            if (alinan["${widget.user1}totalScore"] <
                alinan["${widget.user2}totalScore"]) {
              u2Kazanma = "kazandı";
            }
            if (alinan["${widget.user1}totalScore"] ==
                alinan["${widget.user2}totalScore"]) {
              if (alinan["${widget.user1}time"] >
                  alinan["${widget.user2}time"]) {
                u2Kazanma = "kazandı";
              }
              if (alinan["${widget.user1}time"] <
                  alinan["${widget.user2}time"]) {
                u1Kazanma = "kazandı";
              }
              if (alinan["${widget.user1}time"] ==
                  alinan["${widget.user2}time"]) {
                u1Kazanma = u2Kazanma = "berabere";
              }
            }
            if (kontrol == 0) {
              FirebaseFirestore.instance
                  .collection("Users")
                  .doc("friendsGame")
                  .collection(FirebaseAuth.instance.currentUser.uid)
                  .doc()
                  .set({
                "currentId": FirebaseAuth.instance.currentUser.uid,
                "oyunTürü": "FriendsGame",
                "nick": widget.nick,
                "rakip":
                    (widget.nick != widget.user1) ? widget.user1 : widget.user2,
                "kazanmmDurumu":
                    (widget.nick == widget.user1) ? u1Kazanma : u2Kazanma,
                "user1totalscore":
                    (widget.nick == widget.user1) ? user1score : user2score,
                "user1time":
                    (widget.nick == widget.user1) ? user1time : user2time,
                "user2totalscore":
                    (widget.nick != widget.user1) ? user1score : user2score,
                "user2time":
                    (widget.nick != widget.user1) ? user1time : user2time,
                "user1resim":
                    (widget.nick == widget.user1) ? user1resim : user2resim,
                "user2resim":
                    (widget.nick != widget.user1) ? user1resim : user2resim,
                "tarih": widget.tarih
              });
              kontrol = 1;
            }
          }

          return Scaffold(
            backgroundColor: Color(0xE2013865),
            body: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      bitisDurumu1 == "bitti" && bitisDurumu2 == "bitti"
                          ? u1Kazanma != "berabere"
                              ? u1Kazanma == "kazandı"
                                  ? "${widget.user1} kazandı"
                                  : "${widget.user2} kazandı"
                              : "berabere"
                          : "Diğer kullanici bekleniyor",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Container(
                            padding: EdgeInsets.fromLTRB(8, 25, 8, 25),
                            decoration: BoxDecoration(
                              color: (bitisDurumu1 == "bitti" &&
                                      bitisDurumu2 == "bitti")
                                  ? (u1Kazanma == "kazandı")
                                      ? Color(0x660CFF00)
                                      : Color(0xBAFF0000)
                                  : Colors.grey,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(30),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  user1resim.toString(),
                                  height: 140,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  widget.user1,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                (bitisDurumu1 == "bitti")
                                    ? Text(
                                        user1score.toString(),
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      )
                                    : CircularProgressIndicator(
                                        color: Colors.red, strokeWidth: 5),
                                SizedBox(
                                  height: 10,
                                ),
                                (bitisDurumu1 == "bitti")
                                    ? Text(
                                        user1time.toString(),
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      )
                                    : CircularProgressIndicator(
                                        color: Colors.red, strokeWidth: 5),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Container(
                            padding: EdgeInsets.fromLTRB(8, 25, 8, 25),
                            decoration: BoxDecoration(
                              color: (bitisDurumu2 == "bitti" &&
                                      bitisDurumu1 == "bitti")
                                  ? (u1Kazanma != "kazandı")
                                      ? Color(0x660CFF00)
                                      : Color(0xBAFF0000)
                                  : Colors.grey,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(40),
                                bottomLeft: Radius.circular(30),
                                topLeft: Radius.circular(10),
                              ),
                            ),
                            child: Column(
                              children: [
                                Image.asset(
                                  user2resim.toString(),
                                  height: 140,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  widget.user2,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                (bitisDurumu2 == "bitti")
                                    ? Text(
                                        user2score.toString(),
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      )
                                    : CircularProgressIndicator(
                                        color: Colors.red, strokeWidth: 5),
                                SizedBox(
                                  height: 10,
                                ),
                                (bitisDurumu2 == "bitti")
                                    ? Text(
                                        user2time.toString(),
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      )
                                    : CircularProgressIndicator(
                                        color: Colors.red, strokeWidth: 5),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        (bitisDurumu1 == "bitti" && bitisDurumu2 == "bitti")
                            ? ElevatedButton(
                                onPressed: () {
                                  if ((widget.nick == widget.user1)) {
                                    FirebaseFirestore.instance
                                        .collection("Listener")
                                        .doc(widget.user2)
                                        .collection("istek")
                                        .doc(widget.user1)
                                        .update({"oyunIstek": "yok"});
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FinishFriend(
                                          finishKullaniciAdi: widget.nick,
                                          totalScore: user1score,
                                          kazan: u1Kazanma,
                                        ),
                                      ),
                                    );
                                  } else {
                                    FirebaseFirestore.instance
                                        .collection("Listener")
                                        .doc(widget.user2)
                                        .collection("istek")
                                        .doc(widget.user1)
                                        .update({"oyunIstek": "yok"});
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FinishFriend(
                                          finishKullaniciAdi: widget.nick,
                                          totalScore: user2score,
                                          kazan: u2Kazanma,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  "Finished",
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xF52498AF),
                                  fixedSize: (Size(120, 50)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              )
                            : Text(""),
                      ],
                    )
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
