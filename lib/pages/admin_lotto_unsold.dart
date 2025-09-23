import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminLottoUnsoldPage extends StatefulWidget {
  final String? keyword; // สำหรับค้นหา
  const AdminLottoUnsoldPage({super.key, this.keyword});

  @override
  State<AdminLottoUnsoldPage> createState() => _AdminLottoUnsoldPageState();
}

class _AdminLottoUnsoldPageState extends State<AdminLottoUnsoldPage> {
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

        // ✅ กรองตาม keyword ถ้ามี
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

  // ✅ highlight keyword
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
            color: Colors.red,
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
                  child: highlightText(lotto['number'], widget.keyword),
                );
              },
            ),
    );
  }
}
