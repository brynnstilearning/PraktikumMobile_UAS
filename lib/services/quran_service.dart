// lib/services/quran_service.dart

import '../config/service_config.dart';
import '../models/surat_model.dart';
import 'interfaces/quran_service_interface.dart';

/// Wrapper class untuk backward compatibility
class QuranService implements QuranServiceInterface {
  final QuranServiceInterface _implementation = ServiceConfig.getQuranService();
  
  @override
  Future<List<Surat>> loadSuratList() {
    return _implementation.loadSuratList();
  }
  
  @override
  Future<Surat?> loadSuratDetail(int suratNumber) {
    return _implementation.loadSuratDetail(suratNumber);
  }
  
  @override
  Future<List<Surat>> searchSurat(String query) {
    return _implementation.searchSurat(query);
  }
  
  @override
  Future<List<Surat>> getSuratByRevelationType(String type) {
    return _implementation.getSuratByRevelationType(type);
  }
  
  @override
  Future<Map<String, int>> getSuratStats() {
    return _implementation.getSuratStats();
  }
}