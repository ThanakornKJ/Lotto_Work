import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';
import 'users_home.dart';
import 'users_prizes.dart';

class UserHistoryPage extends StatefulWidget {
  final String userId;

  const UserHistoryPage({super.key, required this.userId});

  @override
  State<UserHistoryPage> createState() => _UserHistoryPageState();
}

class _UserHistoryPageState extends State<UserHistoryPage> {
  bool loading = true;
  List<dynamic> purchasedLotto = [];
  Map<String, String?> lottoResultMap =
      {}; // key: lottoNumber, value: ข้อความผลลัพธ์
  Map<String, String> purchaseIdMap =
      {}; // key: lottoNumber, value: purchase_id

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => loading = true);
    await fetchPurchasedLotto();
    await fetchLottoResults();
    setState(() => loading = false);
  }

  // โหลดหวยที่ซื้อ
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
        purchasedLotto = purchases;

        purchaseIdMap.clear();
        for (var item in purchases) {
          purchaseIdMap[item["lotto_number"].toString()] = item["purchase_id"];
        }
      }
    } catch (e) {
      print("Error fetchPurchasedLotto: $e");
    }
  }

  // โหลดผลรางวัลที่มีอยู่แล้ว (รวมเลขที่ตรวจแล้วไม่ถูกรางวัล)
  Future<void> fetchLottoResults() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://lotto-work.onrender.com/user/${widget.userId}/prizes",
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        lottoResultMap.clear();
        for (var item in data) {
          final lottoNumber = item["lotto_number"];
          if (item["prize_type"] != null) {
            lottoResultMap[lottoNumber] = "ถูกรางวัล ${item["prize_type"]}";
          } else if (item["claimed_no_prize"] == true) {
            lottoResultMap[lottoNumber] = "ไม่ถูกรางวัล";
          } else {
            lottoResultMap[lottoNumber] = null; // ยังไม่ตรวจ
          }
        }
      }
    } catch (e) {
      print("Error fetchLottoResults: $e");
    }
  }

  // บันทึกว่าเช็คแล้วแต่ไม่ถูกรางวัล
  Future<void> markNoPrize(String purchaseId) async {
    try {
      await http.post(
        Uri.parse('https://lotto-work.onrender.com/claim-no-prize'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': widget.userId,
          'purchase_id': purchaseId,
        }),
      );
    } catch (e) {
      print("Error markNoPrize: $e");
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
                      final purchaseId = purchaseIdMap[lottoNumber];

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
                            (resultText == null)
                                ? ElevatedButton.icon(
                                    onPressed: () async {
                                      // เปิดหน้า UsersPrizesPage
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
                                      } else if (purchaseId != null) {
                                        // ถ้าไม่ถูกรางวัล → บันทึกลง server
                                        await markNoPrize(purchaseId);
                                        await fetchLottoResults();
                                        setState(() {});
                                      }
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
