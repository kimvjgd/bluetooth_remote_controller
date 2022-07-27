// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'dart:math' as math;
//
// class LiveChartWidget extends StatefulWidget {
//   const LiveChartWidget({Key key}) : super(key: key);
//
//   @override
//   State<LiveChartWidget> createState() => _LiveChartWidgetState();
// }
//
// class _LiveChartWidgetState extends State<LiveChartWidget> {
//   List<LiveData> chartData;
//   ChartSeriesController _chartSeriesController;
//
//   @override
//   void initState() {
//     super.initState();
//     chartData = getChartData();
//     Timer.periodic(const Duration(milliseconds: 300), updateDataSource);
//   }
//
//   List<LiveData> getChartData() {
//     return <LiveData>[
//       LiveData(0, 41),
//       LiveData(1, 41),
//       LiveData(2, 41),
//       LiveData(3, 41),
//       LiveData(4, 41),
//       LiveData(5, 41),
//       LiveData(6, 41),
//       LiveData(7, 41),
//       LiveData(8, 41),
//       LiveData(9, 41),
//       LiveData(0, 41),
//       LiveData(1, 41),
//       LiveData(2, 41),
//       LiveData(3, 41),
//       LiveData(4, 41),
//       LiveData(5, 41),
//       LiveData(6, 41),
//       LiveData(7, 41),
//       LiveData(8, 41),
//       LiveData(9, 41),
//       LiveData(0, 41),
//       LiveData(1, 41),
//       LiveData(2, 41),
//       LiveData(3, 41),
//       LiveData(4, 41),
//       LiveData(5, 41),
//       LiveData(6, 41),
//       LiveData(7, 41),
//       LiveData(8, 41),
//       LiveData(9, 41),
//       LiveData(0, 41),
//       LiveData(1, 41),
//       LiveData(2, 41),
//       LiveData(3, 41),
//       LiveData(4, 41),
//       LiveData(5, 41),
//       LiveData(6, 41),
//       LiveData(7, 41),
//       LiveData(8, 41),
//       LiveData(9, 41),
//       LiveData(0, 41),
//       LiveData(1, 41),
//       LiveData(2, 41),
//       LiveData(3, 41),
//       LiveData(4, 41),
//       LiveData(5, 41),
//       LiveData(6, 41),
//       LiveData(7, 41),
//       LiveData(8, 41),
//       LiveData(9, 41),
//       LiveData(0, 41),
//       LiveData(1, 41),
//       LiveData(2, 41),
//       LiveData(3, 41),
//       LiveData(4, 41),
//       LiveData(5, 41),
//       LiveData(6, 41),
//       LiveData(7, 41),
//       LiveData(8, 41),
//       LiveData(9, 41),
//     ];
//   }
//
//   int time = 0;
//
//   updateDataSource(Timer timer) {
//     chartData.add(LiveData(time++, (math.Random().nextInt(60))));
//     // if(chartData.length>11){
//
//       chartData.removeAt(0);
//     // }
//     _chartSeriesController.updateDataSource(
//         addedDataIndex: chartData.length - 1, removedDataIndex: 0);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: Container(
//       height: 400,
//       child: SfCartesianChart(
//         legend: Legend(isVisible: true),
//         series: [
//           LineSeries<LiveData, int>(
//             onRendererCreated: (ChartSeriesController controller) {
//               _chartSeriesController = controller;
//             },
//             dataSource: chartData,
//             legendItemText: 'CO2',
//             xValueMapper: (LiveData data, _)=> data.time,
//             yValueMapper: (LiveData data, _)=> data.speed,
//           )
//         ],
//         primaryXAxis: NumericAxis(
//           majorGridLines: MajorGridLines(width: 1),
//           edgeLabelPlacement: EdgeLabelPlacement.none,
//           interval: 5,
//           title: AxisTitle(text: 'Time(seconds)'),
//         ),
//         primaryYAxis: NumericAxis(
//           majorGridLines: MajorGridLines(width: 1),
//           // edgeLabelPlacement: EdgeLabelPlacement,
//           interval: 6,
//           title: AxisTitle(text: 'density(?/M^2)'),
//         ),
//       ),
//     ));
//   }
// }
//
// class LiveData {
//   final int time;
//   final num speed;
//
//   LiveData(this.time, this.speed);
// }
