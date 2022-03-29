import 'package:lazy1922/models/code.dart';
import 'package:hive/hive.dart';
import 'package:lazy1922/models/place.dart';

part 'record.g.dart';

@HiveType(typeId: 1)
class Record {
  @HiveField(0)
  final Code code;
  @HiveField(1)
  final String message;
  @HiveField(2)
  final DateTime time;
  @HiveField(3)
  final double? latitude;
  @HiveField(4)
  final double? longitude;

  const Record({
    required this.code,
    required this.message,
    required this.time,
    this.latitude,
    this.longitude,
  });

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      code: Code(json["code"]),
      message: json["message"],
      time: DateTime.parse(json["time"]),
      latitude: json["latitude"],
      longitude: json["longitude"],
    );
  }

  factory Record.fromPlace(Place place) {
    return Record(
      code: place.code,
      message: place.message,
      time: place.time,
      latitude: place.latitude,
      longitude: place.longitude,
    );
  }

  Record copyWith({
    Code? code,
    String? message,
    DateTime? time,
    double? latitude,
    double? longitude,
  }) {
    return Record(
      code: code ?? this.code,
      message: message ?? this.message,
      time: time ?? this.time,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "code": code.value,
      "message": message,
      "time": time.toIso8601String(),
      "latitude": latitude,
      "longitude": longitude,
    };
  }

  // override equal operator
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

  bool get isLocationAvailable => latitude != null && longitude != null;
}
