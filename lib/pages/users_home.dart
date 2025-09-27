import 'package:flutter/material.dart';
import 'package:lotto/pages/users_lotto_unsold.dart';
import 'package:lotto/pages/users_prizes.dart';
import 'package:lotto/pages/users_wallets.dart';
import 'package:lotto/pages/users_history.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final String userId;
  const HomePage({super.key, required this.userId});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();

  void searchLotto(String query) async {
    if (query.isNotEmpty) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              UsersLottoUnsoldPage(userId: widget.userId, keyword: query),
        ),
      );
      // ✅ เคลียร์ TextField หลังกลับ
      setState(() {
        searchController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[400],

        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 30, color: Colors.orange),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.orange),
              child: Center(
                child: Text(
                  "เมนู",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("หวยที่ซื้อ"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserHistoryPage(userId: widget.userId),
                  ),
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
                child: Image.asset('assets/images/lotto_logo.png', width: 200),
              ),

              // ✅ กล่องค้นหา
              Padding(
                padding: const EdgeInsets.fromLTRB(70, 60, 70, 60),
                child: TextField(
                  controller: searchController,
                  textInputAction:
                      TextInputAction.search, // ปุ่มคีย์บอร์ดเป็น search
                  onSubmitted: (value) =>
                      searchLotto(value), // ✅ กด Enter ค้นหา
                  decoration: InputDecoration(
                    label: const Text(
                      'ค้นหาล็อตโต้:',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => searchLotto(
                        searchController.text,
                      ), // ✅ กดปุ่มแว่นขยายค้นหาได้ด้วย
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

              // ✅ ปุ่มเมนูต่างๆ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              UsersLottoUnsoldPage(userId: widget.userId),
                        ),
                      );
                      // เคลียร์ TextField หลังกลับ
                      setState(() {
                        searchController.clear();
                      });
                    },
                    style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                    child: Image.asset('assets/images/unsold.png', width: 120),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              UsersWalletsPage(userId: widget.userId),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                    child: Image.asset('assets/images/balance.png', width: 120),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              UsersPrizesPage(userId: widget.userId),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                    child: Image.asset('assets/images/results.png', width: 120),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
