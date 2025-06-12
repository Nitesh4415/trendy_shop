import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';


@freezed
class User with _$User {
  const factory User({
    int? id,
    required String username,
    required String email,
    required String password,
  }) = _User;
}