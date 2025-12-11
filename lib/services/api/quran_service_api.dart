// lib/services/api/quran_service_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/surat_model.dart';
import '../../models/ayat_model.dart';
import '../interfaces/quran_service_interface.dart';

class QuranServiceApi implements QuranServiceInterface {
  final String baseUrl = 'https://api.quran.gading.dev';
  
  // Cache
  List<Surat>? _cachedSuratList;
  final Map<int, Surat> _cachedSuratDetails = {};
  
  @override
  Future<List<Surat>> loadSuratList() async {
    // Return cache jika ada
    if (_cachedSuratList != null) {
      print('📦 Using cached surat list');
      return _cachedSuratList!;
    }
    
    try {
      print('📖 Fetching surat list from API...');
      
      final url = Uri.parse('$baseUrl/surah');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['code'] == 200) {
          final List<dynamic> suratData = data['data'];
          
          _cachedSuratList = suratData.map((json) {
            // ✅ PERBAIKAN: Parse revelation type dengan benar
            String revelationType = 'Makkiyyah'; // default
            
            if (json['revelation'] != null && json['revelation']['id'] != null) {
              String revType = json['revelation']['id'].toString().toLowerCase();
              
              // Check apakah Madinah/Madaniyyah
              if (revType.contains('madinah') || revType.contains('madaniyyah')) {
                revelationType = 'Madaniyyah';
              } else {
                revelationType = 'Makkiyyah';
              }
            }
            
            print('📋 Surat ${json['number']}: ${json['name']['transliteration']['id']} - $revelationType (API: ${json['revelation']['id']})');
            
            return Surat(
              number: json['number'],
              name: json['name']['transliteration']['id'],
              nameArabic: json['name']['short'],
              nameTranslation: json['name']['translation']['id'],
              revelationType: revelationType,
              numberOfAyat: json['numberOfVerses'],
            );
          }).toList();
          
          // ✅ LOG STATISTIK
          final makkiyyahCount = _cachedSuratList!.where((s) => s.revelationType == 'Makkiyyah').length;
          final madaniyyahCount = _cachedSuratList!.where((s) => s.revelationType == 'Madaniyyah').length;
          
          print('✅ Loaded ${_cachedSuratList!.length} surat');
          print('📊 Makkiyyah: $makkiyyahCount, Madaniyyah: $madaniyyahCount');
          
          return _cachedSuratList!;
        }
      }
      
      throw Exception('Failed to load surat list: ${response.statusCode}');
    } catch (e) {
      print('❌ Error loading surat list: $e');
      return [];
    }
  }
  
  @override
  Future<Surat?> loadSuratDetail(int suratNumber) async {
    // Return cache jika ada
    if (_cachedSuratDetails.containsKey(suratNumber)) {
      print('📦 Using cached surat $suratNumber');
      return _cachedSuratDetails[suratNumber];
    }
    
    try {
      print('📖 Fetching surat $suratNumber from API...');
      
      final url = Uri.parse('$baseUrl/surah/$suratNumber');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['code'] == 200) {
          final suratData = data['data'];
          
          // Parse ayat-ayat
          final List<dynamic> versesData = suratData['verses'];
          final List<Ayat> ayatList = versesData.map((verse) {
            return Ayat(
              number: verse['number']['inQuran'],
              numberInSurat: verse['number']['inSurah'],
              textArabic: verse['text']['arab'],
              textTransliteration: verse['text']['transliteration']['en'],
              textTranslation: verse['translation']['id'],
            );
          }).toList();
          
          // ✅ PERBAIKAN: Parse revelation type dengan benar
          String revelationType = 'Makkiyyah';
          if (suratData['revelation'] != null && suratData['revelation']['id'] != null) {
            String revType = suratData['revelation']['id'].toString().toLowerCase();
            if (revType.contains('madinah') || revType.contains('madaniyyah')) {
              revelationType = 'Madaniyyah';
            }
          }
          
          // Buat object Surat lengkap
          final surat = Surat(
            number: suratData['number'],
            name: suratData['name']['transliteration']['id'],
            nameArabic: suratData['name']['short'],
            nameTranslation: suratData['name']['translation']['id'],
            revelationType: revelationType,
            numberOfAyat: suratData['numberOfVerses'],
            ayatList: ayatList,
          );
          
          // Cache
          _cachedSuratDetails[suratNumber] = surat;
          
          print('✅ Loaded surat ${surat.name} with ${ayatList.length} ayat');
          return surat;
        }
      }
      
      throw Exception('Failed to load surat detail: ${response.statusCode}');
    } catch (e) {
      print('❌ Error loading surat $suratNumber: $e');
      return null;
    }
  }
  
  @override
  Future<List<Surat>> searchSurat(String query) async {
    try {
      final allSurat = await loadSuratList();
      final lowerQuery = query.toLowerCase();
      
      return allSurat.where((surat) {
        return surat.name.toLowerCase().contains(lowerQuery) ||
               surat.nameTranslation.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      print('❌ Error searching surat: $e');
      return [];
    }
  }
  
  @override
  Future<List<Surat>> getSuratByRevelationType(String type) async {
    try {
      final allSurat = await loadSuratList();
      final filtered = allSurat.where((surat) => surat.revelationType == type).toList();
      
      print('🔍 Filter $type: ${filtered.length} surat');
      return filtered;
    } catch (e) {
      print('❌ Error filtering surat: $e');
      return [];
    }
  }
  
  @override
  Future<Map<String, int>> getSuratStats() async {
    try {
      final allSurat = await loadSuratList();
      
      int total = allSurat.length;
      int makkiyyah = allSurat.where((s) => s.revelationType == 'Makkiyyah').length;
      int madaniyyah = allSurat.where((s) => s.revelationType == 'Madaniyyah').length;
      
      return {
        'total': total,
        'makkiyyah': makkiyyah,
        'madaniyyah': madaniyyah,
      };
    } catch (e) {
      return {
        'total': 0,
        'makkiyyah': 0,
        'madaniyyah': 0,
      };
    }
  }
}