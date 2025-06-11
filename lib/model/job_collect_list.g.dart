// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_collect_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobCollectListResp _$JobCollectListRespFromJson(Map<String, dynamic> json) =>
    JobCollectListResp(
      message: json['message'] as String,
      code: (json['code'] as num).toInt(),
      data:
          json['data'] == null
              ? null
              : JobCollectListData.fromJson(
                json['data'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$JobCollectListRespToJson(JobCollectListResp instance) =>
    <String, dynamic>{
      'message': instance.message,
      'code': instance.code,
      'data': instance.data,
    };

JobCollectListData _$JobCollectListDataFromJson(Map<String, dynamic> json) =>
    JobCollectListData(
      list:
          (json['list'] as List<dynamic>)
              .map((e) => JobCollectItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      page: (json['page'] as num).toInt(),
      pageSize: (json['page_size'] as num).toInt(),
      totalPage: (json['total_page'] as num).toInt(),
    );

Map<String, dynamic> _$JobCollectListDataToJson(JobCollectListData instance) =>
    <String, dynamic>{
      'list': instance.list,
      'page': instance.page,
      'page_size': instance.pageSize,
      'total_page': instance.totalPage,
    };

JobCollectItem _$JobCollectItemFromJson(Map<String, dynamic> json) =>
    JobCollectItem(
      slug: json['slug'] as String,
      id: (json['id'] as num).toInt(),
      jobKey: json['job_key'] as String,
      jobTitle: json['job_title'] as String,
      jobPosition: json['job_positon'] as String,
      createdAt: json['created_at'] as String,
      tags: json['tags'] as String,
      jobCompany: json['job_company'] as String,
      jobSalaryType: (json['job_salary_type'] as num).toInt(),
      jobSalaryUnit: json['job_salary_unit'] as String,
      jobSalaryCurrency: json['job_salary_currency'] as String,
      minSalary: (json['min_salary'] as num).toInt(),
      maxSalary: (json['max_salary'] as num).toInt(),
      jobLang: (json['job_lang'] as num).toInt(),
      officeMode: (json['office_mode'] as num).toInt(),
      jobType: json['job_type'] as String,
      jobEdu: (json['job_edu'] as num).toInt(),
      jobIsCollect: (json['job_is_collect'] as num).toInt(),
      jobIsLike: (json['job_is_like'] as num).toInt(),
    );

Map<String, dynamic> _$JobCollectItemToJson(JobCollectItem instance) =>
    <String, dynamic>{
      'slug': instance.slug,
      'id': instance.id,
      'job_key': instance.jobKey,
      'job_title': instance.jobTitle,
      'job_positon': instance.jobPosition,
      'created_at': instance.createdAt,
      'tags': instance.tags,
      'job_company': instance.jobCompany,
      'job_salary_type': instance.jobSalaryType,
      'job_salary_unit': instance.jobSalaryUnit,
      'job_salary_currency': instance.jobSalaryCurrency,
      'min_salary': instance.minSalary,
      'max_salary': instance.maxSalary,
      'job_lang': instance.jobLang,
      'office_mode': instance.officeMode,
      'job_type': instance.jobType,
      'job_edu': instance.jobEdu,
      'job_is_collect': instance.jobIsCollect,
      'job_is_like': instance.jobIsLike,
    };
