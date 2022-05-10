import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Ranks extends StatefulWidget {
  @override
  _RanksState createState() => _RanksState();
}

class _RanksState extends State<Ranks> {
  String siralamaAd;
  int siralamaPuan;

  void kayitGoster() async {
    final kayitAraci = await SharedPreferences.getInstance();

    String kIsim = kayitAraci.getString("name");
    int kScore = kayitAraci.getInt("score");

    setState(() {
      siralamaAd = kIsim;
      siralamaPuan = kScore;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text('Kullanıcı adı : $siralamaAd'),
          Text('Puan : $siralamaPuan'),
          ElevatedButton(
            child: Text("Getir"),
            onPressed: () => kayitGoster(),
          ),
        ],
      ),
    );
  }
}
