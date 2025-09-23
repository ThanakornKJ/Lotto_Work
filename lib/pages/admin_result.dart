import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';
import 'dart:convert';

class AdminResultPage extends StatefulWidget {
  final List<Map<String, dynamic>> allNumbers;
  const AdminResultPage({super.key, required this.allNumbers});

  @override
  State<AdminResultPage> createState() => _AdminResultPageState();
}

class _AdminResultPageState extends State<AdminResultPage> {
  List<String> soldNumbers = [];
  List<String> poolNumbers = [];

  String prize1 = '';
  String prize2 = '';
  String prize3 = '';
  String last3 = '';
  String last2 = '';

  int prizeAmount1 = 6000000;
  int prizeAmount2 = 200000;
  int prizeAmount3 = 80000;
  int prizeAmountLast3 = 4000;
  int prizeAmountLast2 = 2000;

  final Random _random = Random();
  bool isSaving = false;

  String selectedPool = 'sold'; // ค่าเริ่มต้น

  @override
  void initState() {
    super.initState();
    soldNumbers = widget.allNumbers
        .where((lot) => lot['sold'] == true)
        .map<String>((lot) => lot['number'] as String)
        .toList();
    _updatePool();
  }

  void _updatePool() {
    setState(() {
      poolNumbers = (selectedPool == 'sold')
          ? soldNumbers
          : widget.allNumbers
                .map<String>((lot) => lot['number'] as String)
                .toList();
    });
  }

  void _randomizePrizes() {
    if (poolNumbers.isEmpty) return;

    setState(() {
      // รางวัลที่ 1-3 สุ่มจาก pool
      prize1 = poolNumbers[_random.nextInt(poolNumbers.length)];
      prize2 = poolNumbers[_random.nextInt(poolNumbers.length)];
      prize3 = poolNumbers[_random.nextInt(poolNumbers.length)];

      // last3 จาก prize1
      last3 = prize1.substring(prize1.length - 3);

      // last2 สุ่มจาก pool
      last2 = poolNumbers[_random.nextInt(poolNumbers.length)].substring(
        poolNumbers[0].length - 2,
      );
    });
  }

  Future<void> _saveResults() async {
    if (prize1.isEmpty || prize2.isEmpty || prize3.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาสุ่มรางวัลก่อนบันทึก')),
      );
      return;
    }

    setState(() => isSaving = true);

    final url = Uri.parse('https://lotto-work.onrender.com/results');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prize1': prize1,
          'prize2': prize2,
          'prize3': prize3,
          'last3': last3,
          'last2': last2,
          'pool': selectedPool,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกรางวัลเรียบร้อยแล้ว')),
        );
      } else {
        print(
          'Failed to save results: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => isSaving = false);
    }
  }

  Future<void> fetchSoldNumbers() async {
    final url = Uri.parse('https://lotto-work.onrender.com/lotteries/sold');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        soldNumbers = data.map<String>((e) => e['number'] as String).toList();
        if (selectedPool == 'sold') {
          _updatePool();
        }
      });
    }
  }

  String formatMoney(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Widget buildPrizeRow(String title, String number, int amount) {
    return Column(
      children: [
        Text(title),
        const SizedBox(height: 6),
        Text(
          number,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          '${formatMoney(amount)} บาท',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.orange),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
        backgroundColor: Colors.grey[200],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Image.asset("assets/images/lotto_logo.png", height: 80),
                  const SizedBox(height: 10),
                  const Text(
                    "ผลการออกรางวัล",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  const Text("เลือกล็อตโต้สำหรับสุ่ม: "),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: selectedPool,
                    items: const [
                      DropdownMenuItem(
                        value: 'sold',
                        child: Text('ล็อตโต้ที่ขายแล้ว'),
                      ),
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('ล็อตโต้ทั้งหมด'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      selectedPool = value;
                      _updatePool();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            buildPrizeRow("รางวัลที่ 1", prize1, prizeAmount1),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildPrizeRow("รางวัลที่ 2", prize2, prizeAmount2),
                buildPrizeRow("รางวัลที่ 3", prize3, prizeAmount3),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildPrizeRow("เลขท้าย 3 ตัว", last3, prizeAmountLast3),
                buildPrizeRow("เลขท้าย 2 ตัว", last2, prizeAmountLast2),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: _randomizePrizes,
                      child: const Text("สุ่มรางวัล"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: isSaving ? null : _saveResults,
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text("อัพเดตรางวัล"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
