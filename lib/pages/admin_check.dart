import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminCheckPage extends StatefulWidget {
  const AdminCheckPage({super.key});

  @override
  State<AdminCheckPage> createState() => _AdminCheckPageState();
}

class _AdminCheckPageState extends State<AdminCheckPage> {
  List<dynamic> purchases = [];
  double totalRevenue = 0;

  @override
  void initState() {
    super.initState();
    fetchPurchaseData();
  }

  Future<void> fetchPurchaseData() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.160.2.131:5000/api/admin/purchases"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          purchases = data;
          totalRevenue = purchases.fold(
            0,
            (sum, item) => sum + (item['totalAmount']?.toDouble() ?? 0),
          );
        });
      } else {
        throw Exception("Failed to load purchases");
      }
    } catch (e) {
      debugPrint("Error fetching purchases: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ตรวจสอบผู้ซื้อหวย")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // โลโก้
            Image.asset("assets/images/lotto_logo.png", height: 80),
            const SizedBox(height: 16),

            // ยอดเงินรวม
            const Text(
              "ยอดเงินรวม",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            Text(
              "${totalRevenue.toStringAsFixed(0)} บาท",
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // รายการผู้ซื้อ
            Expanded(
              child: purchases.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: purchases.length,
                      itemBuilder: (context, index) {
                        final item = purchases[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          color: Colors.orange.shade50,
                          child: ListTile(
                            title: Text(
                              "คุณ : ${item['username'] ?? 'ไม่ทราบชื่อ'}",
                            ),
                            subtitle: Text(
                              "ซื้อหวย ${item['totalSets'] ?? 0} ชุด เป็นเงิน ${item['totalAmount'] ?? 0} บาท",
                              style: const TextStyle(fontSize: 14),
                            ),
                            trailing: const Icon(Icons.expand_more),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
