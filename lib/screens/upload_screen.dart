import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_paper_summary/services/pdf_service.dart';
import 'package:flutter_paper_summary/models/paper_model.dart';
import 'package:flutter_paper_summary/utils/app_exceptions.dart';
import 'dart:io';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final PdfService _pdfService = PdfService();
  final TextEditingController _urlController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _downloadAndProcessPdf() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showErrorDialog('URL을 입력해주세요.');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final file = await _pdfService.downloadPdfFromUrl(url);
      if (file != null) {
        await _processPdfFile(file, url: url);
      } else {
        _showErrorDialog('PDF 다운로드에 실패했습니다.');
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      final errorMessage = ExceptionHandler.getErrorMessage(e);
      _showErrorDialog(errorMessage);
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _processPdfFile(File file, {String? url}) async {
    try {
      final extractedData = await _pdfService.extractTextFromPdf(file);

      final paper = await _pdfService.savePaper(
        title: extractedData['title'],
        content: extractedData['content'],
        filePath: file.path,
        url: url,
        authors: extractedData['authors'],
        abstract: extractedData['abstract'],
        pageCount: extractedData['pageCount'],
      );

      setState(() {
        _isProcessing = false;
      });

      _showSuccessDialog(paper);
    } catch (e) {
      _showErrorDialog('처리 오류: ${e.toString()}');
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          '오류',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(PaperModel paper) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          '업로드 완료',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '논문이 성공적으로 업로드되었습니다.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            Text(
              '제목: ${paper.title}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (paper.pageCount > 0)
              Text(
                '페이지 수: ${paper.pageCount}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/paper', arguments: paper);
            },
            child: const Text('논문 보기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('논문 등록'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Text(
              '논문 URL로 등록',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'arXiv, Google Scholar 등의 논문 URL을 입력하여 논문을 등록하세요.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 40),

            // URL 입력 섹션
            _buildUrlInputSection(),

            const SizedBox(height: 40),

            // 예시 URL들
            _buildExampleUrls(),

            const SizedBox(height: 40),

            // 도움말
            _buildHelpSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUrlInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '논문 URL',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          child: TextField(
            controller: _urlController,
            decoration: InputDecoration(
              hintText: 'https://arxiv.org/abs/1706.03762',
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              suffixIcon: Container(
                margin: const EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _downloadAndProcessPdf,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: _isProcessing
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.black
                                : Colors.white,
                          ),
                        )
                      : const Text('등록'),
                ),
              ),
            ),
            maxLines: 3,
            keyboardType: TextInputType.url,
          ),
        ),
      ],
    );
  }

  Widget _buildExampleUrls() {
    final examples = [
      {
        'title': 'arXiv',
        'url': 'https://arxiv.org/abs/1706.03762',
        'description': 'Attention Is All You Need',
      },
      {
        'title': 'Google Scholar',
        'url': 'https://scholar.google.com/...',
        'description': 'Google Scholar 논문 링크',
      },
      {
        'title': 'IEEE Xplore',
        'url': 'https://ieeexplore.ieee.org/...',
        'description': 'IEEE 논문 링크',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '예시 URL',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...examples.map(
          (example) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    LucideIcons.link,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        example['title']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        example['description']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    LucideIcons.copy,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  onPressed: () {
                    _urlController.text = example['url']!;
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHelpSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.info,
                size: 16,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Text(
                '도움말',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• PDF 링크를 직접 입력하거나 논문 페이지 URL을 입력하세요\n'
            '• arXiv, Google Scholar, IEEE 등 대부분의 논문 사이트를 지원합니다\n'
            '• 등록된 논문은 "내 논문" 탭에서 확인할 수 있습니다',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
