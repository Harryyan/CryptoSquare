import 'package:json_annotation/json_annotation.dart';

part 'user_post.g.dart';

@JsonSerializable()
class UserPostResp {
  final String message;
  final int code;
  final UserPostData data;

  UserPostResp({required this.message, required this.code, required this.data});

  factory UserPostResp.fromJson(Map<String, dynamic> json) =>
      _$UserPostRespFromJson(json);

  Map<String, dynamic> toJson() => _$UserPostRespToJson(this);
}

@JsonSerializable()
class UserPostData {
  final int total;
  final List<UserPostItem> data;
  @JsonKey(name: 'current_page')
  final String currentPage;

  UserPostData({
    required this.total,
    required this.data,
    required this.currentPage,
  });

  factory UserPostData.fromJson(Map<String, dynamic> json) =>
      _$UserPostDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserPostDataToJson(this);
}

@JsonSerializable()
class UserPostItem {
  final int id;
  final String title;
  final int status;
  final String type;
  @JsonKey(name: 'cat_id')
  final int catId;
  @JsonKey(name: 'cat_name')
  final String catName;
  @JsonKey(name: 'cat_info')
  final CatInfo catInfo;

  UserPostItem({
    required this.id,
    required this.title,
    required this.status,
    required this.type,
    required this.catId,
    required this.catName,
    required this.catInfo,
  });

  factory UserPostItem.fromJson(Map<String, dynamic> json) =>
      _$UserPostItemFromJson(json);

  Map<String, dynamic> toJson() => _$UserPostItemToJson(this);
}

@JsonSerializable()
class CatInfo {
  final String title;
  @JsonKey(name: 'cat_slug')
  final String catSlug;

  CatInfo({required this.title, required this.catSlug});

  factory CatInfo.fromJson(Map<String, dynamic> json) =>
      _$CatInfoFromJson(json);

  Map<String, dynamic> toJson() => _$CatInfoToJson(this);
}
