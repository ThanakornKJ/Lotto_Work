import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';
import 'users_wallets.dart';

class UsersCatchTheLottery extends StatefulWidget {
  final String userId;
  final String checkedNumber; // ✅ เพิ่มเลขที่ผู้ใช้กรอก

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

  // ดึงรางวัลของผู้ใช้
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
          setState(() {
            winningTickets = prizes;
          });
        }
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() => loading = false);
    }
  }

  // ขึ้นเงินรางวัล
  Future<void> claimPrize(int amount) async {
    try {
      // ดึง wallet ปัจจุบัน
      final walletRes = await http.get(
        Uri.parse('http://lotto-work.onrender.com/wallet/${widget.userId}'),
      );
      if (walletRes.statusCode != 200) return;
      final wallet = json.decode(walletRes.body);
      final currentBalance = wallet['balance'] as int;

      // อัปเดต wallet
      final updateRes = await http.put(
        Uri.parse('http://lotto-work.onrender.com/wallet/${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'balance': currentBalance + amount}),
      );

      if (updateRes.statusCode == 200) {
        // แสดง Popup
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('ขึ้นเงินรางวัลเรียบร้อย'),
            content: Text('จำนวนเงิน: $amount บาท'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ตกลง'),
              ),
            ],
          ),
        );

        // ไปหน้า Wallet
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => UsersWalletsPage(userId: widget.userId),
          ),
        );
      }
    } catch (e) {
      print(e);
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
          ? const Center(child: Text('ไม่มีรางวัลที่ถูก'))
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
                          claimPrize(ticket['prize_amount'] as int),
                      child: const Text('ขึ้นเงิน'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
