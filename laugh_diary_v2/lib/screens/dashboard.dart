import 'dart:async';
import 'package:geocoder_offline/geocoder_offline.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // String? cities;
  // GeocodeData? coder;

  @override
  void initState() {
    super.initState();
    // loadCoder();

    // TODO: Load all data here and call setstate.
  }
  //
  // void loadCoder() async {
  //   cities = await rootBundle.loadString('assets/cities15000.txt');
  //   coder = GeocodeData(
  //       cities!, //input string
  //       'name',
  //       'country code',
  //       'latitude',
  //       'longitude',
  //       fieldDelimiter: '\t',
  //       eol: '\n');
  // }

  @override
  Widget build(BuildContext context) {
    /// TODO: I need EXACTLY 24 x coordinates and 24 y coordinates.
    List<double> dummyX = List.from([]);
    for (var i = 0; i < 24; i++) {
      dummyX.add(i.toDouble());
    }
    List<double> dummyY = List.from([]);
    for (var i = 0; i < 24; i++) {
      dummyY.add(i.toDouble());
    }

    return Column(children: [
      AppBar(
        title: const Text("Dashboard"),
      ),
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              lineCard("Today", "The number of laughter per hour today.",
                  dummyX, dummyY, 5, 9, 1, 2, 0),
              lineCard("Laugh Count", "The number of laughter per hour today.",
                  dummyX, dummyY, 5, 9, 1, 2, 1),
              lineCard("Laugh Count", "The number of laughter per hour today.",
                  dummyX, dummyY, 5, 9, 1, 2, 2),
              lineCard("Laugh Count", "The number of laughter per hour today.",
                  dummyX, dummyY, 5, 9, 1, 2, 3)
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
            title: Text(title),
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
