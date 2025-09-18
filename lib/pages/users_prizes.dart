import 'package:flutter/material.dart';
import 'login_page.dart';

class UsersPrizesPage extends StatefulWidget {
  const UsersPrizesPage({super.key});

  @override
  State<UsersPrizesPage> createState() => _UsersPrizesPageState();
}

class _UsersPrizesPageState extends State<UsersPrizesPage> {
  final TextEditingController _controller = TextEditingController();

  // mock ข้อมูลรางวัล
  String prize1 = "123456";
  String prize2 = "222222";
  String prize3 = "333333";
  String last3 = "456";
  String last2 = "99";

  void _checkPrize() {
    String inputNumber = _controller.text.trim();

    if (inputNumber.length != 6 || int.tryParse(inputNumber) == null) {
      _showResultDialog(false, message: "กรุณาป้อนเลข 6 หลักเท่านั้น!");
      return;
    }

    bool success =
        inputNumber == prize1 ||
        inputNumber == prize2 ||
        inputNumber == prize3 ||
        inputNumber.endsWith(last3) ||
        inputNumber.endsWith(last2);

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
        child: Column(
          children: [
            const SizedBox(height: 20),
            // โลโก้
            Center(
              child: Image.asset("assets/images/lotto_logo.png", height: 100),
            ),
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

            // TextField
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

            // ✅ โชว์รางวัลด้านล่าง
            const Text(
              "ผลรางวัลล่าสุด",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // รางวัลที่ 1
            const Text(
              "รางวัลที่ 1",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              prize1,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 20),

            // รางวัลที่ 2 และ 3
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text("รางวัลที่ 2", style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(
                      prize2,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text("รางวัลที่ 3", style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(
                      prize3,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // เลขท้าย
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text(
                      "รางวัลเลขท้าย 3 ตัว",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      last3,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      "รางวัลเลขท้าย 2 ตัว",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      last2,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
