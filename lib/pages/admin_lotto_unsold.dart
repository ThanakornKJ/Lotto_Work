import 'package:flutter/material.dart';
import 'login_page.dart';

class AdminLottoUnsoldPage extends StatefulWidget {
  const AdminLottoUnsoldPage({super.key});

  @override
  State<AdminLottoUnsoldPage> createState() => _AdminLottoUnsoldPageState();
}

class _AdminLottoUnsoldPageState extends State<AdminLottoUnsoldPage> {
  // mock ข้อมูลลอตเตอรี่ที่ยังไม่ขาย
  final List<String> unsoldLottos = [
    "123456",
    "234567",
    "345678",
    "456789",
    "567890",
    "678901",
    "789012",
    "890123",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                "เมนู",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(leading: Icon(Icons.home), title: Text("หน้าหลัก")),
          ],
        ),
      ),
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
              // Logout → กลับหน้า LoginPage และลบ history
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
                Image.asset("assets/images/lotto_logo.png", height: 80),
                const SizedBox(height: 10),
                const Text(
                  "ลอตเตอรี่ที่ยังไม่ขาย",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // แสดงลอตเตอรี่ที่ยังไม่ขาย
          Expanded(
            child: ListView.builder(
              itemCount: unsoldLottos.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFAF0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        unsoldLottos[index],
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
        ],
      ),
    );
  }
}
