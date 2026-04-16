// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Session _$SessionFromJson(Map<String, dynamic> json) => _Session(
  id: json['id'] as String,
  userId: json['userId'] as String,
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  ipAddress: json['ipAddress'] as String?,
  userAgent: json['userAgent'] as String?,
);

Map<String, dynamic> _$SessionToJson(_Session instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'expiresAt': instance.expiresAt.toIso8601String(),
  'ipAddress': instance.ipAddress,
  'userAgent': instance.userAgent,
};
