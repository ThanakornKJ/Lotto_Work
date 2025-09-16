import 'package:flutter/material.dart';
import 'package:lotto/pages/users_purchases.dart';

class UsersLottoUnsoldPage extends StatefulWidget {
  const UsersLottoUnsoldPage({super.key});

  @override
  State<UsersLottoUnsoldPage> createState() => _UsersLottoUnsoldPageState();
}

class _UsersLottoUnsoldPageState extends State<UsersLottoUnsoldPage> {
  // mock ข้อมูลลอตเตอรี่ที่ยังไม่ขาย
  final List<String> unsoldLottos = [
    "123456",
    "123456",
    "123456",
    "123456",
    "123456",
    "123456",
    "123456",
    "123456",
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
            ListTile(leading: Icon(Icons.shopping_cart), title: Text("ตะกร้า")),
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
              // TODO: ออกจากระบบ หรือไปหน้าอื่น
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
                  "assets/images/lotto_logo.png", // ใส่ path โลโก้ของคุณ
                  height: 80,
                ),
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
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        onPressed: () {
                          // ✅ กดแล้วไป UsersPurchasesPage
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UsersPurchasesPage(),
                            ),
                          );
                        },
                        child: const Text("Buy"),
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
