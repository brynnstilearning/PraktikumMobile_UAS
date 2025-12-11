import 'package:flutter/material.dart';
import 'package:jadwal_kajian_new/services/kajian_service.dart';
import '../models/kajian_model.dart';
import '../config/theme.dart';
import '../services/kajian_service.dart';

// KAJIAN CARD (EXPANDABLE)
// Card untuk menampilkan kajian dengan expand/collapse detail

class KajianCard extends StatefulWidget {
  final Kajian kajian;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const KajianCard({
    super.key,
    required this.kajian,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<KajianCard> createState() => _KajianCardState();
}

class _KajianCardState extends State<KajianCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Parse color dari string
    final categoryColor = Color(int.parse(widget.kajian.categoryColor));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: _toggleExpand,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header (selalu tampil)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Color indicator
                  Container(
                    width: 4,
                    height: 60,
                    decoration: BoxDecoration(
                      color: categoryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: AppColors.textLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.kajian.time,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Title
                        Text(
                          widget.kajian.title,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Ustadz
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: categoryColor.withOpacity(0.2),
                              child: Icon(
                                Icons.person,
                                size: 12,
                                color: categoryColor,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                widget.kajian.ustadz,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Expand icon
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textLight,
                  ),
                ],
              ),

              // Expanded content
              SizeTransition(
                sizeFactor: _expandAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 24),

                    // Date
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      label: 'Tanggal',
                      value: widget.kajian.date,
                    ),
                    const SizedBox(height: 12),

                    // Location
                    _buildDetailRow(
                      icon: Icons.location_on,
                      label: 'Lokasi',
                      value: widget.kajian.location,
                    ),
                    const SizedBox(height: 12),

                    // Theme
                    _buildDetailRow(
                      icon: Icons.book,
                      label: 'Tema',
                      value: widget.kajian.theme,
                    ),

                    // Notes
                    if (widget.kajian.notes.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        icon: Icons.note,
                        label: 'Catatan',
                        value: widget.kajian.notes,
                      ),
                    ],

                    // Category badge
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: categoryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        widget.kajian.category,
                        style: TextStyle(
                          color: categoryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    // TOGGLE SWITCH: TANDAI SELESAI (MODERN!)
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: widget.kajian.status == 'past'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.kajian.status == 'past'
                              ? Colors.green.withOpacity(0.3)
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            widget.kajian.status == 'past'
                                ? Icons.check_circle
                                : Icons.access_time,
                            color: widget.kajian.status == 'past'
                                ? Colors.green
                                : AppColors.textLight,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.kajian.status == 'past'
                                      ? 'Kajian Selesai'
                                      : 'Tandai Sudah Dihadiri',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: widget.kajian.status == 'past'
                                        ? Colors.green
                                        : AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.kajian.status == 'past'
                                      ? 'Kajian ini sudah selesai'
                                      : 'Geser toggle saat sudah hadir',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: widget.kajian.status == 'past',
                            onChanged: (value) {
                              _showMarkAsCompleteDialog();
                            },
                            activeColor: Colors.green,
                          ),
                        ],
                      ),
                    ),

                    // Action buttons (Edit & Delete)
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: widget.onEdit ??
                                () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Fitur Edit belum dikonfigurasi'),
                                    ),
                                  );
                                },
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryPurple,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _showDeleteDialog();
                            },
                            icon: const Icon(Icons.delete, size: 18),
                            label: const Text('Hapus'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textLight),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

// SHOW MARK AS COMPLETE DIALOG
  void _showMarkAsCompleteDialog() {
    final newStatus = widget.kajian.status == 'past' ? 'upcoming' : 'past';
    final message = widget.kajian.status == 'past'
        ? 'Apakah Anda ingin menandai kajian ini sebagai "Akan Datang" lagi?'
        : 'Apakah Anda sudah menghadiri kajian "${widget.kajian.title}"?';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 12),
            Text('Ubah Status?'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog

              // Show loading dengan GlobalKey agar bisa ditutup pasti
              BuildContext? loadingContext;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext ctx) {
                  loadingContext = ctx;
                  return WillPopScope(
                    onWillPop: () async => false,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              );

              try {
                print('🔄 Toggling status to: $newStatus');

                // Toggle status in Firebase
                final result = await KajianService().toggleKajianStatus(
                  widget.kajian.id,
                  newStatus,
                );

                print('📦 Toggle result: ${result['success']}');

                // Close loading - PASTI DITUTUP
                if (loadingContext != null && loadingContext!.mounted) {
                  Navigator.pop(loadingContext!);
                }

                if (!context.mounted) return;

                if (result['success']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message']),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );

                  // Trigger parent reload (auto-refresh)
                  widget.onDelete?.call();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message']),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                print('❌ Error toggling status: $e');

                // Close loading - PASTI DITUTUP
                if (loadingContext != null && loadingContext!.mounted) {
                  Navigator.pop(loadingContext!);
                }

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Ya, Ubah Status'),
          ),
        ],
      ),
    );
  }

  // SHOW DELETE DIALOG
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 12),
            Text('Hapus Kajian?'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus kajian "${widget.kajian.title}"?\n\nData yang dihapus tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog

              // Show loading
              BuildContext? loadingContext;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext ctx) {
                  loadingContext = ctx;
                  return WillPopScope(
                    onWillPop: () async => false,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              );

              try {
                print('🗑️ Deleting kajian: ${widget.kajian.id}');

                // Delete from Firebase
                final result =
                    await KajianService().deleteKajian(widget.kajian.id);

                print('📦 Delete result: ${result['success']}');

                // Close loading
                if (loadingContext != null && loadingContext!.mounted) {
                  Navigator.pop(loadingContext!);
                }

                if (!context.mounted) return;

                if (result['success']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message']),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );

                  // Trigger parent reload
                  // User harus pull to refresh atau restart untuk lihat perubahan
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message']),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                print('❌ Error deleting kajian: $e');

                // Close loading
                if (loadingContext != null && loadingContext!.mounted) {
                  Navigator.pop(loadingContext!);
                }

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );
  }
}
