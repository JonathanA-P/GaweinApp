import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailLowonganScreen extends StatefulWidget {
  final Map<String, dynamic> jobData;

  const DetailLowonganScreen({super.key, required this.jobData});

  @override
  State<DetailLowonganScreen> createState() => _DetailLowonganScreenState();
}

class _DetailLowonganScreenState extends State<DetailLowonganScreen> {
  bool _isApplying = false;
  bool _alreadyApplied = false;
  bool _isRecruiter = false;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyApplied();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();
      if (mounted) setState(() => _isRecruiter = data?['role'] == 'perekrut');
    } catch (_) {}
  }

  Future<void> _checkIfAlreadyApplied() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || widget.jobData['id'] == null) return;

    try {
      final data = await Supabase.instance.client
          .from('applications')
          .select('id')
          .eq('job_id', widget.jobData['id'])
          .eq('applicant_id', user.id)
          .maybeSingle();

      if (mounted) setState(() => _alreadyApplied = data != null);
    } catch (_) {}
  }

  Future<void> _applyJob() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda perlu login terlebih dahulu')),
      );
      return;
    }

    setState(() => _isApplying = true);
    try {
      await Supabase.instance.client.from('applications').insert({
        'job_id': widget.jobData['id'],
        'applicant_id': user.id,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        setState(() => _alreadyApplied = true);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            title: const Text('Lamaran Terkirim! '),
            content: Text(
              'Anda telah berhasil melamar posisi ${widget.jobData['title']} di ${widget.jobData['company_name']}. Kami akan menghubungi Anda segera.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // go back
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        // Code 23505 = unique violation (already applied)
        if (e.code == '23505') {
          setState(() => _alreadyApplied = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Anda sudah melamar posisi ini sebelumnya'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal melamar: ${e.message}'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Lowongan'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Header
            Row(
              children: [
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.business, size: 32, color: Colors.deepPurple),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.jobData['title'] ?? '-',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.jobData['company_name'] ?? '-',
                        style: const TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Salary Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.green),
                  const SizedBox(width: 12),
                  Text(
                    'Estimasi Gaji: ${widget.jobData['salary'] ?? 'Tidak disebutkan'}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),

            if (_alreadyApplied) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Anda sudah melamar posisi ini', style: TextStyle(color: Colors.blue)),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
            const Text(
              'Deskripsi Pekerjaan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              widget.jobData['description'] ??
                  'Tidak ada deskripsi yang disediakan oleh perusahaan.',
              style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 55,
            child: _isRecruiter
                ? OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Anda adalah Rekruiter',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                    ),
                  )
                : ElevatedButton(
                    onPressed: (_isApplying || _alreadyApplied) ? null : _applyJob,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _alreadyApplied ? Colors.grey.shade400 : Colors.deepPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isApplying
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _alreadyApplied ? 'Sudah Dilamar ' : 'Apply Now',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
          ),
        ),
      ),
    );
  }
}
