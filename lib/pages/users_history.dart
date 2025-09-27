import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';
import 'users_home.dart';
import 'users_prizes.dart'; // ✅ import หน้า UsersPrizesPage

class UserHistoryPage extends StatefulWidget {
  final String userId;

  const UserHistoryPage({super.key, required this.userId});

  @override
  State<UserHistoryPage> createState() => _UserHistoryPageState();
}

class _UserHistoryPageState extends State<UserHistoryPage> {
  bool loading = true;
  List<dynamic> purchasedLotto = [];
  Map<String, Map<String, bool>> claimedMap =
      {}; // เก็บสถานะ claimed ของแต่ละเลขหวย

  @override
  void initState() {
    super.initState();
    fetchPurchasedLotto();
  }

  Future<void> fetchPurchasedLotto() async {
    try {
      final response = await http.get(
        Uri.parse("https://lotto-work.onrender.com/purchased/${widget.userId}"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> purchases = data["purchases"] ?? [];

        purchases.sort((a, b) {
          DateTime dateA = DateTime.parse(a["purchase_date"]);
          DateTime dateB = DateTime.parse(b["purchase_date"]);
          return dateB.compareTo(dateA);
        });

        setState(() {
          purchasedLotto = purchases;
        });

        // หลังจากดึงเลขหวยแล้ว ให้ดึงสถานะ claimed
        for (var lotto in purchases) {
          final number = lotto["lotto_number"].toString();
          final status = await fetchClaimedStatus(number);
          setState(() {
            claimedMap[number] = status;
          });
        }
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() => loading = false);
    }
  }

  // ดึงรางวัลของผู้ใช้และ filter เฉพาะรางวัลที่ตรงเลข
  Future<Map<String, bool>> fetchClaimedStatus(String lottoNumber) async {
    try {
      final response = await http.get(
        Uri.parse('https://lotto-work.onrender.com/api/admin/user-prizes'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        final userData = data.firstWhere(
          (u) => u['user_id'] == widget.userId,
          orElse: () => null,
        );

        if (userData != null) {
          Map<String, bool> claimed = {};
          for (var p in userData['prizes']) {
            final winningNumber = p['winning_number'] ?? '';
            final isClaimed = p['claimed'] ?? false;

            bool match = false;
            switch (p['prize_type']) {
              case '1st':
              case '2nd':
              case '3rd':
                if (lottoNumber == winningNumber) match = true;
                break;
              case 'last3':
              case 'last2':
                if (lottoNumber.endsWith(winningNumber)) match = true;
                break;
            }

            if (match) claimed[p['prize_type']] = isClaimed;
          }
          return claimed;
        }
      }
    } catch (e) {
      print(e);
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("หวยที่ซื้อ"),
        backgroundColor: Colors.grey[200],
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.orange),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
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
              leading: const Icon(Icons.home),
              title: const Text("กลับหน้าโฮม"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(userId: widget.userId),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("ออกจากระบบ"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        ),
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
                      "หวยที่ซื้อ",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (purchasedLotto.isEmpty) const Text("ยังไม่มีการซื้อ"),
                    ...purchasedLotto.map((lotto) {
                      DateTime createdAt = DateTime.parse(
                        lotto["purchase_date"],
                      );
                      String formattedDate =
                          "${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}";

                      final status = claimedMap[lotto["lotto_number"]] ?? {};

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 6,
                        ),
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFAF0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              lotto["lotto_number"].toString(),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "วันที่ซื้อ: $formattedDate",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 10),
                            status.isEmpty
                                ? ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UsersPrizesPage(
                                            userId: widget.userId,
                                            initialNumber: lotto["lotto_number"]
                                                .toString(),
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                    ),
                                    icon: const Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      "ตรวจสอบรางวัล",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                : Column(
                                    children: status.entries.map((e) {
                                      return Text(
                                        e.value
                                            ? '${e.key} : ขึ้นเงินสำเร็จแล้ว'
                                            : '${e.key} : ตรวจสอบรางวัล',
                                        style: TextStyle(
                                          color: e.value
                                              ? Colors.green
                                              : Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
    );
  }
}
