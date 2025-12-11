import 'package:flutter/material.dart';
import 'package:jadwal_kajian_new/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/kajian_model.dart';
import '../services/kajian_service.dart';
import '../services/prayer_service.dart';
import '../utils/date_formatter.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class EditKajianScreen extends StatefulWidget {
  final Kajian kajian;

  const EditKajianScreen({
    super.key,
    required this.kajian,
  });

  @override
  State<EditKajianScreen> createState() => _EditKajianScreenState();
}

class _EditKajianScreenState extends State<EditKajianScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _ustadzController;
  late TextEditingController _themeController;
  late TextEditingController _locationController;
  late TextEditingController _notesController;
  final PrayerService _prayerService = PrayerService();

  late DateTime _selectedDate;
  String _selectedTimeMode = 'manual'; // 'manual' atau 'bada_sholat'
  TimeOfDay _selectedTime = TimeOfDay.now(); // ← FIX: Beri default value
  String _selectedBadaSholat = 'Ba\'da Maghrib';
  late String _selectedCategory;
  late String _selectedStatus;

  Map<String, String> _prayerTimesFromJson = {};
  bool _isLoadingPrayerTimes = false;

  @override
  void initState() {
    super.initState();

    // Pre-fill form
    _titleController = TextEditingController(text: widget.kajian.title ?? '');
    _ustadzController = TextEditingController(text: widget.kajian.ustadz ?? '');
    _themeController = TextEditingController(text: widget.kajian.theme ?? '');
    _locationController =
        TextEditingController(text: widget.kajian.location ?? '');
    _notesController = TextEditingController(text: widget.kajian.notes ?? '');

    _selectedDate =
        DateFormatter.parseIsoDate(widget.kajian.date) ?? DateTime.now();
    _selectedCategory = widget.kajian.category ?? 'Tafsir';
    _selectedStatus = widget.kajian.status ?? 'upcoming';

    // Parse existing time - HANDLE NULL
    _parseExistingTime(widget.kajian.time);

    // Load prayer times
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPrayerTimes();
    });
  }

  /// Parse waktu yang sudah ada (manual atau ba'da sholat)
  void _parseExistingTime(String? timeString) {
    // HANDLE NULL ATAU EMPTY STRING
    if (timeString == null || timeString.isEmpty) {
      print('⚠️ Time string is null or empty, using default');
      _selectedTimeMode = 'manual';
      _selectedTime = TimeOfDay.now();
      return;
    }

    print('🕐 Parsing time: $timeString');

    try {
      if (timeString.contains('Ba\'da') || timeString.contains('Bada')) {
        // Ba'da sholat mode
        _selectedTimeMode = 'bada_sholat';

        // Extract "Ba'da Maghrib" from "Ba'da Maghrib (18:00)"
        if (timeString.contains('(')) {
          _selectedBadaSholat = timeString.split(' (')[0].trim();
        } else {
          _selectedBadaSholat = timeString.trim();
        }

        // Validasi: pastikan ada di list options
        if (!AppConstants.badaSholatOptions.contains(_selectedBadaSholat)) {
          print(
              '⚠️ Invalid Ba\'da Sholat: $_selectedBadaSholat, using default');
          _selectedBadaSholat = 'Ba\'da Maghrib';
        }

        // Set default time untuk manual mode (jika user switch)
        _selectedTime = TimeOfDay.now();

        print('✅ Parsed as Ba\'da Sholat: $_selectedBadaSholat');
      } else {
        // Manual mode
        _selectedTimeMode = 'manual';

        // Parse HH:mm format
        final cleanTime = timeString.trim();
        final parts = cleanTime.split(':');

        if (parts.length == 2) {
          final hour = int.tryParse(parts[0].trim());
          final minute = int.tryParse(parts[1].trim());

          if (hour != null &&
              minute != null &&
              hour >= 0 &&
              hour < 24 &&
              minute >= 0 &&
              minute < 60) {
            _selectedTime = TimeOfDay(hour: hour, minute: minute);
            print(
                '✅ Parsed as Manual: ${_selectedTime.hour}:${_selectedTime.minute}');
          } else {
            print('⚠️ Invalid time values, using current time');
            _selectedTime = TimeOfDay.now();
          }
        } else {
          print('⚠️ Invalid time format, using current time');
          _selectedTime = TimeOfDay.now();
        }
      }
    } catch (e) {
      print('❌ Error parsing time: $e');
      // Fallback ke default
      _selectedTimeMode = 'manual';
      _selectedTime = TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ustadzController.dispose();
    _themeController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

// ✅ UPDATE _loadPrayerTimes DENGAN CITY DARI SETTINGS
  Future<void> _loadPrayerTimes() async {
    if (!mounted) return;

    setState(() => _isLoadingPrayerTimes = true);

    try {
      // ✅ AMBIL CITY DARI SETTINGS
      final settings = context.read<SettingsProvider>();

      // ✅ REFRESH DENGAN CITY DARI SETTINGS
      await _prayerService.refreshPrayerTimes(
        city: settings.selectedCity,
        country: 'Indonesia',
      );

      final times = await _prayerService.getPrayerTimesMap();

      if (mounted) {
        setState(() {
          _prayerTimesFromJson = times;
          _isLoadingPrayerTimes = false;
        });
      }
    } catch (e) {
      print('Error loading prayer times: $e');
      if (mounted) {
        setState(() => _isLoadingPrayerTimes = false);
      }
    }
  }

  // Handle save
  void _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Prepare time string
      final timeString = _selectedTimeMode == 'manual'
          ? '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}'
          : _selectedBadaSholat;

      // Get category color
      final categoryData = AppConstants.categories.firstWhere(
        (cat) => cat['name'] == _selectedCategory,
        orElse: () => {'name': 'Lainnya', 'color': 0xFF95A5A6},
      );

      // Create updated Kajian object
      final updatedKajian = widget.kajian.copyWith(
        title: _titleController.text.trim(),
        ustadz: _ustadzController.text.trim(),
        theme: _themeController.text.trim(),
        date: _selectedDate.toIso8601String().split('T')[0],
        time: timeString,
        location: _locationController.text.trim(),
        category: _selectedCategory,
        categoryColor:
            '0x${categoryData['color'].toRadixString(16).padLeft(8, '0')}',
        notes: _notesController.text.trim(),
        status: _selectedStatus,
      );

      // Update in Firebase
      final result = await KajianService().updateKajian(updatedKajian);

      if (!mounted) return;

      // Close loading
      Navigator.pop(context);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Kajian'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteDialog(),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accentBlue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.accentBlue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Anda sedang mengedit: ${widget.kajian.title}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Title
              CustomTextField(
                label: 'Judul Kajian',
                hint: 'Contoh: Kajian Tafsir Al-Baqarah',
                controller: _titleController,
                validator: (value) =>
                    Validators.validateRequired(value, 'Judul kajian'),
              ),

              const SizedBox(height: 20),

              // Ustadz
              CustomTextField(
                label: 'Nama Ustadz',
                hint: 'Contoh: Ustadz Ahmad',
                controller: _ustadzController,
                validator: (value) =>
                    Validators.validateRequired(value, 'Nama ustadz'),
              ),

              const SizedBox(height: 20),

              // Theme
              CustomTextField(
                label: 'Tema Kajian',
                hint: 'Contoh: Tafsir Al-Quran Juz 1-2',
                controller: _themeController,
                validator: (value) =>
                    Validators.validateRequired(value, 'Tema kajian'),
              ),

              const SizedBox(height: 20),

              // Date Picker
              _buildDatePicker(),

              const SizedBox(height: 20),

              // Time Picker Mode (SAMA DENGAN ADD KAJIAN)
              _buildTimePicker(),

              const SizedBox(height: 20),

              // Location
              CustomTextField(
                label: 'Lokasi',
                hint: 'Contoh: Masjid Agung Malang',
                controller: _locationController,
                validator: (value) =>
                    Validators.validateRequired(value, 'Lokasi'),
              ),

              const SizedBox(height: 20),

              // Category
              _buildCategorySelector(),

              const SizedBox(height: 20),

              // Status
              _buildStatusSelector(),

              const SizedBox(height: 20),

              // Notes
              CustomTextField(
                label: 'Catatan',
                hint: 'Catatan tambahan (opsional)',
                controller: _notesController,
                maxLines: 4,
              ),

              const SizedBox(height: 30),

              // Save Button
              CustomButton(
                text: 'Simpan Perubahan',
                onPressed: _handleSave,
                icon: Icons.save,
              ),

              const SizedBox(height: 12),

              // Cancel Button
              CustomOutlineButton(
                text: 'Batal',
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // BUILD DATE PICKER
  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Tanggal',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _showCalendarDialog(),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.primaryPink),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    DateFormatter.formatIndonesian(_selectedDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCalendarDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TableCalendar(
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),
                focusedDay: _selectedDate,
                selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDate = selectedDay;
                  });
                  Navigator.pop(context);
                },
                calendarStyle: const CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: AppColors.primaryPink,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppColors.primaryPurple,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // BUILD TIME PICKER (SAMA DENGAN ADD KAJIAN)
  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Waktu',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),

        // Toggle: Manual vs Ba'da Sholat
        Row(
          children: [
            Expanded(
              child: _buildTimeToggle('Manual', 'manual'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimeToggle('Ba\'da Sholat', 'bada_sholat'),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Time selector based on mode
        if (_selectedTimeMode == 'manual')
          _buildManualTimePicker()
        else
          _buildBadaSholatPicker(),
      ],
    );
  }

  Widget _buildTimeToggle(String label, String mode) {
    final isSelected = _selectedTimeMode == mode;

    return InkWell(
      onTap: () => setState(() => _selectedTimeMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPink : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManualTimePicker() {
    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
        );
        if (picked != null) {
          setState(() => _selectedTime = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: AppColors.primaryPink),
            const SizedBox(width: 12),
            Text(
              '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  // BUILD BA'DA SHOLAT PICKER
  Widget _buildBadaSholatPicker() {
    if (_isLoadingPrayerTimes) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      children: AppConstants.badaSholatOptions.map((option) {
        final isSelected = _selectedBadaSholat == option;

        final simpleName = option.replaceAll('Ba\'da ', '');
        final prayerTime = _prayerTimesFromJson[simpleName] ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => setState(() => _selectedBadaSholat = option),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryPink.withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primaryPink : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected ? AppColors.primaryPink : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? AppColors.primaryPink
                            : AppColors.textDark,
                      ),
                    ),
                  ),
                  if (prayerTime.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryPink.withOpacity(0.1)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        prayerTime,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primaryPink
                              : AppColors.textLight,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // BUILD CATEGORY SELECTOR
  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.categories.map((category) {
            final isSelected = _selectedCategory == category['name'];
            final color = Color(category['color']);

            return InkWell(
              onTap: () => setState(() => _selectedCategory = category['name']),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.2) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? color : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category['icon'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category['name'],
                      style: TextStyle(
                        color: isSelected ? color : AppColors.textDark,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // BUILD STATUS SELECTOR
  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status Kajian',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatusOption('Akan Datang', 'upcoming'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatusOption('Sudah Lewat', 'past'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusOption(String label, String status) {
    final isSelected = _selectedStatus == status;
    final color =
        status == 'upcoming' ? AppColors.accentGreen : AppColors.textLight;

    return InkWell(
      onTap: () => setState(() => _selectedStatus = status),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? color : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SHOW DELETE DIALOG
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kajian'),
        content:
            Text('Apakah Anda yakin ingin menghapus "${widget.kajian.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                final result =
                    await KajianService().deleteKajian(widget.kajian.id);

                if (!mounted) return;

                Navigator.pop(context);

                if (result['success']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message']),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message']),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (!mounted) return;

                Navigator.pop(context);

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
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
