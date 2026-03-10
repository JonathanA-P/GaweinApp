import 'package:flutter/material.dart';
import 'package:gawein/screens/cari_kerja_screen.dart'; 
import 'profil_screen.dart';
import 'kursus_scren.dart';
import 'komunitas_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gawein/screens/tambah_lowongan_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _role; // Variabel baru untuk peran
  bool _isLoading = true; // Variabel baru untuk status loading
  String _fullName = 'User'; // Default jika nama tidak ditemukan

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkUserRole(); // Panggil fungsi cek peran saat startup
  }

Future<void> _checkUserRole() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // Tambahkan 'full_name' di bagian select
      final data = await Supabase.instance.client
          .from('profiles')
          .select('role, full_name') 
          .eq('id', user.id)
          .single();
      
      setState(() {
        _role = data['role'];
        _fullName = data['full_name'] ?? 'User GaweIn'; // <-- SIMPAN NAMA DI SINI
        _isLoading = false;
      });
    }
  }

@override
  Widget build(BuildContext context) {
    // Tampilkan loading spinner jika data peran belum siap
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<Widget> pages = [
      // Jika perekrut, tampilkan konten perekrut. Jika bukan, tampilkan konten Alfredo yang lama.
      _role == 'perekrut' ? _buildPerekrutContent() : _buildHomeContent(), 
      const CariKerjaScreen(),
      const KursusScreen(),
      const KomunitasScreen(),
      const ProfilScreen(), 
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      // INI YANG BARU: Body sekarang berubah dinamis berdasarkan index yang diklik
      body: SafeArea(
        child: pages[_selectedIndex], 
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

  // --- KONTEN BERANDA KITA PINDAHKAN KE METHOD INI ---
  Widget _buildHomeContent() {
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
              const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
               const Text('Good morning', style: TextStyle(color: Colors.white70, fontSize: 14)),
               const SizedBox(height: 4),
               Text(_fullName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
  ],
),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.notifications_none, color: Colors.white),
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
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('See All', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildCommunityThreads() {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          _communityCard('Tanya Jawab Interview', 'Tips lolos interview F&B...', Colors.blue.shade100),
          _communityCard('Sharing Info Loker', 'Ada loker helper gudang di Suhat...', Colors.purple.shade100),
        ],
      ),
    );
  }

  Widget _communityCard(String title, String subtitle, Color color) {
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(color: Colors.black.withOpacity(0.6))),
        ],
      ),
    );
  }

// ==========================================
  // TAHAP 1: FITUR CARI PEKERJAAN (DARI SUPABASE)
  // ==========================================
  Widget _buildJobRecommendations() {
    return SizedBox(
      height: 160,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        // Mengambil data dari tabel 'jobs' Supabase
        future: Supabase.instance.client.from('jobs').select().order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada lowongan kerja.', style: TextStyle(color: Colors.grey)));
          }

          final jobs = snapshot.data!;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return _jobCard(
                job['title'] ?? 'Posisi Tidak Diketahui',
                job['company_name'] ?? 'Perusahaan Rahasia',
                job['salary'] ?? 'Gaji Dirahasiakan',
                Icons.work,
              );
            },
          );
        },
      ),
    );
  }

  // ==========================================
  // TAHAP 3: FITUR COURSE (DARI YOUTUBE API)
  // ==========================================
  Future<List<dynamic>> _fetchYouTubeCourses() async {
    // Catatan: Ganti 'YOUR_API_KEY' dengan API Key asli dari Google Cloud Console kamu
    const apiKey = 'YOUR_API_KEY'; 
    const query = 'belajar programming flutter indonesia'; // Kata kunci pencarian
    const url = 'https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=3&q=$query&type=video&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['items']; // Mengembalikan daftar video
      }
    } catch (e) {
      debugPrint('Error fetch YouTube: $e');
    }
    return []; // Kembalikan list kosong jika gagal (API key belum diatur)
  }

  Widget _buildCourseRecommendations() {
    return FutureBuilder<List<dynamic>>(
      future: _fetchYouTubeCourses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final videos = snapshot.data ?? [];
        
        // Fallback jika API Key belum dipasang atau error
        if (videos.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Column(
              children: [
                _courseListTile('Java OOP Masterclass (Mock)', 'Data dummy karena API Key kosong', Icons.code),
              ],
            ),
          );
        }

        // Tampilkan video asli dari YouTube
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            children: videos.map((video) {
              final snippet = video['snippet'];
              final title = snippet['title'].toString().replaceAll('&quot;', '"'); // Rapikan teks
              final channel = snippet['channelTitle'];
              return Column(
                children: [
                  _courseListTile(title, channel, Icons.play_circle_fill),
                  const SizedBox(height: 12),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _jobCard(String role, String company, String salary, IconData icon) {
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
              onPressed: () {},
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


  Widget _courseListTile(String title, String subtitle, IconData icon) {
    return Container(
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
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
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