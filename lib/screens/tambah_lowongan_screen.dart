import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TambahLowonganScreen extends StatefulWidget {
  const TambahLowonganScreen({super.key});

  @override
  State<TambahLowonganScreen> createState() => _TambahLowonganScreenState();
}

class _TambahLowonganScreenState extends State<TambahLowonganScreen> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _salaryController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _prefillCompanyName();
  }

  Future<void> _prefillCompanyName() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      final data = await _supabase
          .from('profiles')
          .select('company_name')
          .eq('id', user.id)
          .maybeSingle();
      if (data != null && data['company_name'] != null && mounted) {
        _companyController.text = data['company_name'];
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _salaryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _uploadJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase.from('jobs').insert({
          'recruiter_id': user.id,
          'title': _titleController.text.trim(),
          'company_name': _companyController.text.trim(),
          'salary': _salaryController.text.trim(),
          'description': _descriptionController.text.trim(),
          'created_at': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lowongan berhasil dipublikasikan! 🚀'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to trigger parent refresh
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Lowongan'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detail Lowongan Pekerjaan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Job Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Posisi Pekerjaan *',
                  prefixIcon: const Icon(Icons.work_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Posisi pekerjaan tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              // Company Name
              TextFormField(
                controller: _companyController,
                decoration: InputDecoration(
                  labelText: 'Nama Perusahaan *',
                  prefixIcon: const Icon(Icons.business_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Nama perusahaan tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              // Salary
              TextFormField(
                controller: _salaryController,
                decoration: InputDecoration(
                  labelText: 'Estimasi Gaji',
                  hintText: 'Contoh: Rp 2.000.000 - 3.000.000',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: 'Deskripsi Pekerjaan *',
                  hintText:
                      'Tulis kualifikasi, tugas, jam kerja, dan informasi relevan lainnya...',
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 100),
                    child: Icon(Icons.description_outlined),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Deskripsi pekerjaan tidak boleh kosong' : null,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _uploadJob,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isLoading
                      ? const SizedBox.shrink()
                      : const Icon(Icons.publish, color: Colors.white),
                  label: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Publikasikan Lowongan',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
