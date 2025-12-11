// lib/services/firebase/kajian_service_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/kajian_model.dart';
import '../interfaces/kajian_service_interface.dart';

class KajianServiceFirebase implements KajianServiceInterface {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'kajian';
  
  // Cache
  List<Kajian>? _cachedKajian;
  DateTime? _lastFetch;
  final Duration _cacheDuration = const Duration(minutes: 5);
  
  @override
  Future<List<Kajian>> loadKajian() async {
    // Check cache
    if (_cachedKajian != null && _lastFetch != null) {
      final diff = DateTime.now().difference(_lastFetch!);
      if (diff < _cacheDuration) {
        print('📦 Using cached kajian');
        return _cachedKajian!;
      }
    }
    
    try {
      print('📚 Fetching kajian from Firebase...');
      
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('date', descending: false)
          .get();
      
      _cachedKajian = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Tambahkan ID dari Firestore
        return Kajian.fromJson(data);
      }).toList();
      
      _lastFetch = DateTime.now();
      
      print('✅ Loaded ${_cachedKajian!.length} kajian from Firebase');
      return _cachedKajian!;
    } catch (e) {
      print('❌ Error loading kajian: $e');
      return [];
    }
  }
  
  @override
  Future<Kajian?> getKajianById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return Kajian.fromJson(data);
      }
      return null;
    } catch (e) {
      print('❌ Error getting kajian by ID: $e');
      return null;
    }
  }
  
  @override
  Future<Map<String, dynamic>> createKajian(Kajian kajian) async {
    try {
      print('➕ Creating kajian: ${kajian.title}');
      
      // Buat data tanpa ID (ID auto-generate oleh Firestore)
      final data = kajian.toJson();
      data.remove('id'); // Hapus ID, biar Firestore yang generate
      
      // Add timestamp
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      
      // Add to Firestore
      final docRef = await _firestore.collection(_collection).add(data);
      
      // Clear cache
      _cachedKajian = null;
      
      print('✅ Kajian created with ID: ${docRef.id}');
      
      return {
        'success': true,
        'message': 'Kajian berhasil ditambahkan',
        'id': docRef.id,
      };
    } catch (e) {
      print('❌ Error creating kajian: $e');
      return {
        'success': false,
        'message': 'Gagal menambahkan kajian: $e',
      };
    }
  }
  
  @override
  Future<Map<String, dynamic>> updateKajian(Kajian kajian) async {
    try {
      print('✏️ Updating kajian: ${kajian.title}');
      
      final data = kajian.toJson();
      data['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection(_collection).doc(kajian.id).update(data);
      
      // Clear cache
      _cachedKajian = null;
      
      print('✅ Kajian updated');
      
      return {
        'success': true,
        'message': 'Kajian berhasil diupdate',
      };
    } catch (e) {
      print('❌ Error updating kajian: $e');
      return {
        'success': false,
        'message': 'Gagal mengupdate kajian: $e',
      };
    }
  }
  
  @override
  Future<Map<String, dynamic>> deleteKajian(String id) async {
    try {
      print('🗑️ Deleting kajian: $id');
      
      await _firestore.collection(_collection).doc(id).delete();
      
      // Clear cache
      _cachedKajian = null;
      
      print('✅ Kajian deleted');
      
      return {
        'success': true,
        'message': 'Kajian berhasil dihapus',
      };
    } catch (e) {
      print('❌ Error deleting kajian: $e');
      return {
        'success': false,
        'message': 'Gagal menghapus kajian: $e',
      };
    }
  }
  
  @override
  Future<List<Kajian>> getUpcomingKajian() async {
    try {
      final allKajian = await loadKajian();
      return allKajian.where((k) => k.status == 'upcoming').toList();
    } catch (e) {
      return [];
    }
  }
  
  @override
  Future<List<Kajian>> getPastKajian() async {
    try {
      final allKajian = await loadKajian();
      return allKajian.where((k) => k.status == 'past').toList();
    } catch (e) {
      return [];
    }
  }
  
  @override
  Future<List<Kajian>> getKajianByCategory(String category) async {
    try {
      final allKajian = await loadKajian();
      return allKajian.where((k) => k.category == category).toList();
    } catch (e) {
      return [];
    }
  }
  
  @override
  Future<List<Kajian>> searchKajian(String query) async {
    try {
      final allKajian = await loadKajian();
      final lowerQuery = query.toLowerCase();
      
      return allKajian.where((kajian) {
        return kajian.title.toLowerCase().contains(lowerQuery) ||
               kajian.ustadz.toLowerCase().contains(lowerQuery) ||
               kajian.theme.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      return [];
    }
  }
  
  @override
  Future<List<Kajian>> getKajianByDate(String date) async {
    try {
      final allKajian = await loadKajian();
      return allKajian.where((k) => k.date == date).toList();
    } catch (e) {
      return [];
    }
  }
  
  @override
  Future<Map<String, int>> getKajianStats() async {
    try {
      final allKajian = await loadKajian();
      
      int total = allKajian.length;
      int upcoming = allKajian.where((k) => k.status == 'upcoming').length;
      int past = allKajian.where((k) => k.status == 'past').length;
      
      return {
        'total': total,
        'upcoming': upcoming,
        'past': past,
      };
    } catch (e) {
      return {
        'total': 0,
        'upcoming': 0,
        'past': 0,
      };
    }
  }
  
  @override
  Future<Map<String, dynamic>> toggleKajianStatus(String id, String newStatus) async {
    try {
      print('🔄 Toggling kajian status: $id -> $newStatus');
      
      await _firestore.collection(_collection).doc(id).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Clear cache
      _cachedKajian = null;
      
      print('✅ Status toggled');
      
      return {
        'success': true,
        'message': 'Status kajian berhasil diubah',
      };
    } catch (e) {
      print('❌ Error toggling status: $e');
      return {
        'success': false,
        'message': 'Gagal mengubah status: $e',
      };
    }
  }
}