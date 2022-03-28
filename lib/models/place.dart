import 'package:hive/hive.dart';
import 'package:lazy1922/models/code.dart';
import 'package:lazy1922/models/record.dart';

part 'place.g.dart';

@HiveType(typeId: 2)
class Place {
  @HiveField(0)
  final Code code;
  @HiveField(1)
  final String message;
  @HiveField(2)
  final DateTime time;
  @HiveField(3)
  final double latitude;
  @HiveField(4)
  final double longitude;
  @HiveField(5)
  final String name;

  const Place({
    required this.code,
    required this.message,
    required this.time,
    required this.latitude,
    required this.longitude,
    required this.name,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      code: Code(json["code"]),
      message: json["message"],
      time: DateTime.parse(json['time']),
      latitude: json['latitude'],
      longitude: json['longitude'],
      name: json["name"],
    );
  }

  factory Place.fromRecord(Record record, String name) {
    return Place(
      code: record.code,
      message: record.message,
      time: record.time,
      latitude: record.latitude!,
      longitude: record.longitude!,
      name: name,
    );
  }

  Place copyWith({
    Code? code,
    String? message,
    DateTime? time,
    double? latitude,
    double? longitude,
    String? name,
  }) {
    return Place(
      code: code ?? this.code,
      message: message ?? this.message,
      time: time ?? this.time,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "code": code.value,
      "message": message,
      "time": time.toIso8601String(),
      "latitude": latitude,
      "longitude": longitude,
      "name": name,
    };
  }

  @override
  bool operator ==(Object other) {
    if (other is! Record) {
      return false;
    } else if (identical(this, other)) {
      return true;
    } else {
      return code == other.code;
    }
  }

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'code: $code, message: $message, time: $time, latitude: $latitude, longitude: $longitude, name: $name\n';
}
