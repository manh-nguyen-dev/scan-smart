import 'dart:typed_data';

class ScanModel {
  final int? id;
  final String code;
  final DateTime timestamp;
  final Uint8List? image;

  ScanModel({
    this.id,
    required this.code,
    required this.timestamp,
    this.image,
  });

  factory ScanModel.fromMap(Map<String, dynamic> map) {
    return ScanModel(
      id: map['id'],
      code: map['code'],
      timestamp: DateTime.parse(map['timestamp']),
      image: map['image'] != null ? Uint8List.fromList(map['image']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'timestamp': timestamp.toIso8601String(),
      'image': image,
    };
  }
}
