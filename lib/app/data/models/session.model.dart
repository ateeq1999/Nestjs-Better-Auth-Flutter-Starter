import 'package:freezed_annotation/freezed_annotation.dart';

part 'session.model.freezed.dart';
part 'session.model.g.dart';

@freezed
class Session with _$Session {
  const factory Session({
    required String id,
    required String userId,
    required DateTime expiresAt,
    String? ipAddress,
    String? userAgent,
  }) = _Session;

  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);
}
