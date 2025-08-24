import 'package:flutter/material.dart';

// 후보자 모델 클래스
class Candidate {
  final int id;
  final String name;
  final String pledge;

  const Candidate({
    required this.id,
    required this.name,
    required this.pledge,
  });
}

// ✅ VotePage - 후보자 목록 화면
class VotePage extends StatelessWidget {
  const VotePage({Key? key}) : super(key: key);

  final List<Candidate> candidates = const [
    Candidate(
      id: 1,
      name: '홍길동',
      pledge: '''
- 교육 환경 개선
  • 최신 교육 기자재 지원 확대
  • 교사 처우 개선 및 연수 강화

- 복지 확대
  • 저소득층 아동 무상급식 지원
  • 노인 복지센터 시설 확충 및 프로그램 다양화
''',
    ),
    Candidate(
      id: 2,
      name: '김철수',
      pledge: '''
- 청년 일자리 창출
  • 스타트업 지원 펀드 조성
  • 직무 교육 프로그램 활성화

- 경제 활성화
  • 지역 소상공인 세제 혜택 확대
  • 친환경 산업 투자 지원 강화
''',
    ),
    Candidate(
      id: 3,
      name: '이영희',
      pledge: '''
- 환경 보호 강화
  • 플라스틱 사용 규제 강화 및 재활용 확대
  • 도시 녹지 공간 조성 확대

- 친환경 정책 추진
  • 신재생 에너지 보급 확대
  • 탄소 배출 저감 정책 시행
''',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF6F9),
      appBar: AppBar(
        title: const Text(
          '투표하기',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: const Color(0xFF006D77),
        elevation: 2,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: candidates.length,
        itemBuilder: (context, index) {
          final candidate = candidates[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              title: Text(
                candidate.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006D77),
                ),
              ),
              subtitle: Text(
                'ID: ${candidate.id}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF006D77)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PledgePage(candidate: candidate),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ✅ PledgePage - 공약 보기 및 투표 버튼 포함 (ZRC 없음)
class PledgePage extends StatefulWidget {
  final Candidate candidate;

  const PledgePage({Key? key, required this.candidate}) : super(key: key);

  @override
  State<PledgePage> createState() => _PledgePageState();
}

class _PledgePageState extends State<PledgePage> {
  bool hasVoted = false;

  void _vote() {
    if (!hasVoted) {
      setState(() {
        hasVoted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.candidate.name}에게 투표 완료! (ZRC 10개 지급됨)'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF6F9),
      appBar: AppBar(
        title: Text(
          '${widget.candidate.name}의 공약',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: const Color(0xFF006D77),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 6,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  widget.candidate.pledge,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF006D77),
                    height: 1.8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: hasVoted ? null : _vote,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006D77),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(
                hasVoted ? '투표 완료' : '투표하기',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
