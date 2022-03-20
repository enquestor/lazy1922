import 'package:hive/hive.dart';
import 'package:lazy1922/models/code.dart';
import 'package:lazy1922/models/record.dart';

part 'place.g.dart';

@HiveType(typeId: 1)
class Place extends Record {
  @HiveField(5)
  final String name;

  const Place({
    required Code code,
    required String message,
    required DateTime time,
    required double latitude,
    required double longitude,
    required this.name,
  }) : super(code: code, message: message, time: time, latitude: latitude, longitude: longitude);

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
      latitude: record.latitude,
      longitude: record.longitude,
      name: name,
    );
  }

  @override
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
}
