import 'package:flutter/material.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  // UPDATE LENGTH TO BE NUMBER OF PANELS
  List<bool> _isOpen = List.generate(4, (_) => false);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: const Text("Gallery"),
        ),
        SingleChildScrollView(
          child: ExpansionPanelList(
            animationDuration: Duration(milliseconds: 500),
            dividerColor: Colors.black,
            elevation: 0,
            expandedHeaderPadding: EdgeInsets.all(8),
            children: [
              totalLaughter(),
              topWords(),
              longestLaugh(),
              shortestLaugh(),
            ],
            expansionCallback: (i, isOpen) =>
                setState(() {
                  _isOpen[i] = !isOpen;
                }),
          ),
        )
      ],
    );
  }


  ExpansionPanel totalLaughter() {
    return ExpansionPanel(
      // SET INDEX TO BE IN ORDER
      isExpanded: _isOpen[0],
      canTapOnHeader: true,
      backgroundColor: Colors.white,
      headerBuilder: (context, isOpen) {
        return Container(
          child: Text("Total laughter duration",
            style: TextStyle(fontSize: 20),
          ),
          padding: EdgeInsets.all(8),
        );
      },
        body: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            child: Text("90",
              style: TextStyle(fontSize: 15),
            ),
            padding: EdgeInsets.all(8),
          ),
        )
    );
  }

  ExpansionPanel topWords() {
    return ExpansionPanel(
      // SET INDEX TO BE IN ORDER
      isExpanded: _isOpen[1],
      canTapOnHeader: true,
      backgroundColor: Colors.white,
      headerBuilder: (context, isOpen) {
        return Container(
          child: Text("Funniest words",
            style: TextStyle(fontSize: 20),
          ),
          padding: EdgeInsets.all(8),
        );
      },
        body: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            child: Text("poo bum",
              style: TextStyle(fontSize: 15),
            ),
            padding: EdgeInsets.all(8),
          ),
        )
    );
  }
  ExpansionPanel longestLaugh() {
    return ExpansionPanel(
      // SET INDEX TO BE IN ORDER
      isExpanded: _isOpen[2],
      canTapOnHeader: true,
      backgroundColor: Colors.white,
      headerBuilder: (context, isOpen) {
        return Container(
          child: Text("Longest Laugh",
            style: TextStyle(fontSize: 20),
          ),
          padding: EdgeInsets.all(8),
        );
      },
        body: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            child: Text("30",
              style: TextStyle(fontSize: 15),
            ),
            padding: EdgeInsets.all(8),
          ),
        )
    );
  }

  ExpansionPanel shortestLaugh() {
    return ExpansionPanel(
      // SET INDEX TO BE IN ORDER
      isExpanded: _isOpen[3],
      canTapOnHeader: true,
      backgroundColor: Colors.white,
      headerBuilder: (context, isOpen) {
        return Container(
            child: Text("Shortest Chuckle",
              style: TextStyle(fontSize: 20),
            ),
            padding: EdgeInsets.all(8),
        );
      },
      body: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          child: Text("1",
            style: TextStyle(fontSize: 15),
          ),
          padding: EdgeInsets.all(8),
        ),
      )
    );
  }

}