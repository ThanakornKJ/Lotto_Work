import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lotto/pages/admin_result.dart';
import 'package:lotto/pages/login_page.dart';

class AdminRandomPage extends StatefulWidget {
  const AdminRandomPage({super.key});

  @override
  State<AdminRandomPage> createState() => _AdminRandomPageState();
}

class _AdminRandomPageState extends State<AdminRandomPage> {
  List<String> numbers = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _generateLotteries(); // โหลดเลขทันทีตอนเข้า
  }

  Future<void> _generateLotteries() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(
      'http://192.168.88.98:5000/generate-lotteries',
    ); // แก้ IP ให้ตรง server

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> lotteries = data['lotteries'];

        setState(() {
          numbers = lotteries
              .map<String>((lot) => lot['number'] as String)
              .toList();
        });
      } else {
        print('Failed to generate lotteries: ${response.body}');
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
          Center(
            child: Column(
              children: [
                Image.asset("assets/images/lotto_logo.png", height: 80),
                const SizedBox(height: 10),
                const Text(
                  "รายการเลขล็อตโต้ 100 ชุด",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ปุ่มสุ่มใหม่ + ไปหน้าผลรางวัล
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: _generateLotteries,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("สุ่มใหม่อีกครั้ง"),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: numbers.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AdminResultPage(numbers: numbers),
                          ),
                        );
                      },
                child: const Text("ไปหน้าสุ่มรางวัล"),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // แสดงชุดตัวเลข
          Expanded(
            child: numbers.isEmpty
                ? const Center(child: Text("ยังไม่มีเลขล็อตโต้"))
                : ListView.builder(
                    itemCount: numbers.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 6,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFAF0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "ชุดที่ ${index + 1} : ",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              numbers[index],
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
