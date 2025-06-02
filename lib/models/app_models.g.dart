// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Banner _$BannerFromJson(Map<String, dynamic> json) => Banner(
  id: (json['id'] as num).toInt(),
  imageUrl: json['imageUrl'] as String,
  title: json['title'] as String,
  link: json['link'] as String,
);

Map<String, dynamic> _$BannerToJson(Banner instance) => <String, dynamic>{
  'id': instance.id,
  'imageUrl': instance.imageUrl,
  'title': instance.title,
  'link': instance.link,
};

ServiceItem _$ServiceItemFromJson(Map<String, dynamic> json) => ServiceItem(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  iconUrl: json['iconUrl'] as String,
  link: json['link'] as String,
);

Map<String, dynamic> _$ServiceItemToJson(ServiceItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'iconUrl': instance.iconUrl,
      'link': instance.link,
    };

JobPost _$JobPostFromJson(Map<String, dynamic> json) => JobPost(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  company: json['company'] as String,
  location: json['location'] as String,
  salary: json['salary'] as String,
  timeAgo: (json['timeAgo'] as num).toInt(),
  createdAt: json['createdAt'] as String?,
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  jobKey: json['jobKey'] as String?,
  jobType: json['jobType'] as String?,
  officeMode: (json['officeMode'] as num?)?.toInt(),
  jobLang: (json['jobLang'] as num?)?.toInt(),
  isFavorite: json['isFavorite'] as bool? ?? false,
);

Map<String, dynamic> _$JobPostToJson(JobPost instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'company': instance.company,
  'location': instance.location,
  'salary': instance.salary,
  'timeAgo': instance.timeAgo,
  'createdAt': instance.createdAt,
  'tags': instance.tags,
  'jobKey': instance.jobKey,
  'jobType': instance.jobType,
  'officeMode': instance.officeMode,
  'jobLang': instance.jobLang,
  'isFavorite': instance.isFavorite,
};

NewsItem _$NewsItemFromJson(Map<String, dynamic> json) => NewsItem(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  source: json['source'] as String,
  timeAgo: (json['timeAgo'] as num).toInt(),
  content: json['content'] as String?,
);

Map<String, dynamic> _$NewsItemToJson(NewsItem instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'source': instance.source,
  'timeAgo': instance.timeAgo,
  'content': instance.content,
};

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  isLoggedIn: json['isLoggedIn'] as bool? ?? false,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'avatarUrl': instance.avatarUrl,
  'isLoggedIn': instance.isLoggedIn,
};
