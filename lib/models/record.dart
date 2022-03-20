import 'package:lazy1922/models/code.dart';

class Record {
  final Code code;
  final String message;
  final DateTime time;
  final double latitude;
  final double longitude;

  const Record({
    required this.code,
    required this.message,
    required this.time,
    required this.latitude,
    required this.longitude,
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
}
