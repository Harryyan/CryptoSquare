import 'package:json_annotation/json_annotation.dart';

part 'job_collect_list.g.dart';

@JsonSerializable()
class JobCollectListResp {
  final String message;
  final int code;
  final JobCollectListData? data;

  JobCollectListResp({required this.message, required this.code, this.data});

  factory JobCollectListResp.fromJson(Map<String, dynamic> json) =>
      _$JobCollectListRespFromJson(json);

  Map<String, dynamic> toJson() => _$JobCollectListRespToJson(this);
}

@JsonSerializable()
class JobCollectListData {
  final List<JobCollectItem> list;
  final int page;
  @JsonKey(name: 'page_size')
  final int pageSize;
  @JsonKey(name: 'total_page')
  final int totalPage;

  JobCollectListData({
    required this.list,
    required this.page,
    required this.pageSize,
    required this.totalPage,
  });

  factory JobCollectListData.fromJson(Map<String, dynamic> json) =>
      _$JobCollectListDataFromJson(json);

  Map<String, dynamic> toJson() => _$JobCollectListDataToJson(this);
}

@JsonSerializable()
class JobCollectItem {
  final String slug;
  final int id;
  @JsonKey(name: 'job_key')
  final String jobKey;
  @JsonKey(name: 'job_title')
  final String jobTitle;
  @JsonKey(name: 'job_positon')
  final String jobPosition;
  @JsonKey(name: 'created_at')
  final String createdAt;
  final String tags;
  @JsonKey(name: 'job_company')
  final String jobCompany;
  @JsonKey(name: 'job_salary_type')
  final int jobSalaryType;
  @JsonKey(name: 'job_salary_unit')
  final String jobSalaryUnit;
  @JsonKey(name: 'job_salary_currency')
  final String jobSalaryCurrency;
  @JsonKey(name: 'min_salary')
  final int minSalary;
  @JsonKey(name: 'max_salary')
  final int maxSalary;
  @JsonKey(name: 'job_lang')
  final int jobLang;
  @JsonKey(name: 'office_mode')
  final int officeMode;
  @JsonKey(name: 'job_type')
  final String jobType;
  @JsonKey(name: 'job_edu')
  final int jobEdu;
  @JsonKey(name: 'job_is_collect')
  final int jobIsCollect;
  @JsonKey(name: 'job_is_like')
  final int jobIsLike;

  JobCollectItem({
    required this.slug,
    required this.id,
    required this.jobKey,
    required this.jobTitle,
    required this.jobPosition,
    required this.createdAt,
    required this.tags,
    required this.jobCompany,
    required this.jobSalaryType,
    required this.jobSalaryUnit,
    required this.jobSalaryCurrency,
    required this.minSalary,
    required this.maxSalary,
    required this.jobLang,
    required this.officeMode,
    required this.jobType,
    required this.jobEdu,
    required this.jobIsCollect,
    required this.jobIsLike,
  });

  factory JobCollectItem.fromJson(Map<String, dynamic> json) =>
      _$JobCollectItemFromJson(json);

  Map<String, dynamic> toJson() => _$JobCollectItemToJson(this);
}
