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

  JobCollectItem({
    required this.slug,
    required this.id,
    required this.jobKey,
    required this.jobTitle,
    required this.jobPosition,
  });

  factory JobCollectItem.fromJson(Map<String, dynamic> json) =>
      _$JobCollectItemFromJson(json);

  Map<String, dynamic> toJson() => _$JobCollectItemToJson(this);
}
