import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChrome, DeviceOrientation;
import 'package:intl/intl.dart' show DateFormat;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        textTheme: const TextTheme(
          bodyText2: TextStyle(color: Colors.black38, fontSize: 30)
        ),
        fontFamily: 'Alatsi',
      ),
      home: const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(10),
          child: Clock(key: Key('clock'))
        ), // Our entire app will be coded here
      ),
    );
  }
}

// Utility class to access values as binary integers
class BinaryTime {
  List<String> binaryIntegers = []; // This represents the ones or zeros needed to display the binary time

  BinaryTime() {
    DateTime now = DateTime.now();
    String hhmmss = DateFormat("Hms").format(now).replaceAll(':', '');

    binaryIntegers = hhmmss
      .split('')
      .map((str) => int.parse(str).toRadixString(2).padLeft(4, '0'))
      .toList();
  }

  // To make our UI more readable, set a getter for each of the positions in the clock
  get hoursTens => binaryIntegers[0];
  get hoursOnes => binaryIntegers[1];
  get minutesTens => binaryIntegers[2];
  get minutesOnes => binaryIntegers[3];
  get secondsTens => binaryIntegers[4];
  get secondsOnes => binaryIntegers[5];
}

class Clock extends StatefulWidget {
  const Clock({ required Key key }): super(key: key);

  @override
  _ClockState createState() => _ClockState();
}

// ignore: must_be_immutable
class ClockColumn extends StatelessWidget {
  String binaryInteger;
  String title;
  Color color;
  int rows;
  List bits = [];

  ClockColumn({super.key,  required this.binaryInteger, required this.title, required this.color, this.rows = 4 }) {
    bits = binaryInteger.split('');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ...[
          Container(
            child: Text(
              title,
              style: Theme.of(context).textTheme.displayMedium,
            ),
          )
        ],
        ...bits.asMap().entries.map((entry) {
          int idx = entry.key;
          String bit = entry.value;

          bool isActive = bit == '1';
          num binaryCellValue = pow(2, 3 - idx);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 475),
            curve: Curves.ease,
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              color: isActive ? color : idx < 4 - rows ? Colors.white.withOpacity(0) : Colors.black38,
            ),
            margin: const EdgeInsets.all(4),
            child: Center(
              child: isActive ? Text(
                binaryCellValue.toString(),
                style: TextStyle(
                  color: Colors.black.withOpacity(0.2),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                )
              ) : Container(),
            )
          );
        }),
        ...[
          Text(
            int.parse(binaryInteger, radix: 2).toString(),
            style: TextStyle(fontSize: 30, color: color),
          ),
          Container(
            child: Text(
              binaryInteger,
              style: TextStyle(fontSize: 15, color: color)
            )
          )
        ]
      ],
    );
  }
}

class _ClockState extends State<Clock> {
  BinaryTime _now = BinaryTime();

  @override
  void initState() {
    // We set a periodic tick every second to update the _now variable with the current time
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _now = BinaryTime();
      });
    });
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Columns for the clock
          ClockColumn(
            binaryInteger: _now.hoursTens,
            title: '',
            color: Colors.indigo,
            rows: 2,
          ),
          ClockColumn(
            binaryInteger: _now.hoursOnes,
            title: '',
            color: Colors.indigoAccent,
          ),
          ClockColumn(
            binaryInteger: _now.minutesTens,
            title: '',
            color: Colors.amber,
            rows: 3,
          ),
          ClockColumn(
            binaryInteger: _now.minutesOnes,
            title: '',
            color: Colors.amberAccent,
          ),
          ClockColumn(
            binaryInteger: _now.secondsTens,
            title: '',
            color: Colors.green,
            rows: 3,
          ),
          ClockColumn(
            binaryInteger: _now.secondsOnes,
            title: '',
            color: Colors.greenAccent,
          ),
        ],
      )
    );
  }
}