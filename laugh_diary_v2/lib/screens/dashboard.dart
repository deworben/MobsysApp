import 'dart:async';
import 'package:geocoder_offline/geocoder_offline.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:laugh_diary_v2/service/firebase_service.dart';
import 'package:logger/logger.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  List<double> yCoors = List.filled(24, 0);

  var fbService = FirebaseService();
  var logger = Logger();

  @override
  void initState() {
    super.initState();

    yCoors = fbService.getNumLaughsPerHourOverLastDay();
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    List<double> x = List.filled(24, 0);
    for (var i = 0; i < 24; i++) {
      x[i] = i.toDouble();
    }

    List<double> demoY = List.filled(24, 0);
    var rng = new Random();
    for (var i = 0; i < 24; i++) {
      demoY[i] = rng.nextInt(100).toDouble();
    }


    return Column(children: [
      AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Color(0xFF543884),
      ),
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              lineCard("Today", "How many times you laughed today.",
                  x, yCoors, 5, 9, 1, 2, 0),
              lineCard("Demo", "Demonstrating the visual for a user with lots of data.",
                  x, demoY, 5, 9, 1, 20, 1)
            ],
          ),
        ),
      )
    ]);
  }

  Widget lineCard(
      String title,
      String subtitle,
      List<double> xCoordinates,
      List<double> yCoordinates,
      double xMax,
      double yMax,
      double xGap,
      double yGap,
      int lineColorIndex) {
    List<Color> lineColors = List.from([
      const Color(0xCC77428D),
      const Color(0xCCD0104C),
      const Color(0xCC005CAF),
      const Color(0xCCF05E1C),
    ]);

    List<FlSpot> dataPoints = List.from([]);
    // if (yCoordinates.length != xCoordinates.length) {
    //   yCoordinates = List.filled(xCoordinates.length, 0);
    // }

    for (var i = 0; i < xCoordinates.length; i++) {
      dataPoints.add(FlSpot(xCoordinates[i], yCoordinates[i]));
    }

    xMax = max(xMax, xCoordinates.reduce(max));
    yMax = max(yMax, yCoordinates.reduce(max));

    var xLabelStyle = SideTitles(
        showTitles: true,
        interval: xGap,
        margin: 8,
        reservedSize: 16,
        getTitles: (v) {
          switch (v.toInt()) {
            case 1:
              return '12 am';
            case 6:
              return '6 am';
            case 12:
              return '12 pm';
            case 18:
              return '6 pm';
          }
          return '';
        });

    var yLabelStyle = SideTitles(
      showTitles: true,
      interval: yGap,
      margin: 8,
      reservedSize: 16,
    );

    var axisStyles = FlTitlesData(
      rightTitles: yLabelStyle,
      topTitles: SideTitles(showTitles: false),
      bottomTitles: xLabelStyle,
      leftTitles: SideTitles(showTitles: false),
    );

    var borderStyles = FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Color(0xAACCCCCC), width: 2),
          left: BorderSide(color: Color(0xAACCCCCC), width: 2),
          right: BorderSide(color: Color(0xAACCCCCC), width: 2),
          top: BorderSide(color: Color(0xAACCCCCC), width: 2),
        ));

    var gridStyles = FlGridData(
      show: false,
      drawVerticalLine: true,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: const Color(0xAAEEEEEE),
          strokeWidth: 1,
        );
      },
      getDrawingVerticalLine: (value) {
        return FlLine(
          color: const Color(0xAAEEEEEE),
          strokeWidth: 1,
        );
      },
    );

    var line = LineChartBarData(
      isCurved: true,
      preventCurveOverShooting: true,
      colors: [lineColors[lineColorIndex]],
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      spots: dataPoints,
      belowBarData: BarAreaData(show: true, colors: [
        ColorTween(begin: Colors.white, end: Colors.white)
            .lerp(0.2)!
            .withOpacity(0.2),
        ColorTween(
                begin: lineColors[lineColorIndex],
                end: lineColors[lineColorIndex])
            .lerp(0.2)!
            .withOpacity(0.2)
      ]),
    );

    var data = LineChartData(
      gridData: gridStyles,
      titlesData: axisStyles,
      borderData: borderStyles,
      lineBarsData: List.from([line]),
      minX: 0,
      maxX: xMax,
      maxY: yMax,
      minY: 0,
    );

    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            subtitle: Text(subtitle),
          ),
          Container(
              height: 300,
              padding: const EdgeInsets.all(20),
              child: LineChart(data,
                  swapAnimationDuration: const Duration(milliseconds: 250)))
        ],
      ),
    );
  }
}
