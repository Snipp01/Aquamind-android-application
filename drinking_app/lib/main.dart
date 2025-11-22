import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Full import for SystemNavigator and rootBundle
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Water Drinking App',
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Future<void> _initCSV() async {
    for (int i = 1; i <= 12; i++) {
      try {
        final rawData = await rootBundle.loadString("assets/csv/$i.csv");
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$i.csv';
        final File f = File(filePath);

        if (!await f.exists()) {
          await f.create(recursive: true);
          await f.writeAsString(rawData);
        }
      } catch (e) {
        print('Error initializing CSV for month $i: $e');
        try {
          final directory = await getApplicationDocumentsDirectory();
          final filePath = '${directory.path}/$i.csv';
          final File f = File(filePath);
          if (!await f.exists()) {
            await f.create(recursive: true);
            await f.writeAsString('day,glasses\n1,0\n2,0\n3,0\n4,0\n5,0\n6,0\n7,0\n8,0\n9,0\n10,0\n11,0\n12,0\n13,0\n14,0\n15,0\n16,0\n17,0\n18,0\n19,0\n20,0\n21,0\n22,0\n23,0\n24,0\n25,0\n26,0\n27,0\n28,0\n29,0\n30,0\n31,0');
          }
        } catch (fallbackError) {
          print('Fallback CSV creation failed for month $i: $fallbackError');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome!'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Hi! If this is your first time opening the app,\nplease tap on the green button below, otherwise tap red:",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () async {
                  await _initCSV();
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyHome()),
                    );
                  }
                },
                child: Container(
                  color: Colors.lightGreenAccent,
                  width: 350,
                  height: 210,
                  child: const Center(
                    child: Text(
                      "First Time",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyHome()),
                  );
                },
                child: Container(
                  color: Colors.red,
                  width: 350,
                  height: 210,
                  child: const Center(
                    child: Text(
                      "Not First Time",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  Column _buildButtonColumn(BuildContext context, IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(icon),
          color: Colors.blue,
          iconSize: 64,
          onPressed: () {
            if (label == "Drink Water") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OpenDrink()),
              );
            } else if (label == "Water Intake") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OpenNeedDrink()),
              );
            } else if (label == "Summary") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OpenSumm()),
              );
            } else {
              // Exit
              SystemNavigator.pop();
            }
          },
        ),
        Container(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Row _buildRow(BuildContext context, String classi) {
    IconData icon1;
    IconData icon2;
    String label1;
    String label2;

    if (classi == "Row1") {
      icon1 = Icons.add;
      icon2 = Icons.accessibility_new_rounded;
      label1 = "Drink Water";
      label2 = "Water Intake";
    } else {
      icon1 = Icons.access_time;
      icon2 = Icons.backspace_sharp;
      label1 = "Summary";
      label2 = "Exit";
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButtonColumn(context, icon1, label1),
        _buildButtonColumn(context, icon2, label2),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget titleSection = Container(
      color: Colors.blue,
      padding: const EdgeInsets.all(20),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Water Drinking App',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final Widget borderSection = Container(
      color: Colors.blue,
      padding: const EdgeInsets.all(20),
      child: const Text(
        "Please choose from the options below:",
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    final Widget spaceSection = const SizedBox(height: 20);  // Replaces non-const space

    return Scaffold(
      appBar: AppBar(
        title: const Text('WDA'),
      ),
      body: ListView(
        children: [
          titleSection,
          const Image(
            image: AssetImage('assets/images/glass.png'),
            width: 487,
            height: 200,
            fit: BoxFit.scaleDown,
          ),
          borderSection,
          _buildRow(context, "Row1"),
          spaceSection,
          _buildRow(context, "Row2"),
        ],
      ),
    );
  }
}

class OpenDrink extends StatefulWidget {
  const OpenDrink({Key? key}) : super(key: key);

  @override
  State<OpenDrink> createState() => _OpenDrinkState();
}

class _OpenDrinkState extends State<OpenDrink> {
  @override
  void initState() {
    super.initState();
    _updateDrinkCount();
  }

  Future<void> _updateDrinkCount() async {
    var date = DateTime.now();
    var month = '${date.month}';
    var day = '${date.day}';

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$month.csv';
    final file = File(filePath);

    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString('day,glasses\n1,0\n2,0\n3,0\n4,0\n5,0\n6,0\n7,0\n8,0\n9,0\n10,0\n11,0\n12,0\n13,0\n14,0\n15,0\n16,0\n17,0\n18,0\n19,0\n20,0\n21,0\n22,0\n23,0\n24,0\n25,0\n26,0\n27,0\n28,0\n29,0\n30,0\n31,0');
    }

    final rawData = await file.readAsString();
    List<List<dynamic>> data = const CsvToListConverter().convert(rawData);

    bool dayFound = false;
    for (int i = 0; i < data.length; i++) {
      if (data[i][0].toString() == day) {
        var currentCount = data[i][1] is int ? data[i][1] : int.parse(data[i][1].toString());
        data[i][1] = currentCount + 1;
        dayFound = true;
        break;
      }
    }

    if (!dayFound) {
      data.add([day, 1]);
    }

    String csvString = const ListToCsvConverter().convert(data);
    await file.writeAsString(csvString);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Congratulations!'),
      ),
      body: const Center(
        child: GetDate(),
      ),
    );
  }
}

class OpenNeedDrink extends StatefulWidget {
  const OpenNeedDrink({Key? key}) : super(key: key);

  @override
  State<OpenNeedDrink> createState() => _OpenNeedDrinkState();
}

class _OpenNeedDrinkState extends State<OpenNeedDrink> {
  late Future<int> _waterNeededFuture;

  @override
  void initState() {
    super.initState();
    _waterNeededFuture = _calculateWaterNeeded();
  }

  Future<int> _calculateWaterNeeded() async {
    var date = DateTime.now();
    var month = '${date.month}';
    var day = '${date.day}';

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$month.csv';
    final file = File(filePath);

    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString('day,glasses\n1,0\n2,0\n3,0\n4,0\n5,0\n6,0\n7,0\n8,0\n9,0\n10,0\n11,0\n12,0\n13,0\n14,0\n15,0\n16,0\n17,0\n18,0\n19,0\n20,0\n21,0\n22,0\n23,0\n24,0\n25,0\n26,0\n27,0\n28,0\n29,0\n30,0\n31,0');
      return 8;
    }

    final rawData = await file.readAsString();
    final csvData = const CsvToListConverter().convert(rawData);

    int waterDrunk = 0;
    for (int i = 0; i < csvData.length; i++) {
      if (csvData[i][0].toString() == day) {
        waterDrunk = csvData[i][1] is int ? csvData[i][1] : int.parse(csvData[i][1].toString());
        break;
      }
    }

    return 8 - waterDrunk;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Intake'),
      ),
      body: FutureBuilder<int>(
        future: _waterNeededFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final waterNeeded = snapshot.data!;
            final display = waterNeeded > 0 ? waterNeeded.toString() : "0";
            return Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Image(image: AssetImage('assets/images/glass2.png')),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      display,
                      style: const TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'More glasses of water for the day!',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text("You've had enough water for today!"));
          }
        },
      ),
    );
  }
}

class OpenSumm extends StatefulWidget {
  const OpenSumm({Key? key}) : super(key: key);

  @override
  State<OpenSumm> createState() => _OpenSummState();
}

class _OpenSummState extends State<OpenSumm> {
  @override
  Widget build(BuildContext context) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Intake'),
      ),
      body: ListView.builder(
        itemCount: months.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(3),
            child: ListTile(
              title: Text(months[index]),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OpenMonthlySummary(
                      month: index + 1,
                      monthName: months[index],
                    ),
                  ),
                );
              },
            ),
          );  // Note: onTap moved below for simplicity; add if needed
        },
      ),
    );
  }
}

class OpenMonthlySummary extends StatefulWidget {
  final int month;
  final String monthName;

  const OpenMonthlySummary({
    Key? key,
    required this.month,
    required this.monthName,
  }) : super(key: key);

  @override
  State<OpenMonthlySummary> createState() => _OpenMonthlySummaryState();
}

class _OpenMonthlySummaryState extends State<OpenMonthlySummary> {
  List<List<dynamic>> _data = [];

  @override
  void initState() {
    super.initState();
    _loadCSV();
  }

  void _loadCSV() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${widget.month}.csv';
      final f = File(filePath);

      if (await f.exists()) {
        final rawData = await f.readAsString();
        if (mounted) {
          setState(() {
            _data = const CsvToListConverter().convert(rawData);
          });
        }
      } else {
        await f.create(recursive: true);
        await f.writeAsString('day,glasses\n1,0\n2,0\n3,0\n4,0\n5,0\n6,0\n7,0\n8,0\n9,0\n10,0\n11,0\n12,0\n13,0\n14,0\n15,0\n16,0\n17,0\n18,0\n19,0\n20,0\n21,0\n22,0\n23,0\n24,0\n25,0\n26,0\n27,0\n28,0\n29,0\n30,0\n31,0');
        _loadCSV();
      }
    } catch (e) {
      print("Error loading CSV for month ${widget.month}: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.monthName),
      ),
      body: _data.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _data.length,
        itemBuilder: (context, index) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ListTile(
                title: Text("Day: ${_data[index][0]}"),
                trailing: Text("Glasses: ${_data[index][1]}"),
              ),
            ),
          );
        },
      ),
    );
  }
}

class GetDate extends StatefulWidget {
  const GetDate({Key? key}) : super(key: key);

  @override
  State<GetDate> createState() => _GetDateState();
}

class _GetDateState extends State<GetDate> {
  String finalDate = '';
  String finalTime = '';

  @override
  void initState() {
    super.initState();
    _setCurrentDateTime();
  }

  void _setCurrentDateTime() {
    var date = DateTime.now();
    var formattedDate = '${date.day}-${date.month}-${date.year}';
    var formattedTime = '${date.hour}:${date.minute}';

    if (mounted) {
      setState(() {
        finalDate = formattedDate;
        finalTime = formattedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/splash.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "You've drank water",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Date: $finalDate",
              style: const TextStyle(fontSize: 16, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Time: $finalTime",
              style: const TextStyle(fontSize: 16, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
