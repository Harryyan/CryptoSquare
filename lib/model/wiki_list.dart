import 'package:json_annotation/json_annotation.dart';
import 'package:cryptosquare/rest_service/rest_client.dart';

part 'wiki_list.g.dart';

@JsonSerializable()
class WikiListResponse extends BaseResponse<List<WikiItem>> {
  const WikiListResponse({String? message, int? code, List<WikiItem>? data})
      : super(message: message, code: code, data: data);

  factory WikiListResponse.fromJson(Map<String, dynamic> json) {
    return WikiListResponse(
      message: json['message'] as String?,
      code: json['code'] as int?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => WikiItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson(Object? Function(List<WikiItem>) toJsonT) =>
      <String, dynamic>{
        'message': message,
        'code': code,
        'data': data,
      };
}

@JsonSerializable()
class WikiItem {
  const WikiItem({
    this.id,
    this.name,
    this.intro,
    this.slug,
    this.img,
  });

  factory WikiItem.fromJson(Map<String, dynamic> json) =>
      _$WikiItemFromJson(json);

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'intro')
  final String? intro;

  @JsonKey(name: 'slug')
  final String? slug;

  @JsonKey(name: 'img')
  final String? img;

  Map<String, dynamic> toJson() => _$WikiItemToJson(this);
}

@JsonSerializable()
class WikiDetailResponse extends BaseResponse<WikiDetailData> {
  const WikiDetailResponse({String? message, int? code, WikiDetailData? data})
      : super(message: message, code: code, data: data);

  factory WikiDetailResponse.fromJson(Map<String, dynamic> json) {
    return WikiDetailResponse(
      message: json['message'] as String?,
      code: json['code'] as int?,
      data: json['data'] == null
          ? null
          : WikiDetailData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson(Object? Function(WikiDetailData) toJsonT) =>
      <String, dynamic>{
        'message': message,
        'code': code,
        'data': data != null ? toJsonT(data as WikiDetailData) : null,
      };
}

@JsonSerializable()
class WikiDetailData {
  const WikiDetailData({
    this.id,
    this.name,
    this.lang,
    this.intro,
    this.img,
    this.description,
    this.webSite,
    this.logoUrl,
    this.portfolio,
    this.investors,
    this.members,
    this.social,
    this.tags,
    this.slug,
  });

  factory WikiDetailData.fromJson(Map<String, dynamic> json) =>
      _$WikiDetailDataFromJson(json);

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'lang')
  final int? lang;

  @JsonKey(name: 'intro')
  final String? intro;

  @JsonKey(name: 'img')
  final String? img;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'web_site')
  final String? webSite;

  @JsonKey(name: 'logo_url')
  final String? logoUrl;

  @JsonKey(name: 'portfolio')
  final List<PortfolioItem>? portfolio;

  @JsonKey(name: 'investors')
  final List<InvestorDetailItem>? investors;

  @JsonKey(name: 'members')
  final List<MemberDetailItem>? members;

  @JsonKey(name: 'social')
  final SocialLinks? social;

  @JsonKey(name: 'tags')
  final List<TagItem>? tags;

  @JsonKey(name: 'slug')
  final String? slug;

  Map<String, dynamic> toJson() => _$WikiDetailDataToJson(this);
}

@JsonSerializable()
class PortfolioItem {
  const PortfolioItem({
    this.id,
    this.name,
    this.webSite,
    this.intro,
    this.slug,
    this.img,
  });

  factory PortfolioItem.fromJson(Map<String, dynamic> json) =>
      _$PortfolioItemFromJson(json);

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'web_site')
  final String? webSite;

  @JsonKey(name: 'intro')
  final String? intro;

  @JsonKey(name: 'slug')
  final String? slug;

  @JsonKey(name: 'img')
  final String? img;

  Map<String, dynamic> toJson() => _$PortfolioItemToJson(this);
}

@JsonSerializable()
class InvestorDetailItem {
  const InvestorDetailItem({
    this.id,
    this.name,
    this.webSite,
    this.intro,
    this.slug,
    this.img,
  });

  factory InvestorDetailItem.fromJson(Map<String, dynamic> json) =>
      _$InvestorDetailItemFromJson(json);

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'web_site')
  final String? webSite;

  @JsonKey(name: 'intro')
  final String? intro;

  @JsonKey(name: 'slug')
  final String? slug;

  @JsonKey(name: 'img')
  final String? img;

  Map<String, dynamic> toJson() => _$InvestorDetailItemToJson(this);
}

@JsonSerializable()
class MemberDetailItem {
  const MemberDetailItem({
    this.id,
    this.name,
    this.webSite,
    this.intro,
    this.slug,
    this.img,
  });

  factory MemberDetailItem.fromJson(Map<String, dynamic> json) =>
      _$MemberDetailItemFromJson(json);

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'web_site')
  final String? webSite;

  @JsonKey(name: 'intro')
  final String? intro;

  @JsonKey(name: 'slug')
  final String? slug;

  @JsonKey(name: 'img')
  final String? img;

  Map<String, dynamic> toJson() => _$MemberDetailItemToJson(this);
}

@JsonSerializable()
class SocialLinks {
  const SocialLinks({
    this.twitter,
    this.medium,
    this.linkedin,
    this.github,
    this.telegram,
    this.youtube,
    this.reddit,
    this.facebook,
    this.weibo,
  });

  factory SocialLinks.fromJson(Map<String, dynamic> json) =>
      _$SocialLinksFromJson(json);

  @JsonKey(name: 'twitter')
  final String? twitter;

  @JsonKey(name: 'medium')
  final String? medium;

  @JsonKey(name: 'linkedin')
  final String? linkedin;

  @JsonKey(name: 'github')
  final String? github;

  @JsonKey(name: 'telegram')
  final String? telegram;

  @JsonKey(name: 'youtube')
  final String? youtube;

  @JsonKey(name: 'reddit')
  final String? reddit;

  @JsonKey(name: 'facebook')
  final String? facebook;

  @JsonKey(name: 'weibo')
  final String? weibo;

  Map<String, dynamic> toJson() => _$SocialLinksToJson(this);
}

@JsonSerializable()
class TagItem {
  const TagItem({
    this.id,
    this.name,
    this.slug,
  });

  factory TagItem.fromJson(Map<String, dynamic> json) =>
      _$TagItemFromJson(json);

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'slug')
  final String? slug;

  Map<String, dynamic> toJson() => _$TagItemToJson(this);
}

@JsonSerializable()
class WikiSearchResponse extends BaseResponse<WikiSearchData> {
  const WikiSearchResponse({String? message, int? code, WikiSearchData? data})
      : super(message: message, code: code, data: data);

  factory WikiSearchResponse.fromJson(Map<String, dynamic> json) {
    return WikiSearchResponse(
      message: json['message'] as String?,
      code: json['code'] as int?,
      data: json['data'] == null
          ? null
          : WikiSearchData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson(Object? Function(WikiSearchData) toJsonT) =>
      <String, dynamic>{
        'message': message,
        'code': code,
        'data': data != null ? toJsonT(data as WikiSearchData) : null,
      };
}

@JsonSerializable()
class WikiSearchData {
  const WikiSearchData({
    this.total,
    this.currentPage,
    this.data,
  });

  factory WikiSearchData.fromJson(Map<String, dynamic> json) =>
      _$WikiSearchDataFromJson(json);

  @JsonKey(name: 'total')
  final int? total;

  @JsonKey(name: 'current_page')
  final int? currentPage;

  @JsonKey(name: 'data')
  final List<WikiSearchItem>? data;

  Map<String, dynamic> toJson() => _$WikiSearchDataToJson(this);
}

@JsonSerializable()
class WikiSearchItem {
  const WikiSearchItem({
    this.name,
    this.slug,
    this.descs,
    this.intro,
    this.img,
    this.url,
    this.category,
    this.lang,
    this.link,
  });

  factory WikiSearchItem.fromJson(Map<String, dynamic> json) =>
      _$WikiSearchItemFromJson(json);

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'slug')
  final String? slug;

  @JsonKey(name: 'descs')
  final String? descs;

  @JsonKey(name: 'intro')
  final String? intro;

  @JsonKey(name: 'img')
  final String? img;

  @JsonKey(name: 'url')
  final String? url;

  @JsonKey(name: 'category')
  final int? category;

  @JsonKey(name: 'lang')
  final int? lang;

  @JsonKey(name: 'link')
  final String? link;

  Map<String, dynamic> toJson() => _$WikiSearchItemToJson(this);
}

