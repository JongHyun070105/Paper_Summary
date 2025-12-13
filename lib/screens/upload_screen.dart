import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_paper_summary/services/pdf_service.dart';
import 'package:flutter_paper_summary/models/paper_model.dart';
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

  Future<void> _pickAndProcessPdf() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final file = await _pdfService.pickPdfFile();
      if (file != null) {
        await _processPdfFile(file);
      } else {
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      _showErrorDialog('파일 선택 오류: ${e.toString()}');
      setState(() {
        _isProcessing = false;
      });
    }
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
      String errorMessage = '다운로드 오류: ';
      if (e.toString().contains('TimeoutException')) {
        errorMessage += '다운로드 시간이 초과되었습니다.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage += '네트워크 연결을 확인해주세요.';
      } else if (e.toString().contains('유효하지 않은 URL')) {
        errorMessage += '올바른 URL을 입력해주세요.';
      } else if (e.toString().contains('파일 크기가 너무 큽니다')) {
        errorMessage += '파일 크기가 100MB를 초과합니다.';
      } else {
        errorMessage += e.toString();
      }

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
        title: const Text('논문 업로드'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '논문을 업로드하세요',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'PDF 파일을 선택하거나 URL을 입력하여 논문을 업로드할 수 있습니다.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 40),

            // PDF 파일 업로드
            _buildUploadOption(
              icon: LucideIcons.upload,
              title: 'PDF 파일 업로드',
              subtitle: '기기에서 PDF 파일을 선택하세요',
              onTap: _isProcessing ? null : _pickAndProcessPdf,
            ),

            const SizedBox(height: 20),

            // URL 입력
            _buildUrlSection(),

            const SizedBox(height: 40),

            // 처리 상태 표시 (제거됨)
            const SizedBox(height: 40),

            // 도움말
            _buildHelpSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
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
            Icon(
              LucideIcons.chevronRight,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrlSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'URL로 업로드',
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
              hintText: 'https://example.com/paper.pdf',
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              suffixIcon: IconButton(
                icon: const Icon(LucideIcons.download),
                onPressed: _isProcessing ? null : _downloadAndProcessPdf,
              ),
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
            '• PDF 파일에서 자동으로 텍스트를 추출합니다\n'
            '• 제목, 저자, 초록을 자동으로 인식합니다\n'
            '• 업로드된 논문은 "내 논문" 탭에서 확인할 수 있습니다',
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
