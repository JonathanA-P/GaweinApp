import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gawein/screens/home_rekruiter_screen.dart';

class VerifikasiPerusahaanScreen extends StatefulWidget {
  const VerifikasiPerusahaanScreen({super.key});

  @override
  State<VerifikasiPerusahaanScreen> createState() => _VerifikasiPerusahaanScreenState();
}

class _VerifikasiPerusahaanScreenState extends State<VerifikasiPerusahaanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaPerusahaanController = TextEditingController();
  final _bidangIndustriController = TextEditingController();
  final _nomorTeleponController = TextEditingController();
  final _alamatController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _namaPerusahaanController.dispose();
    _bidangIndustriController.dispose();
    _nomorTeleponController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _submitVerification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('profiles').upsert({
          'id': user.id,
          'company_name': _namaPerusahaanController.text.trim(),
          'industry': _bidangIndustriController.text.trim(),
          'phone': _nomorTeleponController.text.trim(),
          'address': _alamatController.text.trim(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selamat datang sebagai Perekrut di GaweIn! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeRekruiterScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Verifikasi Perusahaan',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              const SizedBox(height: 8),
              Text(
                'Lengkapi data di bawah ini agar perusahaan Anda dapat mulai merekrut kandidat terbaik.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
              ),
              const SizedBox(height: 32),
              _buildTextField(
                'Nama Perusahaan',
                'Contoh: PT. GaweIn Sukses',
                Icons.business,
                _namaPerusahaanController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Bidang Industri',
                'Contoh: F&B / Retail / Teknologi',
                Icons.category_outlined,
                _bidangIndustriController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Nomor Telepon Perusahaan',
                'Contoh: 021-xxxxxx',
                Icons.phone_outlined,
                _nomorTeleponController,
                isNumber: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Alamat Lengkap Perusahaan',
                'Masukkan alamat lengkap',
                Icons.location_on_outlined,
                _alamatController,
                maxLines: 3,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Kirim Verifikasi',
                          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
        alignLabelWithHint: maxLines > 1,
      ),
      validator: (value) => (value == null || value.isEmpty) ? '$label tidak boleh kosong' : null,
    );
  }
}
