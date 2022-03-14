import 'package:lazy1922/models/place.dart';
import 'package:lazy1922/models/record.dart';

class Data {
  final bool initialized;
  final List<Place> places;
  final List<Record> records;

  const Data({
    required this.initialized,
    required this.places,
    required this.records,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      initialized: true,
      places: (json['places'] as List<dynamic>).map((place) => Place.fromJson(place)).toList(),
      records: (json['records'] as List<dynamic>).map((record) => Record.fromJson(record)).toList(),
    );
  }

  factory Data.template() {
    return const Data(
      initialized: false,
      places: [],
      records: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'places': places.map((place) => place.toJson()).toList(),
      'records': records.map((record) => record.toJson()).toList(),
    };
  }

  Data copyWith({
    bool? initialized,
    List<Place>? places,
    List<Record>? records,
  }) {
    return Data(
      initialized: initialized ?? this.initialized,
      places: places ?? this.places,
      records: records ?? this.records,
    );
  }
}
