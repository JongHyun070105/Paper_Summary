import 'package:flutter/material.dart';
import 'package:flutter_paper_summary/models/paper_chunk_model.dart';
import 'package:flutter_paper_summary/services/pdf_service.dart';

class PaperContentViewer extends StatefulWidget {
  final String paperId;
  final String? initialSection;

  const PaperContentViewer({
    super.key,
    required this.paperId,
    this.initialSection,
  });

  @override
  State<PaperContentViewer> createState() => _PaperContentViewerState();
}

class _PaperContentViewerState extends State<PaperContentViewer> {
  final PdfService _pdfService = PdfService();
  final ScrollController _scrollController = ScrollController();

  List<PaperChunkModel> _loadedChunks = [];
  bool _isLoading = false;
  bool _hasMoreChunks = true;
  int _currentPage = 0;
  static const int _pageSize = 3; // 한 번에 3개 청크만 로드

  @override
  void initState() {
    super.initState();
    _loadInitialChunks();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreChunks();
    }
  }

  Future<void> _loadInitialChunks() async {
    setState(() => _isLoading = true);

    try {
      final chunks = await _pdfService.getPaperChunks(
        widget.paperId,
        page: 0,
        pageSize: _pageSize,
        section: widget.initialSection,
      );

      setState(() {
        _loadedChunks = chunks;
        _currentPage = 0;
        _hasMoreChunks = chunks.length == _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // 에러 처리
    }
  }

  Future<void> _loadMoreChunks() async {
    if (_isLoading || !_hasMoreChunks) return;

    setState(() => _isLoading = true);

    try {
      final newChunks = await _pdfService.getPaperChunks(
        widget.paperId,
        page: _currentPage + 1,
        pageSize: _pageSize,
        section: widget.initialSection,
      );

      setState(() {
        _loadedChunks.addAll(newChunks);
        _currentPage++;
        _hasMoreChunks = newChunks.length == _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // 에러 처리
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 섹션 네비게이션
        _buildSectionNavigation(),

        // 콘텐츠 영역
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _loadedChunks.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= _loadedChunks.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final chunk = _loadedChunks[index];
              return _buildChunkCard(chunk);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionNavigation() {
    final sections = [
      'Abstract',
      'Introduction',
      'Methods',
      'Results',
      'Discussion',
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(section),
              selected: widget.initialSection == section,
              onSelected: (selected) {
                if (selected) {
                  // 섹션 변경 시 해당 섹션 청크들만 로드
                  _loadSectionChunks(section);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildChunkCard(PaperChunkModel chunk) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 섹션 헤더
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                chunk.section,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 청크 내용
            Text(
              chunk.getContent(false), // 기본적으로 원본 표시
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),

            // 청크 정보
            const SizedBox(height: 8),
            Text(
              'Chunk ${chunk.index + 1} • ${chunk.originalContent.length} characters',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadSectionChunks(String section) async {
    setState(() => _isLoading = true);

    try {
      final chunks = await _pdfService.getPaperChunksBySection(
        widget.paperId,
        section,
      );

      setState(() {
        _loadedChunks = chunks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
}
