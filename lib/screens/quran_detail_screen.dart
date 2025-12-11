import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/surat_model.dart';
import '../models/ayat_model.dart';
import '../services/quran_service.dart';

// QURAN DETAIL SCREEN
// Screen untuk menampilkan detail ayat-ayat dalam surat

class QuranDetailScreen extends StatefulWidget {
  final Surat surat;

  const QuranDetailScreen({
    super.key,
    required this.surat,
  });

  @override
  State<QuranDetailScreen> createState() => _QuranDetailScreenState();
}

class _QuranDetailScreenState extends State<QuranDetailScreen> {
  final QuranService _quranService = QuranService();

  Surat? _suratDetail;
  bool _isLoading = true;
  bool _showTransliteration = true;
  double _arabicFontSize = 28.0;
  double _translationFontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _loadSuratDetail();
  }

// Load detail surat dengan ayat-ayat
Future<void> _loadSuratDetail() async {
  setState(() => _isLoading = true);

  try {
    final suratDetail = await _quranService.loadSuratDetail(widget.surat.number);

    if (suratDetail != null) {
      setState(() {
        _suratDetail = suratDetail;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);

      if (!mounted) return;

      _showNotAvailableDialog();
    }
  } catch (e) {
    print('Error loading surat detail: $e');
    setState(() => _isLoading = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat detail surat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  // Show dialog surat belum tersedia
  void _showNotAvailableDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange),
            SizedBox(width: 12),
            Text('Belum Tersedia'),
          ],
        ),
        content: Text(
          'Surat ${widget.surat.name} belum tersedia.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to list
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar dengan info surat
          _buildSliverAppBar(),

          // Loading atau content
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _suratDetail == null
                  ? SliverFillRemaining(
                      child: _buildNotAvailableState(),
                    )
                  : SliverList(
                      delegate: SliverChildListDelegate([
                        // Bismillah (kecuali At-Taubah)
                        if (widget.surat.number != 9) _buildBismillah(),

                        // List ayat
                        ..._buildAyatList(),

                        const SizedBox(height: 100),
                      ]),
                    ),
        ],
      ),

      // Floating action button untuk settings
      floatingActionButton: _suratDetail != null
          ? FloatingActionButton(
              onPressed: _showSettingsBottomSheet,
              backgroundColor: AppColors.accentGreen,
              child: const Icon(Icons.settings),
            )
          : null,
    );
  }

  // BUILD SLIVER APP BAR
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.surat.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accentGreen,
                AppColors.accentGreen.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    widget.surat.nameArabic,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.surat.nameTranslation,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.surat.revelationType,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${widget.surat.numberOfAyat} Ayat',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // BUILD BISMILLAH
  Widget _buildBismillah() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentGreen.withOpacity(0.3),
        ),
      ),
      child: const Center(
        child: Text(
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.accentGreen,
            height: 2,
          ),
        ),
      ),
    );
  }

  // BUILD AYAT LIST
  List<Widget> _buildAyatList() {
    if (_suratDetail?.ayatList == null) return [];

    return _suratDetail!.ayatList!.map((ayat) {
      return _buildAyatCard(ayat);
    }).toList();
  }

  Widget _buildAyatCard(Ayat ayat) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF2D2D2D), // Dark card background
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nomor ayat & action buttons
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${ayat.numberInSurat}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const Spacer(),

                // Action buttons
                IconButton(
                  icon: const Icon(Icons.bookmark_border, size: 20),
                  color: Colors.white70,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fitur bookmark akan segera tersedia'),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share, size: 20),
                  color: Colors.white70,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fitur share akan segera tersedia'),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Text Arab - RIGHT TO LEFT
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                ayat.textArabic,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl, // RTL untuk Arab
                style: TextStyle(
                  fontSize: _arabicFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 2.2, // Spasi antar baris
                  fontFamily: 'Arial', // Atau font Arab lainnya
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Transliterasi (optional)
            if (_showTransliteration) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ayat.textTransliteration,
                  style: TextStyle(
                    fontSize: _translationFontSize,
                    fontStyle: FontStyle.italic,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Terjemahan
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.transparent,
                border: Border(
                  left: BorderSide(
                    color: AppColors.accentGreen,
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                ayat.textTranslation,
                style: TextStyle(
                  fontSize: _translationFontSize,
                  color: Colors.white,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BUILD NOT AVAILABLE STATE
  Widget _buildNotAvailableState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Surat Belum Tersedia',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textLight,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Surat ${widget.surat.name} segera tersedia',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }

  // SHOW SETTINGS BOTTOM SHEET
  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pengaturan Tampilan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Toggle transliterasi
                  SwitchListTile(
                    title: const Text('Tampilkan Transliterasi'),
                    value: _showTransliteration,
                    activeColor: AppColors.accentGreen,
                    onChanged: (value) {
                      setState(() => _showTransliteration = value);
                      setModalState(() => _showTransliteration = value);
                    },
                  ),

                  const Divider(),

                  // Ukuran font Arab
                  const Text(
                    'Ukuran Font Arab',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Slider(
                    value: _arabicFontSize,
                    min: 20,
                    max: 40,
                    divisions: 4,
                    label: _arabicFontSize.round().toString(),
                    activeColor: AppColors.accentGreen,
                    onChanged: (value) {
                      setState(() => _arabicFontSize = value);
                      setModalState(() => _arabicFontSize = value);
                    },
                  ),

                  const Divider(),

                  // Ukuran font terjemahan
                  const Text(
                    'Ukuran Font Terjemahan',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Slider(
                    value: _translationFontSize,
                    min: 12,
                    max: 24,
                    divisions: 6,
                    label: _translationFontSize.round().toString(),
                    activeColor: AppColors.accentGreen,
                    onChanged: (value) {
                      setState(() => _translationFontSize = value);
                      setModalState(() => _translationFontSize = value);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Close button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
