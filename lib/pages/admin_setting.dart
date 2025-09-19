import 'package:flutter/material.dart';
import 'package:lotto/pages/login_page.dart';
import 'package:http/http.dart' as http; // เพิ่มนี้

class AdminSettingPage extends StatelessWidget {
  const AdminSettingPage({super.key});

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Image.asset("assets/images/lotto_logo.png", height: 120),
            const SizedBox(height: 10),
            const Text(
              "Setting",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 40,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                _showConfirmDialog(context);
              },
              child: Column(
                children: const [
                  Icon(Icons.sync, size: 50, color: Colors.white),
                  SizedBox(height: 5),
                  Text(
                    "รีเซ็ตระบบใหม่ทั้งหมด",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text("คุณแน่ใจว่าจะรีเซ็ตระบบใหม่หรือไม่"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);

              final url = Uri.parse('http://YOUR_SERVER_IP:5000/reset-system');
              try {
                final response = await http.post(url);
                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('รีเซ็ตระบบเรียบร้อยแล้ว')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('รีเซ็ตระบบล้มเหลว: ${response.body}'),
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
              }
            },
            child: const Text("ตกลง"),
          ),
        ],
      ),
    );
  }
}
