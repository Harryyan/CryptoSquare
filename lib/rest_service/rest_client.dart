import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';

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

@RestApi(baseUrl: 'https://d3qx0f55wsubto.cloudfront.net/api/')
abstract class RestClient {
  factory RestClient(Dio dio, {String? baseUrl}) = _RestClient;

  @GET('/tasks')
  Future<BaseResponse<List<Task>>> getTasks();

  @GET('/job/index/jobhot')
  Future<FeaturedJobResponse> getFeaturedJobs(
    @Query('PLATFORM') String platform,
  );

  @GET('/job/index/banner_new')
  Future<BannerResponse> getBanners(
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

  Map<String, dynamic> toJson() => _$JobDataToJson(this);
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
