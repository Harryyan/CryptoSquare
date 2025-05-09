import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:cryptosquare/util/storage.dart';

part 'rest_client.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class BaseResponse<T> {
  const BaseResponse({this.message, this.code, this.data});

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return BaseResponse<T>(
      message: json['message'] as String?,
      code: json['code'] as int?,
      data: _dataFromJson(json['data'], fromJsonT),
    );
  }

  final String? message;
  final int? code;
  final T? data;

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      <String, dynamic>{
        'message': message,
        'code': code,
        'data': data != null ? toJsonT(data as T) : null,
      };

  static T? _dataFromJson<T>(Object? data, T Function(Object? json) fromJsonT) {
    if (data == null) return null;
    return fromJsonT(data);
  }
}

@JsonSerializable()
class FeaturedJobResponse extends BaseResponse<List<JobData>> {
  const FeaturedJobResponse({String? message, int? code, List<JobData>? data})
    : super(message: message, code: code, data: data);

  factory FeaturedJobResponse.fromJson(Map<String, dynamic> json) {
    return FeaturedJobResponse(
      message: json['message'] as String?,
      code: json['code'] as int?,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => JobData.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson(Object? Function(List<JobData>) toJsonT) =>
      <String, dynamic>{'message': message, 'code': code, 'data': data};
}

Dio? _dio;

@RestApi(baseUrl: 'https://d3qx0f55wsubto.cloudfront.net/api')
abstract class RestClient {
  factory RestClient() {
    _dio ??= Dio();

    // 添加拦截器处理用户认证
    _dio?.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          String token = GStorage().getToken();

          options.headers["platform"] = Platform.isAndroid ? "android" : "ios";

          if (token.isNotEmpty) {
            options.headers["x-user-secret"] = token;
          }

          return handler.next(options);
        },
      ),
    );

    // _dio?.httpClientAdapter =
    //     IOHttpClientAdapter()
    //       // ignore: deprecated_member_use
    //       ..onHttpClientCreate = (client) {
    //         // Config the client.
    //         client.findProxy = (uri) {
    //           // Forward all request to proxy "localhost:8888".
    //           return 'PROXY 127.0.0.1:9090';
    //         };
    //         // You can also create a new HttpClient for Dio instead of returning,
    //         // but a client must being returned here.
    //         return client;
    //       };

    return _RestClient(_dio!);
  }

  @GET('/tasks')
  Future<BaseResponse<List<Task>>> getTasks();

  @GET('/job/index/jobhot')
  Future<FeaturedJobResponse> getFeaturedJobs(
    @Query('PLATFORM') String platform,
    @Query('page_size') String pageSize,
  );

  @GET('/job/index/banner_new')
  Future<BannerResponse> getBanners(
    @Query('lang') int lang,
    @Query('PLATFORM') String platform,
  );

  @GET('/v3/index/topbanner')
  Future<BaseResponse<List<HomeServiceItem>>> getHomeServices();

  @GET('/job/detail/{job_key}')
  Future<BaseResponse<JobDetailData>> getJobDetail(
    @Path('job_key') String jobKey,
    @Query('lang') int lang,
    @Query('PLATFORM') String platformStr,
  );

  @POST('/v3/job/collect')
  Future<BaseResponse<JobCollectData>> collectJob(
    @Field('jobkey') String jobKey,
  );

  @GET('/bbs-article/detail/{id}')
  Future<BaseResponse<ArticleDetailData>> getArticleDetail(
    @Path('id') String id,
    @Query('lang') int lang,
    @Query('PLATFORM') String platform,
  );
}

@JsonSerializable()
class Task {
  const Task({this.id, this.name, this.avatar, this.createdAt});

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  final String? id;
  final String? name;
  final String? avatar;
  final String? createdAt;

  Map<String, dynamic> toJson() => _$TaskToJson(this);
}

@JsonSerializable()
class JobData {
  const JobData({
    this.slug,
    this.id,
    this.jobKey,
    this.jobTitle,
    this.jobPosition,
    this.createdAt,
    this.tags,
    this.jobCompany,
    this.jobSalaryType,
    this.jobSalaryUnit,
    this.jobSalaryCurrency,
    this.minSalary,
    this.maxSalary,
    this.jobIsCollect = 0,
  });

  factory JobData.fromJson(Map<String, dynamic> json) =>
      _$JobDataFromJson(json);

  @JsonKey(name: 'slug')
  final String? slug;

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'job_key')
  final String? jobKey;

  @JsonKey(name: 'job_title')
  final String? jobTitle;

  @JsonKey(name: 'job_position')
  final String? jobPosition;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'tags')
  final String? tags;

  @JsonKey(name: 'job_company')
  final String? jobCompany;

  @JsonKey(name: 'job_salary_type')
  final int? jobSalaryType;

  @JsonKey(name: 'job_salary_unit')
  final String? jobSalaryUnit;

  @JsonKey(name: 'job_salary_currency')
  final String? jobSalaryCurrency;

  @JsonKey(name: 'min_salary')
  final int? minSalary;

  @JsonKey(name: 'max_salary')
  final int? maxSalary;

  @JsonKey(name: 'job_is_collect')
  final int? jobIsCollect;

  Map<String, dynamic> toJson() => _$JobDataToJson(this);
}

@JsonSerializable()
class JobDetailApply {
  const JobDetailApply({
    this.isBuyed,
    this.applyStatus,
    this.createTime,
    this.expTime,
    this.applyType,
    this.applyVal,
    this.score,
  });

  factory JobDetailApply.fromJson(Map<String, dynamic> json) =>
      _$JobDetailApplyFromJson(json);

  @JsonKey(name: 'is_buyed')
  final bool? isBuyed;

  @JsonKey(name: 'apply_status')
  final int? applyStatus;

  @JsonKey(name: 'create_time')
  final int? createTime;

  @JsonKey(name: 'exp_time')
  final int? expTime;

  @JsonKey(name: 'apply_type')
  final int? applyType;

  @JsonKey(name: 'apply_val')
  final String? applyVal;

  @JsonKey(name: 'score')
  final int? score;

  Map<String, dynamic> toJson() => _$JobDetailApplyToJson(this);
}

@JsonSerializable()
class JobDetailData {
  const JobDetailData({
    this.id,
    this.jobTitle,
    this.jobPosition,
    this.jobType,
    this.userId,
    this.createTime,
    this.status,
    this.lang,
    this.jobStatus,
    this.officeMode,
    this.jobDesc,
    this.jobWelfare,
    this.jobEdu,
    this.minSalary,
    this.maxSalary,
    this.jobLang,
    this.tags,
    this.isHot,
    this.jobSalaryCurrency,
    this.jobSalaryUnit,
    this.jobSalaryType,
    this.jobCompany,
    this.jobKey,
    this.isTop,
    this.jobLocation,
    this.lastView,
    this.lastViewUser,
    this.replyNums,
    this.replyUser,
    this.ding,
    this.cai,
    this.replyTime,
    this.apply,
    this.jobIsCollect,
    this.jobIsLike,
  });

  factory JobDetailData.fromJson(Map<String, dynamic> json) =>
      _$JobDetailDataFromJson(json);

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'job_title')
  final String? jobTitle;

  @JsonKey(name: 'job_positon')
  final String? jobPosition;

  @JsonKey(name: 'job_type')
  final String? jobType;

  @JsonKey(name: 'user_id')
  final int? userId;

  @JsonKey(name: 'create_time')
  final int? createTime;

  @JsonKey(name: 'status')
  final int? status;

  @JsonKey(name: 'lang')
  final int? lang;

  @JsonKey(name: 'job_status')
  final int? jobStatus;

  @JsonKey(name: 'office_mode')
  final int? officeMode;

  @JsonKey(name: 'job_desc')
  final String? jobDesc;

  @JsonKey(name: 'job_welfare')
  final String? jobWelfare;

  @JsonKey(name: 'job_edu')
  final int? jobEdu;

  @JsonKey(name: 'min_salary')
  final int? minSalary;

  @JsonKey(name: 'max_salary')
  final int? maxSalary;

  @JsonKey(name: 'job_lang')
  final int? jobLang;

  @JsonKey(name: 'tags')
  final String? tags;

  @JsonKey(name: 'is_hot')
  final int? isHot;

  @JsonKey(name: 'job_salary_currency')
  final String? jobSalaryCurrency;

  @JsonKey(name: 'job_salary_unit')
  final String? jobSalaryUnit;

  @JsonKey(name: 'job_salary_type')
  final int? jobSalaryType;

  @JsonKey(name: 'job_company')
  final String? jobCompany;

  @JsonKey(name: 'job_key')
  final String? jobKey;

  @JsonKey(name: 'is_top')
  final int? isTop;

  @JsonKey(name: 'job_location')
  final String? jobLocation;

  @JsonKey(name: 'last_view')
  final int? lastView;

  @JsonKey(name: 'last_view_user')
  final int? lastViewUser;

  @JsonKey(name: 'reply_nums')
  final int? replyNums;

  @JsonKey(name: 'reply_user')
  final String? replyUser;

  @JsonKey(name: 'ding')
  final int? ding;

  @JsonKey(name: 'cai')
  final int? cai;

  @JsonKey(name: 'reply_time')
  final int? replyTime;

  @JsonKey(name: 'apply')
  final JobDetailApply? apply;

  @JsonKey(name: 'job_is_collect')
  final int? jobIsCollect;

  @JsonKey(name: 'job_is_like')
  final int? jobIsLike;

  Map<String, dynamic> toJson() => _$JobDetailDataToJson(this);
}

@JsonSerializable()
class BannerItem {
  const BannerItem({this.id, this.title, this.img, this.link, this.orderid});

  factory BannerItem.fromJson(Map<String, dynamic> json) =>
      _$BannerItemFromJson(json);

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'img')
  final String? img;

  @JsonKey(name: 'link')
  final String? link;

  @JsonKey(name: 'orderid')
  final int? orderid;

  Map<String, dynamic> toJson() => _$BannerItemToJson(this);
}

@JsonSerializable()
class BannerData {
  const BannerData({this.h5, this.pc});

  factory BannerData.fromJson(Map<String, dynamic> json) {
    return BannerData(
      h5:
          (json['h5'] as List<dynamic>?)
              ?.map((e) => BannerItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      pc:
          (json['pc'] as List<dynamic>?)
              ?.map((e) => BannerItem.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  final List<BannerItem>? h5;
  final List<BannerItem>? pc;

  Map<String, dynamic> toJson() => <String, dynamic>{'h5': h5, 'pc': pc};
}

@JsonSerializable()
class BannerResponse extends BaseResponse<BannerData> {
  const BannerResponse({String? message, int? code, BannerData? data})
    : super(message: message, code: code, data: data);

  factory BannerResponse.fromJson(Map<String, dynamic> json) {
    return BannerResponse(
      message: json['message'] as String?,
      code: json['code'] as int?,
      data:
          json['data'] == null
              ? null
              : BannerData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson(Object? Function(BannerData) toJsonT) =>
      <String, dynamic>{
        'message': message,
        'code': code,
        'data': data != null ? toJsonT(data as BannerData) : null,
      };
}

@JsonSerializable()
class TopBannerPop {
  const TopBannerPop({this.title, this.intro, this.img, this.tips});

  factory TopBannerPop.fromJson(Map<String, dynamic> json) =>
      _$TopBannerPopFromJson(json);

  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'intro')
  final dynamic intro;

  @JsonKey(name: 'img')
  final String? img;

  @JsonKey(name: 'tips')
  final dynamic tips;

  Map<String, dynamic> toJson() => _$TopBannerPopToJson(this);
}

@JsonSerializable()
class JobCollectData {
  const JobCollectData({
    this.id,
    this.rsType,
    this.rsId,
    this.value,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory JobCollectData.fromJson(Map<String, dynamic> json) =>
      _$JobCollectDataFromJson(json);

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'rs_type')
  final String? rsType;

  @JsonKey(name: 'rs_id')
  final String? rsId;

  @JsonKey(name: 'value')
  final int? value;

  @JsonKey(name: 'user_id')
  final int? userId;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  Map<String, dynamic> toJson() => _$JobCollectDataToJson(this);
}

@JsonSerializable()
class HomeServiceItem {
  const HomeServiceItem({
    this.id,
    this.icon,
    this.title,
    this.intro,
    this.redirectMsg,
    this.redirectColor,
    this.redirectType,
    this.redirectLink,
    this.pop,
  });

  factory HomeServiceItem.fromJson(Map<String, dynamic> json) =>
      _$HomeServiceItemFromJson(json);

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'icon')
  final String? icon;

  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'intro')
  final String? intro;

  @JsonKey(name: 'redirect_msg')
  final String? redirectMsg;

  @JsonKey(name: 'redirect_color')
  final String? redirectColor;

  @JsonKey(name: 'redirect_type')
  final String? redirectType;

  @JsonKey(name: 'redirect_link')
  final String? redirectLink;

  @JsonKey(name: 'pop')
  final TopBannerPop? pop;

  Map<String, dynamic> toJson() => _$HomeServiceItemToJson(this);
}

@JsonSerializable()
class ArticleComment {
  const ArticleComment({
    this.id,
    this.content,
    this.userId,
    this.commentTo,
    this.toType,
    this.createdAt,
    this.updatedAt,
    this.parentComment,
    this.commentTouid,
    this.groupid,
    this.isDel,
    this.updatetime,
    this.user,
  });

  factory ArticleComment.fromJson(Map<String, dynamic> json) =>
      _$ArticleCommentFromJson(json);

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'content')
  final String? content;

  @JsonKey(name: 'user_id')
  final int? userId;

  @JsonKey(name: 'comment_to')
  final int? commentTo;

  @JsonKey(name: 'to_type')
  final String? toType;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @JsonKey(name: 'parent_comment')
  final int? parentComment;

  @JsonKey(name: 'comment_touid')
  final int? commentTouid;

  @JsonKey(name: 'groupid')
  final int? groupid;

  @JsonKey(name: 'is_del')
  final int? isDel;

  @JsonKey(name: 'updatetime')
  final int? updatetime;

  @JsonKey(name: 'user')
  final ArticleCommentUser? user;

  Map<String, dynamic> toJson() => _$ArticleCommentToJson(this);
}

@JsonSerializable()
class ArticleCommentUser {
  const ArticleCommentUser({this.id, this.userNicename, this.userUrl});

  factory ArticleCommentUser.fromJson(Map<String, dynamic> json) =>
      _$ArticleCommentUserFromJson(json);

  @JsonKey(name: 'ID')
  final int? id;

  @JsonKey(name: 'user_nicename')
  final String? userNicename;

  @JsonKey(name: 'user_url')
  final String? userUrl;

  Map<String, dynamic> toJson() => _$ArticleCommentUserToJson(this);
}

@JsonSerializable()
class ArticleRelatedNews {
  const ArticleRelatedNews({this.id, this.link, this.title});

  factory ArticleRelatedNews.fromJson(Map<String, dynamic> json) =>
      _$ArticleRelatedNewsFromJson(json);

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'link')
  final String? link;

  @JsonKey(name: 'title')
  final String? title;

  Map<String, dynamic> toJson() => _$ArticleRelatedNewsToJson(this);
}

@JsonSerializable()
class ArticleCategoryInfo {
  const ArticleCategoryInfo({this.title, this.catSlug});

  factory ArticleCategoryInfo.fromJson(Map<String, dynamic> json) =>
      _$ArticleCategoryInfoFromJson(json);

  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'cat_slug')
  final String? catSlug;

  Map<String, dynamic> toJson() => _$ArticleCategoryInfoToJson(this);
}

@JsonSerializable()
class ArticleExtensionMeta {
  const ArticleExtensionMeta({this.like, this.eye, this.dislike});

  factory ArticleExtensionMeta.fromJson(Map<String, dynamic> json) =>
      _$ArticleExtensionMetaFromJson(json);

  @JsonKey(name: 'like')
  final int? like;

  @JsonKey(name: 'eye')
  final int? eye;

  @JsonKey(name: 'dislike')
  final int? dislike;

  Map<String, dynamic> toJson() => _$ArticleExtensionMetaToJson(this);
}

@JsonSerializable()
class ArticleAuthInfo {
  const ArticleAuthInfo({
    this.nickname,
    this.avatar,
    this.isOnline,
    this.userKey,
    this.userId,
  });

  factory ArticleAuthInfo.fromJson(Map<String, dynamic> json) =>
      _$ArticleAuthInfoFromJson(json);

  @JsonKey(name: 'nickname')
  final String? nickname;

  @JsonKey(name: 'avatar')
  final String? avatar;

  @JsonKey(name: 'is_online')
  final bool? isOnline;

  @JsonKey(name: 'user_key')
  final String? userKey;

  @JsonKey(name: 'user_id')
  final int? userId;

  Map<String, dynamic> toJson() => _$ArticleAuthInfoToJson(this);
}

@JsonSerializable()
class ArticleExtension {
  const ArticleExtension({this.meta, this.tag, this.auth});

  factory ArticleExtension.fromJson(Map<String, dynamic> json) =>
      _$ArticleExtensionFromJson(json);

  @JsonKey(name: 'meta')
  final ArticleExtensionMeta? meta;

  @JsonKey(name: 'tag')
  final List<dynamic>? tag;

  @JsonKey(name: 'auth')
  final ArticleAuthInfo? auth;

  Map<String, dynamic> toJson() => _$ArticleExtensionToJson(this);
}

@JsonSerializable()
class ArticleUserExt {
  const ArticleUserExt({this.isFavorite, this.isDing, this.isCai});

  factory ArticleUserExt.fromJson(Map<String, dynamic> json) =>
      _$ArticleUserExtFromJson(json);

  @JsonKey(name: 'is_favorite')
  final int? isFavorite;

  @JsonKey(name: 'is_ding')
  final int? isDing;

  @JsonKey(name: 'is_cai')
  final int? isCai;

  Map<String, dynamic> toJson() => _$ArticleUserExtToJson(this);
}

@JsonSerializable()
class ArticleDetailData {
  const ArticleDetailData({
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
    this.ding,
    this.cai,
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
    this.isTop,
    this.isHot,
    this.contact,
    this.address,
    this.trackId,
    this.extension,
    this.userext,
    this.comments,
    this.catInfo,
    this.link,
    this.relNews,
  });

  factory ArticleDetailData.fromJson(Map<String, dynamic> json) =>
      _$ArticleDetailDataFromJson(json);

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

  @JsonKey(name: 'ding')
  final int? ding;

  @JsonKey(name: 'cai')
  final int? cai;

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

  @JsonKey(name: 'is_top')
  final int? isTop;

  @JsonKey(name: 'is_hot')
  final int? isHot;

  @JsonKey(name: 'contact')
  final String? contact;

  @JsonKey(name: 'address')
  final String? address;

  @JsonKey(name: 'track_id')
  final String? trackId;

  @JsonKey(name: 'extension')
  final ArticleExtension? extension;

  @JsonKey(name: 'userext')
  final ArticleUserExt? userext;

  @JsonKey(name: 'comments')
  final List<ArticleComment>? comments;

  @JsonKey(name: 'cat_info')
  final ArticleCategoryInfo? catInfo;

  @JsonKey(name: 'link')
  final String? link;

  @JsonKey(name: 'rel_news')
  final List<ArticleRelatedNews>? relNews;

  Map<String, dynamic> toJson() => _$ArticleDetailDataToJson(this);
}
