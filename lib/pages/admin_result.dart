import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';

class AdminResultPage extends StatefulWidget {
  final List<String> numbers;

  const AdminResultPage({super.key, required this.numbers});

  @override
  State<AdminResultPage> createState() => _AdminResultPageState();
}

class _AdminResultPageState extends State<AdminResultPage> {
  late String prize1;
  late String prize2;
  late String prize3;
  late String last3;
  late String last2;

  late int prizeAmount1;
  late int prizeAmount2;
  late int prizeAmount3;
  late int prizeAmountLast3;
  late int prizeAmountLast2;

  final Random _random = Random();
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _randomizePrizes();
  }

  void _randomizePrizes() {
    if (widget.numbers.isEmpty) return;

    setState(() {
      prize1 = widget.numbers[_random.nextInt(widget.numbers.length)];
      prize2 = widget.numbers[_random.nextInt(widget.numbers.length)];
      prize3 = widget.numbers[_random.nextInt(widget.numbers.length)];
      last3 = prize1.substring(prize1.length - 3);
      last2 = prize1.substring(prize1.length - 2);

      prizeAmount1 = 6000000;
      prizeAmount2 = 200000;
      prizeAmount3 = 80000;
      prizeAmountLast3 = 4000;
      prizeAmountLast2 = 2000;
    });
  }

  Future<void> _saveResults() async {
    setState(() {
      isSaving = true;
    });

    final url = Uri.parse('http://192.168.88.98:5000/results');
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
          'prizeAmount1': prizeAmount1,
          'prizeAmount2': prizeAmount2,
          'prizeAmount3': prizeAmount3,
          'prizeAmountLast3': prizeAmountLast3,
          'prizeAmountLast2': prizeAmountLast2,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกรางวัลเรียบร้อยแล้ว')),
        );
      } else {
        print('Failed to save results: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isSaving = false;
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
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
        backgroundColor: Colors.grey[200],
        elevation: 0,
      ),
      body: Column(
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
                    child: const Text("สุ่มรางวัลใหม่"),
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
    );
  }
}
