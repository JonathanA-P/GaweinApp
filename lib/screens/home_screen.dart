import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gawein/screens/cari_kerja_screen.dart'; 
import 'profil_screen.dart';
import 'kursus_scren.dart';
import 'komunitas_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gawein/screens/tambah_lowongan_screen.dart';
import 'package:gawein/screens/detail_lowongan_screen.dart';
import 'package:gawein/screens/home_rekruiter_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _role;
  String _fullName = 'User GaweIn';
  String? _avatarUrl;
  bool _isLoading = true;
  Future<List<dynamic>>? _jobsFuture;
  Future<List<dynamic>>? _communityFuture;
  Future<List<dynamic>>? _coursesFuture;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    _jobsFuture = Supabase.instance.client
        .from('jobs')
        .select()
        .order('created_at', ascending: false)
        .limit(5);
    _communityFuture = Supabase.instance.client
        .from('community_posts')
        .select()
        .order('created_at', ascending: false)
        .limit(5);
    _coursesFuture = _fetchYouTubeCourses();
  }

Future<void> _checkUserRole() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('role, full_name, avatar_url')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      final role = data?['role'];
      // Recruiters should always use their dedicated screen
      if (role == 'perekrut') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeRekruiterScreen()),
        );
        return;
      }

      setState(() {
        _role = role;
        _fullName = (data?['full_name'] as String?)?.isNotEmpty == true
            ? data!['full_name']
            : (user.userMetadata?['full_name'] as String?) ?? 'User GaweIn';
        _avatarUrl = data?['avatar_url'] as String?;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<List<dynamic>> _fetchYouTubeCourses() async {
    final apiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';
    if (apiKey.isEmpty) return [];
    final url =
        'https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=5&q=tutorial+pemrograman+kerja+indonesia&type=video&key=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['items'] ?? [];
      }
    } catch (e) {
      debugPrint('Error fetch YouTube: $e');
    }
    return [];
  }

@override
  Widget build(BuildContext context) {
    // INI YANG BARU: Daftar halaman untuk Bottom Navigation
    final List<Widget> _pages = [
      _buildHomeContent(), // Index 0: Beranda
      const CariKerjaScreen(), // Index 1: Halaman Cari Kerja yang baru kita buat
      const KursusScreen(), // Index 2: Placeholder Course
      const KomunitasScreen(), // Index 3: Placeholder Komunitas
      const ProfilScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'Cari Kerja'),
          BottomNavigationBarItem(icon: Icon(Icons.book_outlined), label: 'Course'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Komunitas'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show recruiter content if role is perekrut
    if (_role == 'perekrut') {
      return _buildPerekrutContent();
    }

    // Default content for job seekers
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildSectionTitle('Thread Komunitas Terbaru'),
          _buildCommunityThreads(),
          const SizedBox(height: 24),
          _buildSectionTitle('Rekomendasi Pekerjaan'),
          _buildJobRecommendations(),
          const SizedBox(height: 24),
          _buildSectionTitle('Rekomendasi Course'),
          _buildCourseRecommendations(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }


  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1B3A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Row(
            children: [

              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey,
                backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                child: _avatarUrl == null
                    ? const Icon(Icons.person, color: Colors.white, size: 32)
                    : null,
              ),

              const SizedBox(width: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_getGreeting(), style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(_fullName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle),
            child: const Icon(Icons.notifications_none,
                color: Colors.white),
          )

        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const Text('See All',
              style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildCommunityThreads() {
    return SizedBox(
      height: 120,
      child: FutureBuilder<List<dynamic>>(
        future: _communityFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              children: [
                _communityCard('Belum ada thread', 'Jadilah yang pertama berdiskusi!', Colors.blue.shade100),
              ],
            );
          }
          final colors = [Colors.blue.shade100, Colors.purple.shade100, Colors.green.shade100, Colors.orange.shade100];
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index] as Map<String, dynamic>;
              return _communityCard(
                post['author_name'] ?? 'User GaweIn',
                post['content'] ?? '',
                colors[index % colors.length],
              );
            },
          );
        },
      ),
    );
  }

  Widget _communityCard(String title, String subtitle, Color color) {
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 8),
          Text(subtitle,
              style: TextStyle(
                  color: Colors.black.withOpacity(0.6))),
        ],
      ),
    );
  }

// ==========================================
  // TAHAP 1: FITUR CARI PEKERJAAN (DARI SUPABASE)
  // ==========================================
  Widget _buildJobRecommendations() {
    return FutureBuilder<List<dynamic>>(
      future: _jobsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('Belum ada lowongan tersedia.', style: TextStyle(color: Colors.grey)),
              ),
            ),
          );
        }
        final jobs = snapshot.data as List;
        return SizedBox(
          height: 175,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index] as Map<String, dynamic>;
              return _jobCard(
                job['title'] ?? '-',
                job['company_name'] ?? '-',
                job['salary'] ?? '-',
                Icons.work_outline,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailLowonganScreen(jobData: job)),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _jobCard(String role, String company, String salary, IconData icon, {VoidCallback? onTap}) {
    return Container(
      width: 240,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: Colors.deepPurple),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(role, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(company, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              )
            ],
          ),
          const Spacer(),
          Text(salary, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Apply Now'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCourseRecommendations() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: FutureBuilder<List<dynamic>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final courses = snapshot.data ?? [];
          if (courses.isEmpty) {
            return Column(
              children: [
                _courseListTile('Java OOP Masterclass', 'Belajar fundamental PBO', Icons.code, null),
                const SizedBox(height: 12),
                _courseListTile('AI/ML Engineering Basics', 'Pengenalan Machine Learning', Icons.memory, null),
              ],
            );
          }
          return Column(
            children: List.generate(
              courses.length > 3 ? 3 : courses.length,
              (index) {
                final item = courses[index] as Map<String, dynamic>;
                final snippet = item['snippet'] as Map<String, dynamic>;
                final videoId = (item['id'] as Map<String, dynamic>?)?['videoId'] as String? ?? '';
                final title = snippet['title'].toString().replaceAll('&quot;', '"').replaceAll('&#39;', "'");
                final channel = snippet['channelTitle'] as String? ?? '';
                final youtubeUrl = videoId.isNotEmpty ? 'https://www.youtube.com/watch?v=$videoId' : null;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _courseListTile(title, channel, Icons.play_circle_outline, youtubeUrl),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _courseListTile(String title, String subtitle, IconData icon, String? youtubeUrl) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: youtubeUrl != null
          ? () => launchUrl(Uri.parse(youtubeUrl), mode: LaunchMode.externalApplication)
          : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: Colors.deepPurple, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(
              youtubeUrl != null ? Icons.play_circle_outline : Icons.arrow_forward_ios,
              size: youtubeUrl != null ? 24 : 16,
              color: youtubeUrl != null ? Colors.red : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
  // Fungsi ini wajib ada agar error merah di gambar {5F16B24B-B692-4B63-9CA7-367CD466EDA5} hilang
Widget _buildPerekrutContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Selamat Datang Perekrut!\nKelola lowongan Anda di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24), // Jarak antara teks dan tombol
          
          // --- INI TOMBOL BARUNYA ---
          ElevatedButton.icon(
            onPressed: () {
              // Fungsi untuk pindah ke halaman TambahLowonganScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TambahLowonganScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Tambah Lowongan Pekerjaan',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple, // Warna tombol
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
}