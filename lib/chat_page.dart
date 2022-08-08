import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dongpakka_bluetooth/live_chart.dart';
import 'package:dongpakka_bluetooth/local_notification_service.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

import 'package:syncfusion_flutter_charts/charts.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({this.server});

  @override
  _ChatPage createState() => _ChatPage();
}

class _ChatPage extends State<ChatPage> {
  LocalNotificationService service;

  static const clientID = 0;
  BluetoothConnection connection;

  bool alarm = true;
  int testValue = 10000;

  int neckAlarm = 260;

  List<LiveData> chartData = [];
  ChartSeriesController _chartSeriesController;

  // List<_Message> messages = [];
  String _messageBuffer = '';

  List<LiveData> getTestChartData() {
    return <LiveData>[
      LiveData(0, 400),
      LiveData(1, 400),
      LiveData(2, 400),
      LiveData(3, 400),
      LiveData(4, 400),
      LiveData(5, 400),
      LiveData(6, 400),
      LiveData(7, 400),
      LiveData(8, 400),
      LiveData(9, 400),
      LiveData(10, 400),
      LiveData(11, 400),
      LiveData(12, 400),
      LiveData(13, 400),
      LiveData(14, 400),
      LiveData(15, 400),
      LiveData(16, 400),
      LiveData(17, 400),
      LiveData(18, 400),
      LiveData(19, 400),
      LiveData(20, 400),
      LiveData(21, 400),
      LiveData(22, 400),
      LiveData(23, 400),
      LiveData(24, 400),
      LiveData(25, 400),
      LiveData(26, 400),
      LiveData(27, 400),
      LiveData(28, 400),
      LiveData(29, 400),
      LiveData(30, 400),
      LiveData(31, 400),
      LiveData(32, 400),
      LiveData(33, 400),
      LiveData(34, 400),
      LiveData(35, 400),
      LiveData(36, 400),
      LiveData(37, 400),
      LiveData(38, 400),
      LiveData(39, 400),
      LiveData(40, 400),
      LiveData(41, 400),
      LiveData(42, 400),
      LiveData(43, 400),
      LiveData(44, 400),
      LiveData(45, 400),
      LiveData(46, 400),
      LiveData(47, 400),
      LiveData(48, 400),
      LiveData(49, 400),
      LiveData(50, 400),
      LiveData(51, 400),
      LiveData(52, 400),
      LiveData(53, 400),
      LiveData(54, 400),
      LiveData(55, 400),
      LiveData(56, 400),
      LiveData(57, 400),
      LiveData(58, 400),
      LiveData(59, 400),
    ];
  }

  int time = 60;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  bool isConnecting = true;

  bool get isConnected => connection != null && connection.isConnected;
  bool isDisconnecting = false;
  bool newDatacome = false;
  int timerCount = 60;

  updateDataSource(Timer timer) {
    chartData.add(LiveData(time++, (math.Random().nextInt(60))));
    // if(chartData.length>11){

    chartData.removeAt(0);
    // }
    _chartSeriesController.updateDataSource(
        addedDataIndex: chartData.length - 1, removedDataIndex: 0);
  }

  countTime(Timer timer) {
    timerCount++;
  }

  @override
  void initState() {
    super.initState();

    service = LocalNotificationService();
    service.initialize();
    listenToNotification();


    chartData = getTestChartData();
    // Timer.periodic(const Duration(milliseconds: 800), updateDataSource);
    Timer.periodic(const Duration(seconds: 1), countTime);
    // listScrollController.addListener(() {
    //   setState(() {
    //     print('offset');
    //     print(listScrollController.offset);
    //     print('position');
    //     print(listScrollController.position);
    //   });
    // });

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }
    super.dispose();
  }

  final double _value = 90.0;

  @override
  Widget build(BuildContext context) {
    print("timer ${timerCount.toString()}");
    final List<Row> list = chartData
        .map((_liveData) {
          return Row(
            children: <Widget>[
              Text(_liveData.time.toString() + " sec ->"),
              Container(
                child: Text(
                    (text) {
                      return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                    }(_liveData.speed.toString().trim()),
                    style: const TextStyle(color: Colors.white)),
                padding: const EdgeInsets.all(12.0),
                margin:
                    const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                width: 222.0,
                decoration: BoxDecoration(
                    color: _liveData.time == clientID
                        ? Colors.greenAccent
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(7.0)),
              ),
            ],
            mainAxisAlignment: _liveData.time == clientID
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
          );
        })
        .toList()
        .reversed
        .toList();
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 2,
              child: Stack(
            children: [
              Center(child: ExtendedImage.asset('assets/images/body.png')),
              testValue < neckAlarm?
                          Positioned(
                              // neck
                              width: 360,
                              height: 280,
                              child: Opacity(
                                opacity: 0.7,
                                child: Center(
                                    child: Container(
                                  color: Colors.red,
                                  width: 25,
                                  height: 20,
                                )),
                              ))
                      :Container(width: 0, height: 0,),
              // Positioned(
              //     //waist
              //     width: 360,
              //     height: 450,
              //     child: Opacity(
              //       opacity: 0.7,
              //       child: Center(
              //           child: Container(
              //         color: Colors.red,
              //         width: 50,
              //         height: 30,
              //       )),
              //     )),
              // Positioned(
              //     // head <= 생각해보니 이게 그냥 목이네요...
              //     // neck
              //     width: 360,
              //     height: 200,
              //     child: Opacity(
              //       opacity: 0.7,
              //       child: Center(
              //           child: Container(
              //         color: Colors.red,
              //         width: 25,
              //         height: 20,
              //       )),
              //     )),
            ],

          )),
          Expanded(
            flex: 1,
            child: ListView(
                padding: const EdgeInsets.all(12.0),
                controller: listScrollController,
                children: list),
          )        ],
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(
    //       title: (isConnecting
    //           ? Text('Connecting chat to ' + widget.server.name + '...')
    //           : isConnected
    //           ? Text('Live chart with ' + widget.server.name)
    //           : Text('Chat log with ' + widget.server.name))),
    //   body: SafeArea(
    //     child: Column(
    //       // mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Container(
    //           height: 200,
    //           child: SfCartesianChart(
    //             legend: Legend(isVisible: true),
    //             series: [
    //               LineSeries<LiveData, int>(
    //                 onRendererCreated: (ChartSeriesController controller) {
    //                   _chartSeriesController = controller;
    //                 },
    //                 dataSource: chartData,
    //                 legendItemText: 'CO2',
    //                 xValueMapper: (LiveData data, _)=> data.time,
    //                 yValueMapper: (LiveData data, _)=> data.speed,
    //               )
    //             ],
    //             primaryXAxis: NumericAxis(
    //               majorGridLines: MajorGridLines(width: 1),
    //               edgeLabelPlacement: EdgeLabelPlacement.none,
    //               interval: 5,
    //               title: AxisTitle(text: 'Time(seconds)'),
    //             ),
    //             primaryYAxis: NumericAxis(
    //               majorGridLines: MajorGridLines(width: 1),
    //               // edgeLabelPlacement: EdgeLabelPlacement,
    //               interval: 6,
    //               title: AxisTitle(text: 'density(?/M^2)'),
    //             ),
    //           ),
    //         ),
    //         Expanded(
    //           child: ListView(
    //               padding: const EdgeInsets.all(12.0),
    //               controller: listScrollController,
    //               children: list),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    for (var byte in data) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    }
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    testValue = int.parse(dataString);
    // here to add element to chartData

    // if(testValue < neckAlarm) {
      // service.showNotification(id: 0, title: 'Notification Title', body: 'Some body');

    // }

    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        chartData.add(
          LiveData(
            timerCount,
            backspacesCounter > 0
                ? int.parse(_messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter))
                : int.parse(_messageBuffer + dataString.substring(0, index)),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? int.parse(_messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter))
          : (_messageBuffer + dataString));
    }
    print(testValue);
  }
  void listenToNotification() => service.onNotificationClick.stream.listen(onNotificationListener);
  void onNotificationListener(String payload) {
    if(payload != null && payload.isNotEmpty) {
      print('payload $payload');

      // Navigator.push(context, MaterialPageRoute(builder: (context)=>SecondScreen(payload: payload)));
    }
  }
}

class LiveData {
  final int time;
  final num speed;

  LiveData(this.time, this.speed);
}

// class _Message {
//   int whom;
//   String text;
//   _Message(this.whom, this.text);
// }
