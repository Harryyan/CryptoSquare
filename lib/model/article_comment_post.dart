import 'package:json_annotation/json_annotation.dart';

part 'article_comment_post.g.dart';

@JsonSerializable()
class ArticleCommentPostResponse {
  const ArticleCommentPostResponse({this.message, this.code, this.data});

  factory ArticleCommentPostResponse.fromJson(Map<String, dynamic> json) =>
      _$ArticleCommentPostResponseFromJson(json);

  final String? message;
  final int? code;
  final ArticleCommentPostData? data;

  Map<String, dynamic> toJson() => _$ArticleCommentPostResponseToJson(this);
}

@JsonSerializable()
class ArticleCommentPostData {
  const ArticleCommentPostData({
    this.content,
    this.userId,
    this.commentTo,
    this.toType,
    this.parentComment,
    this.commentTouid,
    this.groupid,
    this.updatedAt,
    this.createdAt,
    this.id,
  });

  factory ArticleCommentPostData.fromJson(Map<String, dynamic> json) =>
      _$ArticleCommentPostDataFromJson(json);

  @JsonKey(name: 'content')
  final String? content;

  @JsonKey(name: 'user_id')
  final int? userId;

  @JsonKey(name: 'comment_to')
  final String? commentTo;

  @JsonKey(name: 'to_type')
  final String? toType;

  @JsonKey(name: 'parent_comment')
  final int? parentComment;

  @JsonKey(name: 'comment_touid')
  final int? commentTouid;

  @JsonKey(name: 'groupid')
  final int? groupid;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'id')
  final int? id;

  Map<String, dynamic> toJson() => _$ArticleCommentPostDataToJson(this);
}
