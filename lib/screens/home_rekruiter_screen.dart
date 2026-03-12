import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gawein/screens/tambah_lowongan_screen.dart';
import 'package:gawein/screens/profil_screen.dart';
import 'package:gawein/screens/detail_lowongan_screen.dart';

class HomeRekruiterScreen extends StatefulWidget {
  const HomeRekruiterScreen({super.key});

  @override
  State<HomeRekruiterScreen> createState() => _HomeRekruiterScreenState();
}

class _HomeRekruiterScreenState extends State<HomeRekruiterScreen> {
  int _selectedIndex = 0;
  String _companyName = 'Perusahaan';
  String _fullName = 'Perekrut';
  List<Map<String, dynamic>> _myJobs = [];
  int _totalApplicants = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      // Load profile
      final profileData = await Supabase.instance.client
          .from('profiles')
          .select('full_name, company_name')
          .eq('id', user.id)
          .maybeSingle();

      // Load jobs by this recruiter
      final jobsData = await Supabase.instance.client
          .from('jobs')
          .select()
          .eq('recruiter_id', user.id)
          .order('created_at', ascending: false);

      final jobs = List<Map<String, dynamic>>.from(jobsData);

      // Count total applicants across all jobs
      int totalApplicants = 0;
      if (jobs.isNotEmpty) {
        for (final job in jobs) {
          try {
            final count = await Supabase.instance.client
                .from('applications')
                .select('id')
                .eq('job_id', job['id']);
            totalApplicants += (count as List).length;
          } catch (_) {}
        }
      }

      if (mounted) {
        setState(() {
          _fullName = profileData?['full_name'] ?? 'Perekrut';
          _companyName = profileData?['company_name'] ?? 'Perusahaan';
          _myJobs = jobs;
          _totalApplicants = totalApplicants;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeContent(),
      _buildMyJobsContent(),
      const ProfilScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(child: pages[_selectedIndex]),
      floatingActionButton: _selectedIndex < 2
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TambahLowonganScreen()),
                );
                if (result == true) _loadData();
              },
              backgroundColor: Colors.deepPurple,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Lowongan Baru',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
  type: BottomNavigationBarType.fixed,
  currentIndex: _selectedIndex,
  onTap: _onItemTapped,
  selectedItemColor: Colors.deepPurple,
  unselectedItemColor: Colors.grey,
  items: [
  BottomNavigationBarItem(
    icon: _buildNavIcon('assets/images/Beranda.png', 0),
    label: 'Beranda',
  ),
  BottomNavigationBarItem(
    icon: _buildNavIcon('assets/images/Loker.png', 1),
    label: 'Tambah Pekerjaan',
  ),
  BottomNavigationBarItem(
    icon: _buildNavIcon('assets/images/Profil.png', 2),
    label: 'Profil',
  ),
],
),
    );
  }

  Widget _buildHomeContent() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildStatCards(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lowongan Aktif',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _selectedIndex = 1),
                    child: const Text('Lihat Semua', style: TextStyle(color: Colors.deepPurple)),
                  ),
                ],
              ),
            ),
            if (_myJobs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.work_off_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'Belum ada lowongan aktif.\nTap tombol + untuk membuat lowongan baru.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._myJobs.take(3).map((job) => _buildJobCard(job)),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildMyJobsContent() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_myJobs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_off_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('Belum ada lowongan', style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Text(
              'Tap tombol + untuk membuat\nlowongan pekerjaan baru',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _myJobs.length,
        itemBuilder: (context, index) => _buildJobCard(_myJobs[index]),
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
                backgroundColor: Colors.white,
                child: Icon(Icons.business, color: Colors.deepPurple, size: 32),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _companyName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _fullName,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
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
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _statCard(
              'Lowongan Aktif',
              '${_myJobs.length}',
              Icons.work_outline,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _statCard(
              'Total Pelamar',
              '$_totalApplicants',
              Icons.people_outline,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailLowonganScreen(jobData: job)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.work, color: Colors.deepPurple),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['title'] ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job['company_name'] ?? '-',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    if (job['salary'] != null && (job['salary'] as String).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          job['salary'],
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'delete') {
                    await _deleteJob(job['id'].toString());
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Hapus Lowongan'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteJob(String jobId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Lowongan?'),
        content: const Text('Lowongan ini akan dihapus secara permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await Supabase.instance.client.from('jobs').delete().eq('id', jobId);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lowongan berhasil dihapus'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
  Widget _buildNavIcon(String asset, int index) {
  bool isSelected = _selectedIndex == index;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 250),
    transform: Matrix4.translationValues(0, isSelected ? -10 : 0, 0),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: isSelected ? Colors.deepPurple : Colors.transparent,
      shape: BoxShape.circle,
    ),
    child: ImageIcon(
      AssetImage(asset),
      color: isSelected ? Colors.white : Colors.grey,
      size: 24,
    ),
  );
}
}
