
// SURAT MODEL
// Model ini mendefinisikan struktur data untuk Surat Al-Quran
import 'ayat_model.dart';

class Surat {
  int number;
  String name;
  String nameArabic;
  String nameTranslation;
  String revelationType;
  int numberOfAyat;
  List<Ayat>? ayatList; // Optional, diisi saat load detail

  Surat({
    required this.number,
    required this.name,
    required this.nameArabic,
    required this.nameTranslation,
    required this.revelationType,
    required this.numberOfAyat,
    this.ayatList,
  });

  // Convert dari JSON ke Object Surat
  factory Surat.fromJson(Map<String, dynamic> json) {
    return Surat(
      number: json['number'] ?? 0,
      name: json['name'] ?? '',
      nameArabic: json['nameArabic'] ?? '',
      nameTranslation: json['nameTranslation'] ?? '',
      revelationType: json['revelationType'] ?? 'Makkiyyah',
      numberOfAyat: json['numberOfAyat'] ?? 0,
      ayatList: json['ayatList'] != null
          ? (json['ayatList'] as List).map((a) => Ayat.fromJson(a)).toList()
          : null,
    );
  }

  // Convert dari Object Surat ke JSON
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'nameArabic': nameArabic,
      'nameTranslation': nameTranslation,
      'revelationType': revelationType,
      'numberOfAyat': numberOfAyat,
      'ayatList': ayatList?.map((a) => a.toJson()).toList(),
    };
  }

  // Override toString untuk debugging
  @override
  String toString() {
    return 'Surat(number: $number, name: $name, ayat: $numberOfAyat)';
  }
}