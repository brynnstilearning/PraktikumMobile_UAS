// lib/services/interfaces/quran_service_interface.dart

import '../../models/surat_model.dart';

abstract class QuranServiceInterface {
  /// Load list semua surat (114 surat)
  Future<List<Surat>> loadSuratList();
  
  /// Load detail surat dengan ayat-ayatnya
  /// @param suratNumber: 1-114
  Future<Surat?> loadSuratDetail(int suratNumber);
  
  /// Search surat by name
  Future<List<Surat>> searchSurat(String query);
  
  /// Get surat by revelation type (Makkiyyah/Madaniyyah)
  Future<List<Surat>> getSuratByRevelationType(String type);
  
  /// Get stats (untuk dashboard)
  Future<Map<String, int>> getSuratStats();
}