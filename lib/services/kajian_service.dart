// lib/services/kajian_service.dart

import '../config/service_config.dart';
import '../models/kajian_model.dart';
import 'interfaces/kajian_service_interface.dart';

/// Wrapper class untuk backward compatibility
class KajianService implements KajianServiceInterface {
  final KajianServiceInterface _implementation = ServiceConfig.getKajianService();
  
  @override
  Future<List<Kajian>> loadKajian() {
    return _implementation.loadKajian();
  }
  
  @override
  Future<Kajian?> getKajianById(String id) {
    return _implementation.getKajianById(id);
  }
  
  @override
  Future<Map<String, dynamic>> createKajian(Kajian kajian) {
    return _implementation.createKajian(kajian);
  }
  
  @override
  Future<Map<String, dynamic>> updateKajian(Kajian kajian) {
    return _implementation.updateKajian(kajian);
  }
  
  @override
  Future<Map<String, dynamic>> deleteKajian(String id) {
    return _implementation.deleteKajian(id);
  }
  
  @override
  Future<List<Kajian>> getUpcomingKajian() {
    return _implementation.getUpcomingKajian();
  }
  
  @override
  Future<List<Kajian>> getPastKajian() {
    return _implementation.getPastKajian();
  }
  
  @override
  Future<List<Kajian>> getKajianByCategory(String category) {
    return _implementation.getKajianByCategory(category);
  }
  
  @override
  Future<List<Kajian>> searchKajian(String query) {
    return _implementation.searchKajian(query);
  }
  
  @override
  Future<List<Kajian>> getKajianByDate(String date) {
    return _implementation.getKajianByDate(date);
  }
  
  @override
  Future<Map<String, int>> getKajianStats() {
    return _implementation.getKajianStats();
  }
  
  @override
  Future<Map<String, dynamic>> toggleKajianStatus(String id, String newStatus) {
    return _implementation.toggleKajianStatus(id, newStatus);
  }
}