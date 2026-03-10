import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gawein/screens/personalisasi_screen.dart';
import 'package:gawein/screens/verifikasi_perusahaan_screen.dart';

class PilihPeranScreen extends StatefulWidget {
  const PilihPeranScreen({super.key});

  @override
  State<PilihPeranScreen> createState() => _PilihPeranScreenState();
}

class _PilihPeranScreenState extends State<PilihPeranScreen> {
  bool _isLoading = false;

  Future<void> _updateRole(String role) async {
    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Sesi login tidak ditemukan.')),
          );
        }
        return;
      }

      await supabase.from('profiles').upsert({
        'id': user.id,
        'email': user.email,
        'full_name': user.userMetadata?['full_name'] ?? '',
        'role': role,
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        if (role == 'pencari_kerja') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PersonalisasiScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const VerifikasiPerusahaanScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan peran: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_pin, size: 64, color: Colors.deepPurple),
                  const SizedBox(height: 16),
                  const Text(
                    'Pilih Peran Anda',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sesuaikan pengalaman Anda di GaweIn',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 40),
                  _buildRoleCard(
                    title: 'Pencari Kerja',
                    desc: 'Saya ingin mencari lowongan pekerjaan terbaik.',
                    icon: Icons.person_search,
                    onTap: () => _updateRole('pencari_kerja'),
                  ),
                  const SizedBox(height: 20),
                  _buildRoleCard(
                    title: 'Perekrut / Perusahaan',
                    desc: 'Saya ingin mencari talenta untuk perusahaan.',
                    icon: Icons.business_center,
                    onTap: () => _updateRole('perekrut'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String desc,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.deepPurple.shade100),
          boxShadow: [
            BoxShadow(color: Colors.deepPurple.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.deepPurple, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.deepPurple, size: 16),
          ],
        ),
      ),
    );
  }
}
