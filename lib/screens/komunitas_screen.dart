import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  String? _currentUserId;
  XFile? _selectedImage;
  final Set<dynamic> _likedPostIds = {};

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (image != null && mounted) setState(() => _selectedImage = image);
  }

  Future<String?> _uploadPostImage(String userId) async {
    if (_selectedImage == null) return null;
    try {
      final bytes = await _selectedImage!.readAsBytes()
          .timeout(const Duration(seconds: 30));
      final ext = _selectedImage!.path.split('.').last.toLowerCase();
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';
      await Supabase.instance.client.storage
          .from('post-images')
          .uploadBinary(fileName, bytes,
              fileOptions: const FileOptions(upsert: true))
          .timeout(const Duration(seconds: 30));
      return Supabase.instance.client.storage
          .from('post-images')
          .getPublicUrl(fileName);
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadData({bool showSpinner = true}) async {
    if (showSpinner && mounted) setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final profileData = await Supabase.instance.client
            .from('profiles')
            .select('full_name, role')
            .eq('id', user.id)
            .maybeSingle()
            .timeout(const Duration(seconds: 10));
        final name = profileData?['full_name'] as String?;
        final meta = user.userMetadata?['full_name'] as String?;
        _currentUserName = (name?.isNotEmpty == true ? name : meta) ?? 'User GaweIn';
        _currentUserRole = profileData?['role'] == 'perekrut'
            ? 'Perwakilan Perusahaan'
            : 'Pencari Kerja';
        _currentUserId = user.id;
      }

      final postsData = await Supabase.instance.client
          .from('community_posts')
          .select()
          .order('created_at', ascending: false)
          .limit(20)
          .timeout(const Duration(seconds: 10));

      if (mounted) {
        setState(() {
          _posts = List<Map<String, dynamic>>.from(postsData);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _posts = [];
          _isLoading = false;
        });
        if (showSpinner) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _createPost() async {
    if (_postController.text.trim().isEmpty && _selectedImage == null) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() => _isPosting = true);
    try {
      final imageUrl = await _uploadPostImage(user.id);
      await Supabase.instance.client.from('community_posts').insert({
        'user_id': user.id,
        'author_name': _currentUserName ?? 'User GaweIn',
        'author_role': _currentUserRole ?? 'Pencari Kerja',
        'content': _postController.text.trim(),
        'image_url': imageUrl,
        'likes_count': 0,
        'created_at': DateTime.now().toIso8601String(),
      });

      _postController.clear();
      setState(() => _selectedImage = null);
      await _loadData(showSpinner: false);

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
    final postId = post['id'];
    if (_likedPostIds.contains(postId)) return; // already liked
    _likedPostIds.add(postId);

    // Optimistic update: increment locally immediately
    final idx = _posts.indexWhere((p) => p['id'] == postId);
    if (idx != -1) {
      setState(() {
        _posts[idx] = Map.from(_posts[idx])
          ..['likes_count'] = (_posts[idx]['likes_count'] ?? 0) + 1;
      });
    }
    try {
      await Supabase.instance.client
          .from('community_posts')
          .update({'likes_count': (post['likes_count'] ?? 0) + 1})
          .eq('id', postId)
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      // Revert on failure
      _likedPostIds.remove(postId);
      if (idx != -1 && mounted) {
        setState(() {
          _posts[idx] = Map.from(_posts[idx])
            ..['likes_count'] = (_posts[idx]['likes_count'] ?? 1) - 1;
        });
      }
    }
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
                if (_selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_selectedImage!.path),
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedImage = null),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _isPosting ? null : _pickImage,
                      icon: const Icon(Icons.image_outlined, color: Colors.deepPurple),
                      tooltip: 'Tambah foto',
                    ),
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
              if (post['user_id'] == _currentUserId)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') _deletePost(post);
                  },
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade400, size: 20),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus Postingan', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
          const SizedBox(height: 12),
          if (post['image_url'] != null && (post['image_url'] as String).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post['image_url'],
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: () => _likePost(post),
                child: Row(
                  children: [
                    Icon(
                      _likedPostIds.contains(post['id']) ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: _likedPostIds.contains(post['id']) ? Colors.red : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text('$likes', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    const SizedBox(width: 4),
                    Text('Suka', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () => _showCommentsSheet(post),
                child: Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text('Komentar', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _deletePost(Map<String, dynamic> post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Postingan?'),
        content: const Text('Postingan ini akan dihapus secara permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      // Hapus komentar terkait postingan ini terlebih dahulu
      await Supabase.instance.client
          .from('community_comments')
          .delete()
          .eq('post_id', post['id']);

      // Hapus postingan
      final deletedPost = await Supabase.instance.client
          .from('community_posts')
          .delete()
          .eq('id', post['id'])
          .select();

      if (deletedPost.isEmpty) {
        throw Exception('Postingan tidak ditemukan atau tidak memiliki akses (mungkin karena pengaturan izin database).');
      }

      if (mounted) {
        setState(() => _posts.removeWhere((p) => p['id'] == post['id']));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Postingan berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showCommentsSheet(Map<String, dynamic> post) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CommentsSheet(
        post: post,
        currentUserName: _currentUserName ?? 'User GaweIn',
        currentUserRole: _currentUserRole ?? 'Pencari Kerja',
      ),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  final Map<String, dynamic> post;
  final String currentUserName;
  final String currentUserRole;

  const _CommentsSheet({
    required this.post,
    required this.currentUserName,
    required this.currentUserRole,
  });

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      final data = await Supabase.instance.client
          .from('community_comments')
          .select()
          .eq('post_id', widget.post['id'])
          .order('created_at', ascending: true)
          .timeout(const Duration(seconds: 10));
      if (mounted) {
        setState(() {
          _comments = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() => _isPosting = true);
    try {
      await Supabase.instance.client.from('community_comments').insert({
        'post_id': widget.post['id'],
        'user_id': user.id,
        'author_name': widget.currentUserName,
        'author_role': widget.currentUserRole,
        'content': _commentController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });
      _commentController.clear();
      await _loadComments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  String _timeAgo(String? createdAt) {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(DateTime.parse(createdAt).toLocal());
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline, color: Colors.deepPurple),
                const SizedBox(width: 8),
                const Text('Komentar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada komentar.\nJadi yang pertama!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _comments.length,
                        itemBuilder: (_, index) {
                          final c = _comments[index];
                          final name = c['author_name'] ?? 'User';
                          final avatarColors = [Colors.orange, Colors.blue, Colors.green, Colors.purple, Colors.red];
                          final color = avatarColors[name.hashCode % avatarColors.length];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: color,
                                  child: Text(
                                    name[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                            const Spacer(),
                                            Text(_timeAgo(c['created_at']),
                                                style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(c['content'] ?? '', style: const TextStyle(fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 16, right: 16, top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Tulis komentar...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _isPosting ? null : _postComment,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                    child: _isPosting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
