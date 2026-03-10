import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gawein/screens/detail_lowongan_screen.dart'; // Import halaman detail

class CariKerjaScreen extends StatefulWidget {
  const CariKerjaScreen({super.key});

  @override
  State<CariKerjaScreen> createState() => _CariKerjaScreenState();
}

class _CariKerjaScreenState extends State<CariKerjaScreen> {
  final _supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Pekerjaan'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        // Mengambil SEMUA data dari tabel 'jobs'
        future: _supabase.from('jobs').select().order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada lowongan tersedia.'));
          }

          final jobs = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade50,
                    child: const Icon(Icons.business, color: Colors.deepPurple),
                  ),
                  title: Text(job['title'] ?? 'Posisi', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(job['company_name'] ?? 'Perusahaan'),
                      const SizedBox(height: 4),
                      Text(job['salary'] ?? '-', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Pindah ke halaman detail saat di-klik
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailLowonganScreen(jobData: job),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}