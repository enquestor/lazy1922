class Code {
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
}
