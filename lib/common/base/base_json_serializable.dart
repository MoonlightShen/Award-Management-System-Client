abstract class BaseJsonSerializable {
  Map<String, dynamic> toJson();
  factory BaseJsonSerializable.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson has not been implemented');
  }
}
