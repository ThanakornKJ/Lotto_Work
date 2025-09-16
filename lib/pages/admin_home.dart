import 'package:flutter/material.dart';
import 'package:lotto/pages/admin_random.dart';
import 'package:lotto/pages/admin_setting.dart';
import 'login_page.dart';
import 'admin_lotto_unsold.dart'; // ✅ import หน้าลอตเตอรี่ยังไม่ขาย

class AdminLotto extends StatefulWidget {
  const AdminLotto({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AdminLottoState();
  }
}

class _AdminLottoState extends State<AdminLotto> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[400],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.menu, size: 30, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.logout, size: 30, color: Colors.orange),
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
        ),
      ),
      body: ListView(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                child: Column(
                  children: [
                    Image.asset('assets/images/lotto_logo.png', width: 200),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(70, 60, 70, 60),
                child: TextField(
                  decoration: InputDecoration(
                    label: const Text(
                      'ค้นหาล็อตโต้:',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 20,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // ✅ กดแล้วไป AdminLottoUnsoldPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminLottoUnsoldPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                    child: Image.asset('assets/images/unsold.png', width: 120),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      print('ตรวจสอบยอดเงิน');
                    },
                    style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                    child: Image.asset('assets/images/balance.png', width: 120),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      print('ตรวจผลและขึ้นเงิน');
                    },
                    style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                    child: Image.asset('assets/images/results.png', width: 120),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 50, 0, 0),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // ✅ กดแล้วไป AdminRandomPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminRandomPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                      child: Image.asset(
                        'assets/images/random.png',
                        width: 120,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // ✅ กดแล้วไป AdminSettingPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminSettingPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                      child: Image.asset(
                        'assets/images/setting.png',
                        width: 120,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
