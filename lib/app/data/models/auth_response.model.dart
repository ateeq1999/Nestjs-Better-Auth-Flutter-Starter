import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.model.dart';

part 'auth_response.model.freezed.dart';
part 'auth_response.model.g.dart';

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({required String token, required User user}) =
      _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}
