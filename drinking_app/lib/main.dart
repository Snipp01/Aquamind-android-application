import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // SystemNavigator + rootBundle
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'AquaMind',
      home: MainPage(),
    );
  }
}

/// MAIN PAGE: initialize month CSVs once, then show menu directly

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _initialized = false;

  Future<void> _initCSV() async {
    // Initialize monthly CSVs from assets or fallback
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
            await f.writeAsString(
              'day,glasses\n1,0\n2,0\n3,0\n4,0\n5,0\n6,0\n7,0\n8,0\n9,0\n10,0\n'
                  '11,0\n12,0\n13,0\n14,0\n15,0\n16,0\n17,0\n18,0\n19,0\n20,0\n'
                  '21,0\n22,0\n23,0\n24,0\n25,0\n26,0\n27,0\n28,0\n29,0\n30,0\n31,0',
            );
          }
        } catch (fallbackError) {
          print('Fallback CSV creation failed for month $i: $fallbackError');
        }
      }
    }

    // ensure beverages.csv exists
    final directory = await getApplicationDocumentsDirectory();
    final bevPath = '${directory.path}/beverages.csv';
    final bevFile = File(bevPath);
    if (!await bevFile.exists()) {
      await bevFile.create(recursive: true);
      await bevFile.writeAsString('date,time,beverage,amount,carbs,sugar\n');
    }
    print('BEVERAGE CSV PATH: $bevPath');
  }

  @override
  void initState() {
    super.initState();
    _initCSV().then((_) {
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return const MyHome();
  }
}

/// HOME

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  Column _buildButtonColumn(BuildContext context, IconData icon, String label) {
    final Color textColor =
    label == "Drink Water" ? Colors.blue : Colors.blue ;

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
            } else if (label == "Other Drinks") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BeverageLogPage()),
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
            } else if (label == "Drink Logs") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BeverageHistoryPage()),
              );
            } else {
              SystemNavigator.pop();
            }
          },
        ),
        Container(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: textColor,
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
      icon1 = Icons.local_drink;
      icon2 = Icons.local_cafe;
      label1 = "Drink Water";
      label2 = "Other Drinks";
    } else {
      icon1 = Icons.water_drop_outlined;
      icon2 = Icons.history;
      label1 = "Water Intake";
      label2 = "Drink Logs";
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
                  'AquaMind',
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

    const Widget spaceSection = SizedBox(height: 20);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AquaMind'),
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
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.access_time),
              label: const Text('Monthly Summary'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OpenSumm()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// WATER DRINK SCREEN

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
      await file.writeAsString(
        'day,glasses\n1,0\n2,0\n3,0\n4,0\n5,0\n6,0\n7,0\n8,0\n9,0\n10,0\n'
            '11,0\n12,0\n13,0\n14,0\n15,0\n16,0\n17,0\n18,0\n19,0\n20,0\n'
            '21,0\n22,0\n23,0\n24,0\n25,0\n26,0\n27,0\n28,0\n29,0\n30,0\n31,0',
      );
    }

    final rawData = await file.readAsString();
    List<List<dynamic>> data = const CsvToListConverter().convert(rawData);

    bool dayFound = false;
    for (int i = 0; i < data.length; i++) {
      if (data[i][0].toString() == day) {
        var currentCount = data[i][1] is int
            ? data[i][1]
            : int.parse(data[i][1].toString());
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

/// WATER INTAKE

class OpenNeedDrink extends StatefulWidget {
  const OpenNeedDrink({Key? key}) : super(key: key);

  @override
  State<OpenNeedDrink> createState() => _OpenNeedDrinkState();
}

class _OpenNeedDrinkState extends State<OpenNeedDrink> {
  final TextEditingController _weightController = TextEditingController();
  Future<int>? _waterNeededFuture;

  @override
  void initState() {
    super.initState();
    _loadSavedWeight();
  }

  Future<void> _loadSavedWeight() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/weight.txt';
    final file = File(filePath);

    if (await file.exists()) {
      final saved = (await file.readAsString()).trim();
      final w = double.tryParse(saved);
      if (w != null) {
        setState(() {
          _weightController.text = saved;
          _waterNeededFuture = _calculateWaterNeeded(w);
        });
      }
    }
  }

  Future<void> _saveWeight(double weight) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/weight.txt';
    final file = File(filePath);
    await file.writeAsString(weight.toString());
  }

  Future<int> _calculateWaterNeeded(double weight) async {
    // recommended based on weight
    int recommended = (weight * 30 / 250).round();

    var date = DateTime.now();
    var month = '${date.month}';
    var day = '${date.day}';

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$month.csv';
    final file = File(filePath);

    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString(
        'day,glasses\n1,0\n2,0\n3,0\n4,0\n5,0\n6,0\n7,0\n8,0\n9,0\n10,0\n'
            '11,0\n12,0\n13,0\n14,0\n15,0\n16,0\n17,0\n18,0\n19,0\n20,0\n'
            '21,0\n22,0\n23,0\n24,0\n25,0\n26,0\n27,0\n28,0\n29,0\n30,0\n31,0',
      );
      return recommended;
    }

    final rawData = await file.readAsString();
    final csvData = const CsvToListConverter().convert(rawData);

    int waterDrunk = 0;
    for (int i = 0; i < csvData.length; i++) {
      if (csvData[i][0].toString() == day) {
        waterDrunk = csvData[i][1] is int
            ? csvData[i][1]
            : int.parse(csvData[i][1].toString());
        break;
      }
    }

    final remaining = recommended - waterDrunk;
    return remaining > 0 ? remaining : 0;
  }

  void _onCalculate() {
    final text = _weightController.text.trim();
    if (text.isEmpty) return;
    final weight = double.tryParse(text);
    if (weight == null) return;

    _saveWeight(weight); // persist for next time

    setState(() {
      _waterNeededFuture = _calculateWaterNeeded(weight);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Intake'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Enter your weight (kg) to see how many glasses are left:'),
            const SizedBox(height: 8),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Weight in kg',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _onCalculate,
              child: const Text('Calculate'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _waterNeededFuture == null
                  ? const Center(
                child: Text('Enter weight and tap Calculate.'),
              )
                  : FutureBuilder<int>(
                future: _waterNeededFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final waterNeeded = snapshot.data!;
                    final display =
                    waterNeeded > 0 ? waterNeeded.toString() : "0";
                    return Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Image(
                              image: AssetImage(
                                  'assets/images/glass2.png'),
                            ),
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
                    return const Center(
                        child:
                        Text("You've had enough water for today!"));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// MONTHLY SUMMARY (unchanged structures)

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
          );
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
        await f.writeAsString(
          'day,glasses\n1,0\n2,0\n3,0\n4,0\n5,0\n6,0\n7,0\n8,0\n9,0\n10,0\n'
              '11,0\n12,0\n13,0\n14,0\n15,0\n16,0\n17,0\n18,0\n19,0\n20,0\n'
              '21,0\n22,0\n23,0\n24,0\n25,0\n26,0\n27,0\n28,0\n29,0\n30,0\n31,0',
        );
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

/// SIMPLE CONFIRMATION

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
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Date: $finalDate",
              style: const TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Time: $finalTime",
              style: const TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

///
/// BeverageLogPage for soda/coffee/etc using Nutrition API
/// Logs to beverages.csv with date,time,beverage,amount,carbs,sugar
///

class BeverageLogPage extends StatefulWidget {
  const BeverageLogPage({Key? key}) : super(key: key);

  @override
  State<BeverageLogPage> createState() => _BeverageLogPageState();
}

class _BeverageLogPageState extends State<BeverageLogPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  // Safe numeric parser: handles numbers, numeric strings, or premium placeholders
  double _parseNum(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) {
      final match = RegExp(r'[-+]?[0-9]*\.?[0-9]+').firstMatch(v);
      if (match != null) {
        return double.tryParse(match.group(0)!) ?? 0.0;
      }
    }
    return 0.0;
  }

  Future<void> _search(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.api-ninjas.com/v1/nutrition?query=$trimmed'),
        headers: {
          'X-Api-Key': 'LqUeYXhNYHS0mOb05vo8pg==vQBgGNbAqdL3Nhgq',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data as List;
        setState(() {
          _results = list.map<Map<String, dynamic>>((item) {
            return {
              'name': item['name'] ?? item['food_name'] ?? 'Unnamed Beverage',
              'serving': "${item['serving_size_g'] ?? 100} g",
              'carbs': _parseNum(item['carbohydrates_total_g']),
              'sugar': _parseNum(item['sugar_g']),
            };
          }).toList();
        });
      } else {
        print('Nutrition API error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Nutrition API exception: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _logBeverage({
    required String name,
    required int amount,
    required double carbs,
    required double sugar,
  }) async {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month}-${now.day}';
    final timeStr = '${now.hour}:${now.minute}';

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/beverages.csv';
    final file = File(filePath);

    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString('date,time,beverage,amount,carbs,sugar\n');
    }

    final csvLine =
        '$dateStr,$timeStr,$name,$amount,${carbs * amount},${sugar * amount}\n';
    await file.writeAsString(csvLine, mode: FileMode.append);

    print('WROTE TO $filePath: $csvLine');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged $amount x $name')),
    );

    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BeverageHistoryPage()),
      );
    }
  }

  void _openLogSheet(Map<String, dynamic> item) {
    int tempAmount = 1;
    final name = item['name'] as String;
    final double carbs = (item['carbs'] ?? 0).toDouble();
    final double sugar = (item['sugar'] ?? 0).toDouble();

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Per serving (${item["serving"]}): '
                        'Carbs: ${carbs.toStringAsFixed(1)} g, '
                        'Sugar: ${sugar.toStringAsFixed(1)} g',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Amount (glasses): '),
                      DropdownButton<int>(
                        value: tempAmount,
                        onChanged: (val) {
                          if (val == null) return;
                          setSheetState(() {
                            tempAmount = val;
                          });
                        },
                        items: [1, 2, 3, 4, 5]
                            .map(
                              (e) => DropdownMenuItem<int>(
                            value: e,
                            child: Text('$e'),
                          ),
                        )
                            .toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _logBeverage(
                            name: name,
                            amount: tempAmount,
                            carbs: carbs,
                            sugar: sugar,
                          );
                        },
                        child: const Text('Log'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Other Drinks'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search drink (e.g., soda, coffee)',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: _search,
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final item = _results[index];
                return ListTile(
                  title: Text(item['name'] ?? 'Unnamed Beverage'),
                  subtitle: Text(
                    'Serving: ${item["serving"]} | '
                        'Carbs: ${item["carbs"]} g | Sugar: ${item["sugar"]} g',
                  ),
                  onTap: () => _openLogSheet(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

///
/// BeverageHistoryPage – view all soda/coffee/etc logs
///

class BeverageHistoryPage extends StatefulWidget {
  const BeverageHistoryPage({Key? key}) : super(key: key);

  @override
  State<BeverageHistoryPage> createState() => _BeverageHistoryPageState();
}

class _BeverageHistoryPageState extends State<BeverageHistoryPage> {
  late Future<List<List<String>>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _logsFuture = _loadLogs();
  }

  Future<List<List<String>>> _loadLogs() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/beverages.csv';
    final file = File(filePath);

    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString('date,time,beverage,amount,carbs,sugar\n');
      return [];
    }

    final rawData = await file.readAsString();
    print('READ FROM $filePath:\n$rawData'); // debug

    // Manually parse CSV: each non-empty line -> List<String>
    final lines = rawData.trim().split('\n');
    if (lines.length <= 1) return []; // only header or empty

    final List<List<String>> rows = [];
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      rows.add(line.split(',')); // [date, time, beverage, amount, carbs, sugar]
    }

    return rows;
  }

  void _refreshLogs() {
    setState(() {
      _logsFuture = _loadLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drink Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshLogs,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<List<String>>>(
        future: _logsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.length <= 1) {
            // no data or just header
            return const Center(child: Text('No drinks logged yet.'));
          }

          final data = snapshot.data!; // includes header at index 0

          double totalCarbs = 0;
          double totalSugar = 0;

          // Start from 1 to skip header row [date,time,beverage,amount,carbs,sugar]
          for (var i = 1; i < data.length; i++) {
            final row = data[i];
            if (row.length > 4) {
              totalCarbs += double.tryParse(row[4]) ?? 0;
            }
            if (row.length > 5) {
              totalSugar += double.tryParse(row[5]) ?? 0;
            }
          }

          final int totalDrinks = data.length - 1; // skip header

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Total drinks: $totalDrinks\n'
                      'Total carbs: ${totalCarbs.toStringAsFixed(1)} g   '
                      'Total sugar: ${totalSugar.toStringAsFixed(1)} g',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    if (index == 0) return const SizedBox.shrink(); // header

                    final row = data[index];
                    final date = row[0];
                    final time = row[1];
                    final beverage = row[2];
                    final amount = row[3];
                    final carbs = row.length > 4 ? row[4] : '0';
                    final sugar = row.length > 5 ? row[5] : '0';

                    return Card(
                      child: ListTile(
                        title: Text('$beverage ($amount glasses)'),
                        subtitle: Text(
                          'Date: $date  Time: $time\n'
                              'Carbs: $carbs g  Sugar: $sugar g',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
