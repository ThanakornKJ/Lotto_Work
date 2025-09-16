import 'package:flutter/material.dart';
import 'login_page.dart';

class UsersPurchasesPage extends StatefulWidget {
  const UsersPurchasesPage({super.key});

  @override
  State<UsersPurchasesPage> createState() => _UsersPurchasesPageState();
}

class _UsersPurchasesPageState extends State<UsersPurchasesPage> {
  double balance = 500; // mock เงินคงเหลือ
  final int lottoPrice = 100;
  String? lottoNumber = "123456"; // mock หมายเลข lotto

  void _buyLotto() {
    if (lottoNumber == null || balance < lottoPrice) {
      _showResultDialog(false);
    } else {
      setState(() {
        balance -= lottoPrice;
      });
      _showResultDialog(true);
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

    // auto close after 2 sec
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
          onPressed: () {
            Navigator.pop(context);
          },
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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 30),
              // โลโก้
              Image.asset("assets/images/lotto_logo.png", height: 100),
              const SizedBox(height: 10),
              const Text(
                "ชำระเงิน",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // การ์ดเลข lotto
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 60,
                ),
                color: const Color(0xFFFFFAF0),
                child: Text(
                  lottoNumber ?? "-",
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ราคา
              Text(
                "ราคา : $lottoPrice บาท",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // เงินคงเหลือ
              Text(
                "ยอดเงินคงเหลือ : ${balance.toStringAsFixed(0)} บาท",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // ปุ่มจ่ายเงิน
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
