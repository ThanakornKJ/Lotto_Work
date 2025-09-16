import 'package:flutter/material.dart';
import 'package:lotto/pages/login_page.dart';

class AdminResultPage extends StatefulWidget {
  const AdminResultPage({super.key});

  @override
  State<AdminResultPage> createState() => _AdminResultPageState();
}

class _AdminResultPageState extends State<AdminResultPage> {
  // mock ข้อมูลรางวัล
  String prize1 = "123456";
  String prize2 = "222222";
  String prize3 = "333333";
  String last3 = "456";
  String last2 = "99";

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
              // logout → กลับหน้า LoginPage
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
          // โลโก้
          Center(
            child: Column(
              children: [
                Image.asset(
                  "assets/images/lotto_logo.png", // เพิ่มรูปโลโก้ Lotto
                  height: 80,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          const SizedBox(height: 10),

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

          // รางวัลเลขท้าย
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

          const Spacer(),

          // ปุ่มด้านล่าง
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    // TODO: สุ่มรางวัลใหม่
                  },
                  child: const Text("สุ่มรางวัลใหม่"),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    // TODO: อัพเดตรางวัล
                  },
                  child: const Text("อัพเดตรางวัล"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
