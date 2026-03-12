import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

class KursusScreen extends StatefulWidget {
  const KursusScreen({super.key});

  @override
  State<KursusScreen> createState() => _KursusScreenState();
}

class _KursusScreenState extends State<KursusScreen> {
  // Read YouTube API key from .env
  final String apiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';

  List<dynamic> _myCourses = [];
  List<dynamic> _popularCourses = [];
  bool _isLoading = true;
  bool _isUsingFallback = false;
  String _searchQuery = '';
  String _selectedCategory = 'All Course';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAllCourses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi untuk memuat kedua daftar kursus secara bersamaan
  Future<void> _loadAllCourses() async {
    if (mounted) setState(() { _isLoading = true; _isUsingFallback = false; });
    // Mencari video dengan kata kunci berbeda untuk 2 section
    final myCoursesData = await _fetchYouTubeVideos('tutorial java oop bahasa indonesia', 5);
    final popularCoursesData = await _fetchYouTubeVideos('tutorial machine learning pemula indonesia', 10);

    if (mounted) {
      setState(() {
        _myCourses = myCoursesData;
        _popularCourses = popularCoursesData;
        _isLoading = false;
      });
    }
  }

  // Helper: buat item video dalam format YouTube API response
  Map<String, dynamic> _staticVideoItem(String videoId, String title, String channelTitle) => {
    'id': {'videoId': videoId},
    'snippet': {
      'title': title,
      'channelTitle': channelTitle,
      'thumbnails': {
        'high': {'url': 'https://img.youtube.com/vi/$videoId/hqdefault.jpg'},
        'default': {'url': 'https://img.youtube.com/vi/$videoId/default.jpg'},
      },
    },
  };

  // Data statis kursus Java OOP
  List<Map<String, dynamic>> _getStaticJavaCourses() => [
    _staticVideoItem('2AP4Tnp6FZw', 'Belajar Java OOP - Pengenalan Class & Object', 'Programmer Zaman Now'),
    _staticVideoItem('h1JA2iMtqn4', 'Java OOP - Inheritance (Pewarisan)', 'Programmer Zaman Now'),
    _staticVideoItem('fkSqO8RNKW4', 'Java OOP - Polymorphism Indonesia', 'Kelas Terbuka'),
    _staticVideoItem('NU_1StN5Tkk', 'Java Interface dan Abstract Class', 'Kelas Terbuka'),
    _staticVideoItem('3RhZUtMwZJ8', 'Belajar Design Pattern Java Indonesia', 'Programmer Zaman Now'),
  ];

  // Data statis kursus Machine Learning
  List<Map<String, dynamic>> _getStaticMlCourses() => [
    _staticVideoItem('GwIo3gDZCVQ', 'Belajar Machine Learning - Pengenalan', 'DQLab'),
    _staticVideoItem('7eh4d9ejTKY', 'Machine Learning dengan Python - Pemula', 'Kelas Terbuka'),
    _staticVideoItem('IpGxLWOIZy4', 'Tutorial Scikit-Learn Python Indonesia', 'Indonesia Belajar'),
    _staticVideoItem('VkdkJnB9Ldc', 'Deep Learning - Neural Network Indonesia', 'Programmer Zaman Now'),
    _staticVideoItem('aircAruvnKk', 'Cara Kerja Neural Network (Animasi)', '3Blue1Brown'),
    _staticVideoItem('9yl6-HEY7_s', 'Machine Learning Project Lengkap', 'DQLab'),
    _staticVideoItem('rfscVS0vtbw', 'Machine Learning Python Full Course', 'freeCodeCamp'),
    _staticVideoItem('tPYj3fFJGjk', 'TensorFlow Tutorial Indonesia', 'Build With AI'),
    _staticVideoItem('HGwBXDKFk9I', 'Data Science untuk Karir Indonesia', 'Indonesia AI'),
    _staticVideoItem('vmEHCJofslg', 'Logistic Regression & Classification ML', 'Programmer Zaman Now'),
  ];

  // Ambil data dari YouTube API; jika gagal (termasuk quota habis), gunakan data statis
  Future<List<dynamic>> _fetchYouTubeVideos(String query, int maxResults) async {
    final fallback = query.contains('java') ? _getStaticJavaCourses() : _getStaticMlCourses();
    if (apiKey.isEmpty) {
      if (mounted) setState(() => _isUsingFallback = true);
      return fallback;
    }
    final url = 'https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=$maxResults&q=${Uri.encodeComponent(query)}&type=video&key=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List? ?? [];
        if (items.isNotEmpty) return items;
      }
      debugPrint('YouTube API fallback (status ${response.statusCode})');
      if (mounted) setState(() => _isUsingFallback = true);
    } catch (e) {
      debugPrint('Error fetch YouTube: $e');
      if (mounted) setState(() => _isUsingFallback = true);
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Belajar Hal Baru,',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            Text(
              'Tingkatkan Skillmu!',
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.deepPurple),
            onPressed: () {},
          )
        ],
      ),
      // Tampilkan indikator loading jika data sedang ditarik dari YouTube
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isUsingFallback)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange.shade700, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Menampilkan konten rekomendasi (kuota API YouTube habis)',
                                style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: 'Cari kursus...',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Kategori Kursus (Filter Horizontal)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCategoryChip('All Course'),
                          _buildCategoryChip('Java'),
                          _buildCategoryChip('Python'),
                          _buildCategoryChip('AI/ML'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Bagian Lanjutkan Belajar (My Course)
                    const Text(
                      'Kursus Java & OOP',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Builder(builder: (context) {
                      final filtered = _filterCourses(_myCourses);
                      return SizedBox(
                        height: 200,
                        child: _myCourses.isEmpty
                            ? _buildInlineError()
                            : filtered.isEmpty
                                ? Center(
                                    child: Text(
                                      'Tidak ada hasil untuk "$_searchQuery"',
                                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                  )
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: filtered.length,
                                    itemBuilder: (context, index) => _buildMyCourseCard(filtered[index]),
                                  ),
                      );
                    }),
                    const SizedBox(height: 32),

                    // Bagian Popular Course
                    const Text(
                      'Kursus Populer',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Builder(builder: (context) {
                      final filtered = _filterCourses(_popularCourses);
                      return _popularCourses.isEmpty
                          ? _buildInlineError()
                          : filtered.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Center(
                                    child: Text(
                                      'Tidak ada hasil untuk "$_searchQuery"',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) => _buildPopularCourseTile(filtered[index]),
                                );
                    }),
                  ],
                ),
              ),
            ),
    );
  }

  // Error widget kecil untuk ditampilkan di dalam section
  Widget _buildInlineError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 32),
          const SizedBox(height: 8),
          const Text(
            'Tidak ada video ditemukan',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          TextButton.icon(
            onPressed: _loadAllCourses,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  List<dynamic> _filterCourses(List<dynamic> courses) {
    return courses.where((item) {
      final snippet = (item['snippet'] as Map? ?? {});
      final title = (snippet['title'] as String? ?? '').toLowerCase();
      final channel = (snippet['channelTitle'] as String? ?? '').toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          title.contains(_searchQuery) ||
          channel.contains(_searchQuery);
      final matchesCategory = _selectedCategory == 'All Course' ||
          (_selectedCategory == 'Java' &&
              (title.contains('java') || channel.contains('java'))) ||
          (_selectedCategory == 'Python' &&
              (title.contains('python') || channel.contains('python'))) ||
          (_selectedCategory == 'AI/ML' &&
              (title.contains('machine') || title.contains('learning') ||
                  title.contains('neural') || title.contains('tensorflow') ||
                  title.contains('scikit') || title.contains('data') ||
                  title.contains(' ai ') || title.contains('ml ')));
      return matchesSearch && matchesCategory;
    }).toList();
  }

  // Filter Chip Category
  Widget _buildCategoryChip(String label) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Card untuk kursus yang sedang berjalan (Horizontal List)
  Widget _buildMyCourseCard(Map<String, dynamic> item) {
    final snippet = item['snippet'] as Map<String, dynamic>;
    final videoId = (item['id'] as Map<String, dynamic>?)?['videoId'] as String? ?? '';
    final title = snippet['title'].toString().replaceAll('&quot;', '"').replaceAll('&#39;', "'");
    final channelTitle = snippet['channelTitle'];
    final thumbnailUrl = snippet['thumbnails']['high']['url'];

    return GestureDetector(
      onTap: videoId.isNotEmpty
          ? () => launchUrl(Uri.parse('https://www.youtube.com/watch?v=$videoId'), mode: LaunchMode.externalApplication)
          : null,
      child: Container(
        width: 260,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail Gambar YouTube
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              thumbnailUrl,
              height: 110,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 110, color: Colors.grey.shade200, child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.smart_display, size: 14, color: Colors.red),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        channelTitle,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    ),
    );
  }

  // List Tile untuk kursus populer (Vertical List)
  Widget _buildPopularCourseTile(Map<String, dynamic> item) {
    final snippet = item['snippet'] as Map<String, dynamic>;
    final videoId = (item['id'] as Map<String, dynamic>?)?['videoId'] as String? ?? '';
    final title = snippet['title'].toString().replaceAll('&quot;', '"').replaceAll('&#39;', "'");
    final channelTitle = snippet['channelTitle'];
    final thumbnailUrl = snippet['thumbnails']['default']['url']; // Pakai resolusi kecil untuk list memanjang

    return GestureDetector(
      onTap: videoId.isNotEmpty
          ? () => launchUrl(Uri.parse('https://www.youtube.com/watch?v=$videoId'), mode: LaunchMode.externalApplication)
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail YouTube berbentuk Kotak
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              thumbnailUrl,
              height: 70,
              width: 90,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 70, width: 90, color: Colors.grey.shade200, child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        channelTitle,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Text("Gratis", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 12)),
                    Spacer(),
                    Icon(Icons.ondemand_video, size: 14, color: Colors.red),
                    SizedBox(width: 4),
                    Text("YouTube", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),    ),    );
  }
}