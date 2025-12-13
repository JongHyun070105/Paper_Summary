import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_paper_summary/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  Map<String, String?> _userInfo = {};

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() {
    setState(() {
      _userInfo = _authService.getUserInfo();
    });
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E24),
          title: const Text('로그아웃', style: TextStyle(color: Colors.white)),
          content: const Text(
            '정말 로그아웃하시겠습니까?',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _authService.signOut();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/onboarding');
                }
              },
              child: const Text(
                '로그아웃',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '프로필',
                style: Theme.of(
                  context,
                ).textTheme.displayLarge?.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: _userInfo['photoURL'] != null
                        ? NetworkImage(_userInfo['photoURL']!)
                        : null,
                    child: _userInfo['photoURL'] == null
                        ? const Icon(
                            LucideIcons.user,
                            size: 40,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userInfo['displayName'] ?? 'User',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _userInfo['email'] ?? 'user@example.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              _buildStatItem(context, '읽은 논문', '12'),
              const SizedBox(height: 20),
              _buildStatItem(context, '이번 주 학습 시간', '4h 30m'),
              const SizedBox(height: 40),
              const Divider(color: Colors.white10),
              ListTile(
                leading: Icon(
                  LucideIcons.fileText,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                title: Text(
                  '내 논문',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/my-papers');
                },
              ),
              ListTile(
                leading: Icon(
                  LucideIcons.bookmark,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                title: Text(
                  '북마크',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  // TODO: 북마크 화면으로 이동
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('북마크 기능은 준비 중입니다')),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  LucideIcons.settings,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                title: Text(
                  '설정',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              ListTile(
                leading: const Icon(
                  LucideIcons.logOut,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  '로그아웃',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: _handleLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
