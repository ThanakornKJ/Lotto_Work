import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';

class AdminLottoUnsoldPage extends StatefulWidget {
  const AdminLottoUnsoldPage({super.key});

  @override
  State<AdminLottoUnsoldPage> createState() => _AdminLottoUnsoldPageState();
}

class _AdminLottoUnsoldPageState extends State<AdminLottoUnsoldPage> {
  List<String> unsoldLottos = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUnsoldLottos();
  }

  Future<void> _fetchUnsoldLottos() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(
      'http://192.168.88.98:5000/lotteries',
    ); // แก้ IP ให้ตรง server

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          unsoldLottos = data
              .map<String>((lot) => lot['number'] as String)
              .toList();
        });
      } else {
        print('Failed to fetch lotteries: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

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
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : unsoldLottos.isEmpty
                ? const Center(child: Text("ไม่มีลอตเตอรี่ที่ยังไม่ขาย"))
                : ListView.builder(
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
                        child: Text(
                          unsoldLottos[index],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
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
