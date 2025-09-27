import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';
import 'users_wallets.dart';

class UsersCatchTheLottery extends StatefulWidget {
  final String userId;
  final String checkedNumber; // เลขที่ผู้ใช้กรอก

  const UsersCatchTheLottery({
    super.key,
    required this.userId,
    required this.checkedNumber,
  });

  @override
  State<UsersCatchTheLottery> createState() => _UsersCatchTheLotteryState();
}

class _UsersCatchTheLotteryState extends State<UsersCatchTheLottery> {
  bool loading = true;
  List<Map<String, dynamic>> winningTickets = [];

  @override
  void initState() {
    super.initState();
    fetchWinningTickets();
  }

  // ดึงรางวัลของผู้ใช้และ filter เฉพาะรางวัลที่ตรงเลข
  Future<void> fetchWinningTickets() async {
    setState(() => loading = true);
    try {
      final response = await http.get(
        Uri.parse('http://lotto-work.onrender.com/api/admin/user-prizes'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;

        final userData = data.firstWhere(
          (u) => u['user_id'] == widget.userId,
          orElse: () => null,
        );

        if (userData != null) {
          List<Map<String, dynamic>> prizes = [];
          for (var p in userData['prizes']) {
            if (p['prize_amount'] > 0 && p['winning_number'] != null) {
              bool match = false;
              switch (p['prize_type']) {
                case '1st':
                case '2nd':
                case '3rd':
                  if (widget.checkedNumber == p['winning_number']) match = true;
                  break;
                case 'last3':
                case 'last2':
                  if (widget.checkedNumber.endsWith(p['winning_number']))
                    match = true;
                  break;
              }
              if (match) {
                prizes.add({
                  'prize_type': p['prize_type'],
                  'prize_amount': p['prize_amount'],
                });
              }
            }
          }
          setState(() => winningTickets = prizes);
        }
      } else {
        print('Error fetching prizes: ${response.body}');
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() => loading = false);
    }
  }

  // ขึ้นเงินรางวัล
  Future<void> claimPrize(String prizeType) async {
    try {
      print('Claiming prize $prizeType for user ${widget.userId}');
      final client = http.Client();
      final response = await client.post(
        Uri.parse('https://lotto-work.onrender.com/claim-prize'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': widget.userId, 'prize_type': prizeType}),
      );

      print('Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newBalance = data['balance'];

        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('ขึ้นเงินรางวัลเรียบร้อย'),
            content: Text('จำนวนเงิน: $newBalance บาท'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ตกลง'),
              ),
            ],
          ),
        );

        // ลบรางวัลที่เพิ่งขึ้นเงินออกจากหน้าจอ
        setState(() {
          winningTickets.removeWhere((t) => t['prize_type'] == prizeType);
        });

        // ถ้าอยากกลับหน้า Wallet ก็ยังสามารถทำได้
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => UsersWalletsPage(userId: widget.userId),
        //   ),
        // );
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('ไม่สามารถขึ้นเงินได้'),
            content: Text('Error: ${response.body}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ตกลง'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Exception: $e');
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('เกิดข้อผิดพลาด'),
          content: Text('$e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ตกลง'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ขึ้นรางวัลหวย'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : winningTickets.isEmpty
          ? const Center(child: Text('ไม่มีรางวัลที่ตรงกับเลขที่ตรวจสอบ'))
          : ListView.builder(
              itemCount: winningTickets.length,
              itemBuilder: (context, index) {
                final ticket = winningTickets[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: ListTile(
                    title: Text(
                      'รางวัล: ${ticket['prize_type']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('จำนวนเงิน: ${ticket['prize_amount']} บาท'),
                    trailing: ElevatedButton(
                      onPressed: () =>
                          claimPrize(ticket['prize_type'] as String),
                      child: const Text('ขึ้นเงิน'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
