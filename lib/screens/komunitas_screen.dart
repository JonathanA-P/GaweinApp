import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KomunitasScreen extends StatefulWidget {
  const KomunitasScreen({super.key});

  @override
  State<KomunitasScreen> createState() => _KomunitasScreenState();
}

class _KomunitasScreenState extends State<KomunitasScreen> {
  final _postController = TextEditingController();
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  bool _isPosting = false;
  String? _currentUserName;
  String? _currentUserRole;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load current user profile
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final profileData = await Supabase.instance.client
            .from('profiles')
            .select('full_name, role')
            .eq('id', user.id)
            .maybeSingle();
        _currentUserName = profileData?['full_name'] ?? 'User GaweIn';
        _currentUserRole = profileData?['role'] == 'perekrut'
            ? 'Perwakilan Perusahaan'
            : 'Pencari Kerja';
      }

      // Load posts from Supabase
      final postsData = await Supabase.instance.client
          .from('community_posts')
          .select()
          .order('created_at', ascending: false)
          .limit(20);

      if (mounted) {
        setState(() {
          _posts = List<Map<String, dynamic>>.from(postsData);
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback to empty list if table doesn't exist yet
      if (mounted) {
        setState(() {
          _posts = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createPost() async {
    if (_postController.text.trim().isEmpty) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() => _isPosting = true);
    try {
      await Supabase.instance.client.from('community_posts').insert({
        'user_id': user.id,
        'author_name': _currentUserName ?? 'User GaweIn',
        'author_role': _currentUserRole ?? 'Pencari Kerja',
        'content': _postController.text.trim(),
        'likes_count': 0,
        'created_at': DateTime.now().toIso8601String(),
      });

      _postController.clear();
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Postingan berhasil dipublikasikan!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal posting: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  Future<void> _likePost(Map<String, dynamic> post) async {
    try {
      final currentLikes = (post['likes_count'] ?? 0) as int;
      await Supabase.instance.client
          .from('community_posts')
          .update({'likes_count': currentLikes + 1}).eq('id', post['id']);
      await _loadData();
    } catch (_) {}
  }

  String _timeAgo(String? createdAt) {
    if (createdAt == null) return '';
    final now = DateTime.now();
    final created = DateTime.parse(createdAt).toLocal();
    final diff = now.difference(created);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    return '${diff.inDays} hari yang lalu';
  }

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
            icon: const Icon(Icons.refresh, color: Colors.deepPurple),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Create Post Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.deepPurple,
                      child: Text(
                        (_currentUserName ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _postController,
                        maxLines: 3,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Tanya atau berbagi seputar dunia kerja...',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: _isPosting ? null : _createPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      child: _isPosting
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Post'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Posts Feed
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _posts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.forum_outlined, size: 80, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum ada postingan.\nJadi yang pertama berbagi!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: _posts.length,
                          itemBuilder: (context, index) =>
                              _buildPostCard(_posts[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final name = post['author_name'] ?? 'User';
    final role = post['author_role'] ?? '';
    final content = post['content'] ?? '';
    final likes = post['likes_count'] ?? 0;
    final time = _timeAgo(post['created_at']);
    final avatarColors = [
      Colors.orange,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.red,
    ];
    final avatarColor = avatarColors[name.hashCode % avatarColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: avatarColor,
                child: Text(
                  name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Row(
                      children: [
                        Text(role, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        if (time.isNotEmpty) ...[
                          const Text(' • ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: () => _likePost(post),
                child: Row(
                  children: [
                    Icon(Icons.favorite_border, size: 20, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text('$likes', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    const SizedBox(width: 4),
                    Text('Suka', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
