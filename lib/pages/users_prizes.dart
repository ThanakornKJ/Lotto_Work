import 'package:flutter/material.dart';
import 'login_page.dart';

class UsersPrizesPage extends StatefulWidget {
  const UsersPrizesPage({super.key});

  @override
  State<UsersPrizesPage> createState() => _UsersPrizesPageState();
}

class _UsersPrizesPageState extends State<UsersPrizesPage> {
  final TextEditingController _controller = TextEditingController();
  String winningNumber = "123456"; // mock เลขที่ถูกรางวัล

  void _checkPrize() {
    String inputNumber = _controller.text.trim();

    if (inputNumber.length != 6 || int.tryParse(inputNumber) == null) {
      // แจ้งเตือนถ้าไม่ใช่เลข 6 หลัก
      _showResultDialog(false, message: "กรุณาป้อนเลข 6 หลักเท่านั้น!");
      return;
    }

    bool success = inputNumber == winningNumber;
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

    // ปิด popup อัตโนมัติหลัง 2 วินาที
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
                "ตรวจสอบและขึ้นเงิน",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              const Text(
                "ป้อนหมายเลขเพื่อการตรวจสอบ",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),

              // TextField ป้อนเลข
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

              // ปุ่มตรวจสอบ
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
            ],
          ),
        ),
      ),
    );
  }
}
