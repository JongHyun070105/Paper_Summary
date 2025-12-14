import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_paper_summary/models/paper_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = '전체';
  List<Map<String, dynamic>> _searchResults = [];

  // 관심사 필터 옵션
  final List<String> _filterOptions = [
    '전체',
    '인공지능',
    '머신러닝',
    '딥러닝',
    '컴퓨터 비전',
    '자연어 처리',
    '로보틱스',
  ];

  // 더미 논문 데이터 (나중에 실제 API로 대체)
  final List<Map<String, dynamic>> _allPapers = [
    {
      'title': 'Attention Is All You Need',
      'authors': 'Vaswani et al.',
      'year': '2017',
      'category': '자연어 처리',
      'url': 'https://arxiv.org/abs/1706.03762',
    },
    {
      'title': 'BERT: Pre-training of Deep Bidirectional Transformers',
      'authors': 'Devlin et al.',
      'year': '2018',
      'category': '자연어 처리',
      'url': 'https://arxiv.org/abs/1810.04805',
    },
    {
      'title': 'Deep Residual Learning for Image Recognition',
      'authors': 'He et al.',
      'year': '2015',
      'category': '컴퓨터 비전',
      'url': 'https://arxiv.org/abs/1512.03385',
    },
    {
      'title': 'YOLO: You Only Look Once',
      'authors': 'Redmon et al.',
      'year': '2016',
      'category': '컴퓨터 비전',
      'url': 'https://arxiv.org/abs/1506.02640',
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchResults = _allPapers; // 초기에는 모든 논문 표시
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults = _getFilteredPapers();
      } else {
        _searchResults = _allPapers.where((paper) {
          final title = paper['title'].toString().toLowerCase();
          final authors = paper['authors'].toString().toLowerCase();
          final searchQuery = query.toLowerCase();

          return title.contains(searchQuery) || authors.contains(searchQuery);
        }).toList();
      }
    });
  }

  List<Map<String, dynamic>> _getFilteredPapers() {
    if (_selectedFilter == '전체') {
      return _allPapers;
    }
    return _allPapers
        .where((paper) => paper['category'] == _selectedFilter)
        .toList();
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (_searchController.text.isEmpty) {
        _searchResults = _getFilteredPapers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 검색창
            _buildSearchBar(),

            // 필터 칩스
            _buildFilterChips(),

            // 검색 결과 또는 빈 상태
            Expanded(
              child: _searchResults.isEmpty
                  ? _buildEmptyState()
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _performSearch,
        decoration: InputDecoration(
          hintText: '논문 제목이나 저자를 검색하세요...',
          hintStyle: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(
            LucideIcons.search,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    LucideIcons.x,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filterOptions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final isSelected = _selectedFilter == filter;

          return FilterChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (_) => _onFilterChanged(filter),
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedColor: Theme.of(
              context,
            ).primaryColor.withValues(alpha: 0.2),
            checkmarkColor: Theme.of(context).primaryColor,
            labelStyle: TextStyle(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            side: BorderSide(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.2),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final paper = _searchResults[index];
        return _buildPaperCard(paper);
      },
    );
  }

  Widget _buildPaperCard(Map<String, dynamic> paper) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // 논문 데이터를 PaperModel로 변환
          final paperModel = PaperModel(
            id: paper['title'].hashCode.toString(),
            title: paper['title'],
            content: '이 논문의 상세 내용입니다. 실제로는 PDF에서 추출된 텍스트가 여기에 표시됩니다.',
            uploadedAt: DateTime.now(),
            userId: 'current_user',
            authors: [paper['authors']],
            abstract: '이 논문의 초록입니다.',
            url: paper['url'],
          );

          Navigator.pushNamed(context, '/paper', arguments: paperModel);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LucideIcons.fileText,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          paper['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${paper['authors']} • ${paper['year']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      paper['category'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    LucideIcons.externalLink,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.1),
                ),
              ),
              child: Icon(
                LucideIcons.search,
                size: 48,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '찾는 논문이 없으신가요?',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              '원하는 논문을 직접 등록해보세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/upload');
              },
              icon: const Icon(LucideIcons.plus),
              label: const Text('논문 직접 등록하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
