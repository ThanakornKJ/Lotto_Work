import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';

class UsersPrizesPage extends StatefulWidget {
  const UsersPrizesPage({super.key});

  @override
  State<UsersPrizesPage> createState() => _UsersPrizesPageState();
}

class _UsersPrizesPageState extends State<UsersPrizesPage> {
  final TextEditingController _controller = TextEditingController();

  // เก็บรางวัลจาก DB
  String? prize1;
  String? prize2;
  String? prize3;
  String? last3;
  String? last2;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchResults();
  }

  Future<void> _fetchResults() async {
    setState(() => loading = true);
    try {
      final url = Uri.parse("https://lotto-work.onrender.com/results");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;

        for (var r in results) {
          switch (r['prize_type']) {
            case '1st':
              prize1 = r['winning_number'];
              break;
            case '2nd':
              prize2 = r['winning_number'];
              break;
            case '3rd':
              prize3 = r['winning_number'];
              break;
            case 'last3':
              last3 = r['winning_number'];
              break;
            case 'last2':
              last2 = r['winning_number'];
              break;
          }
        }
      } else {
        throw Exception("โหลดผลรางวัลไม่สำเร็จ");
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    } finally {
      setState(() => loading = false);
    }
  }

  void _checkPrize() {
    String inputNumber = _controller.text.trim();

    if (inputNumber.length != 6 || int.tryParse(inputNumber) == null) {
      _showResultDialog(false, message: "กรุณาป้อนเลข 6 หลักเท่านั้น!");
      return;
    }

    bool success = false;
    if (inputNumber == prize1 ||
        inputNumber == prize2 ||
        inputNumber == prize3 ||
        inputNumber.endsWith(last3 ?? "") ||
        inputNumber.endsWith(last2 ?? "")) {
      success = true;
    }

    _showResultDialog(success);
  }

  void _showResultDialog(bool success, {String? message}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.cancel,
                  color: success ? Colors.green : Colors.red,
                  size: 40,
                ),
                const SizedBox(height: 10),
                Text(
                  message ?? (success ? "คุณถูกรางวัล!!" : "ไม่ถูกรางวัล!!"),
                  style: TextStyle(
                    fontSize: 18,
                    color: success ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }

  Widget _buildPrize(String title, String? number, {bool small = false}) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: small ? 16 : 18)),
        const SizedBox(height: 6),
        Text(
          number ?? "-",
          style: TextStyle(
            fontSize: small ? 22 : 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
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
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Image.asset(
                      "assets/images/lotto_logo.png",
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "ตรวจสอบและขึ้นเงิน",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text("ป้อนหมายเลขเพื่อการตรวจสอบ"),
                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 50),
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "ป้อนเลข 6 หลัก",
                        counterText: "",
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _checkPrize,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("ตรวจสอบ"),
                  ),
                  const SizedBox(height: 30),
                  const Divider(thickness: 1),
                  const SizedBox(height: 20),
                  const Text(
                    "ผลรางวัลล่าสุด",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildPrize("รางวัลที่ 1", prize1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPrize("รางวัลที่ 2", prize2, small: true),
                      _buildPrize("รางวัลที่ 3", prize3, small: true),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPrize("เลขท้าย 3 ตัว", last3, small: true),
                      _buildPrize("เลขท้าย 2 ตัว", last2, small: true),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
