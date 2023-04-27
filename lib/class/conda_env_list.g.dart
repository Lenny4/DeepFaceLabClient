// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conda_env_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CondaEnvList _$CondaEnvListFromJson(Map<String, dynamic> json) => CondaEnvList(
      (json['envs'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$CondaEnvListToJson(CondaEnvList instance) =>
    <String, dynamic>{
      'envs': instance.envs,
    };
