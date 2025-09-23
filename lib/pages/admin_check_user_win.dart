import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';

class AdminCheckUserWinPage extends StatefulWidget {
  const AdminCheckUserWinPage({super.key});

  @override
  State<AdminCheckUserWinPage> createState() => _AdminCheckUserWinPageState();
}

class _AdminCheckUserWinPageState extends State<AdminCheckUserWinPage> {
  List<Map<String, dynamic>> userResults = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserWins();
  }

  Future<void> _fetchUserWins() async {
    try {
      final url = Uri.parse(
        "https://lotto-work.onrender.com/api/admin/user-prizes",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          userResults = data.map<Map<String, dynamic>>((user) {
            return {
              'username': user['username'],
              'prizes': user['prizes'], // List ของรางวัลจริง
            };
          }).toList();
          loading = false;
        });
      } else {
        throw Exception("โหลดข้อมูลไม่สำเร็จ");
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    }
  }

  Widget buildResultCard(Map<String, dynamic> user) {
    final username = user['username'] ?? '';
    final prizes = user['prizes'] ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: const Color(0xFFFFF6E5),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "คุณ : $username",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (prizes.isEmpty)
              const Text("ไม่ได้ถูกรางวัล")
            else
              for (var prize in prizes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    "ถูกรางวัล ${prize['prize_type']} จำนวน 1 รางวัล\nเงินรางวัล: ${prize['prize_amount'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} บาท",
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ตรวจผลการขึ้นรางวัล"),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
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
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : userResults.isEmpty
          ? const Center(child: Text("ไม่มีข้อมูลรางวัล"))
          : ListView.builder(
              itemCount: userResults.length,
              itemBuilder: (context, index) {
                return buildResultCard(userResults[index]);
              },
            ),
    );
  }
}
