import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:cryptosquare/util/storage.dart';
import 'package:cryptosquare/model/article_list.dart';
import 'package:cryptosquare/model/article_comment_post.dart';
import 'package:cryptosquare/model/job_collect_list.dart';
import 'package:cryptosquare/model/wiki_list.dart';

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

@JsonSerializable()
class JobListResponse {
  const JobListResponse({this.message, this.code, this.data});

  factory JobListResponse.fromJson(Map<String, dynamic> json) {
    return JobListResponse(
      message: json['message'] as String?,
      code: json['code'] as int?,
      data:
          json['data'] == null
              ? null
              : JobListData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  final String? message;
  final int? code;
  final JobListData? data;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'message': message,
    'code': code,
    'data': data?.toJson(),
  };
}

@JsonSerializable()
class JobListData {
  const JobListData({this.list, this.page, this.pageSize, this.totalPage});

  factory JobListData.fromJson(Map<String, dynamic> json) {
    return JobListData(
      list:
          (json['list'] as List<dynamic>?)
              ?.map((e) => JobData.fromJson(e as Map<String, dynamic>))
              .toList(),
      page: json['page'] as int?,
      pageSize: json['page_size'] as int?,
      totalPage: json['total_page'] as int?,
    );
  }

  final List<JobData>? list;
  final int? page;
  @JsonKey(name: 'page_size')
  final int? pageSize;
  @JsonKey(name: 'total_page')
  final int? totalPage;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'list': list,
    'page': page,
    'page_size': pageSize,
    'total_page': totalPage,
  };
}

Dio? _dio;

@RestApi(baseUrl: 'https://d3qx0f55wsubto.cloudfront.net/api')
// @RestApi(baseUrl: 'https://terminal-cn2.bitpush.news/api')
abstract class RestClient {
  factory RestClient() {
    _dio ??= Dio();

    // 配置超时时间
    _dio?.options.connectTimeout = const Duration(seconds: 30);
    _dio?.options.receiveTimeout = const Duration(seconds: 30);
    _dio?.options.sendTimeout = const Duration(seconds: 30);

    // 添加重试拦截器
    _dio?.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if (error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.connectionTimeout) {
            // 如果是连接错误，尝试重试
            try {
              final response = await _dio?.fetch(error.requestOptions);
              return handler.resolve(response!);
            } catch (e) {
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
        onRequest: (options, handler) {
          String token = GStorage().getToken();

          options.headers["platform"] = Platform.isAndroid ? "android" : "ios";

          if (token.isNotEmpty) {
            options.headers["x-user-secret"] = token;
          }

          options.headers["app-version"] = '2.0.0';

          return handler.next(options);
        },
      ),
    );

    // 配置HTTP客户端
    (_dio?.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (
      client,
    ) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

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

  @GET('/bbs-article/comment/{article_id}')
  Future<ArticleCommentResponse> getArticleComments(
    @Path('article_id') String articleId,
    @Query('lang') int lang,
    @Query('PLATFORM') String platform,
  );

  @GET('/bbs-article')
  Future<ArticleListResponse> getArticleList(
    @Query('cat_id') int catId,
    @Query('page_size') int pageSize,
    @Query('page') int page,
    @Query('lang') int lang,
    @Query('PLATFORM') String platform,
    @Query('keyword') String? keyword,
  );

  @GET('/wiki/topList')
  Future<WikiListResponse> getWikiTopList(
    @Query('lang') int lang,
    @Query('PLATFORM') String platform,
  );

  @GET('/version/detail')
  Future<WikiDetailResponse> getWikiDetail(
    @Query('slug') String slug,
    @Query('lang') int lang,
    @Query('PLATFORM') String platform,
  );

  @GET('/v2/wiki')
  Future<WikiSearchResponse> searchWiki(
    @Query('keyword') String keyword,
    @Query('lang') int lang,
    @Query('page') int page,
    @Query('page_size') int pageSize,
    @Query('PLATFORM') String platform,
  );

  @GET('/job/index/job_list')
  Future<JobListResponse> getJobList(
    @Query('PLATFORM') String platform, {
    @Query('page_size') int pageSize = 30,
    @Query('page') int page = 1,
    @Query('keyword') String keyword = '',
    @Query('lang') int lang = 1,
    @Query('job_type') String jobType = '',
    @Query('office_mode') int officeMode = -1,
    @Query('job_lang') int jobLang = -1,
  });

  @GET('/v3/job/scoreconfig')
  Future<ScoreConfigResponse> getScoreConfig();

  @POST('/bbs-article/comment/{article_id}')
  Future<ArticleCommentPostResponse> postArticleComment(
    @Path('article_id') String articleId,
    @Field('PLATFORM') String platform,
    @Field('comment') String comment,
    @Field('comment_id') int? commentId,
    @Field('lang') int lang,
  );

  @POST("/bbs-article")
  Future<PostCreateResp> createPost(
    @Field("title") String title,
    @Field("tag") String tag,
    @Field("cat_id") int catId,
    @Field("lang") int lang,
    @Field("origin") String origin,
    @Field("origin_link") String originLink,
    @Field("body") String body,
  );

  @POST("/bbs-article/{id}")
  Future<PostCreateResp> updatePost(
    @Path("id") String id,
    @Field("title") String title,
    @Field("tag") String tag,
    @Field("cat_id") int catId,
    @Field("lang") int lang,
    @Field("origin") String origin,
    @Field("origin_link") String originLink,
    @Field("body") String body,
  );

  @POST("/job/charge/apply")
  Future<BaseResponse<dynamic>> applyJobCharge(@Field("jobkey") String jobkey);

  @GET("/bbs/category")
  Future<CSBBSCategoryResp> category(@Query("lang") int lang);

  @GET('/v3/job/student_view')
  Future<StudentViewResponse> getStudentViewList();

  @GET('/v3/job/course_list')
  Future<CourseListResponse> getCourseList();

  @GET('/v3/index/serverintro')
  Future<ServerIntroResponse> getServerIntro();
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

class CSBBSCategoryResp {
  String? message;
  int? code;
  List<BBSCategoryData>? data;

  CSBBSCategoryResp({this.message, this.code, this.data});

  CSBBSCategoryResp.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    code = json['code'];
    if (json['data'] != null) {
      data = <BBSCategoryData>[];
      json['data'].forEach((v) {
        data!.add(new BBSCategoryData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['code'] = this.code;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BBSCategoryData {
  int? id;
  String? name;
  String? slug;

  BBSCategoryData({this.id, this.name, this.slug});

  BBSCategoryData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['slug'] = this.slug;
    return data;
  }
}

@JsonSerializable()
class PostCreateResp {
  String? message;
  int? code;
  dynamic data;

  PostCreateResp({this.message, this.code, this.data});

  factory PostCreateResp.fromJson(Map<String, dynamic> json) {
    return PostCreateResp(
      message: json['message'],
      code: json['code'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['code'] = this.code;
    data['data'] = this.data;
    return data;
  }
}

@JsonSerializable()
class ScoreConfigResponse {
  const ScoreConfigResponse({this.message, this.code, this.data});

  factory ScoreConfigResponse.fromJson(Map<String, dynamic> json) {
    Map<String, ScoreConfigItem> scoreItems = {};
    if (json['data'] != null) {
      final dataMap = json['data'] as Map<String, dynamic>;
      dataMap.forEach((key, value) {
        scoreItems[key] = ScoreConfigItem.fromJson(
          value as Map<String, dynamic>,
        );
      });
    }

    return ScoreConfigResponse(
      message: json['message'] as String?,
      code: json['code'] as int?,
      data: scoreItems,
    );
  }

  final String? message;
  final int? code;
  final Map<String, ScoreConfigItem>? data;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'message': message,
    'code': code,
    'data': data,
  };
}

@JsonSerializable()
class ScoreConfigItem {
  const ScoreConfigItem({this.title, this.titleEn, this.score, this.id});

  factory ScoreConfigItem.fromJson(Map<String, dynamic> json) {
    return ScoreConfigItem(
      title: json['title'] as String?,
      titleEn: json['title_en'] as String?,
      score: json['score'] as int?,
      id: json['id'] as int?,
    );
  }

  final String? title;
  @JsonKey(name: 'title_en')
  final String? titleEn;
  final int? score;
  final int? id;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'title': title,
    'title_en': titleEn,
    'score': score,
    'id': id,
  };
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
    this.jobType,
    this.officeMode,
    this.jobLang,
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

  @JsonKey(name: 'job_type')
  final String? jobType;

  @JsonKey(name: 'office_mode')
  final int? officeMode;

  @JsonKey(name: 'job_lang')
  final int? jobLang;

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
  final dynamic applyType;

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
  const ArticleExtension({this.tag, this.auth});

  factory ArticleExtension.fromJson(Map<String, dynamic> json) =>
      _$ArticleExtensionFromJson(json);

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

@JsonSerializable()
class ArticleCommentResponse extends BaseResponse<List<ArticleCommentItem>> {
  const ArticleCommentResponse({
    String? message,
    int? code,
    List<ArticleCommentItem>? data,
  }) : super(message: message, code: code, data: data);

  factory ArticleCommentResponse.fromJson(Map<String, dynamic> json) {
    return ArticleCommentResponse(
      message: json['message'] as String?,
      code: json['code'] as int?,
      data:
          (json['data'] as List<dynamic>?)
              ?.map(
                (e) => ArticleCommentItem.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson(
    Object? Function(List<ArticleCommentItem>) toJsonT,
  ) => <String, dynamic>{'message': message, 'code': code, 'data': data};
}

@JsonSerializable()
class ArticleCommentItem {
  const ArticleCommentItem({
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
    this.reply,
    this.currentUserCanDel,
    this.user,
  });

  factory ArticleCommentItem.fromJson(Map<String, dynamic> json) =>
      _$ArticleCommentItemFromJson(json);

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

  @JsonKey(name: 'reply')
  final List<ArticleCommentReply>? reply;

  @JsonKey(name: 'current_user_can_del')
  final int? currentUserCanDel;

  @JsonKey(name: 'user')
  final ArticleCommentUser? user;

  Map<String, dynamic> toJson() => _$ArticleCommentItemToJson(this);
}

@JsonSerializable()
class ArticleCommentReply {
  const ArticleCommentReply({
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

  factory ArticleCommentReply.fromJson(Map<String, dynamic> json) =>
      _$ArticleCommentReplyFromJson(json);

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

  Map<String, dynamic> toJson() => _$ArticleCommentReplyToJson(this);
}

@JsonSerializable()
class CategoryItem {
  const CategoryItem({this.id, this.name, this.nameEn});

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'] as int?,
      name: json['name'] as String?,
      nameEn: json['name_en'] as String?,
    );
  }

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'name_en')
  final String? nameEn;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'name_en': nameEn,
  };
}

@JsonSerializable()
class StudentViewResponse {
  const StudentViewResponse({this.message, this.code, this.data});

  factory StudentViewResponse.fromJson(Map<String, dynamic> json) {
    return StudentViewResponse(
      message: json['message'] as String?,
      code: json['code'] as int?,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => StudentViewItem.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  final String? message;
  final int? code;
  final List<StudentViewItem>? data;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'message': message,
    'code': code,
    'data': data?.map((e) => e.toJson()).toList(),
  };
}

@JsonSerializable()
class StudentViewItem {
  const StudentViewItem({this.id, this.title, this.intro, this.link, this.img});

  factory StudentViewItem.fromJson(Map<String, dynamic> json) {
    return StudentViewItem(
      id: json['id'] as int?,
      title: json['title'] as String?,
      intro: json['intro'] as String?,
      link: json['link'] as String?,
      img: json['img'] as String?,
    );
  }

  final int? id;
  final String? title;
  final String? intro;
  final String? link;
  final String? img;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'intro': intro,
    'link': link,
    'img': img,
  };
}

@JsonSerializable()
class CourseListResponse {
  const CourseListResponse({this.message, this.code, this.data});

  factory CourseListResponse.fromJson(Map<String, dynamic> json) {
    return CourseListResponse(
      message: json['message'] as String?,
      code: json['code'] as int?,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => CourseItem.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  final String? message;
  final int? code;
  final List<CourseItem>? data;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'message': message,
    'code': code,
    'data': data?.map((e) => e.toJson()).toList(),
  };
}

@JsonSerializable()
class CourseItem {
  const CourseItem({
    this.id,
    this.title,
    this.intro,
    this.link,
    this.img,
    this.price,
  });

  factory CourseItem.fromJson(Map<String, dynamic> json) {
    return CourseItem(
      id: json['id'] as int?,
      title: json['title'] as String?,
      intro: json['intro'] as String?,
      link: json['link'] as String?,
      img: json['img'] as String?,
      price: json['price'] as int?,
    );
  }

  final int? id;
  final String? title;
  final String? intro;
  final String? link;
  final String? img;
  final int? price;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'intro': intro,
    'link': link,
    'img': img,
    'price': price,
  };
}

@JsonSerializable()
class ServerIntroResponse {
  const ServerIntroResponse({this.message, this.code, this.data});

  factory ServerIntroResponse.fromJson(Map<String, dynamic> json) {
    return ServerIntroResponse(
      message: json['message'] as String?,
      code: json['code'] as int?,
      data:
          json['data'] != null
              ? ServerIntroData.fromJson(json['data'] as Map<String, dynamic>)
              : null,
    );
  }

  final String? message;
  final int? code;
  final ServerIntroData? data;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'message': message,
    'code': code,
    'data': data?.toJson(),
  };
}

@JsonSerializable()
class ServerIntroData {
  const ServerIntroData({this.banner, this.data});

  factory ServerIntroData.fromJson(Map<String, dynamic> json) {
    return ServerIntroData(
      banner:
          json['banner'] != null
              ? ServerIntroBanner.fromJson(
                json['banner'] as Map<String, dynamic>,
              )
              : null,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => ServerIntroItem.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  final ServerIntroBanner? banner;
  final List<ServerIntroItem>? data;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'banner': banner?.toJson(),
    'data': data?.map((e) => e.toJson()).toList(),
  };
}

@JsonSerializable()
class ServerIntroBanner {
  const ServerIntroBanner({
    this.img,
    this.title,
    this.intro,
    this.link,
    this.linkText,
  });

  factory ServerIntroBanner.fromJson(Map<String, dynamic> json) {
    return ServerIntroBanner(
      img: json['img'] as String?,
      title: json['title'] as String?,
      intro: json['intro'] as String?,
      link: json['link'] as String?,
      linkText: json['link_text'] as String?,
    );
  }

  final String? img;
  final String? title;
  final String? intro;
  final String? link;
  @JsonKey(name: 'link_text')
  final String? linkText;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'img': img,
    'title': title,
    'intro': intro,
    'link': link,
    'link_text': linkText,
  };
}

@JsonSerializable()
class ServerIntroItem {
  const ServerIntroItem({
    this.id,
    this.icon,
    this.title,
    this.intro,
    this.tips,
    this.redirectMsg,
    this.redirectColor,
    this.redirectType,
    this.redirectLink,
    this.pop,
  });

  factory ServerIntroItem.fromJson(Map<String, dynamic> json) {
    return ServerIntroItem(
      id: json['id'] as int?,
      icon: json['icon'] as String?,
      title: json['title'] as String?,
      intro: json['intro'] as String?,
      tips: (json['tips'] as List<dynamic>?)?.map((e) => e as String).toList(),
      redirectMsg: json['redirect_msg'] as String?,
      redirectColor: json['redirect_color'] as String?,
      redirectType: json['redirect_type'] as String?,
      redirectLink: json['redirect_link'] as String?,
      pop:
          json['pop'] != null
              ? ServerIntroPopup.fromJson(json['pop'] as Map<String, dynamic>)
              : null,
    );
  }

  final int? id;
  final String? icon;
  final String? title;
  final String? intro;
  final List<String>? tips;
  @JsonKey(name: 'redirect_msg')
  final String? redirectMsg;
  @JsonKey(name: 'redirect_color')
  final String? redirectColor;
  @JsonKey(name: 'redirect_type')
  final String? redirectType;
  @JsonKey(name: 'redirect_link')
  final String? redirectLink;
  final ServerIntroPopup? pop;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'icon': icon,
    'title': title,
    'intro': intro,
    'tips': tips,
    'redirect_msg': redirectMsg,
    'redirect_color': redirectColor,
    'redirect_type': redirectType,
    'redirect_link': redirectLink,
    'pop': pop?.toJson(),
  };
}

@JsonSerializable()
class ServerIntroPopup {
  const ServerIntroPopup({this.title, this.intro, this.img, this.tips});

  factory ServerIntroPopup.fromJson(Map<String, dynamic> json) {
    return ServerIntroPopup(
      title: json['title'] as String?,
      intro:
          (json['intro'] as List<dynamic>?)?.map((e) => e as String).toList(),
      img: json['img'] as String?,
      tips: (json['tips'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }

  final String? title;
  final List<String>? intro;
  final String? img;
  final List<String>? tips;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'title': title,
    'intro': intro,
    'img': img,
    'tips': tips,
  };
}
