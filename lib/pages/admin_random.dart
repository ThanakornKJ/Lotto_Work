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
  List<Map<String, dynamic>> lotteries = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchLotteries(); // โหลดเลขล็อตโต้ตั้งแต่เปิดหน้า
  }

  Future<void> _fetchLotteries() async {
    setState(() => isLoading = true);
    final url = Uri.parse('https://lotto-work.onrender.com/lotteries');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // data อาจเป็น List ตรง ๆ
        setState(() {
          lotteries = List<Map<String, dynamic>>.from(data);
        });
      } else {
        print('Failed to fetch lotteries: ${response.statusCode}');
      }
    } catch (e) {
      print('Error _fetchLotteries: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _generateLotteries() async {
    setState(() => isLoading = true);
    final url = Uri.parse('https://lotto-work.onrender.com/generate-lotteries');

    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // ตรวจสอบว่า data เป็น Map และมี key 'lotteries'
        if (data['lotteries'] != null) {
          setState(() {
            lotteries = List<Map<String, dynamic>>.from(data['lotteries']);
          });
        } else {
          print('Response ไม่ตรงรูปแบบ: $data');
        }
      } else {
        print('Failed to generate lotteries: ${response.statusCode}');
      }
    } catch (e) {
      print('Error _generateLotteries: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<String> getNumbers() {
    return lotteries.map<String>((lot) => lot['number'] as String).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.orange),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
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
                    : const Text("สุ่มเลขล็อตโต้"),
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminResultPage(allNumbers: lotteries),
                    ),
                  );
                },

                child: const Text("ไปหน้าสุ่มรางวัล"),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Expanded(
            child: lotteries.isEmpty
                ? const Center(child: Text("ยังไม่มีเลขล็อตโต้"))
                : ListView.builder(
                    itemCount: lotteries.length,
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
                              lotteries[index]['number'],
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
