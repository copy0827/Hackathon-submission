import 'package:flutter/material.dart';

class WalletRegisterPage extends StatefulWidget {
  const WalletRegisterPage({Key? key}) : super(key: key);

  @override
  State<WalletRegisterPage> createState() => _WalletRegisterPageState();
}

class _WalletRegisterPageState extends State<WalletRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _privateKeyController = TextEditingController();

  bool _isObscured = true; // 개인키 숨김 토글용

  @override
  void dispose() {
    _addressController.dispose();
    _privateKeyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final address = _addressController.text.trim();
      final privateKey = _privateKeyController.text.trim();

      // 지갑 등록 완료 후 이전 페이지로 데이터 전달
      Navigator.pop(context, {
        'address': address,
        'privateKey': privateKey,
      });
    }
  }

  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return '지갑 주소를 입력하세요';
    }

    return null;
  }

  String? _validatePrivateKey(String? value) {
    if (value == null || value.isEmpty) {
      return '개인키를 입력하세요';
    }
    // 추가 검증 가능 (예: 64자리 16진수 등)
    if (value.length != 64) {
      return '개인키는 64자리여야 합니다';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('지갑 등록'),
        backgroundColor: const Color(0xFF006D77),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFEDF6F9),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                '지갑 주소와 개인키를 입력해주세요.',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF006D77),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              // 지갑 주소 입력
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: '지갑 주소',
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: _validateAddress,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // 개인키 입력
              TextFormField(
                controller: _privateKeyController,
                obscureText: _isObscured,
                decoration: InputDecoration(
                  labelText: '개인키',
                  prefixIcon: const Icon(Icons.vpn_key),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: _validatePrivateKey,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 40),

              // 제출 버튼
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006D77),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '지갑 등록',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
