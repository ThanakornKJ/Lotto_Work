import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'users_purchases.dart';

class UsersLottoUnsoldPage extends StatefulWidget {
  final String userId;
  final String? keyword; // ✅ เพิ่ม keyword สำหรับ search

  const UsersLottoUnsoldPage({super.key, required this.userId, this.keyword});

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
        Uri.parse('https://lotto-work.onrender.com/lotteries'),
      );
      if (response.statusCode == 200) {
        List<dynamic> allLottos = json.decode(response.body);

        // ✅ partial match filter
        if (widget.keyword != null && widget.keyword!.isNotEmpty) {
          allLottos = allLottos.where((lotto) {
            return lotto['number'].toString().contains(widget.keyword!);
          }).toList();
        }

        setState(() {
          unsoldLottos = allLottos;
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

  // ✅ ฟังก์ชัน highlight keyword
  Widget highlightText(String text, String? keyword) {
    if (keyword == null || keyword.isEmpty) {
      return Text(
        text,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      );
    }

    List<TextSpan> spans = [];
    int start = 0;
    int index;

    while ((index = text.indexOf(keyword, start)) != -1) {
      if (index > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, index),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        );
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + keyword.length),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.red, // ✅ highlight สีแดง
          ),
        ),
      );

      start = index + keyword.length;
    }

    if (start < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(start),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.keyword != null && widget.keyword!.isNotEmpty
              ? "ผลการค้นหา: ${widget.keyword}"
              : "ลอตเตอรี่ที่ยังไม่ขาย",
        ),
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
                      highlightText(lotto['number'], widget.keyword),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UsersPurchasesPage(
                                lottoNumber: lotto['number'],
                                lottoPrice: lotto['price'],
                                lottoId: lotto['lotto_id'],
                                userId: widget.userId,
                              ),
                            ),
                          );

                          if (result == true) {
                            setState(() {
                              unsoldLottos.removeAt(index);
                            });
                          }
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
