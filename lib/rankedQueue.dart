import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myfirsproje/Finish.dart';

import 'menu.dart';

class rankedQueue extends StatefulWidget {
  String user, homekullaniciAdi, odaID, user1url, user2url, user1, user2;
  List<int> list;

  rankedQueue(
      {this.user,
      this.homekullaniciAdi,
      this.odaID,
      this.list,
      this.user1,
      this.user2,
      this.user1url,
      this.user2url});

  @override
  _rankedQueueState createState() => _rankedQueueState();
}

class _rankedQueueState extends State<rankedQueue> {
  List<Icon> _scoreTracker = [];
  int _questionIndex = 0;
  int _totalScore = 0;
  int selectedans = 0;
  String cevap1 = "";
  String cevap2 = "";

  int userElo = 0;
  String cevap3 = "";
  int dogrucevap = 0;
  int soruno = 0, istatistik = 0;
  bool answerWasSelected = false;
  bool endOfQuiz = false;
  bool isitcorrect = false;
  bool correctAnswerSelected = false;

  void _questionAnswered(bool isitcorrect) {
    setState(() {
      // answer was selected
      answerWasSelected = true;
      // check if answer was correct
      if (isitcorrect) {
        _totalScore++;
        correctAnswerSelected = true;
      } else {
        print("burası çalıştı");
        FirebaseFirestore.instance
            .collection("Question")
            .doc("${soruno}")
            .update({"istatistik": istatistik++});
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
    // Testin bittiğini firebase e bildiriyoruz ve sonucları kaydediyoruz
    FirebaseFirestore.instance.collection("Games").doc(widget.odaID).update({
      widget.user + "testDurum": "bitti",
      widget.user + "totalScore": _totalScore,
      widget.user + "time": timer.tick
    });

    FirebaseFirestore.instance
        .collection("Person")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((DocumentSnapshot ds) {
      userElo = ds["elo"];
      if (userElo == -100) {
        userElo = 200;
      }
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => sonucHesaplama(
                    user: widget.user,
                    nick: widget.homekullaniciAdi,
                    elo: userElo,
                    odaID: widget.odaID,
                    tarih: formattedDate,
                  )));
    });
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

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(
        "Quit",
        style: TextStyle(
            color: Colors.red, fontSize: 17, fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        FirebaseFirestore.instance
            .collection("Games")
            .doc(widget.odaID)
            .update({
          "silmeDurumu": true,
          widget.user.toString() + "testDurum": "bitti",
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Menu(),
          ),
        );
      },
    );
    Widget continueButton = TextButton(
      child: Text(
        "Continue",
        style: TextStyle(
            color: Colors.green, fontSize: 17, fontWeight: FontWeight.bold),
      ),
      onPressed: () => Navigator.pop(context, false),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      content: Text(
        "Are you sure you want to quit?",
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

  var kont = 0;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        showAlertDialog(context);
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
            soruno = alinanVeri[widget.list[_questionIndex]]["soruno"];
            istatistik = alinanVeri[widget.list[_questionIndex]]["istatistik"];
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

class sonucHesaplama extends StatefulWidget {
  int elo = 0;
  String user, odaID = "", nick, tarih;

  sonucHesaplama({this.user, this.elo, this.odaID, this.nick, this.tarih});

  @override
  _sonucHesaplamaState createState() => _sonucHesaplamaState();
}

class _sonucHesaplamaState extends State<sonucHesaplama> {
  String bitisDurumu1 = "devam";
  int kontrol = 0;
  String bitisDurumu2 = "devam";
  String u1Kazanma = "kaybetti";
  String u2Kazanma = "kaybetti";
  String user1ad, user2ad, user1resim, user2resim;
  int user1score, user2score, user1time, user2time;

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
          var alinan = veri.data;
          bitisDurumu1 = alinan["user1testDurum"].toString();
          bitisDurumu2 = alinan["user2testDurum"].toString();

          user1ad = alinan["user1"];
          user1resim = alinan["user1resim"];
          user2ad = alinan["user2"];
          user2resim = alinan["user2resim"];

          // İki kullanıcının testtinin bitip bitmediği kontrol ediliyor.
          // Daha sonra kimin kazanıldığı total skor ve ssüreye göre belirleniyor
          if (bitisDurumu1 == "bitti") {
            user1score = alinan["user1totalScore"];
            user1time = alinan["user1time"];
          }
          if (bitisDurumu2 == "bitti") {
            user2score = alinan["user2totalScore"];
            user2time = alinan["user2time"];
          }

          if (bitisDurumu1 == "bitti" && bitisDurumu2 == "bitti") {
            if (alinan["user1totalScore"] > alinan["user2totalScore"]) {
              u1Kazanma = "kazandı";
            }
            if (alinan["user1totalScore"] < alinan["user2totalScore"]) {
              u2Kazanma = "kazandı";
            }
            if (alinan["user1totalScore"] == alinan["user2totalScore"]) {
              if (alinan["user1time"] > alinan["user2time"]) {
                u2Kazanma = "kazandı";
              }
              if (alinan["user1time"] < alinan["user2time"]) {
                u1Kazanma = "kazandı";
              }
              if (alinan["user1time"] == alinan["user2time"]) {
                u1Kazanma = u2Kazanma = "berabere";
              }
            }
            if (kontrol == 0) {
              FirebaseFirestore.instance
                  .collection("Users")
                  .doc("rankedGame")
                  .collection(FirebaseAuth.instance.currentUser.uid)
                  .doc()
                  .set({
                "currentId": FirebaseAuth.instance.currentUser.uid,
                "oyunTürü": "Ranked",
                "nick": widget.nick,
                "rakip": (widget.nick != user1ad) ? user1ad : user2ad,
                "elo": (widget.nick == user1ad && u1Kazanma == "kazandı")
                    ? widget.elo + 5
                    : widget.elo - 5,
                "kazanmmDurumu":
                    (widget.nick == user1ad) ? u1Kazanma : u2Kazanma,
                "user1totalscore":
                    (widget.nick == user1ad) ? user1score : user2score,
                "user1time": (widget.nick == user1ad) ? user1time : user2time,
                "user2totalscore":
                    (widget.nick != user1ad) ? user1score : user2score,
                "user2time": (widget.nick != user1ad) ? user1time : user2time,
                "user1resim":
                    (widget.nick == user1ad) ? user1resim : user2resim,
                "user2resim":
                    (widget.nick != user1ad) ? user1resim : user2resim,
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
                      bitisDurumu1 == "bitti" && bitisDurumu2 == "bitt"
                          ? u1Kazanma != "berabere"
                              ? u1Kazanma == "kazandı"
                                  ? "$user1ad kazandı"
                                  : "$user2ad kazandı"
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
                                  user1ad,
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
                                  user2ad,
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
                                  if ((widget.nick == user1ad)) {
                                    print(
                                        "sa sa sasasasaasasasssaassssssssssssssssssssssssssssssssss");
                                    if (alinan["silmeDurumu"] == false) {
                                      FirebaseFirestore.instance
                                          .collection("Games")
                                          .doc(widget.odaID)
                                          .update({"silmeDurumu": true});
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Finishh(
                                            finishKullaniciAdi: widget.nick,
                                            totalScore: user1score,
                                            kazan: u1Kazanma,
                                            elo: widget.elo,
                                          ),
                                        ),
                                      );
                                    } else {
                                      FirebaseFirestore.instance
                                          .collection("Games")
                                          .doc(widget.odaID)
                                          .delete();
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Finishh(
                                            finishKullaniciAdi: widget.nick,
                                            totalScore: user1score,
                                            kazan: u1Kazanma,
                                            elo: widget.elo,
                                          ),
                                        ),
                                      );
                                    }
                                  } else {
                                    if (alinan["silmeDurumu"] == false) {
                                      FirebaseFirestore.instance
                                          .collection("Games")
                                          .doc(widget.odaID)
                                          .update({"silmeDurumu": true});
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Finishh(
                                            finishKullaniciAdi: widget.nick,
                                            totalScore: user2score,
                                            kazan: u2Kazanma,
                                            elo: widget.elo,
                                          ),
                                        ),
                                      );
                                    } else {
                                      FirebaseFirestore.instance
                                          .collection("Games")
                                          .doc(widget.odaID)
                                          .delete();
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Finishh(
                                            finishKullaniciAdi: widget.nick,
                                            totalScore: user2score,
                                            kazan: u2Kazanma,
                                            elo: widget.elo,
                                          ),
                                        ),
                                      );
                                    }
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
