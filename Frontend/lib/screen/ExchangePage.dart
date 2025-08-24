import 'package:flutter/material.dart';
import 'exchange2.dart';  // ZrcConversionPage가 여기 있다고 가정

class ExchangePage extends StatelessWidget {
  final double zrcBalance;
  final String userAddress;
  final String privateKey;

  const ExchangePage({
    super.key,
    required this.zrcBalance,
    required this.userAddress,
    required this.privateKey,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('환전하기'),
        backgroundColor: const Color(0xFF006D77),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFEDF6F9),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '잔액: $zrcBalance ZRC',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006D77),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '지갑 주소:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            Text(
              userAddress,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            Text(
              '개인키:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            Text(
              privateKey,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ZrcConversionPage(
                        zrcBalance: zrcBalance,
                        userAddress: userAddress,
                        privateKey: privateKey,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF40907F),
                  padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 64),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  '환전 시작',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
