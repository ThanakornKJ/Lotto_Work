import 'package:flutter/material.dart';
import 'package:lotto/pages/admin_result.dart';
import 'package:lotto/pages/login_page.dart';

class AdminRandomPage extends StatefulWidget {
  const AdminRandomPage({super.key});

  @override
  State<AdminRandomPage> createState() => _AdminRandomPageState();
}

class _AdminRandomPageState extends State<AdminRandomPage> {
  // เก็บเลขที่สุ่มได้ (ตัวอย่าง mock data)
  final List<String> numbers = [
    "123456",
    "111222",
    "111111",
    "456789",
    "002345",
    "094306",
  ];

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
                  "assets/images/lotto_logo.png", // ใส่โลโก้ Lotto ของคุณ
                  height: 80,
                ),
                const SizedBox(height: 10),
                const Text(
                  "สุ่มออกรางวัล",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ปุ่มสุ่ม
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  // TODO: สุ่มตัวเลขใหม่
                },
                child: const Text("คลิกเพื่อสุ่มตัวเลข"),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  // ✅ กดแล้วไป AdminResultPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminResultPage(),
                    ),
                  );
                },
                child: const Text("สุ่มรางวัล"),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // แสดงชุดตัวเลข
          Expanded(
            child: ListView.builder(
              itemCount: numbers.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 6,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFAF0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "ชุดที่ ${index + 1} : ",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        numbers[index],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ปุ่มสุ่มใหม่อีกครั้ง
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                // TODO: สุ่มใหม่ทั้งหมด
              },
              child: const Text("สุ่มใหม่อีกครั้ง"),
            ),
          ),
        ],
      ),
    );
  }
}
