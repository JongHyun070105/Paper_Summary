import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_paper_summary/services/theme_service.dart';
import 'package:flutter_paper_summary/services/user_preferences_service.dart';
import 'package:flutter_paper_summary/services/auth_service.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserPreferencesService _prefsService = UserPreferencesService();
  final AuthService _authService = AuthService();

  List<String> _userInterests = [];
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'ko';

  final List<String> _availableInterests = [
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

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final interests = await _prefsService.getInterests();
    final notifications = await _prefsService.getNotificationsEnabled();
    final language = await _prefsService.getLanguage();

    setState(() {
      _userInterests = interests;
      _notificationsEnabled = notifications;
      _selectedLanguage = language;
    });
  }

  Future<void> _saveInterests() async {
    await _prefsService.saveInterests(_userInterests);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('관심사가 저장되었습니다'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showInterestSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _InterestSelectorSheet(
        availableInterests: _availableInterests,
        selectedInterests: _userInterests,
        onInterestsChanged: (interests) {
          setState(() => _userInterests = interests);
          _saveInterests();
        },
      ),
    );
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            '로그아웃',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          content: Text(
            '정말 로그아웃하시겠습니까?',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
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
    final themeService = Provider.of<ThemeService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 테마 설정
          _buildSectionTitle('테마'),
          _buildSettingTile(
            icon: themeService.isDarkMode ? LucideIcons.moon : LucideIcons.sun,
            title: '다크 모드',
            subtitle: themeService.isDarkMode ? '어두운 테마 사용 중' : '밝은 테마 사용 중',
            trailing: Switch(
              value: themeService.isDarkMode,
              onChanged: (_) => themeService.toggleTheme(),
              activeThumbColor: Theme.of(context).primaryColor,
            ),
          ),

          const SizedBox(height: 24),

          // 개인화 설정
          _buildSectionTitle('개인화'),
          _buildSettingTile(
            icon: LucideIcons.heart,
            title: '관심사 설정',
            subtitle: _userInterests.isEmpty
                ? '관심사를 선택해주세요'
                : '${_userInterests.length}개 선택됨',
            onTap: _showInterestSelector,
          ),
          _buildSettingTile(
            icon: LucideIcons.bell,
            title: '알림',
            subtitle: _notificationsEnabled ? '알림 받기' : '알림 끄기',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) async {
                setState(() => _notificationsEnabled = value);
                await _prefsService.setNotificationsEnabled(value);
              },
              activeThumbColor: Theme.of(context).primaryColor,
            ),
          ),

          const SizedBox(height: 24),

          // 앱 정보
          _buildSectionTitle('앱 정보'),
          _buildSettingTile(
            icon: LucideIcons.info,
            title: '버전 정보',
            subtitle: '1.0.0',
          ),
          _buildSettingTile(
            icon: LucideIcons.helpCircle,
            title: '도움말',
            subtitle: '사용법 및 FAQ',
            onTap: () {
              // TODO: 도움말 화면으로 이동
            },
          ),

          const SizedBox(height: 24),

          // 계정
          _buildSectionTitle('계정'),
          _buildSettingTile(
            icon: LucideIcons.logOut,
            title: '로그아웃',
            subtitle: '계정에서 로그아웃',
            onTap: _handleLogout,
            titleColor: Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: titleColor ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        trailing:
            trailing ??
            (onTap != null
                ? Icon(
                    LucideIcons.chevronRight,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  )
                : null),
        onTap: onTap,
      ),
    );
  }
}

class _InterestSelectorSheet extends StatefulWidget {
  final List<String> availableInterests;
  final List<String> selectedInterests;
  final Function(List<String>) onInterestsChanged;

  const _InterestSelectorSheet({
    required this.availableInterests,
    required this.selectedInterests,
    required this.onInterestsChanged,
  });

  @override
  State<_InterestSelectorSheet> createState() => _InterestSelectorSheetState();
}

class _InterestSelectorSheetState extends State<_InterestSelectorSheet> {
  late List<String> _tempSelectedInterests;

  @override
  void initState() {
    super.initState();
    _tempSelectedInterests = List.from(widget.selectedInterests);
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_tempSelectedInterests.contains(interest)) {
        _tempSelectedInterests.remove(interest);
      } else {
        _tempSelectedInterests.add(interest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '관심사 선택',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    widget.onInterestsChanged(_tempSelectedInterests);
                    Navigator.pop(context);
                  },
                  child: const Text('완료'),
                ),
              ],
            ),
          ),

          const Divider(),

          // Interests Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: widget.availableInterests.map((interest) {
                  final isSelected = _tempSelectedInterests.contains(interest);
                  return GestureDetector(
                    onTap: () => _toggleInterest(interest),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.2),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        interest,
                        style: TextStyle(
                          color: isSelected
                              ? (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.black
                                    : Colors.white)
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
