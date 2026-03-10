import 'package:flutter/material.dart';
import 'package:gawein/screens/home_rekruiter_screen.dart'; // <-- Ini sudah dibuka kuncinya

class VerifikasiPerusahaanScreen extends StatefulWidget {
  const VerifikasiPerusahaanScreen({super.key});

  @override
  State<VerifikasiPerusahaanScreen> createState() => _VerifikasiPerusahaanScreenState();
}

class _VerifikasiPerusahaanScreenState extends State<VerifikasiPerusahaanScreen> {
  final _formKey = GlobalKey<FormState>();

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
              // Header
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

              // Form Input
              _buildTextField('Nama Perusahaan', 'Contoh: PT. GaweIn Sukses', Icons.business),
              const SizedBox(height: 16),
              _buildTextField('Bidang Industri', 'Contoh: F&B / Retail / Teknologi', Icons.category_outlined),
              const SizedBox(height: 16),
              _buildTextField('Nomor Telepon Perusahaan', 'Contoh: 021-xxxxxx', Icons.phone_outlined, isNumber: true),
              const SizedBox(height: 16),
              _buildTextField('Alamat Lengkap Perusahaan', 'Masukkan alamat lengkap', Icons.location_on_outlined, maxLines: 3),
              const SizedBox(height: 24),

              // Bagian Upload Dokumen
              const Text('Dokumen Legalitas (NIB / SIUP)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple.shade200, style: BorderStyle.solid),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.upload_file, size: 40, color: Colors.deepPurple),
                    SizedBox(height: 12),
                    Text('Upload Dokumen', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                    SizedBox(height: 4),
                    Text('Format PDF/JPG/PNG, max 5MB', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Tombol Submit
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      
                      // <-- INI BAGIAN NAVIGASI YANG SUDAH DIBUKA KUNCINYA -->
                      Navigator.pushReplacement(
                        context, 
                        MaterialPageRoute(builder: (context) => const HomeRekruiterScreen()),
                      );
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Verifikasi Berhasil Dikirim!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: const Text('Kirim Verifikasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: maxLines == 1 ? Icon(icon, color: Colors.grey) : null,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.deepPurple, width: 2)),
      ),
      validator: (value) => (value == null || value.isEmpty) ? '$label tidak boleh kosong' : null,
    );
  }
}