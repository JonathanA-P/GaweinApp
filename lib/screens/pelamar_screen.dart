import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PelamarScreen extends StatefulWidget {
  final String jobId;
  final String jobTitle;

  const PelamarScreen({super.key, required this.jobId, required this.jobTitle});

  @override
  State<PelamarScreen> createState() => _PelamarScreenState();
}

class _PelamarScreenState extends State<PelamarScreen> {
  List<Map<String, dynamic>> _applicants = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadApplicants();
  }

  Future<void> _loadApplicants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final appsData = await Supabase.instance.client
          .from('applications')
          .select('id, applicant_id, status, created_at')
          .eq('job_id', widget.jobId)
          .order('created_at', ascending: false);

      List<Map<String, dynamic>> enrichedApps = [];
      for (var app in appsData) {
        final Map<String, dynamic> appMap = Map<String, dynamic>.from(app as Map);
        try {
          final profile = await Supabase.instance.client
              .from('profiles')
              .select('full_name, avatar_url, bio')
              .eq('id', appMap['applicant_id'])
              .maybeSingle();
          appMap['profiles'] = profile;
        } catch (_) {
          appMap['profiles'] = null;
        }
        enrichedApps.add(appMap);
      }

      if (mounted) {
        setState(() {
          _applicants = enrichedApps;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateStatus(String applicationId, String newStatus) async {
    try {
      await Supabase.instance.client
          .from('applications')
          .update({'status': newStatus})
          .eq('id', applicationId);

      // Update local state
      setState(() {
        final idx = _applicants.indexWhere((a) => a['id'].toString() == applicationId);
        if (idx != -1) {
          _applicants[idx] = {..._applicants[idx], 'status': newStatus};
        }
      });

      if (mounted) {
        final label = newStatus == 'accepted'
            ? 'Diterima'
            : newStatus == 'rejected'
                ? 'Ditolak'
                : 'Pending';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status diubah ke $label'),
            backgroundColor: newStatus == 'accepted'
                ? Colors.green
                : newStatus == 'rejected'
                    ? Colors.red
                    : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah status: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'accepted':
        return 'Diterima';
      case 'rejected':
        return 'Ditolak';
      default:
        return 'Pending';
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.hourglass_top;
    }
  }

  void _showStatusDialog(Map<String, dynamic> applicant) {
    final profile = applicant['profiles'] as Map<String, dynamic>?;
    final name = profile?['full_name'] ?? 'Pelamar';
    final currentStatus = applicant['status'] ?? 'pending';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ubah Status - $name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pilih status untuk pelamar ini:'),
            const SizedBox(height: 16),
            _statusOptionTile(
              applicant['id'].toString(),
              'pending',
              currentStatus,
              Icons.hourglass_top,
              Colors.orange,
              'Pending',
            ),
            _statusOptionTile(
              applicant['id'].toString(),
              'accepted',
              currentStatus,
              Icons.check_circle,
              Colors.green,
              'Diterima',
            ),
            _statusOptionTile(
              applicant['id'].toString(),
              'rejected',
              currentStatus,
              Icons.cancel,
              Colors.red,
              'Ditolak',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _statusOptionTile(
    String applicationId,
    String status,
    String currentStatus,
    IconData icon,
    Color color,
    String label,
  ) {
    final isSelected = currentStatus == status;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      trailing: isSelected ? Icon(Icons.check, color: color) : null,
      tileColor: isSelected ? color.withOpacity(0.08) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () async {
        Navigator.pop(context);
        if (!isSelected) await _updateStatus(applicationId, status);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daftar Pelamar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              widget.jobTitle,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E1B3A),
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_applicants.length} pelamar',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 12),
            Text('Gagal memuat data', style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _loadApplicants,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            ),
          ],
        ),
      );
    }

    if (_applicants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Belum ada pelamar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pelamar yang mendaftar akan\nmuncul di sini',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Summary chips
    final pendingCount = _applicants.where((a) => (a['status'] ?? 'pending') == 'pending').length;
    final acceptedCount = _applicants.where((a) => a['status'] == 'accepted').length;
    final rejectedCount = _applicants.where((a) => a['status'] == 'rejected').length;

    return RefreshIndicator(
      onRefresh: _loadApplicants,
      child: Column(
        children: [
          // Summary bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _summaryChip('Pending', pendingCount, Colors.orange),
                const SizedBox(width: 8),
                _summaryChip('Diterima', acceptedCount, Colors.green),
                const SizedBox(width: 8),
                _summaryChip('Ditolak', rejectedCount, Colors.red),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _applicants.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _buildApplicantCard(_applicants[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicantCard(Map<String, dynamic> applicant) {
    final profile = applicant['profiles'] as Map<String, dynamic>?;
    final name = profile?['full_name'] ?? 'Nama tidak tersedia';
    final bio = profile?['bio'] as String?;
    final avatarUrl = profile?['avatar_url'] as String?;
    final status = applicant['status'] ?? 'pending';
    final appliedAt = applicant['created_at'] != null
        ? DateTime.tryParse(applicant['created_at'].toString())
        : null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.deepPurple.shade100,
                  backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: avatarUrl == null || avatarUrl.isEmpty
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (appliedAt != null)
                        Text(
                          'Melamar ${_formatDate(appliedAt)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _statusColor(status).withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(status), size: 12, color: _statusColor(status)),
                      const SizedBox(width: 4),
                      Text(
                        _statusLabel(status),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _statusColor(status),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (bio != null && bio.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Text(
                bio,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showStatusDialog(applicant),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Ubah Status'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.deepPurple,
                  side: const BorderSide(color: Colors.deepPurple),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'hari ini';
    if (diff.inDays == 1) return 'kemarin';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} minggu lalu';
    return '${date.day}/${date.month}/${date.year}';
  }
}
