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
          SnackBar(
            content: Text('Gagal menyimpan peran: $e'),
            backgroundColor: Colors.red,
          ),
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Pilih Peran Anda',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sesuaikan pengalaman Anda di GaweIn',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 40),

                  Row(
                    children: [
                      Expanded(
                        child: _buildRoleCard(
                          title: 'Pelamar',
                          desc: 'Siap Bekerja',
                          image: 'assets/images/Pekerja.png',
                          onTap: () => _updateRole('pencari_kerja'),
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: _buildRoleCard(
                          title: 'Pemilik Usaha',
                          desc : 'Pemberi Lowongan Kerja',
                          image: 'assets/images/Pemilik_Usaha.png',
                          onTap: () => _updateRole('perekrut'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String desc,
    required String image,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Image.asset(
              image,
              height: 110,
            ),

            const SizedBox(height: 16),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              desc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}