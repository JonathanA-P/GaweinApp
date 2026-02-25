import 'package:flutter/material.dart';
import 'package:timtujuh/screens/cari_kerja_screen.dart'; 
import 'profil_screen.dart';
import 'kursus_scren.dart';
import 'komunitas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
      // INI YANG BARU: Body sekarang berubah dinamis berdasarkan index yang diklik
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

  // (Sisa widget _buildProfileHeader, _buildSectionTitle, _buildCommunityThreads, 
  // _buildJobRecommendations, _buildCourseRecommendations dari kode sebelumnya tetap di sini)
  
  // ... [Masukkan function _buildProfileHeader dll yang sudah saya berikan sebelumnya di sini] ...
  
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
                children: const [
                  Text('Good morning', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  SizedBox(height: 4),
                  Text('Alfredo', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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

  Widget _buildJobRecommendations() {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          _jobCard('Barista / Waiter', 'Kopi Mbois Malang', 'Rp 1.5M - 2M', Icons.coffee),
          _jobCard('Staff Gudang Logistik', 'PT. Logistik Jaya Abadi', 'Rp 2M - 2.5M', Icons.inventory),
        ],
      ),
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

  Widget _buildCourseRecommendations() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        children: [
          _courseListTile('Java OOP Masterclass', 'Belajar fundamental PBO', Icons.code),
          const SizedBox(height: 12),
          _courseListTile('AI/ML Engineering Basics', 'Pengenalan Machine Learning', Icons.memory),
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
}