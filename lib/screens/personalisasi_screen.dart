import 'package:flutter/material.dart';
import 'package:gawein/screens/home_screen.dart';

class PersonalisasiScreen extends StatefulWidget {
  const PersonalisasiScreen({super.key});

  @override
  State<PersonalisasiScreen> createState() => _PersonalisasiScreenState();
}

class _PersonalisasiScreenState extends State<PersonalisasiScreen> {
  // Daftar kategori sesuai constraint PRD
  final List<String> _kategori = ['Toko/Retail', 'F&B/Cafe/Restoran', 'Gudang & Logistik', 'Helper/Tenaga Umum'];
  final List<String> _selectedKategori = [];

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
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih kategori pekerjaan yang Anda minati agar kami dapat memberikan rekomendasi yang paling cocok.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            Wrap(
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _selectedKategori.isEmpty ? null : () {
                  // Masuk ke Beranda Pencari Kerja
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false, // Hapus history navigasi sebelumnya
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Lanjutkan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}