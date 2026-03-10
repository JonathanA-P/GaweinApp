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

  @override
  void initState() {
    super.initState();
    _loadAllCourses();
  }

  // Fungsi untuk memuat kedua daftar kursus secara bersamaan
  Future<void> _loadAllCourses() async {
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

  // Fungsi utama untuk menarik data dari YouTube API
  Future<List<dynamic>> _fetchYouTubeVideos(String query, int maxResults) async {
    final url = 'https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=$maxResults&q=$query&type=video&key=$apiKey';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['items'];
      } else {
        debugPrint('Gagal memuat YouTube: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetch YouTube: $e');
    }
    return []; 
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
                    // Search Bar
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for any course...',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
                          _buildCategoryChip('All Course', true),
                          _buildCategoryChip('Java', false),
                          _buildCategoryChip('Python', false),
                          _buildCategoryChip('AI/ML', false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Bagian Lanjutkan Belajar (My Course)
                    const Text(
                      'Lanjutkan Belajar',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: _myCourses.isEmpty 
                          ? const Center(child: Text('Tidak ada video ditemukan / API Key belum diatur'))
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _myCourses.length,
                              itemBuilder: (context, index) {
                                return _buildMyCourseCard(_myCourses[index]);
                              },
                            ),
                    ),
                    const SizedBox(height: 32),

                    // Bagian Popular Course
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kursus Populer',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'See All',
                          style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _popularCourses.isEmpty
                        ? const Center(child: Text('Tidak ada video ditemukan / API Key belum diatur'))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _popularCourses.length,
                            itemBuilder: (context, index) {
                              return _buildPopularCourseTile(_popularCourses[index]);
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  // Filter Chip Category
  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
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