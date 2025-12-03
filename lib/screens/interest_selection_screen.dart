import 'package:flutter/material.dart';

class InterestSelectionScreen extends StatefulWidget {
  const InterestSelectionScreen({super.key});

  @override
  State<InterestSelectionScreen> createState() =>
      _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen> {
  final List<String> _interests = [
    '인공지능',
    '머신러닝',
    '컴퓨터 비전',
    '자연어 처리',
    '로보틱스',
    '양자 컴퓨팅',
    '블록체인',
    '사이버 보안',
    '데이터 사이언스',
    '사물인터넷',
    '바이오테크',
    '뇌과학',
  ];

  final Set<String> _selectedInterests = {};

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                '어떤 분야에\n관심이 있으신가요?',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 38,
                  height: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '관심사를 선택하시면 맞춤형 논문을 추천해 드립니다.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[400],
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _interests.map((interest) {
                    final isSelected = _selectedInterests.contains(interest);
                    return GestureDetector(
                      onTap: () => _toggleInterest(interest),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : const Color(0xFF1E1E24),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.white10,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Text(
                          interest,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedInterests.isNotEmpty
                      ? () {
                          Navigator.pushReplacementNamed(
                            context,
                            '/main',
                            arguments: _selectedInterests.toList(),
                          );
                        }
                      : null,
                  style:
                      ElevatedButton.styleFrom(
                        backgroundColor: _selectedInterests.isNotEmpty
                            ? Theme.of(context).primaryColor
                            : Colors.grey[800],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        shadowColor: _selectedInterests.isNotEmpty
                            ? Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.3)
                            : Colors.transparent,
                      ).copyWith(
                        elevation: MaterialStateProperty.resolveWith<double>((
                          Set<MaterialState> states,
                        ) {
                          if (states.contains(MaterialState.disabled)) {
                            return 0;
                          }
                          return 8;
                        }),
                      ),
                  child: const Text(
                    '계속하기',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
