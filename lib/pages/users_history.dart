import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';
import 'users_home.dart'; // ✅ import หน้า HomePage

class UserHistoryPage extends StatefulWidget {
  final String userId;

  const UserHistoryPage({super.key, required this.userId});

  @override
  State<UserHistoryPage> createState() => _UserHistoryPageState();
}

class _UserHistoryPageState extends State<UserHistoryPage> {
  bool loading = true;
  List<dynamic> purchasedLotto = [];

  @override
  void initState() {
    super.initState();
    fetchPurchasedLotto();
  }

  Future<void> fetchPurchasedLotto() async {
    try {
      print("Fetching purchases for userId: ${widget.userId}");
      final response = await http.get(
        Uri.parse("https://lotto-work.onrender.com/purchased/${widget.userId}"),
      );
      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          purchasedLotto = data["purchases"]; // ✅ ใส่ตรงนี้
          loading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
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

      // ✅ Drawer เมนูสามขีด
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
                        child: Text(
                          lotto["lotto_number"].toString(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
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
