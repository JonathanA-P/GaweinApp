import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TambahLowonganScreen extends StatefulWidget {
  const TambahLowonganScreen({super.key});

  @override
  State<TambahLowonganScreen> createState() => _TambahLowonganScreenState();
}

class _TambahLowonganScreenState extends State<TambahLowonganScreen> {
  final _supabase = Supabase.instance.client;
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _salaryController = TextEditingController();
  bool _isLoading = false;

  Future<void> _uploadJob() async {
    if (_titleController.text.isEmpty || _companyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Isi judul dan perusahaan!')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        // Mengirim data ketikan ke tabel 'jobs' di Supabase
        await _supabase.from('jobs').insert({
          'recruiter_id': user.id,
          'title': _titleController.text,
          'company_name': _companyController.text,
          'salary': _salaryController.text,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lowongan di-upload! 🚀')));
          Navigator.pop(context); // Otomatis kembali ke Home setelah sukses
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Lowongan')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Posisi Pekerjaan', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _companyController, decoration: const InputDecoration(labelText: 'Nama Perusahaan', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _salaryController, decoration: const InputDecoration(labelText: 'Gaji', border: OutlineInputBorder())),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _uploadJob,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Upload', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}