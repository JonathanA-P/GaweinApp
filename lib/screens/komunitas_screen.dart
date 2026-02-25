import 'package:flutter/material.dart';

class KomunitasScreen extends StatefulWidget {
  const KomunitasScreen({super.key});

  @override
  State<KomunitasScreen> createState() => _KomunitasScreenState();
}

class _KomunitasScreenState extends State<KomunitasScreen> {
  // Dummy data untuk feed komunitas
  final List<Map<String, dynamic>> _posts = [
    {
      "name": "Siska Andini",
      "role": "Pencari Kerja",
      "time": "2 jam yang lalu",
      "content": "Halo teman-teman, adakah yang tahu info loker part-time di daerah Suhat Malang untuk mahasiswa? Preferensi F&B atau barista. Terima kasih sebelumnya! 🙏",
      "hasImage": false,
      "likes": 12,
      "comments": 5,
      "avatarColor": Colors.orange,
    },
    {
      "name": "HR Kopi Mbois",
      "role": "Perwakilan Perusahaan",
      "time": "5 jam yang lalu",
      "content": "Tips buat teman-teman yang mau melamar sebagai Waiter/Barista: Pastikan kalian menonjolkan pengalaman organisasi atau pelayanan yang pernah kalian ikuti. Sikap ramah dan komunikatif itu nomor satu! Semangat kerjanya 💪",
      "hasImage": true,
      "imageUrl": "https://via.placeholder.com/400x200.png?text=Tips+Interview+Kerja", // Placeholder gambar
      "likes": 48,
      "comments": 14,
      "avatarColor": Colors.blue,
    },
    {
      "name": "Budi Santoso",
      "role": "Pekerja Gudang",
      "time": "1 hari yang lalu",
      "content": "Kemarin habis ikut kursus Manajemen Logistik Dasar dari GaweIn, materinya daging banget buat yang mau ngelamar jadi staff gudang. Rekomen banget buat kalian ambil mumpung gratis!",
      "hasImage": false,
      "likes": 24,
      "comments": 2,
      "avatarColor": Colors.green,
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Komunitas',
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.deepPurple),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.deepPurple),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Section "Upload Bar" (Sesuai PRD)
          _buildCreatePostSection(),
          
          // Section Feed Komunitas
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return _buildPostCard(post);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk membuat postingan baru
  Widget _buildCreatePostSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.deepPurple,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tanya seputar dunia kerja...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Upload Foto Button (Sesuai Constraint: Hanya Foto)
              TextButton.icon(
                onPressed: () {
                  // Aksi upload foto
                },
                icon: const Icon(Icons.image_outlined, color: Colors.green),
                label: const Text('Foto', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  // Aksi Post
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: const Text('Post'),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Widget untuk Card setiap Postingan
  Widget _buildPostCard(Map<String, dynamic> post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Postingan (Avatar, Nama, Waktu)
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: post['avatarColor'],
                child: Text(
                  post['name'][0], 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Row(
                      children: [
                        Text(
                          post['role'],
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        const Text('•', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          post['time'],
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz, color: Colors.grey),
                onPressed: () {},
              )
            ],
          ),
          const SizedBox(height: 12),
          
          // Caption / Text Bar
          Text(
            post['content'],
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          
          // Opsional Foto
          if (post['hasImage']) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post['imageUrl'],
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          const Divider(),
          
          // Action Buttons (Like & Comment)
          Row(
            children: [
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    const Icon(Icons.favorite_border, color: Colors.grey, size: 20),
                    const SizedBox(width: 6),
                    Text('${post['likes']}', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 20),
                    const SizedBox(width: 6),
                    Text('${post['comments']}', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}