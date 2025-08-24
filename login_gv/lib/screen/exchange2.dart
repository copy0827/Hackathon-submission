import 'package:flutter/material.dart';

class ZrcConversionPage extends StatefulWidget {
  final double zrcBalance;
  final String userAddress;
  final String privateKey;

  const ZrcConversionPage({
    Key? key,
    required this.zrcBalance,
    required this.userAddress,
    required this.privateKey,
  }) : super(key: key);

  @override
  _ZrcConversionPageState createState() => _ZrcConversionPageState();
}

class _ZrcConversionPageState extends State<ZrcConversionPage> {
  final _amountController = TextEditingController();
  final _addressController = TextEditingController();
  final _privateKeyController = TextEditingController();

  String _selectedChain = 'bitcoin';
  String _message = '';
  bool _isLoading = false;
  late double _currentBalance;

  final Map<String, String> chains = {
    'bitcoin': 'Bitcoin (BTC)',
    'ethereum': 'Ethereum (ETH)',
    'dogecoin': 'Dogecoin (DOGE)',
  };

  @override
  void initState() {
    super.initState();

    // zrcBalance가 0이거나 음수면 기본값으로 10.0 설정
    _currentBalance = widget.zrcBalance <= 0 ? 10.0 : widget.zrcBalance;

    _addressController.text = widget.userAddress;
    _privateKeyController.text = widget.privateKey;
  }

  void _handleConvertMock() {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      setState(() {
        _message = '유효한 금액을 입력하세요.';
      });
      return;
    }

    if (amount > _currentBalance) {
      setState(() {
        _message = '잔액보다 많은 금액은 변환할 수 없습니다.';
      });
      return;
    }

    if (_addressController.text.trim().isEmpty || _privateKeyController.text.trim().isEmpty) {
      setState(() {
        _message = '주소와 개인키를 입력하세요.';
      });
      return;
    }

    // 하드코딩된 변환 처리 (서버 요청 없이 로컬 잔액만 수정)
    setState(() {
      _currentBalance -= amount;
      _message = '변환이 성공적으로 완료되었습니다.';
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _addressController.dispose();
    _privateKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZRC-20 토큰 변환'),
        backgroundColor: const Color(0xFF006D77),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '잔액: $_currentBalance ZRC',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: '변환할 양',
                hintText: '0.0',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedChain,
              items: chains.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedChain = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: '변환 대상 체인',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: '받을 주소',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _privateKeyController,
              decoration: const InputDecoration(
                labelText: '개인키',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleConvertMock,
              child: const Text('변환 요청'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: const Color(0xFF006D77),
              ),
            ),
            if (_message.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                _message,
                style: TextStyle(
                  color: _message.contains('성공') ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ]
          ],
        ),
      ),
    );
  }
}
