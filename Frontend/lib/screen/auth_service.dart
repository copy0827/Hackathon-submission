import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: '124416418762-mdtfkf1ijtogkb0j1uu9rrnibg6rb4ug.apps.googleusercontent.com', // 실제 클라이언트 ID 입력
);

class AuthService {
  final String baseUrl = 'https://172.25.75.35'; // 실제 서버 주소

  // 구글 로그인
  Future<bool> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': idToken}),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', idToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 게스트 로그인 (아이디/비밀번호 방식)
  Future<bool> signInGuestWithIdPassword(String id, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/guest/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final guestToken = data['guest_token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', guestToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 게스트 로그인 (토큰만 발급받기)
  Future<bool> signInAsGuest() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/guest'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final guestToken = data['guest_token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', guestToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_token');
    await _googleSignIn.signOut();
  }

  // 환전 PATCH + 최신 잔액 GET
  Future<double?> exchangeCurrency(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');

    final patchUrl = Uri.parse('$baseUrl/exchange');
    final getBalanceUrl = Uri.parse('$baseUrl/balance');

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    // PATCH 환전 요청
    final patchResponse = await http.patch(
      patchUrl,
      headers: headers,
      body: jsonEncode({'symbol': symbol}),
    );

    if (patchResponse.statusCode == 200) {
      // GET 최신 잔액 요청
      final getResponse = await http.get(getBalanceUrl, headers: headers);

      if (getResponse.statusCode == 200) {
        final data = jsonDecode(getResponse.body);
        return (data['zrcBalance'] as num).toDouble();
      } else {
        throw Exception('잔액을 불러오지 못했습니다.');
      }
    } else {
      throw Exception('환전 요청 실패: ${patchResponse.statusCode}');
    }
  }
}
