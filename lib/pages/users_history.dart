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

  // แก้ไขเป็น String? เพื่อรองรับค่า null
  Map<String, String?> lottoResultMap =
      {}; // key: lottoNumber, value: ข้อความผลลัพธ์

  @override
  void initState() {
    super.initState();
    fetchPurchasedLotto();
  }

  // fetchPurchasedLotto
  Future<void> fetchPurchasedLotto() async {
    setState(() => loading = true);
    try {
      final response = await http.get(
        Uri.parse("https://lotto-work.onrender.com/api/admin/user-prizes"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;

        // หาเฉพาะ user ของ current user
        final currentUserData = data.firstWhere(
          (u) => u['user_id'] == widget.userId,
          orElse: () => null,
        );

        if (currentUserData != null) {
          List<dynamic> prizes = currentUserData['prizes'] ?? [];

          // สร้าง purchasedLotto list จาก prizes
          setState(() {
            purchasedLotto = prizes.map((p) {
              return {
                "lotto_number":
                    p['winning_number'] ?? "", // หรือเลขที่ซื้อถ้ามี
                "claimed": p['claimed'] ?? false,
                "purchase_date":
                    p['purchase_date'] ?? DateTime.now().toIso8601String(),
              };
            }).toList();

            lottoResultMap = {
              for (var item in purchasedLotto)
                item['lotto_number']: item['claimed']
                    ? "✅ ถูกรางวัลแล้ว"
                    : null,
            };
          });
        } else {
          setState(() => purchasedLotto = []);
        }
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() => loading = false);
    }
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

                      final lottoNumber = lotto["lotto_number"].toString();
                      final resultText = lottoResultMap[lottoNumber];

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
                              lottoNumber,
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
                            resultText == null
                                ? ElevatedButton.icon(
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UsersPrizesPage(
                                            userId: widget.userId,
                                            initialNumber: lottoNumber,
                                          ),
                                        ),
                                      );

                                      if (result != null && result is String) {
                                        setState(() {
                                          lottoResultMap[lottoNumber] = result;
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
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
                                : Text(
                                    resultText,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: resultText.contains("ถูกรางวัล")
                                          ? Colors.green
                                          : Colors.red,
                                    ),
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
