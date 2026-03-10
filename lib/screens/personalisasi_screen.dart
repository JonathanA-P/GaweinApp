import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gawein/screens/home_screen.dart';

class PersonalisasiScreen extends StatefulWidget {
  const PersonalisasiScreen({super.key});

  @override
  State<PersonalisasiScreen> createState() => _PersonalisasiScreenState();
}

class _PersonalisasiScreenState extends State<PersonalisasiScreen> {
  final List<String> _kategori = [
    'Toko/Retail',
    'F&B/Cafe/Restoran',
    'Gudang & Logistik',
    'Helper/Tenaga Umum',
    'Teknologi',
    'Pendidikan',
    'Kesehatan',
    'Kreatif & Desain',
  ];
  final List<String> _selectedKategori = [];
  bool _isLoading = false;

  Future<void> _saveAndContinue() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('profiles').upsert({
          'id': user.id,
          'interests': _selectedKategori.join(', '),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Minat Anda',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih kategori pekerjaan yang Anda minati agar kami dapat memberikan rekomendasi yang paling cocok.',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _kategori.map((kategori) {
                  final isSelected = _selectedKategori.contains(kategori);
                  return FilterChip(
                    label: Text(kategori),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedKategori.add(kategori);
                        } else {
                          _selectedKategori.remove(kategori);
                        }
                      });
                    },
                    selectedColor: Colors.deepPurple,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: Colors.grey.shade100,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: (_selectedKategori.isEmpty || _isLoading) ? null : _saveAndContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Lanjutkan',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
