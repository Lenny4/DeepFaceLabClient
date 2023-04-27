import 'package:json_annotation/json_annotation.dart';

part 'conda_env_list.g.dart';

@JsonSerializable()
class CondaEnvList {
  CondaEnvList(this.envs);

  List<String> envs;

  factory CondaEnvList.fromJson(Map<String, dynamic> json) =>
      _$CondaEnvListFromJson(json);

  Map<String, dynamic> toJson() => _$CondaEnvListToJson(this);
}
