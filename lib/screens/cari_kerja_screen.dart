import 'package:flutter/material.dart';

class CariKerjaScreen extends StatefulWidget {
  const CariKerjaScreen({super.key});

  @override
  State<CariKerjaScreen> createState() => _CariKerjaScreenState();
}

class _CariKerjaScreenState extends State<CariKerjaScreen> {
  // Dummy data lowongan kerja di Malang sesuai constraint low-level informal
  final List<Map<String, dynamic>> _jobList = [
    {
      "role": "Barista / Waiter",
      "company": "Kopi Mbois Malang",
      "location": "Lowokwaru, Malang",
      "salary": "Rp 1.500.000 - Rp 2.000.000",
      "type": "F&B / Restoran",
      "flexibility": "Bulanan",
      "isVerified": true,
      "icon": Icons.coffee,
    },
    {
      "role": "Staff Gudang Logistik",
      "company": "PT. Logistik Jaya Abadi",
      "location": "Klojen, Malang",
      "salary": "Rp 2.000.000 - Rp 2.500.000",
      "type": "Gudang & Logistik",
      "flexibility": "Bulanan",
      "isVerified": true,
      "icon": Icons.inventory_2_outlined,
    },
    {
      "role": "Helper Tenaga Umum",
      "company": "Proyek Bangunan Sentosa",
      "location": "Blimbing, Malang",
      "salary": "Rp 80.000 - Rp 100.000 / Hari",
      "type": "Helper / Tenaga Umum",
      "flexibility": "Harian",
      "isVerified": false,
      "icon": Icons.handyman_outlined,
    },
    {
      "role": "Asisten Toko / Retail",
      "company": "Toko Kelontong Berkah",
      "location": "Sukun, Malang",
      "salary": "Rp 1.200.000 - Rp 1.500.000",
      "type": "Toko / Retail",
      "flexibility": "Bulanan",
      "isVerified": true,
      "icon": Icons.storefront_outlined,
    },
  ];

  // Fungsi untuk memunculkan Bottom Sheet Filter
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Lowongan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              const Text('Jenis Pekerjaan', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip('Toko/Retail'),
                  _buildFilterChip('F&B/Cafe'),
                  _buildFilterChip('Gudang & Logistik'),
                  _buildFilterChip('Helper Umum'),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Fleksibilitas Pekerjaan', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip('Harian'),
                  _buildFilterChip('Mingguan'),
                  _buildFilterChip('Bulanan'),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Rentang Gaji', style: TextStyle(fontWeight: FontWeight.bold)),
              // Bisa diganti RangeSlider di kemudian hari
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip('< Rp 1 Juta'),
                  _buildFilterChip('Rp 1 - 2 Juta'),
                  _buildFilterChip('> Rp 2 Juta'),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Terapkan Filter'),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label),
      onSelected: (bool selected) {},
      selectedColor: Colors.deepPurple.shade100,
      checkmarkColor: Colors.deepPurple,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Background putih/abu terang sesuai catatan PRD
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Cari Kerja, Yuk!', // Sesuai referensi punchline PRD
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.deepPurple),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari lowongan pekerjaan...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Tombol Filter Tunggal
                InkWell(
                  onTap: _showFilterBottomSheet,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          
          // Job List Section (Memanjang ke bawah)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _jobList.length,
              itemBuilder: (context, index) {
                final job = _jobList[index];
                return _buildJobCard(job);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Job Card bergaya Google reference dipadukan dengan aksen ungu
  Widget _buildJobCard(Map<String, dynamic> job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Icon/Logo Placeholder
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(job['icon'], color: Colors.deepPurple, size: 28),
              ),
              const SizedBox(width: 16),
              // Job Details Header
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['role'],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          job['company'],
                          style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                        ),
                        if (job['isVerified']) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: Colors.blue, size: 16),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
              // More options button
              const Icon(Icons.more_vert, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 16),
          // Location & Type Tags
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(job['location'], style: const TextStyle(color: Colors.grey)),
              const SizedBox(width: 16),
              const Icon(Icons.schedule, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(job['flexibility'], style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          // Salary and Apply Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                job['salary'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Navigasi ke halaman Detail Pekerjaan -> Apply
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade50,
                  foregroundColor: Colors.deepPurple,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Detail'),
              ),
            ],
          )
        ],
      ),
    );
  }
}