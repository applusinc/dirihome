import 'dart:async';
import 'dart:convert';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Door extends StatefulWidget {
  const Door({super.key});

  @override
  State<Door> createState() => _DoorState();
}

class _DoorState extends State<Door> {
  Card door_item(String title, String subtitle, int isOpened) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Icon(isOpened == 1 ? Icons.door_sliding : Icons.door_back_door),
      ),
    );
  }

  Future<void> _onRefresh() async {
    final res = await http.get(Uri.parse("https://kitapzone.xyz/dirihome/history"));
    data = json.decode(res.body);
    final res2 = await http.get(Uri.parse("https://kitapzone.xyz/dirihome/status"));
    final data2 = json.decode(res2.body);
    if (data2["result"] as int == 0) {
      doorOpen = false;
    } else {
      doorOpen = true;
    }

    lastOpened = data2["last"].toString();
    setState(() {
      
    });
  }

  List data = [
    
  ];
  bool doorOpen = true;
  String lastOpened = "0 dakika";

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _onAutoRefresh();
    // Belirli aralıklarla veriyi güncellemek için bir timer başlatılır.
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      _onAutoRefresh();
    });
  }

  @override
  void dispose() {
    // Timer'ı dispose etmeyi unutmayın.
    _timer?.cancel();
    super.dispose();
  }


   Future<void> _onAutoRefresh() async {
    try {
      final res = await http.get(Uri.parse("https://kitapzone.xyz/dirihome/history"));
      data = json.decode(res.body);
      final res2 = await http.get(Uri.parse("https://kitapzone.xyz/dirihome/status"));
      final data2 = json.decode(res2.body);
      if (data2["result"] as int == 0) {
        doorOpen = false;
      } else {
        doorOpen = true;
      }
      lastOpened = data2["last"].toString();
      setState(() {});
    } catch (error) {
      // Hata durumunu ele alabilirsiniz.
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diri Home"),
      ),
      body: CustomMaterialIndicator(
        indicatorBuilder: (context, controller) {
          return const Icon(
            Icons.ac_unit,
            color: Colors.blue,
            size: 30,
          );
        },
        onRefresh: _onRefresh,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                doorOpen ? Icons.door_sliding : Icons.door_back_door,
                size: 150,
              ),
              Text(
                doorOpen
                    ? "Kapı Açık \n$lastOpened'dir açık."
                    : "Kapı Kapalı \n$lastOpened'dir kapalı.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const Card(
                  child: ListTile(
                title: Text("Bugünki olaylar,"),
              )),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return door_item(
                        data[index]["title"].toString(),
                        data[index]["subtitle"].toString(),
                        data[index]["isopened"] as int);
                  },
                ),
              ),
            ]),
      ),
    );
  }
}
