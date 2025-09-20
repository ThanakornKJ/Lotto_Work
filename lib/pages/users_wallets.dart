import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';

class UsersWalletsPage extends StatefulWidget {
  final String userId; // รับ user_id จากหน้า login
  const UsersWalletsPage({super.key, required this.userId});

  @override
  State<UsersWalletsPage> createState() => _UsersWalletsPageState();
}

class _UsersWalletsPageState extends State<UsersWalletsPage> {
  double balance = 0;
  bool loading = true;

  final TextEditingController depositController = TextEditingController();
  final TextEditingController withdrawController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchWallet();
  }

  Future<void> fetchWallet() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.160.2.131:5000/wallet/${widget.userId}'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          balance = data['balance'].toDouble();
          loading = false;
        });
      } else {
        setState(() => loading = false);
        throw Exception('Failed to fetch wallet');
      }
    } catch (e) {
      print(e);
      setState(() => loading = false);
    }
  }

  Future<void> updateWallet(double amount, bool isDeposit) async {
    try {
      final newBalance = isDeposit ? balance + amount : balance - amount;
      if (newBalance < 0) return;

      final response = await http.put(
        Uri.parse('http://10.160.2.131:5000/wallet/${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'balance': newBalance}),
      );

      if (response.statusCode == 200) {
        setState(() {
          balance = newBalance;
        });
      } else {
        throw Exception('Failed to update wallet');
      }
    } catch (e) {
      print(e);
    }
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
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
        backgroundColor: Colors.grey[200],
        elevation: 0,
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
                      "ตรวจสอบยอดเงิน",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 60,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFAF0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "ยอดเงินคงเหลือ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            balance.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ฝากเงิน
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: depositController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "ใส่จำนวนเงิน :",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                filled: true,
                                fillColor: Colors.grey[200],
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              final amount = double.tryParse(
                                depositController.text,
                              );
                              if (amount != null && amount > 0) {
                                updateWallet(amount, true);
                                depositController.clear();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("ฝากเงิน"),
                          ),
                        ],
                      ),
                    ),

                    // ถอนเงิน
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: withdrawController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "ใส่จำนวนเงิน :",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                filled: true,
                                fillColor: Colors.grey[200],
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              final amount = double.tryParse(
                                withdrawController.text,
                              );
                              if (amount != null &&
                                  amount > 0 &&
                                  amount <= balance) {
                                updateWallet(amount, false);
                                withdrawController.clear();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("ถอนเงิน"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
