import 'package:flutter/material.dart';

class KursusScreen extends StatefulWidget {
  const KursusScreen({super.key});

  @override
  State<KursusScreen> createState() => _KursusScreenState();
}

class _KursusScreenState extends State<KursusScreen> {
  // Dummy data untuk kursus yang sedang diambil (My Course)
  final List<Map<String, dynamic>> _myCourses = [
    {
      "title": "Java OOP Masterclass",
      "lessons": "12 lesson",
      "time": "1h 15m",
      "progress": 0.6, // 60%
      "icon": Icons.data_object,
      "color": Colors.orange,
    },
    {
      "title": "Kewirausahaan Mahasiswa",
      "lessons": "8 lesson",
      "time": "45m",
      "progress": 0.3, // 30%
      "icon": Icons.storefront,
      "color": Colors.blue,
    },
  ];

  // Dummy data untuk Kursus Populer
  final List<Map<String, dynamic>> _popularCourses = [
    {
      "title": "Pengantar AI & Machine Learning",
      "instructor": "Budi Setiawan",
      "price": "Gratis",
      "time": "2h 30m",
      "icon": Icons.memory,
      "color": Colors.deepPurple,
    },
    {
      "title": "Dasar Keamanan Siber (Security Eng.)",
      "instructor": "Siska",
      "price": "Gratis",
      "time": "1h 50m",
      "icon": Icons.security,
      "color": Colors.redAccent,
    },
    {
      "title": "Pengenalan Game Development",
      "instructor": "Agus M.",
      "price": "Gratis",
      "time": "3h 10m",
      "icon": Icons.videogame_asset,
      "color": Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome,',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const Text(
              'Alfredo',
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.deepPurple),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar [cite: 276]
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search for any course...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Kategori Kursus (Filter Horizontal)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip('All Course', true),
                    _buildCategoryChip('Design', false),
                    _buildCategoryChip('Coding', false),
                    _buildCategoryChip('Business', false),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Bagian My Course [cite: 277]
              const Text(
                'My Course',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _myCourses.length,
                  itemBuilder: (context, index) {
                    final course = _myCourses[index];
                    return _buildMyCourseCard(course);
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Bagian Popular Course [cite: 278]
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Popular Course',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'See All',
                    style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _popularCourses.length,
                itemBuilder: (context, index) {
                  final course = _popularCourses[index];
                  return _buildPopularCourseTile(course);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Filter Chip Category
  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.deepPurple : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // Card untuk kursus yang sedang berjalan
  Widget _buildMyCourseCard(Map<String, dynamic> course) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: course['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(course['icon'], color: course['color'], size: 30),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${course['time']} • ${course['lessons']}',
                  style: const TextStyle(fontSize: 10, color: Colors.deepPurple, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            course['title'],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Progress Bar
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: course['progress'],
                  backgroundColor: Colors.grey.shade200,
                  color: course['color'],
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(course['progress'] * 100).toInt()}%',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              )
            ],
          )
        ],
      ),
    );
  }

  // List Tile untuk kursus populer
  Widget _buildPopularCourseTile(Map<String, dynamic> course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: course['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(course['icon'], color: course['color'], size: 35),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      course['instructor'],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      course['price'],
                      style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      course['time'],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}