import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gawein/screens/login_screen.dart'; // Diubah untuk mengarah ke LoginScreen

class PilihPeranScreen extends StatelessWidget {
  const PilihPeranScreen({super.key});

  // Fungsi untuk update role di database Supabase
  Future<void> _updateRole(BuildContext context, String role) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Sesi login tidak ditemukan, coba login ulang.')),
        );
        return;
      }

      // Gunakan UPSERT untuk menyimpan peran di database
      await supabase.from('profiles').upsert({
        'id': user.id,
        'role': role,
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      if (context.mounted) {
        // Tampilkan pesan sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pendaftaran Selesai! Silakan Login kembali.'), backgroundColor: Colors.green),
        );

        // Logout akun
        await supabase.auth.signOut();

        // Bersihkan seluruh riwayat navigasi dan pindah ke Layar Login
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan peran: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Pilih Peran Anda',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Sesuaikan pengalaman Anda di GaweIn'),
            const SizedBox(height: 40),
            
            // Kartu Pilihan: Pencari Kerja
            _buildRoleCard(
              context,
              title: 'Pencari Kerja',
              desc: 'Saya ingin mencari lowongan pekerjaan terbaik.',
              icon: Icons.person_search,
              onTap: () => _updateRole(context, 'pencari_kerja'),
            ),
            
            const SizedBox(height: 20),
            
            // Kartu Pilihan: Perekrut
            _buildRoleCard(
              context,
              title: 'Perekrut / Perusahaan',
              desc: 'Saya ingin mencari talenta untuk perusahaan.',
              icon: Icons.business_center,
              onTap: () => _updateRole(context, 'perekrut'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, 
      {required String title, required String desc, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.deepPurple),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(desc, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}