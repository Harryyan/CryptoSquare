// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_comment_post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArticleCommentPostResponse _$ArticleCommentPostResponseFromJson(
  Map<String, dynamic> json,
) => ArticleCommentPostResponse(
  message: json['message'] as String?,
  code: (json['code'] as num?)?.toInt(),
  data:
      json['data'] == null
          ? null
          : ArticleCommentPostData.fromJson(
            json['data'] as Map<String, dynamic>,
          ),
);

Map<String, dynamic> _$ArticleCommentPostResponseToJson(
  ArticleCommentPostResponse instance,
) => <String, dynamic>{
  'message': instance.message,
  'code': instance.code,
  'data': instance.data,
};

ArticleCommentPostData _$ArticleCommentPostDataFromJson(
  Map<String, dynamic> json,
) => ArticleCommentPostData(
  content: json['content'] as String?,
  userId: (json['user_id'] as num?)?.toInt(),
  commentTo: json['comment_to'] as String?,
  toType: json['to_type'] as String?,
  parentComment: (json['parent_comment'] as num?)?.toInt(),
  commentTouid: (json['comment_touid'] as num?)?.toInt(),
  groupid: (json['groupid'] as num?)?.toInt(),
  updatedAt: json['updated_at'] as String?,
  createdAt: json['created_at'] as String?,
  id: (json['id'] as num?)?.toInt(),
);

Map<String, dynamic> _$ArticleCommentPostDataToJson(
  ArticleCommentPostData instance,
) => <String, dynamic>{
  'content': instance.content,
  'user_id': instance.userId,
  'comment_to': instance.commentTo,
  'to_type': instance.toType,
  'parent_comment': instance.parentComment,
  'comment_touid': instance.commentTouid,
  'groupid': instance.groupid,
  'updated_at': instance.updatedAt,
  'created_at': instance.createdAt,
  'id': instance.id,
};
