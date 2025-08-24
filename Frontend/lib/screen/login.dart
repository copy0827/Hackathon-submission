import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'wallet.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();

  Future<void> _navigateToWalletAndHome() async {
    final walletResult = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WalletRegisterPage()),
    );

    if (walletResult != null && walletResult is Map<String, String>) {
      final userAddress = walletResult['address'] ?? '';
      final privateKey = walletResult['privateKey'] ?? '';
      final zrcBalance = 0.0; // 초기 잔액 설정

      // 지갑 등록이 완료되면 홈 화면으로 이동 (데이터 전달)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Home(
            zrcBalance: zrcBalance,
            userAddress: userAddress,
            privateKey: privateKey,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상단 아이콘
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.teal[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.how_to_vote,
                  size: 80,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 32),

              // Google 로그인 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.g_mobiledata, color: Colors.white),
                  label: const Text(
                    'Google로 로그인',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  onPressed: _handleGoogleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 게스트 로그인 버튼
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.person_outline),
                  label: const Text(
                    '게스트로 시작하기',
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: _handleGuestLogin,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.teal[700],
                    side: BorderSide(color: Colors.teal.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleLogin() async {
    final success = await _authService.signInWithGoogle();
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google 로그인 실패')),
      );
      return;
    }

    await _navigateToWalletAndHome();
  }

  Future<void> _handleGuestLogin() async {
    await _navigateToWalletAndHome();
  }
}
