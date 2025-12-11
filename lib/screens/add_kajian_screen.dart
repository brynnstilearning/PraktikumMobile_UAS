import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jadwal_kajian_new/models/kajian_model.dart';
import 'package:jadwal_kajian_new/services/kajian_service.dart';
import 'package:table_calendar/table_calendar.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../services/prayer_service.dart';
import '../providers/settings_provider.dart';
import '../utils/date_formatter.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class AddKajianScreen extends StatefulWidget {
  const AddKajianScreen({super.key});

  @override
  State<AddKajianScreen> createState() => _AddKajianScreenState();
}

class _AddKajianScreenState extends State<AddKajianScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _ustadzController = TextEditingController();
  final _themeController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final PrayerService _prayerService = PrayerService();

  DateTime _selectedDate = DateTime.now();
  String _selectedTimeMode = 'manual';
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedBadaSholat = 'Ba\'da Maghrib';
  String _selectedCategory = 'Tafsir';

  Map<String, String> _prayerTimesFromJson = {};
  bool _isLoadingPrayerTimes = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPrayerTimes();
    });
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

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final settings = context.read<SettingsProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final timeString = _selectedTimeMode == 'manual'
          ? '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}'
          : _selectedBadaSholat;

      final categoryData = AppConstants.categories.firstWhere(
        (cat) => cat['name'] == _selectedCategory,
        orElse: () => {'name': 'Lainnya', 'color': 0xFF95A5A6},
      );

      final newKajian = Kajian(
        id: '',
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
        status: 'upcoming',
      );

      final result = await KajianService().createKajian(newKajian);

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
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(settings.addKajianTitle), // ✅
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Consumer<SettingsProvider>(
                builder: (context, s, _) => CustomTextField(
                  label: s.kajianTitle, // ✅
                  hint: s.kajianTitleHint, // ✅
                  controller: _titleController,
                  validator: (value) =>
                      Validators.validateRequired(value, s.kajianTitle),
                ),
              ),

              const SizedBox(height: 20),

              // Ustadz
              Consumer<SettingsProvider>(
                builder: (context, s, _) => CustomTextField(
                  label: s.ustadzName, // ✅
                  hint: s.ustadzNameHint, // ✅
                  controller: _ustadzController,
                  validator: (value) =>
                      Validators.validateRequired(value, s.ustadzName),
                ),
              ),

              const SizedBox(height: 20),

              // Theme
              Consumer<SettingsProvider>(
                builder: (context, s, _) => CustomTextField(
                  label: s.kajianTheme, // ✅
                  hint: s.kajianThemeHint, // ✅
                  controller: _themeController,
                  validator: (value) =>
                      Validators.validateRequired(value, s.kajianTheme),
                ),
              ),

              const SizedBox(height: 20),

              // Date Picker
              _buildDatePicker(),

              const SizedBox(height: 20),

              // Time Picker Mode
              _buildTimePicker(),

              const SizedBox(height: 20),

              // Location
              Consumer<SettingsProvider>(
                builder: (context, s, _) => CustomTextField(
                  label: s.locationLabel, // ✅
                  hint: s.locationHint, // ✅
                  controller: _locationController,
                  validator: (value) =>
                      Validators.validateRequired(value, s.locationLabel),
                ),
              ),

              const SizedBox(height: 20),

              // Category
              _buildCategorySelector(),

              const SizedBox(height: 20),

              // Notes
              Consumer<SettingsProvider>(
                builder: (context, s, _) => CustomTextField(
                  label: s.notesLabel, // ✅
                  hint: s.notesHint, // ✅
                  controller: _notesController,
                  maxLines: 4,
                ),
              ),

              const SizedBox(height: 30),

              // Save Button
              CustomButton(
                text: settings.saveKajian, // ✅
                onPressed: _handleSave,
                icon: Icons.save,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    final settings = context.watch<SettingsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          settings.selectDate, // ✅
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
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 365)),
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

  Widget _buildTimePicker() {
    final settings = context.watch<SettingsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          settings.selectTime, // ✅
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTimeToggle(settings.manual, 'manual'), // ✅
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimeToggle(settings.afterPrayer, 'bada_sholat'), // ✅
            ),
          ],
        ),
        const SizedBox(height: 16),
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

  Widget _buildCategorySelector() {
    final settings = context.watch<SettingsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          settings.category, // ✅
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
}
