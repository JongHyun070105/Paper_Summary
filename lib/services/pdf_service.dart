import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_paper_summary/models/paper_model.dart';
import 'package:flutter_paper_summary/models/paper_chunk_model.dart';
import 'package:flutter_paper_summary/services/auth_service.dart';
import 'package:flutter_paper_summary/services/paper_chunk_service.dart';

class PdfService {
  final AuthService _authService = AuthService();
  final Uuid _uuid = const Uuid();

  // PDF 파일 선택
  Future<File?> pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: false, // 메모리 사용량 최적화
      );

      if (result != null &&
          result.files.isNotEmpty &&
          result.files.single.path != null) {
        final file = File(result.files.single.path!);

        // 파일 크기 체크 (100MB 제한)
        final fileSize = await file.length();
        if (fileSize > 100 * 1024 * 1024) {
          throw Exception('파일 크기가 너무 큽니다. (최대 100MB)');
        }

        return file;
      }
      return null;
    } catch (e) {
      print('PDF 파일 선택 오류: $e');
      rethrow; // 에러를 다시 던져서 UI에서 처리할 수 있도록
    }
  }

  // URL에서 PDF 다운로드
  Future<File?> downloadPdfFromUrl(String url) async {
    try {
      // URL 유효성 검사
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.hasScheme) {
        throw Exception('유효하지 않은 URL입니다.');
      }

      final response = await http
          .get(
            uri,
            headers: {
              'User-Agent': 'Mozilla/5.0 (compatible; Flutter PDF Reader)',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        // Content-Type 확인
        final contentType = response.headers['content-type'];
        if (contentType != null && !contentType.contains('pdf')) {
          print('경고: Content-Type이 PDF가 아닙니다: $contentType');
        }

        // 파일 크기 체크
        if (response.bodyBytes.length > 100 * 1024 * 1024) {
          throw Exception('파일 크기가 너무 큽니다. (최대 100MB)');
        }

        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/${_uuid.v4()}.pdf');
        await file.writeAsBytes(response.bodyBytes);

        return file;
      } else {
        throw Exception('다운로드 실패: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('PDF 다운로드 오류: $e');
      rethrow;
    }
  }

  // PDF에서 텍스트 추출
  Future<Map<String, dynamic>> extractTextFromPdf(File pdfFile) async {
    try {
      if (!await pdfFile.exists()) {
        throw Exception('PDF 파일이 존재하지 않습니다.');
      }

      final Uint8List bytes = await pdfFile.readAsBytes();
      if (bytes.isEmpty) {
        throw Exception('PDF 파일이 비어있습니다.');
      }

      final PdfDocument document = PdfDocument(inputBytes: bytes);

      String extractedText = '';
      String title = '';
      String abstract = '';
      List<String> authors = [];

      // 각 페이지에서 텍스트 추출
      if (document.pages.count > 0) {
        try {
          // 전체 문서에서 텍스트 추출 (더 안전한 방법)
          final PdfTextExtractor textExtractor = PdfTextExtractor(document);
          final String fullText = textExtractor.extractText();

          if (fullText.isNotEmpty) {
            extractedText = fullText;

            // 첫 페이지에서 메타데이터 추출
            final result = _extractMetadataFromFirstPage(fullText);
            title = result['title'] ?? '';
            authors = List<String>.from(result['authors'] ?? []);
            abstract = result['abstract'] ?? '';
          } else {
            // 전체 추출이 실패하면 페이지별로 시도
            for (int i = 0; i < document.pages.count; i++) {
              try {
                final String pageText = textExtractor.extractText(
                  startPageIndex: i,
                  endPageIndex: i,
                );

                if (pageText.isNotEmpty) {
                  extractedText += '$pageText\n\n';

                  if (i == 0) {
                    final result = _extractMetadataFromFirstPage(pageText);
                    title = result['title'] ?? '';
                    authors = List<String>.from(result['authors'] ?? []);
                    abstract = result['abstract'] ?? '';
                  }
                }
              } catch (e) {
                print('페이지 $i 텍스트 추출 오류: $e');
                continue;
              }
            }
          }
        } catch (e) {
          print('PDF 텍스트 추출 전체 오류: $e');
          // 텍스트 추출이 완전히 실패한 경우 기본값 반환
          extractedText = 'PDF 텍스트를 추출할 수 없습니다.';
        }
      }

      document.dispose();

      return {
        'title': title.isNotEmpty
            ? title
            : _generateTitleFromContent(extractedText),
        'content': extractedText,
        'authors': authors,
        'abstract': abstract,
        'pageCount': document.pages.count,
      };
    } catch (e) {
      print('PDF 텍스트 추출 오류: $e');
      return {
        'title': 'PDF 문서 (${pdfFile.path.split('/').last})',
        'content': 'PDF 텍스트를 추출할 수 없습니다.\n오류: ${e.toString()}',
        'authors': <String>[],
        'abstract': '텍스트 추출 실패',
        'pageCount': 0,
      };
    }
  }

  // 첫 페이지에서 메타데이터 추출
  Map<String, dynamic> _extractMetadataFromFirstPage(String text) {
    if (text.isEmpty) {
      return {'title': '', 'authors': <String>[], 'abstract': ''};
    }

    final lines = text
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    String title = '';
    List<String> authors = [];
    String abstract = '';

    // 제목 추출 (보통 첫 번째 큰 텍스트)
    if (lines.isNotEmpty) {
      title = lines[0].trim();
      // 너무 짧거나 긴 경우 다음 줄도 확인
      if (title.length < 10 && lines.length > 1) {
        title = lines[1].trim();
      }
    }

    // Abstract 찾기
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].toLowerCase();
      if (line.contains('abstract') || line.contains('초록')) {
        // Abstract 다음 몇 줄을 추출
        final abstractLines = <String>[];
        for (int j = i + 1; j < lines.length && j < i + 10; j++) {
          final nextLine = lines[j].trim();
          if (nextLine.toLowerCase().contains('introduction') ||
              nextLine.toLowerCase().contains('서론') ||
              nextLine.length < 20) {
            break;
          }
          abstractLines.add(nextLine);
        }
        abstract = abstractLines.join(' ').trim();
        break;
      }
    }

    return {'title': title, 'authors': authors, 'abstract': abstract};
  }

  // 내용에서 제목 생성
  String _generateTitleFromContent(String content) {
    final lines = content
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
    if (lines.isNotEmpty) {
      String firstLine = lines[0].trim();
      if (firstLine.length > 50) {
        firstLine = '${firstLine.substring(0, 50)}...';
      }
      return firstLine;
    }
    return 'PDF 문서';
  }

  // 논문을 로컬에 저장
  Future<PaperModel> savePaper({
    required String title,
    required String content,
    String? filePath,
    String? url,
    List<String> authors = const [],
    String? abstract,
    int pageCount = 0,
  }) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception('사용자가 로그인되지 않았습니다.');

    final paper = PaperModel(
      id: _uuid.v4(),
      title: title,
      content: content,
      filePath: filePath,
      url: url,
      uploadedAt: DateTime.now(),
      userId: user.uid,
      authors: authors,
      abstract: abstract,
      pageCount: pageCount,
    );

    // 로컬 저장소에 저장 (SharedPreferences 사용)
    await _savePaperToLocal(paper);

    return paper;
  }

  // 로컬에 논문 저장
  Future<void> _savePaperToLocal(PaperModel paper) async {
    // TODO: SharedPreferences나 로컬 DB에 저장
    // 지금은 간단히 구현
  }

  // 논문을 청크와 함께 저장
  Future<PaperWithChunks> savePaperWithChunks({
    required String title,
    required String content,
    String? filePath,
    String? url,
    List<String> authors = const [],
    String? abstract,
    int pageCount = 0,
  }) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception('사용자가 로그인되지 않았습니다.');

    // 1. 기본 논문 정보 생성
    final paperId = _uuid.v4();
    final paper = PaperModel(
      id: paperId,
      title: title,
      content: '', // 청크로 분할되므로 빈 문자열
      filePath: filePath,
      url: url,
      uploadedAt: DateTime.now(),
      userId: user.uid,
      authors: authors,
      abstract: abstract,
      pageCount: pageCount,
    );

    // 2. 텍스트를 청크로 분할
    final chunkData = PaperChunkService.splitIntoChunks(content);
    final chunks = chunkData
        .map(
          (data) => PaperChunkModel(
            id: _uuid.v4(),
            paperId: paperId,
            index: data['index'],
            section: data['section'],
            content: data['content'],
            startChar: data['startChar'],
            endChar: data['endChar'],
            createdAt: DateTime.now(),
          ),
        )
        .toList();

    // 3. 로컬 저장소에 저장
    await _savePaperWithChunksToLocal(paper, chunks);

    return PaperWithChunks(paper: paper, chunks: chunks);
  }

  // 로컬에 논문과 청크 저장
  Future<void> _savePaperWithChunksToLocal(
    PaperModel paper,
    List<PaperChunkModel> chunks,
  ) async {
    // TODO: SharedPreferences나 로컬 DB에 저장
    // 청크는 별도 테이블/키로 관리
  }

  // 논문 청크 페이지네이션으로 가져오기
  Future<List<PaperChunkModel>> getPaperChunks(
    String paperId, {
    int page = 0,
    int pageSize = 5,
    String? section,
  }) async {
    // TODO: 실제 구현에서는 DB에서 페이지네이션으로 가져오기
    return [];
  }

  // 특정 섹션의 청크들 가져오기
  Future<List<PaperChunkModel>> getPaperChunksBySection(
    String paperId,
    String section,
  ) async {
    // TODO: 실제 구현
    return [];
  }

  // 사용자의 논문 목록 가져오기
  Future<List<PaperModel>> getUserPapers() async {
    final user = _authService.currentUser;
    if (user == null) return [];

    // TODO: 실제로는 로컬 저장소나 Firebase에서 가져오기
    // 지금은 더미 데이터 반환
    return [];
  }
}
