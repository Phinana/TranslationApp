import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myfirsproje/service/auth.dart';

import 'Finish.dart';
import 'menu.dart';

class timeTrial extends StatefulWidget {
  String homekullaniciAdi, url;
  List<int> list;

  timeTrial({this.homekullaniciAdi, this.list, this.url});

  @override
  _timeTrialState createState() => _timeTrialState();
}

class _timeTrialState extends State<timeTrial> {
  List<Icon> _scoreTracker = [];
  int _questionIndex = 0;
  int _totalScore = 0;
  int selectedans = 0;
  String cevap1 = "";
  String cevap2 = "";
  List<int> cevaplar = [0]..length = 50;
  int userElo = 0;
  String cevap3 = "";
  int dogrucevap = 0;
  bool answerWasSelected = false;
  bool isitcorrect = false;
  bool correctAnswerSelected = false;

  AuthService _authService = AuthService();

  void _questionAnswered(bool isitcorrect) {
    setState(() {
      cevaplar[_questionIndex] = selectedans;
      print(cevaplar[_questionIndex]);
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
    });
  }

  void finish() {
    // Süreyi durdurup geçen süreyi tutar
    bitisSuresi = 100 - timer.tick;
    timer.cancel();
    _counter = bitisSuresi;

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm:ss \n EEE d MMM').format(now);

    //  Kulanıcının test sonuçlarını firebase'e kaydediyoruz
    final fireStore = FirebaseFirestore.instance;
    CollectionReference firebaseRef = fireStore
        .collection("Users")
        .doc("timeTrial")
        .collection(FirebaseAuth.instance.currentUser.uid);
    Map<String, dynamic> resultsData = {
      'kullanıcıAdi': widget.homekullaniciAdi,
      'totalScore': _totalScore,
      'tarih': formattedDate,
      'totalQuestion': _questionIndex + 1,
    };
    firebaseRef.doc(formattedDate).set(resultsData);

    // Sonuç ekranını açıyoruz
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FinishTime(
          finishKullaniciAdi: widget.homekullaniciAdi,
          totalScore: _totalScore,
          totalquestion: _questionIndex,
        ),
      ),
    );
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
        if (timer.tick == 100) {
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
        timer.cancel();
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
            return Scaffold(
              backgroundColor: Color(0xFF373855),
              body: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: RawMaterialButton(
                          onPressed: () {
                            showAlertDialog(context);
                          },
                          fillColor: Colors.white,
                          shape: CircleBorder(),
                          constraints:
                              BoxConstraints(minHeight: 35, minWidth: 35),
                          child: Image.asset(
                            "images/leftarrow.png",
                            height: 35,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(2, 20, 3, 20),
                            child: GestureDetector(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                                decoration: BoxDecoration(
                                  color: Colors.deepOrange,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.homekullaniciAdi,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontFamily: 'İtalic',
                                      decoration: TextDecoration.none,
                                      fontSize: 14,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Image.asset(
                              widget.url,
                              height: 50,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
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
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          child: Row(
                            children: [
                              if (_scoreTracker.length == 0)
                                SizedBox(
                                  height: 25.0,
                                ),
                              if (_scoreTracker.length > 0) ..._scoreTracker
                            ],
                          ),
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
                              alinanVeri[widget.list[_questionIndex]]["soru"]
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
                        SizedBox(height: 18.0),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 40.0),
                              primary: Colors.white,
                            ),
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
                              'Next Question',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            '${_totalScore.toString() + "/" + (_questionIndex + 1).toString()}',
                            style: TextStyle(
                                fontSize: 35.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        if (answerWasSelected)
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
            );
          }
        },
      ),
    );
  }
}
