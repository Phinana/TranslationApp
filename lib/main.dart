import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myfirsproje/menu.dart';
import 'package:myfirsproje/service/auth.dart';
import 'package:video_player/video_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(VideoApp());
}

class VideoApp extends StatefulWidget {
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  VideoPlayerController _controller;

  @override
  void initState() {
    Future.delayed(
      Duration(milliseconds: 5000),
      () {
        return runApp(MyApp());
      },
    );
    super.initState();
    _controller = VideoPlayerController.asset('video/launchscreen.mp4')
      ..initialize().then((_) {
        _controller.setLooping(false);
        _controller.setVolume(1.0);
        _controller.play();
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Video Demo',
      home: Scaffold(
        backgroundColor: Color(0xFF272837),
        body: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : Container(),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, veri) {
          if (veri.hasData) {
            return Menu();
          } else {
            return GirisEkrani();
          }
        },
      ),
    );
  }
}

class KayitEkrani extends StatefulWidget {
  @override
  _KayitEkraniState createState() => _KayitEkraniState();
}

class _KayitEkraniState extends State<KayitEkrani> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nickController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  AuthService _authService = AuthService();

  var firestore = FirebaseFirestore.instance;
  var user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xE2014E8D),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                  child: Image.network(
                    "https://pbs.twimg.com/media/CktwjRtWkAAm3Dc.png",
                    width: 150.0,
                    height: 150.0,
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Container(
                      height: size.height * .62,
                      width: size.width * .85,
                      decoration: BoxDecoration(
                          color: Color(0xFF105A58).withOpacity(.75),
                          borderRadius: BorderRadius.all(Radius.circular(28)),
                          boxShadow: [
                            BoxShadow(
                                color: Color(0xE4928686).withOpacity(.8),
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
                                  controller: _nameController,
                                  style: TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: Color(0xFF91A8B4),
                                    ),
                                    hintText: "Ad soyad giriniz",
                                    prefixText: " ",
                                    hintStyle: TextStyle(color: Colors.grey),
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
                                  controller: _nickController,
                                  style: TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.sports_esports,
                                      color: Color(0xFF91A8B4),
                                    ),
                                    hintText: "Nick giriniz",
                                    prefixText: " ",
                                    hintStyle: TextStyle(color: Colors.grey),
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
                                  keyboardType: TextInputType.emailAddress,
                                  controller: _emailController,
                                  validator: (_emailController) {
                                    return _emailController.contains("@")
                                        ? null
                                        : "Geçersiz E-mail";
                                  },
                                  style: TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.mail,
                                      color: Color(0xFF91A8B4),
                                    ),
                                    hintText: "E-mail giriniz",
                                    prefixText: " ",
                                    hintStyle: TextStyle(color: Colors.grey),
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
                                  controller: _passwordController,
                                  validator: (_passwordController) {
                                    return _passwordController.length >= 6
                                        ? null
                                        : "Şifre 6 karakterden az olamaz";
                                  },
                                  style: TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.vpn_key,
                                      color: Color(0xFF91A8B4),
                                    ),
                                    hintText: "Şifre giriniz",
                                    prefixText: " ",
                                    hintStyle: TextStyle(color: Colors.grey),
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
                                height: 22,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _authService
                                      .createPerson(
                                          _nameController.text,
                                          _nickController.text,
                                          _emailController.text,
                                          _passwordController.text)
                                      .then((value) {
                                    return Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                GirisEkrani()));
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                    primary: Color(0xff055884),
                                    fixedSize: Size(250, 55),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25))),
                                child: Text(
                                  'Kayıt Ol',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                      color: Colors.white,
                                      fontFamily: 'Manrope',
                                      decoration: TextDecoration.none),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(0, 18, 0, 0),
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    //Giriş sayfasına git
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                GirisEkrani()));
                                  },
                                  child: Text(
                                    "Hesabım Var",
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.white,
                                    ),
                                  ),
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
}

class GirisEkrani extends StatefulWidget {
  @override
  _GirisEkraniState createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xE2014E8D),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 30),
                  child: Image.network(
                    "https://pbs.twimg.com/media/CktwjRtWkAAm3Dc.png",
                    width: 150.0,
                    height: 150.0,
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Container(
                      height: size.height * .48,
                      width: size.width * .85,
                      decoration: BoxDecoration(
                          color: Color(0xFF105A58).withOpacity(.75),
                          borderRadius: BorderRadius.all(Radius.circular(28)),
                          boxShadow: [
                            BoxShadow(
                                color: Color(0xE4928686).withOpacity(.8),
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
                                  keyboardType: TextInputType.emailAddress,
                                  controller: _emailController,
                                  validator: (_emailController) {
                                    return _emailController.contains("@")
                                        ? null
                                        : "Geçersiz E-mail";
                                  },
                                  style: TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.mail,
                                      color: Color(0xFF91A8B4),
                                    ),
                                    hintText: "E-mail giriniz",
                                    prefixText: " ",
                                    hintStyle: TextStyle(color: Colors.grey),
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
                                  controller: _passwordController,
                                  validator: (_passwordController) {
                                    return _passwordController.length >= 6
                                        ? null
                                        : "Şifre 6 karakterden az olamaz";
                                  },
                                  style: TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.vpn_key,
                                      color: Color(0xFF91A8B4),
                                    ),
                                    hintText: "Şifre giriniz",
                                    prefixText: " ",
                                    hintStyle: TextStyle(color: Colors.grey),
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
                                height: 25,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _authService
                                      .signIn(_emailController.text,
                                          _passwordController.text)
                                      .then((value) {
                                    return Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Menu(),
                                      ),
                                    );
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                    primary: Color(0xff055884),
                                    fixedSize: Size(250, 55),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25))),
                                child: Text(
                                  'Giriş Yap',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                      color: Colors.white,
                                      fontFamily: 'Manrope',
                                      decoration: TextDecoration.none),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(0, 18, 0, 0),
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    //Giriş sayfasına git
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                KayitEkrani()));
                                  },
                                  child: Text(
                                    "Kayıt Ol",
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.white,
                                    ),
                                  ),
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
}
