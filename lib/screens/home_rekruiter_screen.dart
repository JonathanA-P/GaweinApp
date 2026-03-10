import 'package:flutter/material.dart';

class HomeRekruiterScreen extends StatefulWidget {
  const HomeRekruiterScreen({super.key});

  @override
  State<HomeRekruiterScreen> createState() => _HomeRekruiterScreenState();
}

class _HomeRekruiterScreenState extends State<HomeRekruiterScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              
              // Kartu Statistik (Pelamar & Penawaran)
              _buildStatCards(),
              const SizedBox(height: 24),
              
              // Section Lowongan Aktif
              _buildSectionTitle('Lowongan Aktif', 'Kelola'),
              _buildActiveJobs(),
              const SizedBox(height: 24),
              
              // Section Wawancara Terdekat
              _buildSectionTitle('Wawancara Terjadwal', 'Lihat Semua'),
              _buildUpcomingInterviews(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      // Tombol Tambah Lowongan (Sesuai PRD)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigasi ke halaman Tambah Lowongan
        },
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Lowongan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Kandidat'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Jadwal'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Profil'),
        ],
      ),
    );
  }

  // Header melengkung berwarna gelap (Sama dengan UI Pencari Kerja)
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
                backgroundColor: Colors.white,
                child: Icon(Icons.business, color: Colors.deepPurple, size: 32),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'PT. Kopi Mbois Malang', // Placeholder Nama Perusahaan
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'HR Dashboard',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none, color: Colors.white),
          )
        ],
      ),
    );
  }

  // Kartu Rangkuman Statistik Pelamar & Penawaran
  Widget _buildStatCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          Expanded(child: _statCard('Pelamar Baru', '12', Icons.group_add, Colors.blue)),
          const SizedBox(width: 16),
          Expanded(child: _statCard('Menunggu Respon', '3', Icons.pending_actions, Colors.orange)),
        ],
      ),
    );
  }

  Widget _statCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String actionText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            actionText,
            style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // Horizontal List untuk Lowongan yang sedang Aktif
  Widget _buildActiveJobs() {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          _activeJobCard('Barista Full-time', '15 Pelamar', true),
          _activeJobCard('Waiter Part-time', '8 Pelamar', true),
          _activeJobCard('Kasir', 'Ditutup', false),
        ],
      ),
    );
  }

  Widget _activeJobCard(String role, String statusText, bool isActive) {
    return Container(
      width: 220,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isActive ? Colors.deepPurple : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isActive ? 'Aktif' : 'Non-aktif',
              style: TextStyle(color: isActive ? Colors.white : Colors.black54, fontSize: 10),
            ),
          ),
          const SizedBox(height: 12),
          Text(role, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isActive ? Colors.white : Colors.black87)),
          const SizedBox(height: 8),
          Text(statusText, style: TextStyle(color: isActive ? Colors.white70 : Colors.black54, fontSize: 12)),
        ],
      ),
    );
  }

  // Daftar Wawancara Terjadwal ke Bawah
  Widget _buildUpcomingInterviews() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        children: [
          _interviewTile('Budi Santoso', 'Barista Full-time', 'Besok, 10:00 WIB'),
          const SizedBox(height: 12),
          _interviewTile('Siska Andini', 'Waiter Part-time', 'Senin, 13:00 WIB'),
        ],
      ),
    );
  }

  Widget _interviewTile(String name, String role, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blueGrey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('Melamar: $role', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.deepPurple),
                    const SizedBox(width: 4),
                    Text(time, style: const TextStyle(color: Colors.deepPurple, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check_circle_outline, color: Colors.green),
            tooltip: 'Tandai Selesai (Mark as Done)',
            onPressed: () {
               // TODO: Logika untuk "Mark as Done" sesuai PRD
            },
          )
        ],
      ),
    );
  }
}