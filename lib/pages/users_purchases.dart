import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';

class UsersPurchasesPage extends StatefulWidget {
  final String lottoNumber;
  final int lottoPrice;
  final String lottoId;
  final String userId; // ✅ เพิ่ม userId

  const UsersPurchasesPage({
    super.key,
    required this.lottoNumber,
    required this.lottoPrice,
    required this.lottoId,
    required this.userId, // ✅
  });

  @override
  State<UsersPurchasesPage> createState() => _UsersPurchasesPageState();
}

class _UsersPurchasesPageState extends State<UsersPurchasesPage> {
  double balance = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchWallet();
  }

  Future<void> fetchWallet() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://lotto-work.onrender.com/wallet/${widget.userId}',
        ), // ✅ ใช้ userId จริง
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          balance = data['balance'].toDouble();
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      print(e);
      setState(() => loading = false);
    }
  }

  Future<void> _buyLotto() async {
    if (balance < widget.lottoPrice) {
      _showResultDialog(false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://lotto-work.onrender.com/purchase'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'purchase_id': 'PU${DateTime.now().millisecondsSinceEpoch}',
          'user_id': widget.userId, // ✅ ใช้ userId จริง
          'lotto_id': widget.lottoId,
          'amount_paid': widget.lottoPrice,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          balance = data['wallet']['balance'].toDouble();
        });
        _showResultDialog(true);
      } else {
        _showResultDialog(false);
      }
    } catch (e) {
      print(e);
      _showResultDialog(false);
    }
  }

  void _showResultDialog(bool success) {
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
                  success ? "ซื้อลอตเตอรี่สำเร็จ!" : "ซื้อลอตเตอรี่ไม่สำเร็จ!",
                  style: TextStyle(
                    fontSize: 18,
                    color: success ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
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
              // ✅ กด Logout ค่อยกลับไป LoginPage
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
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
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Image.asset("assets/images/lotto_logo.png", height: 100),
                    const SizedBox(height: 10),
                    const Text(
                      "ชำระเงิน",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 60,
                      ),
                      color: const Color(0xFFFFFAF0),
                      child: Text(
                        widget.lottoNumber,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "ราคา : ${widget.lottoPrice} บาท",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "ยอดเงินคงเหลือ : ${balance.toStringAsFixed(0)} บาท",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _buyLotto,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("ชำระเงิน"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
