import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dongpakka_bluetooth/live_chart.dart';
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
  static const clientID = 0;
  BluetoothConnection connection;

  List<LiveData> chartData = [];
  ChartSeriesController _chartSeriesController;

  // List<_Message> messages = [];
  String _messageBuffer = '';
  List<LiveData> getTestChartData() {
    return <LiveData>[
      LiveData(0, 1),
      LiveData(1, 1),
      LiveData(2, 1),
      LiveData(3, 1),
      LiveData(4, 1),
      LiveData(5, 1),
      LiveData(6, 1),
      LiveData(7, 1),
      LiveData(8, 1),
      LiveData(9, 1),
      LiveData(10, 1),
      LiveData(11, 1),
      LiveData(12, 1),
      LiveData(13, 1),
      LiveData(14, 1),
      LiveData(15, 1),
      LiveData(16, 1),
      LiveData(17, 1),
      LiveData(18, 1),
      LiveData(19, 1),
      LiveData(20, 1),
      LiveData(21, 1),
      LiveData(22, 1),
      LiveData(23, 1),
      LiveData(24, 1),
      LiveData(25, 1),
      LiveData(26, 1),
      LiveData(27, 1),
      LiveData(28, 1),
      LiveData(29, 1),
      LiveData(30, 1),
      LiveData(31, 1),
      LiveData(32, 1),
      LiveData(33, 1),
      LiveData(34, 1),
      LiveData(35, 1),
      LiveData(36, 1),
      LiveData(37, 1),
      LiveData(38, 1),
      LiveData(39, 1),
      LiveData(40, 1),
      LiveData(41, 1),
      LiveData(42, 1),
      LiveData(43, 1),
      LiveData(44, 1),
      LiveData(45, 1),
      LiveData(46, 1),
      LiveData(47, 1),
      LiveData(48, 1),
      LiveData(49, 1),
      LiveData(50, 1),
      LiveData(51, 1),
      LiveData(52, 1),
      LiveData(53, 1),
      LiveData(54, 1),
      LiveData(55, 1),
      LiveData(56, 1),
      LiveData(57, 1),
      LiveData(58, 1),
      LiveData(59, 1),
    ];
  }

  int time = 60;

  final TextEditingController textEditingController =
  TextEditingController();
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
    final List<Row> list = chartData.map((_liveData) {
      return Row(
        children: <Widget>[
          Text(_liveData.time.toString()+" sec ->"),
          Container(
            child: Text(
                    (text) {
                  return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                }(_liveData.speed.toString().trim()),
                style: const TextStyle(color: Colors.white)),
            padding: const EdgeInsets.all(12.0),
            margin: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
                color:
                _liveData.time == clientID ? Colors.greenAccent : Colors.grey,
                borderRadius: BorderRadius.circular(7.0)),
          ),
        ],
        mainAxisAlignment: _liveData.time == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
      );
    }).toList().reversed.toList();

    return Scaffold(
      appBar: AppBar(
          title: (isConnecting
              ? Text('Connecting chat to ' + widget.server.name + '...')
              : isConnected
              ? Text('Live chart with ' + widget.server.name)
              : Text('Chat log with ' + widget.server.name))),
      body: SafeArea(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 200,
              child: SfCartesianChart(
                legend: Legend(isVisible: true),
                series: [
                  LineSeries<LiveData, int>(
                    onRendererCreated: (ChartSeriesController controller) {
                      _chartSeriesController = controller;
                    },
                    dataSource: chartData,
                    legendItemText: 'CO2',
                    xValueMapper: (LiveData data, _)=> data.time,
                    yValueMapper: (LiveData data, _)=> data.speed,
                  )
                ],
                primaryXAxis: NumericAxis(
                  majorGridLines: MajorGridLines(width: 1),
                  edgeLabelPlacement: EdgeLabelPlacement.none,
                  interval: 5,
                  title: AxisTitle(text: 'Time(seconds)'),
                ),
                primaryYAxis: NumericAxis(
                  majorGridLines: MajorGridLines(width: 1),
                  // edgeLabelPlacement: EdgeLabelPlacement,
                  interval: 6,
                  title: AxisTitle(text: 'density(?/M^2)'),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                  padding: const EdgeInsets.all(12.0),
                  controller: listScrollController,
                  children: list),
            ),
            // Row(
            //   children: <Widget>[
            //     Flexible(
            //       child: Container(
            //         margin: const EdgeInsets.only(left: 16.0),
            //         child: TextField(
            //           style: const TextStyle(fontSize: 15.0),
            //           controller: textEditingController,
            //           decoration: InputDecoration.collapsed(
            //             hintText: isConnecting
            //                 ? 'Wait until connected...'
            //                 : isConnected
            //                     ? 'Type your message...'
            //                     : 'Chat got disconnected',
            //             hintStyle: const TextStyle(color: Colors.grey),
            //           ),
            //           enabled: isConnected,
            //         ),
            //       ),
            //     ),
            //     Container(
            //       margin: const EdgeInsets.all(8.0),
            //       child: IconButton(
            //           icon: const Icon(Icons.send),
            //           onPressed: isConnected
            //               ? () => _sendMessage(textEditingController.text)
            //               : null),
            //     ),
            //   ],
            // )
          ],
        ),
      ),
    );
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

    // here to add element to chartData

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