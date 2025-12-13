import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter_paper_summary/models/paper_model.dart';

class PaperDetailScreen extends StatefulWidget {
  const PaperDetailScreen({super.key});

  @override
  State<PaperDetailScreen> createState() => _PaperDetailScreenState();
}

class _PaperDetailScreenState extends State<PaperDetailScreen>
    with TickerProviderStateMixin {
  final TextEditingController _chatController = TextEditingController();
  final FocusNode _chatFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];

  bool _isTranslated = true;
  bool _isChatOpen = false;
  bool _isCircleMode = false;
  bool _showPip = false;
  bool _isBookmarked = false;
  bool _isLoading = false;
  bool _isInputFocused = false;
  Offset? _dragStart;
  Offset? _dragEnd;

  late AnimationController _chatAnimationController;
  late Animation<double> _chatAnimation;

  // 추천 질문 리스트
  final List<String> _suggestedQuestions = [
    '이 논문 요약해줘',
    '핵심 개념은?',
    '어떤 방법론을 사용했어?',
  ];

  @override
  void initState() {
    super.initState();
    _chatAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _chatAnimation = CurvedAnimation(
      parent: _chatAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _chatFocusNode.dispose();
    _chatController.dispose();
    _scrollController.dispose();
    _chatAnimationController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_chatController.text.trim().isEmpty) return;

    final userMessage = _chatController.text.trim();
    _chatController.clear();

    setState(() {
      _messages.add({'role': 'user', 'text': userMessage});
      _isLoading = true;
    });

    if (!_isChatOpen) {
      setState(() => _isChatOpen = true);
      _chatAnimationController.forward();
    }

    // Mock AI response
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'ai',
            'text':
                '질문하신 내용에 대한 요약입니다. 이 논문에서는 Transformer 아키텍처를 제안하고 있습니다. '
                'Self-Attention 메커니즘을 활용하여 순환 신경망 없이도 뛰어난 성능을 달성했습니다.',
          });
          _isLoading = false;
        });
      }
    });
  }

  void _openChat() {
    setState(() => _isChatOpen = true);
    _chatAnimationController.forward();
  }

  void _closeChat() {
    _chatAnimationController.reverse().then((_) {
      if (mounted) {
        setState(() => _isChatOpen = false);
      }
    });
    _chatFocusNode.unfocus();
  }

  void _showAISummary() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 400,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'AI 요약',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    '이 논문은 순환 신경망과 합성곱 신경망 없이 오직 어텐션 메커니즘만으로 구성된 '
                    'Transformer 아키텍처를 제안합니다.\n\n'
                    '핵심 내용:\n'
                    '• Self-Attention을 활용한 새로운 접근\n'
                    '• 병렬 처리가 가능하여 학습 속도 향상\n'
                    '• 기계 번역 등 다양한 NLP 태스크에서 SOTA 달성',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(height: 1.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildPaperText(String text) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(height: 1.6, fontSize: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // 업로드된 논문 데이터 확인
    final args = ModalRoute.of(context)?.settings.arguments;
    String paperTitle = 'Attention Is All You Need';
    String paperContent = '';

    if (args is PaperModel) {
      paperTitle = args.title;
      paperContent = args.content;
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Main Content (Paper Text)
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(
                20,
                120,
                20,
                _isChatOpen ? 420 : 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paperTitle,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(
                    _isTranslated ? '초록 (Abstract)' : 'Abstract',
                  ),
                  const SizedBox(height: 12),
                  _buildPaperText(
                    _isTranslated
                        ? '지배적인 시퀀스 변환 모델들은 인코더와 디코더를 포함하는 복잡한 순환 신경망이나 합성곱 신경망에 기반하고 있습니다. 가장 성능이 좋은 모델들도 어텐션 메커니즘을 통해 인코더와 디코더를 연결합니다. 우리는 순환과 합성곱을 완전히 배제하고 오직 어텐션 메커니즘에만 기반한 새로운 단순한 네트워크 아키텍처인 Transformer를 제안합니다.'
                        : 'The dominant sequence transduction models are based on complex recurrent or convolutional neural networks that include an encoder and a decoder. The best performing models also connect the encoder and decoder through an attention mechanism. We propose a new simple network architecture, the Transformer, based solely on attention mechanisms, dispensing with recurrence and convolutions entirely.',
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(
                    _isTranslated ? '1. 서론 (Introduction)' : '1. Introduction',
                  ),
                  const SizedBox(height: 12),
                  _buildPaperText(
                    _isTranslated
                        ? '순환 신경망, 특히 LSTM과 GRU는 언어 모델링 및 기계 번역과 같은 시퀀스 모델링 및 변환 문제에서 최첨단 접근 방식으로 확고히 자리 잡았습니다. 이러한 모델들은 일반적으로 입력과 출력 시퀀스의 심볼 위치를 따라 계산을 인수분해합니다.'
                        : 'Recurrent neural networks, long short-term memory and gated recurrent neural networks in particular, have been firmly established as state of the art approaches in sequence modeling and transduction problems such as language modeling and machine translation. These models typically factor computation along the symbol positions of the input and output sequences.',
                  ),
                  const SizedBox(height: 100), // 추가 여백
                ],
              ),
            ),
          ),

          // Circle to Search Overlay
          if (_isCircleMode)
            Positioned.fill(
              child: GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    _dragStart = details.localPosition;
                    _dragEnd = details.localPosition;
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    _dragEnd = details.localPosition;
                  });
                },
                onPanEnd: (details) {
                  if (_dragStart != null && _dragEnd != null) {
                    setState(() {
                      _showPip = true;
                      _isCircleMode = false;
                    });
                  }
                },
                child: Container(
                  color: Colors.black54,
                  child: CustomPaint(
                    painter: _DragRectPainter(_dragStart, _dragEnd),
                    child: const Center(
                      child: Text(
                        '비교할 영역을 드래그하세요',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // PIP View
          if (_showPip)
            Positioned(
              top: 120,
              right: 20,
              child: GestureDetector(
                onTap: () => setState(() => _showPip = false),
                child: Container(
                  width: 160,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.fileText,
                              color: Theme.of(context).primaryColor,
                              size: 40,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Original PDF',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => _showPip = false),
                          child: const Icon(
                            LucideIcons.x,
                            color: Colors.white70,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Top Bar (Back + Actions)
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      LucideIcons.arrowLeft,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                  ),
                ),
                // Right Actions
                Row(
                  children: [
                    // Bookmark Button
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isBookmarked
                              ? LucideIcons.bookmark
                              : LucideIcons.bookmark,
                          color: _isBookmarked ? Colors.amber : Colors.white,
                          size: 20,
                          fill: _isBookmarked ? 1.0 : 0.0,
                        ),
                        onPressed: () {
                          setState(() => _isBookmarked = !_isBookmarked);
                        },
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // AI Summary Button
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          LucideIcons.sparkles,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                        onPressed: _showAISummary,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Translation Toggle
                    GestureDetector(
                      onTap: () =>
                          setState(() => _isTranslated = !_isTranslated),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _isTranslated ? 'KO' : 'EN',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Circle to Search Button
          if (!_isCircleMode && !_isChatOpen)
            Positioned(
              right: 20,
              bottom: 160,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: FloatingActionButton.extended(
                  onPressed: () => setState(() => _isCircleMode = true),
                  backgroundColor: Theme.of(context).primaryColor,
                  elevation: 0,
                  label: const Text(
                    'Circle',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  icon: const Icon(
                    LucideIcons.scan,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
            ),

          // Liquid Glass Chat Overlay
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutBack,
            left: 0,
            right: 0,
            bottom: _isChatOpen ? 0 : -500,
            height: 400,
            child: GlassmorphicContainer(
              width: double.infinity,
              height: 400,
              borderRadius: 30,
              blur: 30,
              alignment: Alignment.bottomCenter,
              border: 0,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2A2A35).withValues(alpha: 0.8),
                  const Color(0xFF1E1E24).withValues(alpha: 0.9),
                ],
              ),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              child: Column(
                children: [
                  // Chat Header (Close Button)
                  if (_isChatOpen)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'AI Assistant',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              LucideIcons.x,
                              color: Colors.white70,
                            ),
                            onPressed: () =>
                                setState(() => _isChatOpen = false),
                          ),
                        ],
                      ),
                    ),
                  // Messages
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      reverse: true,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[_messages.length - 1 - index];
                        final isUser = msg['role'] == 'user';
                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? Theme.of(context).primaryColor
                                  : Colors.white10,
                              borderRadius: BorderRadius.circular(20).copyWith(
                                bottomRight: isUser ? Radius.zero : null,
                                bottomLeft: isUser ? null : Radius.zero,
                              ),
                            ),
                            child: Text(
                              msg['text']!,
                              style: TextStyle(
                                color: isUser ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Input Area
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: TextField(
                              controller: _chatController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: '논문에 대해 물어보세요...',
                                hintStyle: TextStyle(color: Colors.white38),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _sendMessage,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.send,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Chat Trigger (When chat is closed)
          if (!_isChatOpen)
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              child: Focus(
                onFocusChange: (hasFocus) {
                  // Focus 변경 시 처리 (필요시)
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    // 키보드가 올라오면 (포커스 시) 더 심플한 스타일
                    gradient: _isInputFocused
                        ? null
                        : LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.15),
                              Colors.white.withValues(alpha: 0.08),
                            ],
                          ),
                    color: _isInputFocused ? const Color(0xFF1E1E24) : null,
                    border: Border.all(
                      color: _isInputFocused
                          ? Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.2),
                      width: _isInputFocused ? 2 : 1.5,
                    ),
                    boxShadow: _isInputFocused
                        ? [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 추천 질문 칩스 (가로 스크롤, 포커스 안 되었을 때만 표시)
                        if (!_isInputFocused)
                          Container(
                            height: 36,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _suggestedQuestions.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final question = _suggestedQuestions[index];
                                return GestureDetector(
                                  onTap: () {
                                    _chatController.text = question;
                                    _sendMessage();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        question,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        // 입력창
                        Row(
                          children: [
                            Expanded(
                              child: Focus(
                                onFocusChange: (hasFocus) {
                                  setState(() {
                                    _isInputFocused = hasFocus;
                                  });
                                },
                                child: TextField(
                                  controller: _chatController,
                                  focusNode: _chatFocusNode,
                                  autofocus: false,
                                  enableInteractiveSelection: true,
                                  textInputAction: TextInputAction.send,
                                  keyboardType: TextInputType.text,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'AI에게 질문하기...',
                                    hintStyle: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    filled: true,
                                    fillColor: Colors.black.withValues(
                                      alpha: 0.3,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide(
                                        color: Colors.white.withValues(
                                          alpha: 0.1,
                                        ),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide(
                                        color: Theme.of(
                                          context,
                                        ).primaryColor.withValues(alpha: 0.5),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  onSubmitted: (_) => _sendMessage(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: _sendMessage,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  LucideIcons.send,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DragRectPainter extends CustomPainter {
  final Offset? start;
  final Offset? end;

  _DragRectPainter(this.start, this.end);

  @override
  void paint(Canvas canvas, Size size) {
    if (start == null || end == null) return;

    // 채우기 (흰색 20% 투명도)
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    // 테두리 (노란색)
    final borderPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rect = Rect.fromPoints(start!, end!);
    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
