
// KAJIAN MODEL
// Model ini mendefinisikan struktur data untuk Kajian
// Digunakan untuk: Dashboard, Add/Edit Kajian, Detail

class Kajian {
  String id;
  String title;
  String ustadz;
  String theme;
  String date;
  String time;
  String location;
  String category;
  String categoryColor;
  String notes;
  String status; // "upcoming" atau "past"

  Kajian({
    required this.id,
    required this.title,
    required this.ustadz,
    required this.theme,
    required this.date,
    required this.time,
    required this.location,
    required this.category,
    required this.categoryColor,
    required this.notes,
    required this.status,
  });

  // Convert dari JSON ke Object Kajian
  factory Kajian.fromJson(Map<String, dynamic> json) {
    return Kajian(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      ustadz: json['ustadz'] ?? '',
      theme: json['theme'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      location: json['location'] ?? '',
      category: json['category'] ?? 'Lainnya',
      categoryColor: json['categoryColor'] ?? '0xFF95A5A6',
      notes: json['notes'] ?? '',
      status: json['status'] ?? 'upcoming',
    );
  }

  // Convert dari Object Kajian ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'ustadz': ustadz,
      'theme': theme,
      'date': date,
      'time': time,
      'location': location,
      'category': category,
      'categoryColor': categoryColor,
      'notes': notes,
      'status': status,
    };
  }

  // Copy With - untuk update data
  Kajian copyWith({
    String? id,
    String? title,
    String? ustadz,
    String? theme,
    String? date,
    String? time,
    String? location,
    String? category,
    String? categoryColor,
    String? notes,
    String? status,
  }) {
    return Kajian(
      id: id ?? this.id,
      title: title ?? this.title,
      ustadz: ustadz ?? this.ustadz,
      theme: theme ?? this.theme,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      category: category ?? this.category,
      categoryColor: categoryColor ?? this.categoryColor,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }

  // Override toString untuk debugging
  @override
  String toString() {
    return 'Kajian(id: $id, title: $title, ustadz: $ustadz, date: $date, status: $status)';
  }
}