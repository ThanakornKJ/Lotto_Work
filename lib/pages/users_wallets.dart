import 'package:flutter/material.dart';
import 'login_page.dart';

class UsersWalletsPage extends StatefulWidget {
  const UsersWalletsPage({super.key});

  @override
  State<UsersWalletsPage> createState() => _UsersWalletsPageState();
}

class _UsersWalletsPageState extends State<UsersWalletsPage> {
  double balance = 500; // mock ค่าคงเหลือ
  final TextEditingController depositController = TextEditingController();
  final TextEditingController withdrawController = TextEditingController();

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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 30),
              // โลโก้
              Image.asset("assets/images/lotto_logo.png", height: 100),
              const SizedBox(height: 10),
              const Text(
                "ตรวจสอบยอดเงิน",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // การ์ดแสดงยอดคงเหลือ
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

              // ช่องกรอก + ปุ่ม เติมเงิน
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
                        if (depositController.text.isNotEmpty) {
                          setState(() {
                            balance +=
                                double.tryParse(depositController.text) ?? 0;
                          });
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

              // ช่องกรอก + ปุ่ม ถอนเงิน
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
                        if (withdrawController.text.isNotEmpty) {
                          setState(() {
                            balance -=
                                double.tryParse(withdrawController.text) ?? 0;
                            if (balance < 0) balance = 0;
                          });
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
