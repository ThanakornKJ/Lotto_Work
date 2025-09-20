import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'users_purchases.dart';

class UsersLottoUnsoldPage extends StatefulWidget {
  final String userId; // ✅ รับ userId จากหน้า HomePage
  const UsersLottoUnsoldPage({super.key, required this.userId});

  @override
  State<UsersLottoUnsoldPage> createState() => _UsersLottoUnsoldPageState();
}

class _UsersLottoUnsoldPageState extends State<UsersLottoUnsoldPage> {
  List<dynamic> unsoldLottos = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchUnsoldLottos();
  }

  Future<void> fetchUnsoldLottos() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.160.2.131:5000/lotteries'),
      );
      if (response.statusCode == 200) {
        setState(() {
          unsoldLottos = json.decode(response.body);
          loading = false;
        });
      } else {
        throw Exception('Failed to load lotteries');
      }
    } catch (e) {
      print(e);
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ลอตเตอรี่ที่ยังไม่ขาย"),
        backgroundColor: Colors.grey[200],
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : unsoldLottos.isEmpty
          ? const Center(child: Text("ไม่มีล็อตเตอรี่เหลือขาย"))
          : ListView.builder(
              itemCount: unsoldLottos.length,
              itemBuilder: (context, index) {
                final lotto = unsoldLottos[index];
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        lotto['number'],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UsersPurchasesPage(
                                lottoNumber: lotto['number'],
                                lottoPrice: lotto['price'],
                                lottoId: lotto['lotto_id'],
                                userId: widget.userId, // ✅ ส่ง userId มาด้วย
                              ),
                            ),
                          );
                        },
                        child: const Text("Buy"),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
