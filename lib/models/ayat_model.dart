
// AYAT MODEL
// Model ini mendefinisikan struktur data untuk Ayat Al-Quran

class Ayat {
  int number;
  int numberInSurat;
  String textArabic;
  String textTransliteration;
  String textTranslation;

  Ayat({
    required this.number,
    required this.numberInSurat,
    required this.textArabic,
    required this.textTransliteration,
    required this.textTranslation,
  });

  // Convert dari JSON ke Object Ayat
  factory Ayat.fromJson(Map<String, dynamic> json) {
    return Ayat(
      number: json['number'] ?? 0,
      numberInSurat: json['numberInSurat'] ?? 0,
      textArabic: json['textArabic'] ?? '',
      textTransliteration: json['textTransliteration'] ?? '',
      textTranslation: json['textTranslation'] ?? '',
    );
  }

  // Convert dari Object Ayat ke JSON
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'numberInSurat': numberInSurat,
      'textArabic': textArabic,
      'textTransliteration': textTransliteration,
      'textTranslation': textTranslation,
    };
  }

  // Override toString untuk debugging
  @override
  String toString() {
    return 'Ayat(numberInSurat: $numberInSurat, arabic: ${textArabic.substring(0, 20)}...)';
  }
}