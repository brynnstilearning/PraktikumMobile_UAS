// lib/services/interfaces/kajian_service_interface.dart

import '../../models/kajian_model.dart';

abstract class KajianServiceInterface {
  /// Load semua kajian
  Future<List<Kajian>> loadKajian();
  
  /// Get kajian by ID
  Future<Kajian?> getKajianById(String id);
  
  /// Create kajian baru
  Future<Map<String, dynamic>> createKajian(Kajian kajian);
  
  /// Update kajian
  Future<Map<String, dynamic>> updateKajian(Kajian kajian);
  
  /// Delete kajian
  Future<Map<String, dynamic>> deleteKajian(String id);
  
  /// Get upcoming kajian (yang akan datang)
  Future<List<Kajian>> getUpcomingKajian();
  
  /// Get past kajian (yang sudah lewat)
  Future<List<Kajian>> getPastKajian();
  
  /// Get kajian by category
  Future<List<Kajian>> getKajianByCategory(String category);
  
  /// Search kajian by title/ustadz/theme
  Future<List<Kajian>> searchKajian(String query);
  
  /// Get kajian by date
  Future<List<Kajian>> getKajianByDate(String date);
  
  /// Get kajian stats
  Future<Map<String, int>> getKajianStats();
  
  /// Toggle status kajian (upcoming <-> past)
  Future<Map<String, dynamic>> toggleKajianStatus(String id, String newStatus);
}