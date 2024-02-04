import 'dart:convert';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:dirihome/door.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  int isAlarm = 1;
  int sound = 255;
  int ms = 1000;
  Future<void> _onRefresh() async {
    final res = await http.get(Uri.parse("https://kitapzone.xyz/dirihome/settings"));
    final data = json.decode(res.body);
    isAlarm = data["alarm"] as int;
    sound = data["sound"] as int;
    ms = data["ms"] as int;
    setState(() {});
  }

  Future<void> setSettings() async {
    final res = await http.post(
  Uri.parse("https://kitapzone.xyz/dirihome/settings"),
  headers: {"Content-Type": "application/json"},
  body: jsonEncode({"alarm": isAlarm.toString(), "sound": sound.toString(), "ms": ms.toString()})
);

    await _onRefresh();
  }
@override
  void initState() {
    _onRefresh();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diri Home"),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 10),
        child: CustomMaterialIndicator(
          indicatorBuilder: (context, controller) {
            return const Icon(
              Icons.ac_unit,
              color: Colors.blue,
              size: 30,
            );
          },
          onRefresh: _onRefresh,
          child: ListView(children: [
            CardItem(
              "Kapı",
              "Evin dış kapısını yönetin.",
              Icons.door_back_door,
              () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Door(),
                    ));
              },
            ),
            CardItem(
                isAlarm == 1 ? "Alarm Etkin" : "Alarm Devre Dışı",
                isAlarm == 1
                    ? "Devre dışı bırakmak için tıklayın"
                    : "Etkinleştirmek için tıklayın",
                Icons.alarm, () async {
              if (isAlarm == 1) {
                isAlarm = 0;
              } else {
                isAlarm = 1;
              }
              await setSettings();
            }),
            CardItem("Alarmın sesi $sound", "Değiştirmek için tıklayın",
                Icons.volume_up_outlined, () async {
              String? voice = await _showTextInputDialog(
                  context, "Alarm sesi 0 ile 255 arası");
              String voiceN = voice ?? "0";
              sound = int.tryParse(voiceN) ?? 0;
              await setSettings();
            }),
            CardItem("Alarmın süresi $ms milisaniye",
                "Değiştirmek için tıklayın", Icons.timer_sharp, () async {
              String? time = await _showTextInputDialog(
                  context, "Alarmın süresi (1000ms = 1 sn)");
              String timeN = time ?? "0";
              ms = int.tryParse(timeN) ?? 0;
              await setSettings();
            })
          ]),
        ),
      ),
    );
  }

  

  // ignore: non_constant_identifier_names
  GestureDetector CardItem(
      String text, String subtitle, IconData data, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8,
        margin: const EdgeInsets.all(5),
        child: ListTile(
          title: Text(
            text,
            style: const TextStyle(color: Colors.black), // Renk ayarlaması
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(color: Colors.black), // Renk ayarlaması
          ),
          leading: Icon(
            data,
            color: Colors.black, // Renk ayarlaması
          ),
        ),
      ),
    );
  }
}


Future<String?> _showTextInputDialog(BuildContext context, String title) async {
  final _textFieldController = TextEditingController();
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Düzenle"),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: title),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("İptal"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Tamam'),
              onPressed: () =>
                  Navigator.pop(context, _textFieldController.text),
            ),
          ],
        );
      });
}
