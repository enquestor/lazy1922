import 'package:hive/hive.dart';

part 'code.g.dart';

@HiveType(typeId: 2)
class Code {
  @HiveField(0)
  String value;

  Code(this.value);

  factory Code.parse(String message) {
    String code = "";
    RegExp(r'\d+').allMatches(message).forEach((number) {
      code += number.group(0)!;
    });
    return Code(code);
  }

  String get formatted => '${value.substring(0, 4)} ${value.substring(4, 8)} ${value.substring(8, 12)} ${value.substring(12)}';

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) {
    if (other is! Code) {
      return false;
    } else if (identical(this, other)) {
      return true;
    } else {
      return value == other.value;
    }
  }

  @override
  int get hashCode => value.hashCode;
}
