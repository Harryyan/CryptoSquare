import 'package:json_annotation/json_annotation.dart';
import 'package:cryptosquare/rest_service/rest_client.dart';

// 导入ArticleExtensionMeta和ArticleAuthInfo类
export 'package:cryptosquare/rest_service/rest_client.dart'
    show ArticleExtensionMeta, ArticleAuthInfo, ArticleCategoryInfo;

part 'article_list.g.dart';

@JsonSerializable()
class ArticleListResponse extends BaseResponse<ArticleListData> {
  const ArticleListResponse({String? message, int? code, ArticleListData? data})
    : super(message: message, code: code, data: data);

  factory ArticleListResponse.fromJson(Map<String, dynamic> json) {
    return ArticleListResponse(
      message: json['message'] as String?,
      code: json['code'] as int?,
      data:
          json['data'] == null
              ? null
              : ArticleListData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson(Object? Function(ArticleListData) toJsonT) =>
      <String, dynamic>{
        'message': message,
        'code': code,
        'data': data != null ? toJsonT(data as ArticleListData) : null,
      };
}

@JsonSerializable()
class ArticleListData {
  const ArticleListData({
    this.total,
    this.data,
    this.currentPage,
    this.catName,
    this.catInfo,
    this.loginUid,
  });

  factory ArticleListData.fromJson(Map<String, dynamic> json) =>
      _$ArticleListDataFromJson(json);

  final int? total;
  final List<ArticleItem>? data;

  @JsonKey(name: 'current_page')
  final String? currentPage;

  @JsonKey(name: 'cat_name')
  final String? catName;

  @JsonKey(name: 'cat_info')
  final ArticleCategoryInfo? catInfo;

  @JsonKey(name: 'login_uid')
  final int? loginUid;

  Map<String, dynamic> toJson() => _$ArticleListDataToJson(this);
}

@JsonSerializable()
class ArticleItemExtension {
  const ArticleItemExtension({this.meta, this.tag, this.auth});

  factory ArticleItemExtension.fromJson(Map<String, dynamic> json) =>
      _$ArticleItemExtensionFromJson(json);

  @JsonKey(name: 'meta')
  final ArticleExtensionMeta? meta;

  @JsonKey(name: 'tag')
  final List<dynamic>? tag;

  @JsonKey(name: 'auth')
  final ArticleAuthInfo? auth;

  Map<String, dynamic> toJson() => _$ArticleItemExtensionToJson(this);
}

@JsonSerializable()
class ArticleItem {
  const ArticleItem({
    this.id,
    this.title,
    this.content,
    this.user,
    this.status,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.lang,
    this.lastView,
    this.lastViewUser,
    this.replyNums,
    this.replyUser,
    this.replyTime,
    this.catId,
    this.origin,
    this.originLink,
    this.createTime,
    this.profile,
    this.hasTag,
    this.sh5,
    this.startTime,
    this.endTime,
    this.address,
    this.extension,
    this.link,
    this.cover,
  });

  factory ArticleItem.fromJson(Map<String, dynamic> json) =>
      _$ArticleItemFromJson(json);

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'content')
  final String? content;

  @JsonKey(name: 'user')
  final int? user;

  @JsonKey(name: 'status')
  final int? status;

  @JsonKey(name: 'type')
  final String? type;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @JsonKey(name: 'lang')
  final int? lang;

  @JsonKey(name: 'last_view')
  final int? lastView;

  @JsonKey(name: 'last_view_user')
  final int? lastViewUser;

  @JsonKey(name: 'reply_nums')
  final int? replyNums;

  @JsonKey(name: 'reply_user')
  final String? replyUser;

  @JsonKey(name: 'reply_time')
  final int? replyTime;

  @JsonKey(name: 'cat_id')
  final int? catId;

  @JsonKey(name: 'origin')
  final String? origin;

  @JsonKey(name: 'origin_link')
  final String? originLink;

  @JsonKey(name: 'create_time')
  final int? createTime;

  @JsonKey(name: 'profile')
  final String? profile;

  @JsonKey(name: 'has_tag')
  final int? hasTag;

  @JsonKey(name: 'sh5')
  final int? sh5;

  @JsonKey(name: 'start_time')
  final String? startTime;

  @JsonKey(name: 'end_time')
  final String? endTime;

  @JsonKey(name: 'address')
  final String? address;

  @JsonKey(name: 'extension')
  final ArticleItemExtension? extension;

  @JsonKey(name: 'link')
  final String? link;

  @JsonKey(name: 'cover')
  final String? cover;

  Map<String, dynamic> toJson() => _$ArticleItemToJson(this);
}
