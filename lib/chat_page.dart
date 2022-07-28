import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dongpakka_bluetooth/live_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

import 'package:syncfusion_flutter_charts/charts.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({this.server});

  @override
  _ChatPage createState() => _ChatPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}



class _ChatPage extends State<ChatPage> {
  static const clientID = 0;
  BluetoothConnection connection;

  List<_Message> messages = [];
  String _messageBuffer = '';

  final TextEditingController textEditingController =
      TextEditingController();
  final ScrollController listScrollController = ScrollController();

  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;
  bool newDatacome = false;

  @override
  void initState() {
    super.initState();

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
    // Avoid memory leak (`setState` after dispose) and disconnect
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
    final List<Row> list = messages.map((_message) {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
                (text) {
                  return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                }(_message.text.trim()),
                style: const TextStyle(color: Colors.white)),
            padding: const EdgeInsets.all(12.0),
            margin: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
                color:
                    _message.whom == clientID ? Colors.greenAccent : Colors.grey,
                borderRadius: BorderRadius.circular(7.0)),
          ),
        ],
        mainAxisAlignment: _message.whom == clientID
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
                width:Get.width, height:Get.height/3,child: LiveChartWidget()),


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
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

}


class LiveChartWidget extends StatefulWidget {
  const LiveChartWidget({Key key}) : super(key: key);

  @override
  State<LiveChartWidget> createState() => _LiveChartWidgetState();
}

class _LiveChartWidgetState extends State<LiveChartWidget> {
  List<LiveData> chartData;
  ChartSeriesController _chartSeriesController;

  @override
  void initState() {
    super.initState();
    chartData = getChartData();
    Timer.periodic(const Duration(milliseconds: 300), updateDataSource);

  }

  List<LiveData> getChartData() {
    return <LiveData>[
      LiveData(0, 41),
      LiveData(1, 41),
      LiveData(2, 41),
      LiveData(3, 41),
      LiveData(4, 41),
      LiveData(5, 41),
      LiveData(6, 41),
      LiveData(7, 41),
      LiveData(8, 41),
      LiveData(9, 41),
      LiveData(0, 41),
      LiveData(1, 41),
      LiveData(2, 41),
      LiveData(3, 41),
      LiveData(4, 41),
      LiveData(5, 41),
      LiveData(6, 41),
      LiveData(7, 41),
      LiveData(8, 41),
      LiveData(9, 41),
      LiveData(0, 41),
      LiveData(1, 41),
      LiveData(2, 41),
      LiveData(3, 41),
      LiveData(4, 41),
      LiveData(5, 41),
      LiveData(6, 41),
      LiveData(7, 41),
      LiveData(8, 41),
      LiveData(9, 41),
      LiveData(0, 41),
      LiveData(1, 41),
      LiveData(2, 41),
      LiveData(3, 41),
      LiveData(4, 41),
      LiveData(5, 41),
      LiveData(6, 41),
      LiveData(7, 41),
      LiveData(8, 41),
      LiveData(9, 41),
      LiveData(0, 41),
      LiveData(1, 41),
      LiveData(2, 41),
      LiveData(3, 41),
      LiveData(4, 41),
      LiveData(5, 41),
      LiveData(6, 41),
      LiveData(7, 41),
      LiveData(8, 41),
      LiveData(9, 41),
      LiveData(0, 41),
      LiveData(1, 41),
      LiveData(2, 41),
      LiveData(3, 41),
      LiveData(4, 41),
      LiveData(5, 41),
      LiveData(6, 41),
      LiveData(7, 41),
      LiveData(8, 41),
      LiveData(9, 41),
    ];
  }

  int time = 0;

  updateDataSource(Timer timer) {
    chartData.add(LiveData(time++, (math.Random().nextInt(60))));
    // if(chartData.length>11){

    chartData.removeAt(0);
    // }
    _chartSeriesController.updateDataSource(
        addedDataIndex: chartData.length - 1, removedDataIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(
      height: 400,
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
    ));
  }
}

class LiveData {
  final int time;
  final num speed;

  LiveData(this.time, this.speed);
}


