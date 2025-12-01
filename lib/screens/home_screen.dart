import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _papers = [
    {
      'title': 'Attention Is All You Need',
      'authors': 'Vaswani et al.',
      'year': '2017',
      'color': const Color(0xFF6C63FF),
    },
    {
      'title': 'BERT: Pre-training of Deep Bidirectional Transformers',
      'authors': 'Devlin et al.',
      'year': '2018',
      'color': const Color(0xFFFF6584),
    },
    {
      'title': 'GPT-3: Language Models are Few-Shot Learners',
      'authors': 'Brown et al.',
      'year': '2020',
      'color': const Color(0xFF43D099),
    },
    {
      'title': 'Deep Residual Learning for Image Recognition',
      'authors': 'He et al.',
      'year': '2015',
      'color': const Color(0xFFFFA726),
    },
    {
      'title': 'YOLO: You Only Look Once',
      'authors': 'Redmon et al.',
      'year': '2016',
      'color': const Color(0xFF29B6F6),
    },
    {
      'title': 'An Image is Worth 16x16 Words',
      'authors': 'Dosovitskiy et al.',
      'year': '2020',
      'color': const Color(0xFFAB47BC),
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Retrieve arguments safely
    final args = ModalRoute.of(context)?.settings.arguments;
    List<String> selectedInterests = [];
    if (args is List<String>) {
      selectedInterests = args;
    } else {
      // Default fallback if no args provided (e.g. direct nav during dev)
      selectedInterests = ['AI', 'ML'];
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: selectedInterests
                            .map(
                              (interest) => Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Chip(
                                  label: Text(interest),
                                  backgroundColor: const Color(0xFF1E1E24),
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.filter, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF1E1E24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Gallery - GridView with fixed height
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75, // Width:Height ratio
                ),
                itemCount: _papers.length,
                itemBuilder: (context, index) {
                  final paper = _papers[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/paper');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E24),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Paper Preview/Thumbnail
                              Expanded(
                                flex: 3,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        (paper['color'] as Color).withValues(
                                          alpha: 0.3,
                                        ),
                                        (paper['color'] as Color).withValues(
                                          alpha: 0.1,
                                        ),
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      LucideIcons.fileText,
                                      size: 48,
                                      color: paper['color'],
                                    ),
                                  ),
                                ),
                              ),
                              // Paper Info
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        paper['title'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.white,
                                          height: 1.2,
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            paper['authors'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            paper['year'],
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[500],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Bookmark Icon
                          Positioned(
                            top: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () {
                                // TODO: Toggle bookmark
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  LucideIcons.bookmark,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
